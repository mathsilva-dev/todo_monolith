import 'package:flutter/material.dart';

import '../../../../../core/domain/repositories/to_dos_repository.dart';
import '../../../../../core/domain/usecases/to_dos_usecase.dart';
import '../../../../../core/domain/usecases/to_dos_usecase_i.dart';
import '../../../../../core/external/to_dos_datasource_i.dart';
import '../../../../../core/infra/datasources/to_dos_datasource.dart';
import '../../../../../core/infra/repositories/to_dos_repository_i.dart';
import '../../business/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late RegisterController controller;
  bool isLoading = false;
  _RegisterPageState() {
    ToDosDatasource localDataBase = ToDosDatasourceI();
    ToDosRepository repository = ToDosRepositoryI(localDataBase);
    ToDosUsecase useCase = ToDosUsecaseI(repository);
    controller = RegisterController(useCase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register ToDo'),
        leading: BackButton(
          onPressed: () {
            if (isLoading) return;
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator.adaptive()
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      onChanged: (val) => controller.toDo =
                          controller.toDo.copyWith(title: val),
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      onChanged: (val) => controller.toDo =
                          controller.toDo.copyWith(description: val),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => isLoading = true);

                          controller.saveToDo().then(
                            (value) {
                              if (value.$1 != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    content: Text(value.$1!.message),
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ToDo saved with success'),
                                ),
                              );

                              Navigator.pop(context, true);
                            },
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
