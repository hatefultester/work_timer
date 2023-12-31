import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/config/logger.dart';
import 'package:work_timer/src/data/config/storage.dart';
import 'package:work_timer/src/data/extension/task_model_extensions.dart';

import '../models/task_model.dart';
import '../models/task_priority_enum.dart';
import '../models/work_day_model.dart';

class TaskService extends GetxService {
  static TaskService get to => Get.find();

  late Map<TaskFilterEnum, List<TaskModel>>? _tasksFromStorage;

  Map<TaskFilterEnum, List<TaskModel>> get tasksFromStorage => _tasksFromStorage ?? {};

  late TaskPriorityEnum? _defaultPriority;

  TaskPriorityEnum get defaultTaskPriority => _defaultPriority ?? TaskPriorityEnum.major;

  late RxBool isSynced = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _startSync();
    _tasksFromStorage = {};
    final tasks = await TaskModelStorageExtension.getAllTasksGrouped(storage);
    _tasksFromStorage = tasks;

    logger.i('TaskService: tasksFromStorage: $_tasksFromStorage');

    final defaultPriorityJson = storage.read<String?>('task-priority-default');
    _defaultPriority = TaskPriorityEnum.fromJson(defaultPriorityJson);
    _stopSync();
  }

  @override
  void onClose() {
    _defaultPriority = null;
    _tasksFromStorage = null;
    isSynced.dispose();
    super.onClose();
  }

  void _startSync() {
    isSynced.value = false;
  }

  void _stopSync() {
    isSynced.value = true;
  }

  Future<List<TaskModel>> getTaskForWorkDay(WorkDayModel model) async {
    final completedTasks = tasksFromStorage[TaskFilterEnum.completedTasks]!;
    final uncompletedTasks = [
      ...tasksFromStorage[TaskFilterEnum.uncompletedMinorTasks]!,
      ...tasksFromStorage[TaskFilterEnum.uncompletedMajorTasks]!,
      ...tasksFromStorage[TaskFilterEnum.uncompletedCriticalTasks]!,
    ];
    final taskList = <TaskModel>[];
    taskList.addAll(completedTasks.where((element) => element.workDayId == model.id));
    taskList.addAll(uncompletedTasks
        .where((element) => element.workDayId == model.id || element.startDate.isBefore(model.workDate)));
    await TaskModelStorageExtension.updateTasks(taskList, storage);
    logger.d('TaskService: getTaskForWorkDay: $taskList');
    return taskList;
  }

  Future<void> createNewTask(TaskModel taskModel) async {
    _startSync();
    final TaskFilterEnum filter = TaskFilterEnum.fromTaskModel(taskModel);
    tasksFromStorage[filter] = [...tasksFromStorage[filter]!, taskModel].toList();
    await tasksFromStorage.updateGroupInStorage(MapEntry(filter, tasksFromStorage[filter]!), storage);
    _stopSync();
  }

  Future<void> updateTask(TaskModel taskModel) async {
    _startSync();
    deleteTaskById(taskModel.id, internal: true);
    final TaskFilterEnum filter = TaskFilterEnum.fromTaskModel(taskModel);
    tasksFromStorage[filter] = {taskModel, ...tasksFromStorage[filter]!}.toList();
    await tasksFromStorage.updateGroupInStorage(MapEntry(filter, tasksFromStorage[filter]!), storage);
    _stopSync();
  }

  Future<void> deleteTask(TaskModel taskModel) async {
    _startSync();
    final TaskFilterEnum filter = TaskFilterEnum.fromTaskModel(taskModel);
    tasksFromStorage[filter] = tasksFromStorage[filter]!..remove(taskModel);
    await tasksFromStorage.updateGroupInStorage(MapEntry(filter, tasksFromStorage[filter]!), storage);
    _stopSync();
  }

  Future<void> deleteTaskById(String taskId, {bool internal = false}) async {
    if (!internal) {
      _startSync();
    }
    final TaskModel? taskModel =
        tasksFromStorage.values.expand((element) => element).firstWhereOrNull((element) => element.id == taskId);
    if (taskModel == null) return;
    final TaskFilterEnum filter = TaskFilterEnum.fromTaskModel(taskModel);
    tasksFromStorage[filter] = tasksFromStorage[filter]!..remove(taskModel);
    if (!internal) {
      await tasksFromStorage.updateGroupInStorage(MapEntry(filter, tasksFromStorage[filter]!), storage);
      _stopSync();
    }
  }

  Future<void> setDefaultTaskPriority(TaskPriorityEnum defaultPriority) async {
    if (defaultTaskPriority == _defaultPriority) return;
    _defaultPriority = defaultPriority;
    final json = defaultTaskPriority.toJson();
    await storage.write('task-priority-default', json);
    await storage.save();
  }
}
