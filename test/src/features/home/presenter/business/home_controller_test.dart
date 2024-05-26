import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_monolith/src/core/domain/entities/to_do_entity.dart';
import 'package:todo_monolith/src/core/domain/usecases/to_dos_usecase_i.dart';
import 'package:todo_monolith/src/core/infra/datasources/to_dos_datasource.dart';
import 'package:todo_monolith/src/core/infra/repositories/to_dos_repository_i.dart';
import 'package:todo_monolith/src/features/home/presenter/business/home_controller.dart';

void main() {
  late HomeController controller;
  late ToDosDatasource toDosDatasource;

  var toDo = ToDoEntity(
      title: 'Test 1', description: 'Test Desc 1', isCompleted: false);

  setUp(() {
    toDosDatasource = ToDosDatasourceMock();
    controller = HomeController(
      ToDosUsecaseI(
        ToDosRepositoryI(toDosDatasource),
      ),
    );

    registerFallbackValue(toDo);
  });

  test(
    'Should HomeController return a ToDo List in fetch method with correct values',
    () async {
      var toDosList = [
        ToDoEntity(
            title: 'Test 1', description: 'Test Desc 1', isCompleted: false),
        ToDoEntity(
            title: 'Test 2', description: 'Test Desc 2', isCompleted: true),
        ToDoEntity(
            title: 'Test 3', description: 'Test Desc 3', isCompleted: true),
      ];

      when(() => toDosDatasource.fetchAll()).thenAnswer((_) async => toDosList);
      await controller.fetchAll();
      expect(controller.toDos.value, toDosList);
    },
  );

  test(
    'Should HomeController return a Exception in fetch method for any reason',
    () async {
      when(() => toDosDatasource.fetchAll()).thenThrow(Exception());
      await controller.fetchAll();
      expect(controller.toDos.value, []);
    },
  );

  test(
    'Should HomeController complete a ToDo in complete method',
    () async {
      var toDosList = [
        toDo,
        ToDoEntity(
            title: 'Test 2', description: 'Test Desc 2', isCompleted: true),
        ToDoEntity(
            title: 'Test 3', description: 'Test Desc 3', isCompleted: true),
      ];

      when(() => toDosDatasource.fetchAll()).thenAnswer((_) async => toDosList);
      when(() => toDosDatasource.delete(toDo)).thenAnswer((_) async => true);
      when(() => toDosDatasource.save(any(that: isA<ToDoEntity>())))
          .thenAnswer((_) async => true);
      await controller.fetchAll();
      await controller.completeToDo(toDo, true);
      expect(
        controller.toDos.value,
        toDosList..replaceRange(0, 1, [toDo.copyWith(isCompleted: true)]),
      );
    },
  );

  test(
    'Should HomeController remove a ToDo in delete method',
    () async {
      var toDosList = [
        toDo,
        ToDoEntity(
            title: 'Test 2', description: 'Test Desc 2', isCompleted: true),
        ToDoEntity(
            title: 'Test 3', description: 'Test Desc 3', isCompleted: true),
      ];

      when(() => toDosDatasource.delete(toDo)).thenAnswer((_) async => true);
      when(() => toDosDatasource.fetchAll()).thenAnswer((_) async => toDosList);
      await controller.fetchAll();
      await controller.deleteToDo(toDo);
      expect(controller.toDos.value, toDosList..remove(toDo));
    },
  );
}

class ToDosDatasourceMock extends Mock implements ToDosDatasource {}
