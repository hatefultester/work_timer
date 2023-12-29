import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

extension ControllerExtensions on GetxController {
  d(String message) => kDebugMode ? Get.find<Logger>().i(message) : null;
}
