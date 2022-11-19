import 'package:cachy/features/home/home_repository.dart';
import 'package:cachy/features/home/home_state.dart';
import 'package:cachy/features/home/models/user.dart';
import 'package:flutter/cupertino.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository repository;
  HomeController(this.repository);

  HomeState _state = HomeStateInitial();

  HomeState get state => _state;

  List<User> _users = [];

  List<User> get users => _users;

  void updateState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  void createUser({
    required String name,
    required String email,
  }) async {
    updateState(HomeStateLoading());
    try {
      final result = await repository.createUser(
        User(
          name: name,
          email: email,
        ),
      );
      if (result) {
        updateState(HomeStateSuccess());
      } else {
        updateState(HomeStateError());
      }
    } catch (e) {
      updateState(HomeStateError());
    }
  }

  Future<void> getUsers() async {
    updateState(HomeStateLoading());
    try {
      _users = await repository.getUsers();
      if (_users.isNotEmpty) {
        updateState(HomeStateSuccess());
      } else {
        updateState(HomeStateInitial());
      }
    } catch (e) {
      updateState(HomeStateError());
    }
  }
}
