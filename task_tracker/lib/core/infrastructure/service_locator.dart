import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:task_tracker/core/infrastructure/local_storage_data_source.dart';
import 'package:task_tracker/core/infrastructure/services/project_service.dart';
import 'package:task_tracker/core/infrastructure/services/task_service.dart';
import 'package:task_tracker/core/infrastructure/services/todo_service.dart';

import 'services/session_service.dart';

abstract class ServiceLocator {
  static initializeServices() async {
    Get.put<LocalStorageDataSourceInterface>(LocalStorageDataSource());
    Get.put<Logger>(Logger());
    Get.lazyPut<ProjectService>(() => ProjectService(Get.find(), Get.find()));
    Get.lazyPut<SessionService>(() => SessionService(Get.find(), Get.find()));
    Get.lazyPut<TaskService>(() => TaskService(Get.find(), Get.find()));
    Get.lazyPut<ToDoService>(() => ToDoService(Get.find(), Get.find()));
  }
}
