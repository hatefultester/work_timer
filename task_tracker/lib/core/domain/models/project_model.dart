import 'package:task_tracker/core/domain/extensions/mappers.dart';
import 'package:task_tracker/core/domain/value_key_data_object.dart';

import '../id.dart';

class ProjectModel extends Model<ProjectId> {
  const ProjectModel(super.id, super.creationTime, this.name, this.description, this.priority);

  factory ProjectModel.create({
    required String name,
    required String description,
    required int priority,
  }) {
    return ProjectModel(ProjectId.create(), DateTime.now(), name, description, priority);
  }

  final String name;

  final String description;

  final int priority;

  ProjectModel changePriority(int newPriority) => ProjectModel(id, creationTime, name, description, newPriority);

  ProjectModel changeDescription(String newDescription) =>
      ProjectModel(id, creationTime, name, newDescription, priority);

  ProjectModel changeName(String newName) => ProjectModel(id, creationTime, newName, description, priority);

  ProjectModel copyWith({
    String? name,
    String? description,
    int? priority,
  }) {
    return ProjectModel(
        id, creationTime, name ?? this.name, description ?? this.description, priority ?? this.priority);
  }

  static ProjectModel? fromDataObject(ValueKeyDataObject dataObject) {
    final map = dataObject.map;
    if (map == null) return null;

    final id = Id.fromValue<ProjectId>(dataObject.key);
    final idParsed = id.fold((l) => null, (r) => r);
    if (idParsed == null) return null;

    final creationTime = DateTimeMapper.fromJson(map['creationTime']);
    if (creationTime == null) return null;

    final name = map['name'] as String;
    final description = map['description'] as String;
    final priority = map['priority'] as int;
    return ProjectModel(idParsed, creationTime, name, description, priority);
  }

  @override
  Map<String, dynamic> get map => {
        'creationTime': creationTime.toJson(),
        'name': name,
        'description': description,
        'priority': priority,
      };

  @override
  List<Object?> get props => [id, creationTime, name, description, priority];
}
