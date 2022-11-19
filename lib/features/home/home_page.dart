import 'package:cachy/features/home/home_controller.dart';
import 'package:cachy/features/home/home_repository.dart';
import 'package:cachy/features/home/home_state.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final name = TextEditingController();
  final email = TextEditingController();

  final controller = HomeController(SharedPreferencesRepository());

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 32.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: const Text("create user"),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: EdgeInsets.only(
                    left: 32.0,
                    right: 32.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: "Nome",
                        ),
                      ),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: "Email",
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.createUser(
                          name: name.text,
                          email: email.text,
                        ),
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            if (controller.state is HomeStateLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return const Text("Cadastrar");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("show users"),
              onPressed: () {
                controller.getUsers();
                showModalBottomSheet(
                  context: context,
                  builder: (context) => AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      //TODO: tratar caso de HomeStateError
                      if (controller.state is HomeStateInitial) {
                        return const Center(
                          child:
                              Text("Não há usuários cadastrados no momento."),
                        );
                      }
                      if (controller.state is HomeStateSuccess) {
                        return ListView.builder(
                          itemCount: controller.users.length,
                          itemBuilder: (context, index) {
                            final item = controller.users[index];
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text(item.email),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
