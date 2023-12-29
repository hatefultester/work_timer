import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:task_tracker/core/domain/models/todo_model.dart';
import 'package:task_tracker/core/domain/value_key_data_object.dart';
import 'package:task_tracker/core/infrastructure/model_crud_service.dart';

import '../../domain/id.dart';

class ToDoService extends ModelCrudService<ToDoModel> {
  static ToDoService get to => Get.find();

  ToDoService(super.localStorageDataSource, super.logger) : super(showInfoLogs: kDebugMode);

  @override
  String get modelPrefix => IdTypeEnum.toDoId.toJsonValueKey();

  @override
  ToDoModel? modelValueKeyDataObjectMapper(ValueKeyDataObject object) => ToDoModel.fromDataObject(object);

  @override
  String? validateModelCreation(ToDoModel model) {
    return null;
  }

  @override
  String? validateModelUpdate(ToDoModel oldModel, ToDoModel newModel) {
    return null;
  }
}
