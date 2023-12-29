import 'package:task_tracker/core/domain/extensions/mappers.dart';

import '../id.dart';
import '../value_key_data_object.dart';

class TaskModel extends Model<TaskId> {
  const TaskModel(super.id, super.creationTime, this.name, this.description, this.priority, this.isCompleted,
      this.estimatedTime, this.projectId);

  factory TaskModel.create({
    required ProjectId projectId,
    required String name,
    required String description,
    required int priority,
    bool isCompleted = false,
    Duration? estimatedTime,
  }) {
    return TaskModel(
        TaskId.create(), DateTime.now(), name, description, priority, isCompleted, estimatedTime, projectId);
  }

  final ProjectId projectId;

  final String name;

  final String description;

  final int priority;

  final bool isCompleted;

  final Duration? estimatedTime;

  bool get withEstimatedTime => estimatedTime != null;

  TaskModel changePriority(int newPriority) =>
      TaskModel(id, creationTime, name, description, newPriority, isCompleted, estimatedTime, projectId);

  TaskModel changeIsCompleted(bool newIsCompleted) =>
      TaskModel(id, creationTime, name, description, priority, newIsCompleted, estimatedTime, projectId);

  TaskModel changeEstimatedTime(Duration? newEstimatedTime) =>
      TaskModel(id, creationTime, name, description, priority, isCompleted, newEstimatedTime, projectId);

  TaskModel changeDescription(String newDescription) =>
      TaskModel(id, creationTime, name, newDescription, priority, isCompleted, estimatedTime, projectId);

  TaskModel changeName(String newName) =>
      TaskModel(id, creationTime, newName, description, priority, isCompleted, estimatedTime, projectId);

  TaskModel changeProjectId(ProjectId newProjectId) =>
      TaskModel(id, creationTime, name, description, priority, isCompleted, estimatedTime, newProjectId);

  TaskModel copyWith({
    String? name,
    String? description,
    int? priority,
    bool? isCompleted,
    Duration? estimatedTime,
    ProjectId? projectId,
  }) {
    return TaskModel(
      id,
      creationTime,
      name ?? this.name,
      description ?? this.description,
      priority ?? this.priority,
      isCompleted ?? this.isCompleted,
      estimatedTime ?? this.estimatedTime,
      projectId ?? this.projectId,
    );
  }

  static TaskModel? fromDataObject(ValueKeyDataObject dataObject) {
    final map = dataObject.map;
    if (map == null) return null;

    final id = Id.fromValue<TaskId>(dataObject.key);
    final idParsed = id.fold((l) => null, (r) => r);
    if (idParsed == null) return null;

    final creationTime = DateTimeMapper.fromJson(map['creationTime']);
    if (creationTime == null) return null;

    final projectId = Id.fromValue<ProjectId>(map['projectId'] as String);
    final projectIdParsed = projectId.fold((l) => null, (r) => r);
    if (projectIdParsed == null) return null;

    final name = map['name'] as String;
    final description = map['description'] as String;
    final priority = map['priority'] as int;
    final isCompleted = map['isCompleted'] as bool;
    final estimatedTime = DurationMapper.fromJson(map['estimatedTime']);
    return TaskModel(idParsed, creationTime, name, description, priority, isCompleted, estimatedTime, projectIdParsed);
  }

  @override
  Map<String, dynamic> get map => {
        'projectId': projectId.toJson(),
        'creationTime': creationTime.toJson(),
        'name': name,
        'description': description,
        'priority': priority,
        'isCompleted': isCompleted,
        'estimatedTime': estimatedTime?.toJson(),
      };

  @override
  List<Object?> get props => [id, creationTime, name, description, priority, isCompleted, estimatedTime];
}
