import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/config/logger.dart';
import 'package:work_timer/src/data/extension/task_model_extensions.dart';
import 'package:work_timer/src/features/components/ios_task_component.dart';
import 'package:work_timer/src/features/components/ios_timer_component.dart';
import 'package:work_timer/src/features/mixins/add_new_task_mixin.dart';

import '../../data/models/task_model.dart';
import '../../data/models/work_day_model.dart';
import '../../data/services/task_service.dart';
import '../../data/services/work_day_service.dart';
import '../../ui_kit/shared/gap.dart';
import '../components/ios_task_list_view.dart';
import '../mixins/change_work_duration_mixin.dart';
import '../mixins/cupertino_menu_animator_mixin.dart';
import '../mixins/service_update_listener_mixin.dart';
import '../mixins/timer_functionality_mixin.dart';
import '../mixins/timer_tile_customization_mixin.dart';

class IOSTodayView extends StatelessWidget {
  const IOSTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSTodayController>(
      init: IOSTodayController(context),
      builder: (controller) {
        return Obx(
          () {
            final isLoading = !controller.isSynced.value;
            if (isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [IOSTimerComponent(), IOSTaskComponent()],
                ),
                Gap.v32,
                SizedBox(
                  height: 300,
                  child: IOSTaskListView(
                    tasks: controller.workDayTasks,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class IOSTodayController extends GetxController
    with
        TimerFunctionalityMixin,
        ChangeWorkDurationMixin,
        ServiceUpdateListenerMixin,
        CupertinoMenuAnimatorMixin,
        TileCustomizationMixin,
        AddNewTaskMixin {
  @override
  late Rxn<WorkDayModel> workDay;

  @override
  late Rxn<List<TaskModel>> workDayTasks;

  late final ValueNotifier<double> workedHoursPercentage;
  late final ValueNotifier<double> taskDonePercentage;

  IOSTodayController(BuildContext context) {
    initTileCustomizationResources(context);
    workDay = Rxn();
    workDayTasks = Rxn();
    workedHoursPercentage = ValueNotifier(0);
    taskDonePercentage = ValueNotifier(0);
  }

  @override
  void onInit() async {
    await initServiceListenerResources();
    initChangeWorkDurationResources();
    initTimerResources();
    super.onInit();
  }

  @override
  void onClose() async {
    await WorkDayService.to.updateWorkDay(workDay.value!);
    disposeChangeWorkDurationResources();
    disposeServiceListenerResources();
    disposeTimerResources();
    disposeTileCustomizationResources();
    workedHoursPercentage.dispose();
    taskDonePercentage.dispose();
    workDay.dispose();
    workDayTasks.dispose();
    super.onClose();
  }

  @override
  void updateTasks(List<TaskModel> newWorkDayTasks) {
    workDayTasks.update((_) => newWorkDayTasks);
    if (newWorkDayTasks.isEmpty) {
      taskDonePercentage.value = 0;
      return;
    }
    final completed = newWorkDayTasks.completedTasks.length;
    taskDonePercentage.value = (completed / newWorkDayTasks.length) * 100;
  }

  @override
  void updateWorkDay(WorkDayModel workDayNew) {
    workDay.update((val) => workDayNew);
    workedHoursPercentage.value = (workDayNew.workedTimeInSeconds / workDayNew.plannedWorkingTimeInSeconds) * 100;
  }

  @override
  bool get shouldTimerFunctionalityUpdateStorage => isUserChangingDuration;

  @override
  bool get shouldChangeWorkDurationFunctionalityUpdateStorage => true;

  @override
  String? get workDayId => workDay.value?.id;

  onTaskTap(TaskModel task) async {
    logger.w('onTaskTap: $task');
    await TaskService.to.updateTask(task.changeCompletionStatus(!task.isCompleted));
  }
}
