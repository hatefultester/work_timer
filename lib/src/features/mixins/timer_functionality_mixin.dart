import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/work_day_model.dart';
import '../../data/services/work_day_service.dart';

mixin TimerFunctionalityMixin on GetxController {
  Timer? _timer;
  RxBool? _isTimerRunning;

  RxBool get isTimerRunning => _isTimerRunning ?? false.obs;

  bool get shouldTimerFunctionalityUpdateStorage;

  Rxn<WorkDayModel> get workDay;

  updateWorkDay(WorkDayModel workDayNew);

  initTimerResources() {
    _timer = null;
    _isTimerRunning = false.obs;
  }

  disposeTimerResources() {
    _timer?.cancel();
    _timer = null;
    _isTimerRunning?.dispose();
    _isTimerRunning = null;
  }

  void startTimerAction(BuildContext context) {
    _isTimerRunning?.value = true;
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _timer = Timer.periodic(1.seconds, (timer) {
      final workDayNew = workDay.value?.changeWorkedTime((workDay.value?.workedTimeInSeconds ?? 0) + 1);
      if (workDayNew == null) return;
      updateWorkDay(workDayNew);
      if (timer.tick % 60 == 0 && shouldTimerFunctionalityUpdateStorage) {
        WorkDayService.to.updateWorkDay(workDayNew, backgroundSync: true);
      }
    });
  }

  void stopTimerAction(BuildContext context) async {
    _isTimerRunning?.value = false;
    _timer?.cancel();
    _timer = null;
    if (workDay.value != null) await WorkDayService.to.updateWorkDay(workDay.value!);
  }
}
