import 'package:task_tracker/core/domain/extensions/mappers.dart';
import 'package:task_tracker/core/domain/id.dart';

import '../value_key_data_object.dart';

class ToDoModel extends Model<ToDoId> {
  const ToDoModel(super.id, super.creationTime, this.taskId, this.name, this.goal, this.isCompleted);

  factory ToDoModel.create({
    required TaskId taskId,
    required String name,
    required String goal,
    bool isCompleted = false,
  }) {
    return ToDoModel(ToDoId.create(), DateTime.now(), taskId, name, goal, isCompleted);
  }

  final TaskId taskId;
  final String name;
  final String goal;
  final bool isCompleted;

  ToDoModel changeIsCompleted(bool newIsCompleted) => ToDoModel(id, creationTime, taskId, name, goal, newIsCompleted);

  ToDoModel changeGoal(String newGoal) => ToDoModel(id, creationTime, taskId, name, newGoal, isCompleted);

  ToDoModel changeName(String newName) => ToDoModel(id, creationTime, taskId, newName, goal, isCompleted);

  ToDoModel changeTaskId(TaskId newTaskId) => ToDoModel(id, creationTime, newTaskId, name, goal, isCompleted);

  ToDoModel copyWith({
    TaskId? taskId,
    String? name,
    String? goal,
    bool? isCompleted,
  }) {
    return ToDoModel(
        id, creationTime, taskId ?? this.taskId, name ?? this.name, goal ?? this.goal, isCompleted ?? this.isCompleted);
  }

  static ToDoModel? fromDataObject(ValueKeyDataObject dataObject) {
    final map = dataObject.map;
    if (map == null) return null;

    final id = Id.fromValue<ToDoId>(dataObject.key);
    final idParsed = id.fold((l) => null, (r) => r);
    if (idParsed == null) return null;

    final creationTime = DateTimeMapper.fromJson(map['creationTime']);
    if (creationTime == null) return null;

    final taskId = Id.fromValue<TaskId>(map['taskId']);
    final taskIdParsed = taskId.fold((l) => null, (r) => r);
    if (taskIdParsed == null) return null;

    final name = map['name'] as String;
    final goal = map['goal'] as String;
    final isCompleted = map['isCompleted'] as bool;
    return ToDoModel(idParsed, creationTime, taskIdParsed, name, goal, isCompleted);
  }

  @override
  Map<String, dynamic> get map => {
        'creationTime': creationTime.toJson(),
        'taskId': taskId.toJson(),
        'name': name,
        'goal': goal,
        'isCompleted': isCompleted,
      };

  @override
  List<Object?> get props => [id, creationTime, taskId, name, goal, isCompleted];
}
