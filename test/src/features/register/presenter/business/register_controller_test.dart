import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_monolith/src/core/domain/entities/to_do_entity.dart';
import 'package:todo_monolith/src/core/domain/usecases/to_dos_usecase_i.dart';
import 'package:todo_monolith/src/core/infra/datasources/to_dos_datasource.dart';
import 'package:todo_monolith/src/core/infra/repositories/to_dos_repository_i.dart';
import 'package:todo_monolith/src/features/register/presenter/business/register_controller.dart';

void main() {
  late RegisterController controller;
  late ToDosDatasource toDosDatasource;

  var toDo = ToDoEntity(
      title: 'Test 1', description: 'Test Desc 1', isCompleted: false);

  setUp(() {
    toDosDatasource = ToDosDatasourceMock();
    controller = RegisterController(
      ToDosUsecaseI(
        ToDosRepositoryI(toDosDatasource),
      ),
    );

    registerFallbackValue(toDo);
  });

  test(
    'Should RegisterController Save a ToDo inside a List in save method with correct values',
    () async {
      when(() => toDosDatasource.save(any(that: isA<ToDoEntity>())))
          .thenAnswer((_) async => toDo);
      await controller.saveToDo();
      expect(controller.toDo, isA<ToDoEntity>());
    },
  );

  test(
    'Should RegisterController return a Exception in save method for any reason',
    () async {
      when(() => toDosDatasource.save(any(that: isA<ToDoEntity>())))
          .thenThrow(Exception());
      await controller.saveToDo();
      expect(controller.toDo, isA<ToDoEntity>());
    },
  );
}

class ToDosDatasourceMock extends Mock implements ToDosDatasource {}
