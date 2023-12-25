import 'dart:convert';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Random random = Random();

class WorkDayModel extends Equatable {
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
  List<Object?> get props => [id];
}

const workDayListKey = 'work-day-list-key';

extension WorkDayListExtension on List<WorkDayModel> {
  List<WorkDayModel> updateWorkDay(WorkDayModel model) => List<WorkDayModel>.from({model, ...this});

  List<WorkDayModel> updateWorkDays(List<WorkDayModel> models) => List<WorkDayModel>.from({models, ...this});

  List<Map<String, dynamic>> toJson() => map((e) => e.toJson()).toList();

  static List<WorkDayModel> fromJson(dynamic json) => switch (json) {
        List<Map<String, dynamic>> data => data.map((e) => WorkDayModel.fromJson(e)).toList(),
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

extension WorkDayModelStorage on List<WorkDayModel> {
  static int get defaultPlannedHours => 8 * 60 * 60;

  static getWorkDaysFromStorage(GetStorage storage) {
    final workDayListStorageData = storage.read<String?>(workDayListKey);
    final workDayListJson = workDayListStorageData != null ? jsonDecode(workDayListStorageData) : null;
    final workDayList = WorkDayListExtension.fromJson(workDayListJson);
    if (!workDayList.containsToday) {
      workDayList.add(WorkDayModel.start(plannedWorkingTimeInSeconds: defaultPlannedHours));
    }
    return workDayList;
  }

  Future<void> storeWorkDaysToStorage(GetStorage storage) async {
    final workDayListStorageData = storage.read<String?>(workDayListKey);
    final workDayListJson = workDayListStorageData != null ? jsonDecode(workDayListStorageData) : null;
    final workDayList = WorkDayListExtension.fromJson(workDayListJson);
    final workDayListUpdated = workDayList.updateWorkDays(this);
    final updatedJson = jsonEncode(workDayListUpdated.toJson());
    await storage.write(workDayListKey, updatedJson);
    await storage.save();
  }
}
