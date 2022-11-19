import 'dart:convert';
import 'dart:io';

import 'package:cachy/features/home/models/user.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeRepository {
  Future<bool> createUser(User model);
  Future<List<User>> getUsers();
}

class SharedPreferencesRepository implements HomeRepository {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Future<List<User>> getUsers() async {
    final prefs = await _prefs;
    try {
      final users = prefs.getStringList('users') ?? [];
      if (users.isEmpty) {
        return [];
      }
      final userList = users.map((e) => User.fromJson(e)).toList();
      return userList;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> createUser(User model) async {
    final prefs = await _prefs;
    final users = prefs.getStringList('users') ?? [];

    try {
      users.add(model.toJson());
      await prefs.setStringList('users', users);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

class PathProviderRepository implements HomeRepository {
  //https://docs.flutter.dev/cookbook/persistence/reading-writing-files
  @override
  Future<List<User>> getUsers() async {
    try {
      final result = await _read();

      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> createUser(User model) async {
    try {
      final result = await _write(model);
      if (await result.exists()) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> get _path async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _path;
    final file = await File("$path/users.json").create(recursive: true);
    return file;
  }

  Future<File> _write(User model) async {
    final file = await _localFile;
    var content = await file.readAsString();
    if (content.isEmpty) {
      content = "[]";
    }
    final list = List.from(jsonDecode(content));

    list.add(model.toJson());

    return file.writeAsString(jsonEncode(list));
  }

  Future<List<User>> _read() async {
    var list = <User>[];
    try {
      final file = await _localFile;

      final content = await file.readAsString();
      if (content.isNotEmpty) {
        list = List.from(jsonDecode(content))
            .map((e) => User.fromJson(e))
            .toList();
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }
}

class ExternalApiRepository implements HomeRepository {
  final _dio = Dio(
    BaseOptions(baseUrl: "https://0e57-45-165-167-82.sa.ngrok.io/"),
  );
  @override
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final response = await _dio.get("/users");
      if (response.statusCode == 200) {
        final decoded = List.from(response.data);
        final users = decoded.map((e) => User.fromMap(e)).toList();
        return users;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> createUser(User model) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final response = await _dio.post(
        "/users",
        data: model.toMap(),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }
}
