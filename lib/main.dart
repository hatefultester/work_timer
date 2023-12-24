import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:work_timer/shared/service/logger.dart';
import 'package:work_timer/shared/service/storage.dart';

import 'ios/ios_app.dart';

Future<void> main() async {
  await GetStorage.init();
  initLogger();
  initStorage();
  runApp(const IOSApp());
}
