import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:task_tracker/core/domain/value_key_data_object.dart';

import '../../domain/id.dart';
import '../../domain/models/task_model.dart';
import '../model_crud_service.dart';

class TaskService extends ModelCrudService<TaskModel> {
  static TaskService get to => Get.find();

  TaskService(super.localStorageDataSource, super.logger) : super(showInfoLogs: kDebugMode);

  @override
  String get modelPrefix => IdTypeEnum.taskId.toJsonValueKey();

  @override
  TaskModel? modelValueKeyDataObjectMapper(ValueKeyDataObject object) => TaskModel.fromDataObject(object);


  @override
  String? validateModelCreation(TaskModel model) {
    return null;
  }

  @override
  String? validateModelUpdate(TaskModel oldModel, TaskModel newModel) {
    return null;
  }
}