
import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/work_day_model.dart';
import '../services/work_day_service.dart';

extension WorkDayListExtension on List<WorkDayModel> {
  List<WorkDayModel> updateWorkDay(WorkDayModel model) {
    final list = List<WorkDayModel>.from([model]);
    for (final item in this) {
      if (item.id != model.id) list.add(item);
    }
    return list;
  }

  List<WorkDayModel> updateWorkDays(List<WorkDayModel> models) {
    final ids = models.map((e) => e.id);
    final newList = List<WorkDayModel>.from(models, growable: true);
    for (final model in this) {
      if (!ids.contains(model.id)) newList.add(model);
    }
    return newList;
  }

  List<Map<String, dynamic>> toJson() => map((e) => e.toJson()).toList();

  static List<WorkDayModel> fromJson(dynamic json) => switch (json) {
    List<dynamic> data => data.map((e) => WorkDayModel.fromJson(e)).toList(),
    _ => [],
  };

  bool get containsToday {
    final today = DateTime.now().toYMD();
    return firstWhereOrNull((e) => e.workDate.toYMD().isAtSameMomentAs(today)) != null;
  }
}

extension DateTimeExtension on DateTime {
  DateTime toYMD() => DateTime(year, month, day);
}

extension DurationExtension on Duration {
  String toHMS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return "${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

extension WorkDayModelStorage on List<WorkDayModel> {
  static int get defaultPlannedHours => WorkDayService.to.defaultWorkingHoursInSeconds;

  static getWorkDaysFromStorage(GetStorage storage) {
    final workDayListStorageData = storage.read<String?>(WorkDayModel.workDayListKey);
    final workDayListJson = workDayListStorageData != null ? jsonDecode(workDayListStorageData) : null;
    final workDayList = WorkDayListExtension.fromJson(workDayListJson);
    if (!workDayList.containsToday) {
      final newDay = WorkDayModel.start(plannedWorkingTimeInSeconds: defaultPlannedHours);
      workDayList.add(newDay);
    }
    return workDayList;
  }

  Future<void> storeWorkDaysToStorage(GetStorage storage) async {
    final workDayListStorageData = storage.read<String?>(WorkDayModel.workDayListKey);
    final workDayListJson = workDayListStorageData != null ? jsonDecode(workDayListStorageData) : null;
    final workDayList = WorkDayListExtension.fromJson(workDayListJson);
    final workDayListUpdated = workDayList.updateWorkDays(this);
    final updatedJson = jsonEncode(workDayListUpdated.toJson());
    await storage.write(WorkDayModel.workDayListKey, updatedJson);
    await storage.save();
  }
}
