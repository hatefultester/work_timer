import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../models/task_model.dart';

extension TaskModelStorageExtension on Map<TaskFilterEnum, List<TaskModel>> {
  static Future<void> updateTasks(List<TaskModel> models, GetStorage storage) async {
    if (models.isEmpty) return;
    final toGroups = models.groupByFilter;
    Get.find<Logger>().e('toGroups: $toGroups');
    final fromStorage = await getAllTasksGrouped(storage);
    fromStorage[TaskFilterEnum.completedTasks] = <TaskModel>{
      ...(toGroups[TaskFilterEnum.completedTasks] ?? []),
      ...(fromStorage[TaskFilterEnum.completedTasks] ?? [])
    }.toList();
    fromStorage[TaskFilterEnum.uncompletedCriticalTasks] = <TaskModel>{
      ...(toGroups[TaskFilterEnum.uncompletedCriticalTasks] ?? []),
      ...(fromStorage[TaskFilterEnum.uncompletedCriticalTasks] ?? [])
    }.toList();
    fromStorage[TaskFilterEnum.uncompletedMinorTasks] = <TaskModel>{
      ...(toGroups[TaskFilterEnum.uncompletedMinorTasks] ?? []),
      ...(fromStorage[TaskFilterEnum.uncompletedMinorTasks] ?? [])
    }.toList();
    fromStorage[TaskFilterEnum.uncompletedMajorTasks] = <TaskModel>{
      ...(toGroups[TaskFilterEnum.uncompletedMajorTasks] ?? []),
      ...(fromStorage[TaskFilterEnum.uncompletedMajorTasks] ?? [])
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
    final oldDataList = TaskListFilterExtension.fromJson(oldDataJson);
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
    return TaskListFilterExtension.fromJson(dataFromStorageJson);
  }
}

extension TaskListFilterExtension on List<TaskModel> {
  List<TaskModel> get completedTasks => where((element) => element.isCompleted).toList();

  List<TaskModel> get unCompletedTasks => where((element) => !element.isCompleted).toList();

  Map<TaskFilterEnum, List<TaskModel>> get groupByFilter => groupBy(this, TaskFilterEnum.fromTaskModel);

  static List<TaskModel> fromJson(dynamic json) => switch (json) {
        List<dynamic> jsonMap => jsonMap.map((e) => TaskModel.fromJson(e)).toList(),
        _ => [],
      };

  List<Map<String, dynamic>> toJson() => map((e) => e.toJson()).toList();

  List<TaskModel> addTasksAndFilter(List<TaskModel> tasks) =>
      List<TaskModel>.from([...tasks, ...this]).toSet().toList();
}
