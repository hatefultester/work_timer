import 'dart:math';
import 'package:equatable/equatable.dart';

Random random = Random();

class WorkDayModel extends Equatable {
  static const workDayListKey = 'work-day-list-key';
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

