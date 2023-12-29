import 'package:task_tracker/core/domain/models/project_model.dart';

import '../models/session_model.dart';
import '../models/task_model.dart';

extension TaskModelExtension on TaskModel {
  Duration totalTimeSpent(List<SessionModel> sessions) {
    return sessions
        .where((session) => session.taskId == id)
        .map((session) => session.duration)
        .reduce((value, element) => value + element);
  }

  Duration totalTimeSpentToday(List<SessionModel> sessions) {
    return sessions
        .where((session) => session.taskId == id)
        .where((session) => session.creationTime.day == DateTime.now().day)
        .map((session) => session.duration)
        .reduce((value, element) => value + element);
  }

  Duration totalTimeSpentThisWeek(List<SessionModel> sessions) {
    return sessions
        .where((session) => session.taskId == id)
        .where((session) => session.creationTime.weekday == DateTime.now().weekday)
        .map((session) => session.duration)
        .reduce((value, element) => value + element);
  }

  Duration totalTimeSpentThisMonth(List<SessionModel> sessions) {
    return sessions
        .where((session) => session.taskId == id)
        .where((session) => session.creationTime.month == DateTime.now().month)
        .map((session) => session.duration)
        .reduce((value, element) => value + element);
  }
}

extension ProjectModelExtension on ProjectModel {
  Duration totalTimeSpent(List<TaskModel> tasks, List<SessionModel> sessions) {
    return tasks
        .where((task) => task.projectId == id)
        .map((task) => task.totalTimeSpent(sessions))
        .reduce((value, element) => value + element);
  }

  Duration totalTimeSpentToday(List<TaskModel> tasks, List<SessionModel> sessions) {
    return tasks
        .where((task) => task.projectId == id)
        .map((task) => task.totalTimeSpentToday(sessions))
        .reduce((value, element) => value + element);
  }

  Duration totalTimeSpentThisWeek(List<TaskModel> tasks, List<SessionModel> sessions) {
    return tasks
        .where((task) => task.projectId == id)
        .map((task) => task.totalTimeSpentThisWeek(sessions))
        .reduce((value, element) => value + element);
  }

  Duration totalTimeSpentThisMonth(List<TaskModel> tasks, List<SessionModel> sessions) {
    return tasks
        .where((task) => task.projectId == id)
        .map((task) => task.totalTimeSpentThisMonth(sessions))
        .reduce((value, element) => value + element);
  }
}
