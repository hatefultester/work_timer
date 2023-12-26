import 'dart:convert';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../services/work_day_service.dart';

Random random = Random();

class WorkDayModel extends Equatable {
  static const Duration minimalDayDuration = Duration(hours: 2);
  static const Duration maximalDayDuration = Duration(hours: 14);

  const WorkDayModel._internal({
    required this.plannedWorkingTimeInSeconds,
    required this.workedTimeInSeconds,
    required this.workDate,
    required this.id,
    required this.wasEdited,
  });

  factory WorkDayModel.start({
    required int plannedWorkingTimeInSeconds,
  }) {
    final index = random.nextInt(100);
    final time = DateTime.now();
    final id = '$index-${time.toIso8601String()}';
    return WorkDayModel._internal(
      plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
      workedTimeInSeconds: 0,
      workDate: time,
      id: id,
      wasEdited: false,
    );
  }

  factory WorkDayModel.fromJson(Map<String, dynamic> json) {
    final plannedWorkingTimeInSeconds = json['plannedTime'] as int;
    final workedTimeInSeconds = json['workedTime'] as int;
    final workDate = json['workDate'] as String;
    final id = json['id'] as String;
    final wasEdited = json['wasEdited'] as bool;
    return WorkDayModel._internal(
      id: id,
      plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
      workedTimeInSeconds: workedTimeInSeconds,
      workDate: DateTime.parse(workDate),
      wasEdited: wasEdited,
    );
  }

  final String id;
  final DateTime workDate;
  final int plannedWorkingTimeInSeconds;
  final int workedTimeInSeconds;
  final bool wasEdited;

  WorkDayModel changePlannedTime(int plannedWorkingTimeInSeconds) => WorkDayModel._internal(
        id: id,
        plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
        workedTimeInSeconds: workedTimeInSeconds,
        workDate: workDate,
        wasEdited: true,
      );

  WorkDayModel changeWorkedTime(int workedTimeInSeconds) => WorkDayModel._internal(
        id: id,
        plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
        workedTimeInSeconds: workedTimeInSeconds,
        workDate: workDate,
        wasEdited: true,
      );

  WorkDayModel signalizeEdit() => WorkDayModel._internal(
      plannedWorkingTimeInSeconds: plannedWorkingTimeInSeconds,
      workedTimeInSeconds: workedTimeInSeconds,
      workDate: workDate,
      id: id,
      wasEdited: true);

  Map<String, dynamic> toJson() => {
        'plannedTime': plannedWorkingTimeInSeconds,
        'workedTime': workedTimeInSeconds,
        'workDate': workDate.toIso8601String(),
        'id': id,
        'wasEdited': wasEdited,
      };

  @override
  List<Object?> get props => [id, plannedWorkingTimeInSeconds, workedTimeInSeconds];
}

const workDayListKey = 'work-day-list-key';

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
    final workDayListStorageData = storage.read<String?>(workDayListKey);
    Get.find<Logger>().d('work day list storage data: $workDayListStorageData');
    final workDayListJson = workDayListStorageData != null ? jsonDecode(workDayListStorageData) : null;
    Get.find<Logger>().d('work day list json data: ${workDayListJson.runtimeType}');

    final workDayList = WorkDayListExtension.fromJson(workDayListJson);
    Get.find<Logger>().d('work day list fetched: ${workDayList.toString()}');
    if (!workDayList.containsToday) {
      workDayList.add(WorkDayModel.start(plannedWorkingTimeInSeconds: defaultPlannedHours));
    }
    return workDayList;
  }

  Future<void> storeWorkDaysToStorage(GetStorage storage) async {
    final workDayListStorageData = storage.read<String?>(workDayListKey);
    final workDayListJson = workDayListStorageData != null ? jsonDecode(workDayListStorageData) : null;
    final workDayList = WorkDayListExtension.fromJson(workDayListJson);
    Get.find<Logger>().d('work day list before: ${workDayList.toString()}');
    final workDayListUpdated = workDayList.updateWorkDays(this);
    Get.find<Logger>().d('work day list updated: ${workDayListUpdated.toString()}');
    final updatedJson = jsonEncode(workDayListUpdated.toJson());
    await storage.write(workDayListKey, updatedJson);
    await storage.save();
  }
}
