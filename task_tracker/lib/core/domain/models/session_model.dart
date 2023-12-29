import 'package:task_tracker/core/domain/extensions/mappers.dart';

import '../id.dart';
import '../value_key_data_object.dart';

class SessionModel extends Model<SessionId> {
  const SessionModel(
      super.id, super.creationTime, this.taskId, this.goal, this.duration, this.completedDuration, this.wasGoalReached);

  factory SessionModel.create({
    required TaskId taskId,
    required String name,
    required Duration duration,
  }) {
    return SessionModel(SessionId.create(), DateTime.now(), taskId, name, duration, Duration.zero, false);
  }

  final TaskId taskId;

  final String goal;

  final Duration duration;

  final Duration completedDuration;

  final bool wasGoalReached;

  int get remainingDurationInSeconds => duration.inSeconds - completedDuration.inSeconds;

  SessionModel changeDuration(Duration newDuration) =>
      SessionModel(id, creationTime, taskId, goal, newDuration, completedDuration, wasGoalReached);

  SessionModel changeGoal(String newGoal) =>
      SessionModel(id, creationTime, taskId, newGoal, duration, completedDuration, wasGoalReached);

  SessionModel addCompletedTimeInSeconds(int seconds) => SessionModel(
      id, creationTime, taskId, goal, duration, completedDuration + Duration(seconds: seconds), wasGoalReached);

  SessionModel complete() => SessionModel(id, creationTime, taskId, goal, duration, duration, true);

  SessionModel changeTaskId(TaskId newTaskId) =>
      SessionModel(id, creationTime, newTaskId, goal, duration, completedDuration, wasGoalReached);

  SessionModel copyWith({
    TaskId? taskId,
    String? goal,
    Duration? duration,
    Duration? completedDuration,
    bool? wasGoalReached,
  }) {
    return SessionModel(id, creationTime, taskId ?? this.taskId, goal ?? this.goal, duration ?? this.duration,
        completedDuration ?? this.completedDuration, wasGoalReached ?? this.wasGoalReached);
  }

  static SessionModel? fromDataObject(ValueKeyDataObject dataObject) {
    final map = dataObject.map;
    if (map == null) return null;

    final id = Id.fromValue<SessionId>(dataObject.key);
    final idParsed = id.fold((l) => null, (r) => r);
    if (idParsed == null) return null;

    final creationTime = DateTimeMapper.fromJson(map['creationTime']);
    if (creationTime == null) return null;

    final taskId = Id.fromValue<TaskId>(map['taskId'] as String);
    final taskIdParsed = taskId.fold((l) => null, (r) => r);
    if (taskIdParsed == null) return null;

    final goal = map['goal'] as String;
    final duration = DurationMapper.fromJson(map['duration']);
    if (duration == null) return null;
    final completedDuration = DurationMapper.fromJson(map['completedDuration']);
    if (completedDuration == null) return null;
    final wasGoalReached = map['wasGoalReached'] as bool;
    return SessionModel(idParsed, creationTime, taskIdParsed, goal, duration, completedDuration, wasGoalReached);
  }

  @override
  Map<String, dynamic> get map => {
        'creationTime': creationTime.toJson(),
        'taskId': taskId.toJson(),
        'goal': goal,
        'duration': duration.toJson(),
        'completedDuration': completedDuration.toJson(),
        'wasGoalReached': wasGoalReached,
      };

  @override
  List<Object?> get props => [id, creationTime, taskId, goal, duration, completedDuration, wasGoalReached];
}
