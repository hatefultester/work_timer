import 'package:get/get.dart';
import 'package:work_timer/src/data/config/storage.dart';

import '../models/task_model.dart';
import '../models/work_day_model.dart';

class TaskService extends GetxService {
  static TaskService get to => Get.find();

  late Map<TaskFilterEnum, List<TaskModel>>? _tasksFromStorage;

  Map<TaskFilterEnum, List<TaskModel>> get tasksFromStorage => _tasksFromStorage ?? {};

  late RxBool isSynced = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _startSync();
    _tasksFromStorage = {};
    final tasks = await TaskModelStorage.getAllTasksGrouped(storage);
    _tasksFromStorage = tasks;
    _stopSync();
  }

  @override
  void onClose() {
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
    await TaskModelStorage.updateTasks(taskList, storage);
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
}
