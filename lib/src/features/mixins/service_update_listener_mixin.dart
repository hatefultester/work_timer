import 'package:get/get.dart';
import 'package:work_timer/src/data/config/logger.dart';

import '../../data/models/task_model.dart';
import '../../data/models/work_day_model.dart';
import '../../data/services/task_service.dart';
import '../../data/services/work_day_service.dart';

mixin ServiceUpdateListenerMixin on GetxController {
  RxBool? _isSynced;

  RxBool get isSynced => _isSynced ?? false.obs;

  Worker? _syncWorker;
  Worker? _updateWorker;

  Rxn<WorkDayModel> get workDay;

  Rxn<List<TaskModel>> get workDayTasks;

  updateWorkDay(WorkDayModel workDayNew);

  updateTasks(List<TaskModel> newWorkDayTasks);

  initServiceListenerResources() async {
    _isSynced = false.obs;
    _updateWorker = ever(isSynced, _updateController);
    _syncWorker = everAll([TaskService.to.isSynced, WorkDayService.to.isSynced], _syncCallback);
    await Future.delayed(600.milliseconds);
    _syncCallback();
    _updateController(true);
  }

  disposeServiceListenerResources() {
    _isSynced?.dispose();
    _updateWorker?.dispose();
    _syncWorker?.dispose();
    _isSynced = null;
    _updateWorker = null;
    _syncWorker = null;
  }

  _syncCallback([_]) async {
    if (TaskService.to.isSynced.isDisposed && WorkDayService.to.isSynced.isDisposed) _syncWorker?.dispose();
    logger.d('TaskService.to.isSynced.value: ${TaskService.to.isSynced.value}');
    logger.d('WorkDayService.to.isSynced.value: ${WorkDayService.to.isSynced.value}');
    isSynced.value = TaskService.to.isSynced.value && WorkDayService.to.isSynced.value;
    logger.w('isSynced.value: ${isSynced.value}');
  }

  _updateController(bool callback) async {
    if (!callback) return;
    logger.w('updateController was called');
    final workDayFromStorage = WorkDayService.to.todayWorkDay;
    final workDayTasksFromStorage = await TaskService.to.getTaskForWorkDay(WorkDayService.to.todayWorkDay);
    if (workDayFromStorage != workDay.value) {
      updateWorkDay(workDayFromStorage);
      logger.w('workDayFromStorage updating: $workDayFromStorage');
    }
    if (workDayTasksFromStorage != workDayTasks.value) {
      updateTasks(workDayTasksFromStorage);
      logger.w('workDayTasksFromStorage updating: $workDayTasksFromStorage');
    }
  }
}
