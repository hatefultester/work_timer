import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:task_tracker/core/domain/models/session_model.dart';
import 'package:task_tracker/core/domain/value_key_data_object.dart';
import 'package:task_tracker/core/infrastructure/model_crud_service.dart';

import '../../domain/id.dart';

class SessionService extends ModelCrudService<SessionModel> {
  static SessionService get to => Get.find();
  SessionService(super.localStorageDataSource, super.logger) : super(showInfoLogs: kDebugMode);


  @override
  String get modelPrefix => IdTypeEnum.sessionId.toJsonValueKey();

  @override
  SessionModel? modelValueKeyDataObjectMapper(ValueKeyDataObject object) => SessionModel.fromDataObject(object);

  @override
  String? validateModelCreation(SessionModel model) {
    return null;
  }

  @override
  String? validateModelUpdate(SessionModel oldModel, SessionModel newModel) {
    return null;
  }

}