import 'package:equatable/equatable.dart';
import 'package:work_timer/src/data/models/work_day_model.dart';
import 'package:work_timer/src/data/services/task_service.dart';

import 'task_priority_enum.dart';

enum TaskFilterEnum {
  completedTasks,
  uncompletedMinorTasks,
  uncompletedMajorTasks,
  uncompletedCriticalTasks;

  static TaskFilterEnum fromTaskModel(TaskModel model) {
    if (model.isCompleted) return completedTasks;
    if (model.priority == TaskPriorityEnum.minor) return uncompletedMinorTasks;
    if (model.priority == TaskPriorityEnum.major) return uncompletedMajorTasks;
    return uncompletedCriticalTasks;
  }

  String get storageKey => switch (this) {
        completedTasks => 'completed-tasks-list',
        uncompletedMinorTasks => 'uncompleted-minor-tasks-list',
        uncompletedMajorTasks => 'uncompleted-major-tasks-list',
        uncompletedCriticalTasks => 'uncompleted-critical-tasks-list',
      };
}

class TaskModel extends Equatable {
  const TaskModel._internal({
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.startDate,
    required this.priority,
    required this.id,
    this.workDayId,
  });

  factory TaskModel.empty([String? workDayId]) => TaskModel.newTask(
        name: '',
        description: '',
        priority: TaskService.to.defaultTaskPriority,
        workDayId: workDayId,
      );

  factory TaskModel.newTask({
    required String name,
    required String description,
    required TaskPriorityEnum priority,
    String? workDayId,
  }) {
    final index = random.nextInt(100);
    final time = DateTime.now();
    final id = '$index-${time.toIso8601String()}';
    return TaskModel._internal(
      name: name,
      description: description,
      isCompleted: false,
      priority: priority,
      startDate: time,
      id: id,
      workDayId: workDayId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final description = json['description'] as String;
    final isCompleted = json['isCompleted'] as bool;
    final priority = json['priority'];
    final startDate = json['startDate'] as String;
    final id = json['id'] as String;
    final workDayId = json['workDayId'] as String?;
    return TaskModel._internal(
      name: name,
      description: description,
      isCompleted: isCompleted,
      priority: TaskPriorityEnum.fromJson(priority),
      startDate: DateTime.parse(startDate),
      id: id,
      workDayId: workDayId,
    );
  }

  TaskModel changeCompletionStatus(bool isCompleted) => TaskModel._internal(
        id: id,
        name: name,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        startDate: startDate,
        workDayId: workDayId,
      );

  TaskModel changeName(String name) => TaskModel._internal(
        id: id,
        name: name,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        startDate: startDate,
        workDayId: workDayId,
      );

  TaskModel changeDescription(String description) => TaskModel._internal(
        id: id,
        name: name,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        startDate: startDate,
        workDayId: workDayId,
      );

  TaskModel changePriority(TaskPriorityEnum priority) => TaskModel._internal(
        id: id,
        name: name,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        startDate: startDate,
        workDayId: workDayId,
      );

  TaskModel setWorkId(String? workDayId) => TaskModel._internal(
        id: id,
        name: name,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        startDate: startDate,
        workDayId: workDayId,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.toJson(),
        'startDate': startDate.toIso8601String(),
        'id': id,
        'workDayId': workDayId,
      };

  final String id;
  final String? workDayId;
  final String name;
  final String description;
  final bool isCompleted;
  final TaskPriorityEnum priority;
  final DateTime startDate;

  @override
  List<Object?> get props => [id];
}
