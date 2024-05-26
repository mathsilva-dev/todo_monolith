import 'package:flutter/material.dart';

import '../../../../../core/domain/repositories/to_dos_repository.dart';
import '../../../../../core/domain/usecases/to_dos_usecase.dart';
import '../../../../../core/domain/usecases/to_dos_usecase_i.dart';
import '../../../../../core/external/to_dos_datasource_i.dart';
import '../../../../../core/infra/datasources/to_dos_datasource.dart';
import '../../../../../core/infra/repositories/to_dos_repository_i.dart';
import '../../business/home_controller.dart';
import '../components/to_do_component.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController controller;
  bool isLoading = false;
  _HomePageState() {
    ToDosDatasource localDataBase = ToDosDatasourceI();
    ToDosRepository repository = ToDosRepositoryI(localDataBase);
    ToDosUsecase useCase = ToDosUsecaseI(repository);
    controller = HomeController(useCase);
  }

  @override
  void initState() {
    super.initState();
    if (mounted) fetchAll();
  }

  void fetchAll() async {
    setState(() => isLoading = true);
    await controller.fetchAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo Home')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator.adaptive()
            : SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.toDos.value.length,
                  itemBuilder: (_, i) {
                    final toDo = controller.toDos.value[i];
                    return ToDoComponent(
                      key: Key(toDo.hashCode.toString()),
                      toDo: toDo,
                      onDismissed: (direction) {
                        setState(() => isLoading = true);

                        controller.deleteToDo(toDo).then(
                          (value) async {
                            if (!value.$2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(value.$1!.message)));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ToDo removed')));

                            setState(() => isLoading = false);
                          },
                        );
                      },
                      onChanged: (value) {
                        setState(() => isLoading = true);

                        controller.completeToDo(toDo, !toDo.isCompleted).then(
                          (value) async {
                            if (!value.$2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(value.$1!.message)));
                              return;
                            }

                            await controller.fetchAll();
                            setState(() => isLoading = false);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register').then((value) {
                  if (value != null && value is bool) fetchAll();
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
