import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:get_storage/get_storage.dart';
import 'package:work_timer/src/data/models/work_day_model.dart';

enum PriorityEnum {
  minor,
  major,
  critical;

  String toStringFormatted() => switch (this) {
        minor => 'Minor',
        major => 'Major',
        critical => 'Critical',
      };

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

  factory TaskModel.newTask({
    required String name,
    required String description,
    required PriorityEnum priority,
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
      priority: PriorityEnum.fromJson(priority),
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

  TaskModel changePriority(PriorityEnum priority) => TaskModel._internal(
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
  final PriorityEnum priority;
  final DateTime startDate;

  @override
  List<Object?> get props => [id];
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

  List<TaskModel> addTasksAndFilter(List<TaskModel> tasks) => List<TaskModel>.from([tasks, ...this]);
}

extension TaskModelStorage on Map<TaskFilterEnum, List<TaskModel>> {
  static Future<void> updateTasks(List<TaskModel> models, GetStorage storage) async {
    if (models.isEmpty) return;
    final toGroups = models.groupByFilter;
    final fromStorage = await getAllTasksGrouped(storage);
    fromStorage[TaskFilterEnum.completedTasks] = <TaskModel>{
      ...toGroups[TaskFilterEnum.completedTasks]!,
      ...fromStorage[TaskFilterEnum.completedTasks]!
    }.toList();
    fromStorage[TaskFilterEnum.uncompletedCriticalTasks] = <TaskModel>{
      ...toGroups[TaskFilterEnum.uncompletedCriticalTasks]!,
      ...fromStorage[TaskFilterEnum.uncompletedCriticalTasks]!
    }.toList();
    fromStorage[TaskFilterEnum.uncompletedMinorTasks] = <TaskModel>{
      ...toGroups[TaskFilterEnum.uncompletedMinorTasks]!,
      ...fromStorage[TaskFilterEnum.uncompletedMinorTasks]!
    }.toList();
    fromStorage[TaskFilterEnum.uncompletedMajorTasks] = <TaskModel>{
      ...toGroups[TaskFilterEnum.uncompletedMajorTasks]!,
      ...fromStorage[TaskFilterEnum.uncompletedMajorTasks]!
    }.toList();
    await fromStorage.saveTasksToStorage(storage);
  }

  Future<void> saveTasksToStorage(GetStorage storage) async {
    for (final group in entries) {
      await updateGroupInStorage(group, storage);
    }
  }

  updateGroupInStorage(MapEntry<TaskFilterEnum, List<TaskModel>> group, GetStorage storage) async {
    final oldDataFromStorage = storage.read<String?>(group.key.storageKey);
    final oldDataJson = oldDataFromStorage != null ? jsonDecode(oldDataFromStorage) : null;
    final oldDataList = TaskFilter.fromJson(oldDataJson);
    final updatedData = oldDataList.addTasksAndFilter(group.value);
    final updateDataEncoded = jsonEncode(updatedData.toJson());
    await storage.write(group.key.storageKey, updateDataEncoded);
    await storage.save();
  }

  static Future<Map<TaskFilterEnum, List<TaskModel>>> getAllTasksGrouped(GetStorage storage) async {
    final Map<TaskFilterEnum, List<TaskModel>> map = {};
    for (final filterEnum in TaskFilterEnum.values) {
      final value = await getTaskGroup(filterEnum, storage);
      map.addEntries([MapEntry(filterEnum, value)]);
    }
    return map;
  }

  static Future<List<TaskModel>> getTaskGroup(TaskFilterEnum filter, GetStorage storage) async {
    final dataFromStorage = storage.read<String?>(filter.storageKey);
    final dataFromStorageJson = dataFromStorage != null ? jsonDecode(dataFromStorage) : null;
    return TaskFilter.fromJson(dataFromStorageJson);
  }
}
