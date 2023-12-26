import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/services/task_service.dart';
import 'package:work_timer/src/data/services/work_day_service.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';
import 'package:work_timer/src/ui_kit/shared/progress_bar_component.dart';

import '../../data/models/task_model.dart';
import '../../data/models/work_day_model.dart';
import '../../ui_kit/shared/gap.dart';

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
                  children: [
                    CupertinoContextMenu.builder(
                        enableHapticFeedback: true,
                        actions: [
                          Obx(() {
                            final isRunning = controller.isTimerRunning.value;
                            return CupertinoContextMenuAction(
                              onPressed: () {
                                Navigator.pop(context);
                                if (isRunning) {
                                  controller.stopTimerAction(context);
                                } else {
                                  controller.startTimerAction(context);
                                }
                              },
                              isDestructiveAction: isRunning,
                              trailingIcon: isRunning ? CupertinoIcons.timer : CupertinoIcons.timer_fill,
                              child: Text(isRunning ? 'Stop working' : 'Start working'),
                            );
                          }),
                          CupertinoContextMenuAction(
                            onPressed: () {
                              Navigator.pop(context);
                              controller.changeWorkingHoursAction(context);
                            },
                            trailingIcon: CupertinoIcons.clock_fill,
                            child: const Text('Change working duration'),
                          ),
                          CupertinoContextMenuAction(
                            onPressed: () {
                              Navigator.pop(context);
                              controller.customizeWorkingHoursTile(context);
                            },
                            trailingIcon: CupertinoIcons.circle_righthalf_fill,
                            child: const Text('Customize'),
                          ),
                        ],
                        builder: (BuildContext context, Animation<double> animation) {
                          return Obx(() {
                            final backgroundColor = controller.workDurationBackgroundTileColor.value;
                            final Animation<Decoration> boxDecorationAnimation =
                                controller.boxDecorationAnimation(animation, context, backgroundColor: backgroundColor);

                            return DefaultTextStyle(
                              style: TextStyle(
                                color: backgroundColor.invertColor(),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: animation.value < CupertinoContextMenu.animationOpensAt
                                    ? boxDecorationAnimation.value
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Obx(
                                    () {
                                      final progressColor = controller.workDurationProgressColor.value;
                                      final day = controller.workDay.value;
                                      final duration = Duration(seconds: day?.workedTimeInSeconds ?? 0);
                                      final label = duration.toHMS();
                                      return ProgressBarComponent(
                                        key: ValueKey(progressColor),
                                        progressColor: progressColor,
                                        percentageNotifier: controller.workedHoursPercentage,
                                        label: label,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                    Gap.h24,
                    CupertinoContextMenu.builder(
                      enableHapticFeedback: true,
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.addNewTaskAction(context);
                          },
                          trailingIcon: CupertinoIcons.create_solid,
                          child: const Text('Add new task'),
                        ),
                        CupertinoContextMenuAction(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.customizeCircularProgressIndicatorForTasksAction(context);
                          },
                          trailingIcon: CupertinoIcons.circle_righthalf_fill,
                          child: const Text('Customize'),
                        ),
                      ],
                      builder: (BuildContext context, Animation<double> animation) {
                        final Animation<Decoration> boxDecorationAnimation =
                            controller.boxDecorationAnimation(animation, context);
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: animation.value < CupertinoContextMenu.animationOpensAt
                              ? boxDecorationAnimation.value
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Obx(
                              () {
                                final completed = controller.workDayTasks.value?.completedTasks.length ?? 0;
                                final label = '$completed/${controller.workDayTasks.value?.length ?? 0}';
                                return ProgressBarComponent(
                                  percentageNotifier: controller.taskDonePercentage,
                                  label: label,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class IOSTodayController extends GetxController {
  late final RxBool isSynced;
  late final Worker syncWorker;
  late final Worker updateWorker;

  late final RxBool isTimerRunning;

  late final ValueNotifier<double> workedHoursPercentage;
  late final ValueNotifier<double> taskDonePercentage;

  late Rxn<WorkDayModel> workDay;
  late Rxn<List<TaskModel>> workDayTasks;

  late final Rx<Color> workDurationBackgroundTileColor;
  late final Rx<Color> workDurationProgressColor;

  late final Rx<Duration> _internalWorkingInterval;
  Worker? _internalWorkingIntervalWorker;
  bool _ignoreDebouncer = true;

  Timer? timer;

  IOSTodayController(BuildContext context) {
    final dynamicBackgroundColor = CupertinoColors.systemGroupedBackground.resolveFrom(context);
    final dynamicProgressColor = CupertinoColors.activeBlue.resolveFrom(context);
    workDurationBackgroundTileColor = (Color.fromRGBO(dynamicBackgroundColor.red, dynamicBackgroundColor.green,
            dynamicBackgroundColor.blue, dynamicBackgroundColor.opacity))
        .obs;
    workDurationProgressColor = (Color.fromRGBO(dynamicProgressColor.red, dynamicProgressColor.green,
            dynamicProgressColor.blue, dynamicProgressColor.opacity))
        .obs;
  }

  @override
  void onInit() async {
    super.onInit();
    workDay = Rxn();
    workDayTasks = Rxn();
    isSynced = false.obs;
    isTimerRunning = false.obs;

    updateWorker = ever(isSynced, _updateController, condition: isSynced.value == true);
    syncWorker = everAll([TaskService.to.isSynced, WorkDayService.to.isSynced], _syncCallback);
    workedHoursPercentage = ValueNotifier(0);
    taskDonePercentage = ValueNotifier(0);
    await Future.delayed(600.milliseconds);
    _syncCallback();
    _updateController(true);
    _internalWorkingInterval = (Duration(seconds: workDay.value?.plannedWorkingTimeInSeconds ?? 8 * 60 * 60)).obs;
    _internalWorkingIntervalWorker = debounce(_internalWorkingInterval, (callback) {
      if (_ignoreDebouncer || workDay.value == null) return;
      final newModel = workDay.value!.changePlannedTime(callback.inSeconds);
      updateWorkDay(newModel);
    }, time: 50.milliseconds);
  }

  @override
  void onClose() {
    workDay.dispose();
    workDayTasks.dispose();
    taskDonePercentage.dispose();
    workedHoursPercentage.dispose();
    syncWorker.dispose();
    isSynced.dispose();
    super.dispose();
  }

  _syncCallback([_]) async {
    if (TaskService.to.isSynced.isDisposed && WorkDayService.to.isSynced.isDisposed) syncWorker.dispose();
    isSynced.value = TaskService.to.isSynced.value && WorkDayService.to.isSynced.value;
  }

  _updateController(bool callback) async {
    if (!callback) return;
    final workDayFromStorage = WorkDayService.to.todayWorkDay;
    final workDayTasksFromStorage = await TaskService.to.getTaskForWorkDay(WorkDayService.to.todayWorkDay);
    if (workDayFromStorage != workDay.value) updateWorkDay(workDayFromStorage);
    if (workDayTasksFromStorage != workDayTasks.value) updateWorkDayTasks(workDayTasksFromStorage);
  }

  void updateWorkDayTasks(List<TaskModel> newWorkDayTasks) {
    workDayTasks.update((_) => newWorkDayTasks);
    if (newWorkDayTasks.isEmpty) {
      taskDonePercentage.value = 0;
      return;
    }
    final completed = newWorkDayTasks.completedTasks.length;

    taskDonePercentage.value = (completed / newWorkDayTasks.length) * 100;
  }

  void updateWorkDay(WorkDayModel newWorkDay) {
    workDay.update((val) => newWorkDay);
    workedHoursPercentage.value = (newWorkDay.workedTimeInSeconds / newWorkDay.plannedWorkingTimeInSeconds) * 100;
  }

  Animation<Decoration> boxDecorationAnimation(
    Animation<double> animation,
    BuildContext context, {
    Color? backgroundColor,
  }) {
    final DecorationTween tween = DecorationTween(
      begin: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        boxShadow: const <BoxShadow>[],
        borderRadius: BorderRadius.circular(20.0),
      ),
      end: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        boxShadow: CupertinoContextMenu.kEndBoxShadow,
        borderRadius: BorderRadius.circular(20.0),
      ),
    );

    return tween.animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.0,
          CupertinoContextMenu.animationOpensAt,
        ),
      ),
    );
  }

  void addNewTaskAction(BuildContext context) {}

  void customizeCircularProgressIndicatorForTasksAction(BuildContext context) {}

  void changeWorkingHoursAction(BuildContext context) async {
    if (workDay.value == null) return;
    _ignoreDebouncer = false;
    await showIOSTimerPicker(
      context,
      initialTimerDuration: workDay.value!.plannedWorkingTimeInSeconds.seconds,
      onClosed: (context, originalDuration, wasConfirmed) async {
        final selectedInterval = _internalWorkingInterval.value;
        final isLessThenMinimal = selectedInterval < WorkDayModel.minimalDayDuration;
        final isMoreThenMaximal = selectedInterval > WorkDayModel.maximalDayDuration;
        if (!isLessThenMinimal && !isMoreThenMaximal && workDay.value != null) {
          showIOSLoadingOverlay(context);
          final newModel = workDay.value!.changePlannedTime(selectedInterval.inSeconds);
          updateWorkDay(newModel);
          await WorkDayService.to.updateWorkDay(newModel, backgroundSync: true);
          await hideIOSLoadingOverlay();
        } else {
          final newModel = workDay.value!.changePlannedTime(originalDuration.inSeconds);
          updateWorkDay(newModel);
          showIOSAlertDialog(
            context,
            message: 'Working interval must be between 2 - 14 hours',
            title: 'Selected interval was not allowed',
          );
        }

        if (!(_internalWorkingIntervalWorker?.disposed ?? true)) {
          _ignoreDebouncer = true;
        }
      },
      onDurationChanged: (Duration duration) {
        _internalWorkingInterval.value = duration;
      },
    );
  }

  void stopTimerAction(BuildContext context) async {
    isTimerRunning.value = false;
    timer?.cancel();
    timer = null;
    if (workDay.value != null) await WorkDayService.to.updateWorkDay(workDay.value!);
  }

  void startTimerAction(BuildContext context) {
    isTimerRunning.value = true;
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    timer = Timer.periodic(1.seconds, (timer) {
      final workDayNew = workDay.value?.changeWorkedTime((workDay.value?.workedTimeInSeconds ?? 0) + 1);
      if (workDayNew == null) return;
      updateWorkDay(workDayNew);
      if (timer.tick % 60 == 0 && _ignoreDebouncer) {
        WorkDayService.to.updateWorkDay(workDayNew, backgroundSync: true);
      }
    });
  }

  void customizeWorkingHoursTile(BuildContext context) async {
    await showIOSColorCustomizationBottomSheet(context, options: [
      IOSColorCustomizationBottomSheetOption(
        label: 'Background',
        value: workDurationBackgroundTileColor.value,
      ),
      IOSColorCustomizationBottomSheetOption(
        label: 'Progress color',
        value: workDurationProgressColor.value,
      ),
    ], onChanged: (updatedList) async {
      workDurationBackgroundTileColor.value = updatedList[0].value;
      workDurationProgressColor.value = updatedList[1].value;
    }, onClosed: (context, originalOptions, wasSaved) async {});
  }
}
