import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:work_timer/src/data/config/logger.dart';
import 'package:work_timer/src/data/config/storage.dart';
import 'package:work_timer/src/data/services/work_day_service.dart';

import 'src/features/ios_app.dart';
import 'src/data/services/task_service.dart';

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
