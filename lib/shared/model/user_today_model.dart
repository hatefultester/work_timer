import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum PriorityEnum {
  minor,
  major,
  critical;

  String toJson() => switch (this) { minor => 'minor', major => 'major', critical => 'critical' };

  static PriorityEnum fromJson(dynamic json) => switch (json) {
        'minor' => minor,
        'major' => major,
        'critical' => critical,
        _ => major,
      };
}

enum TaskFilterEnum {
  completedTasks,
  uncompletedMinorTasks,
  uncompletedMajorTasks,
  uncompletedCriticalTasks;

  static TaskFilterEnum fromTaskModel(TaskModel model) {
    if (model.isCompleted) return completedTasks;
    if (model.priority == PriorityEnum.minor) return uncompletedMinorTasks;
    if (model.priority == PriorityEnum.major) return uncompletedMajorTasks;
    return uncompletedCriticalTasks;
  }
}

class TaskModel extends Equatable {
  const TaskModel._internal({
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.priority,
  });

  factory TaskModel.newTask({
    required String name,
    required String description,
    required PriorityEnum priority,
  }) =>
      TaskModel._internal(name: name, description: description, isCompleted: false, priority: priority);

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final description = json['description'] as String;
    final isCompleted = json['isCompleted'] as bool;
    final priority = json['priority'];
    return TaskModel._internal(
      name: name,
      description: description,
      isCompleted: isCompleted,
      priority: PriorityEnum.fromJson(priority),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.toJson(),
      };

  final String name;
  final String description;
  final bool isCompleted;
  final PriorityEnum priority;

  @override
  List<Object?> get props => [name, description, isCompleted, priority];
}

class WorkDayModel extends Equatable {
  const WorkDayModel._internal({
    required this.plannedWorkingTimeInSeconds,
    required this.workedTimeInSeconds,
    required this.tasks,
  });

  factory WorkDayModel.start({
    required int plannedWorkingTimeInSeconds,
  }) =>
      WorkDayModel._internal(
        plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
        workedTimeInSeconds: 0,
        tasks: const [],
      );

  factory WorkDayModel.fromJson(Map<String, dynamic> json) {
    final plannedWorkingTimeInSeconds = json['plannedTime'] as int;
    final workedTimeInSeconds = json['workedTime'] as int;
    final tasks = json['tasks'];
    return WorkDayModel._internal(
      plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
      workedTimeInSeconds: workedTimeInSeconds,
      tasks: TaskFilter.fromJson(tasks),
    );
  }

  final int plannedWorkingTimeInSeconds;
  final int workedTimeInSeconds;
  final List<TaskModel> tasks;

  Map<String, dynamic> toJson() => {
        'plannedTime': plannedWorkingTimeInSeconds,
        'workedTime': workedTimeInSeconds,
        'tasks': tasks.toJson(),
      };

  @override
  List<Object?> get props => [plannedWorkingTimeInSeconds, workedTimeInSeconds, tasks];
}

extension TaskFilter on List<TaskModel> {
  List<TaskModel> get completedTasks => where((element) => element.isCompleted).toList();

  List<TaskModel> get unCompletedTasks => where((element) => !element.isCompleted).toList();

  Map<TaskFilterEnum, List<TaskModel>> get groupByFilter => groupBy(this, TaskFilterEnum.fromTaskModel);

  static List<TaskModel> fromJson(dynamic json) => switch (json) {
        List<Map<String, dynamic>> jsonMap => jsonMap.map((e) => TaskModel.fromJson(e)).toList(),
        _ => [],
      };

  List<Map<String, dynamic>> toJson() => map((e) => e.toJson()).toList();
}
