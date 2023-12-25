import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:work_timer/shared/service/logger.dart';
import 'package:work_timer/shared/service/storage.dart';
import 'package:work_timer/shared/service/work_day_service.dart';

import 'ios/ios_app.dart';
import 'shared/service/task_service.dart';

Future<void> main() async {
  await GetStorage.init();
  initLogger();
  initStorage();
  initServices();
  runApp(const IOSApp());
}

initServices() {
  Get.put<TaskService>(TaskService(), permanent: true);
  Get.put<WorkDayService>(WorkDayService(), permanent: true);
}
