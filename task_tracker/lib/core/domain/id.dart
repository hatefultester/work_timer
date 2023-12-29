import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'custom_failure.dart';

sealed class Id extends Equatable {
  const Id(this.value);

  static Either<CustomFailure, T> fromValue<T extends Id>(dynamic value) {
    try {
      if (value is! String) {
        throw Exception('Id value must be a String');
      }
      final idTypeValue = value.split('://');
      final idTypeResult = IdTypeEnum.fromJsonValueKey(idTypeValue.first);
      final idObject = switch (idTypeResult) {
        IdTypeEnum.projectId => ProjectId._internal(idTypeValue.last),
        IdTypeEnum.taskId => TaskId._internal(idTypeValue.last),
        IdTypeEnum.toDoId => ToDoId._internal(idTypeValue.last),
        IdTypeEnum.sessionId => SessionId._internal(idTypeValue.last),
      };
      if (idObject is! T) {
        throw Exception('Id value type does not match the expected type');
      }
      return Right(idObject);
    } on Exception catch (e, s) {
      return Left(
        CustomFailure(
          message: 'Failed to parse Id from json value: $value',
          exception: e,
          stackTrace: s,
        ),
      );
    }
  }



  String toJson() {
    final idTypeValue = switch (this) {
      ProjectId() => IdTypeEnum.projectId.toJsonValueKey(),
      TaskId() => IdTypeEnum.taskId.toJsonValueKey(),
      ToDoId() => IdTypeEnum.toDoId.toJsonValueKey(),
      SessionId() => IdTypeEnum.sessionId.toJsonValueKey(),
    };
    return '$idTypeValue://$value';
  }

  final String value;

  @override
  List<Object?> get props => [value];
}

enum IdTypeEnum {
  projectId,
  taskId,
  toDoId,
  sessionId;

  toJsonValueKey() => switch (this) {
        IdTypeEnum.projectId => 'projectId',
        IdTypeEnum.taskId => 'taskId',
        IdTypeEnum.toDoId => 'toDoId',
        IdTypeEnum.sessionId => 'sessionId',
      };

  static IdTypeEnum fromJsonValueKey(String key) => switch (key) {
        'projectId' => IdTypeEnum.projectId,
        'taskId' => IdTypeEnum.taskId,
        'toDoId' => IdTypeEnum.toDoId,
        'sessionId' => IdTypeEnum.sessionId,
        _ => throw Exception('Unknown IdTypeEnum key: $key'),
      };
}

class ProjectId extends Id {
  const ProjectId._internal(String value) : super(value);

  factory ProjectId.create() {
    return ProjectId._internal(DateTime.now().toIso8601String());
  }
}

class TaskId extends Id {
  const TaskId._internal(String value) : super(value);

  factory TaskId.create() {
    return TaskId._internal(DateTime.now().toIso8601String());
  }

}


class ToDoId extends Id {
  const ToDoId._internal(String value) : super(value);

  factory ToDoId.create() {
    return ToDoId._internal(DateTime.now().toIso8601String());
  }
}

class SessionId extends Id {
  const SessionId._internal(String value) : super(value);

  factory SessionId.create() {
    return SessionId._internal(DateTime.now().toIso8601String());
  }
}
