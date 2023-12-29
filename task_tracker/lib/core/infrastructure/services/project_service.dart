import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:task_tracker/core/domain/models/project_model.dart';
import 'package:task_tracker/core/domain/value_key_data_object.dart';
import 'package:task_tracker/core/infrastructure/model_crud_service.dart';

import '../../domain/id.dart';

class ProjectService extends ModelCrudService<ProjectModel> {
  static ProjectService get to => Get.find();

  ProjectService(super.localStorageDataSource, super.logger) : super(showInfoLogs: kDebugMode);

  @override
  String get modelPrefix => IdTypeEnum.projectId.toJsonValueKey();

  @override
  ProjectModel? modelValueKeyDataObjectMapper(ValueKeyDataObject object) => ProjectModel.fromDataObject(object);

  @override
  String? validateModelCreation(ProjectModel model) {
    return null;
  }

  @override
  String? validateModelUpdate(ProjectModel oldModel, ProjectModel newModel) {
    return null;
  }
}
