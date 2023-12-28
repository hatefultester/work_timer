import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

import '../../data/models/work_day_model.dart';
import '../../data/services/work_day_service.dart';

mixin ChangeWorkDurationMixin on GetxController {
  Rx<Duration>? _internalWorkingInterval;
  Worker? _internalWorkingIntervalWorker;
  bool? _ignoreDebouncer = true;

  bool get isUserChangingDuration => !(_ignoreDebouncer ?? true);

  Rxn<WorkDayModel> get workDay;

  updateWorkDay(WorkDayModel workDayNew);

  initChangeWorkDurationResources() {
    _internalWorkingInterval = (Duration(seconds: workDay.value?.plannedWorkingTimeInSeconds ?? 8 * 60 * 60)).obs;
    _internalWorkingIntervalWorker = debounce(
      _internalWorkingInterval!,
      (callback) {
        if ((_ignoreDebouncer ?? true) || workDay.value == null) return;
        final newModel = workDay.value!.changePlannedTime(callback.inSeconds);
        updateWorkDay(newModel);
      },
      time: 50.milliseconds,
    );
  }

  disposeChangeWorkDurationResources() {
    _internalWorkingInterval?.dispose();
    _internalWorkingIntervalWorker?.dispose();
    _ignoreDebouncer = null;
    _internalWorkingInterval = null;
    _internalWorkingIntervalWorker = null;
  }

  bool get shouldChangeWorkDurationFunctionalityUpdateStorage;

  void changeWorkingHoursAction(BuildContext context) async {
    if (workDay.value == null) return;
    _ignoreDebouncer = false;
    await showIOSTimerPicker(
      context,
      initialTimerDuration: workDay.value!.plannedWorkingTimeInSeconds.seconds,
      onClosed: (context, originalDuration, wasConfirmed) async {
        final selectedInterval = _internalWorkingInterval?.value ?? originalDuration;
        final isLessThenMinimal = selectedInterval < WorkDayModel.minimalDayDuration;
        final isMoreThenMaximal = selectedInterval > WorkDayModel.maximalDayDuration;
        if (!isLessThenMinimal && !isMoreThenMaximal && workDay.value != null) {
          showIOSLoadingOverlay(context);
          final newModel = workDay.value!.changePlannedTime(selectedInterval.inSeconds);
          updateWorkDay(newModel);
          if (shouldChangeWorkDurationFunctionalityUpdateStorage) {
            await WorkDayService.to.updateWorkDay(newModel, backgroundSync: true);
          }
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
        _internalWorkingInterval?.value = duration;
      },
    );
  }
}
