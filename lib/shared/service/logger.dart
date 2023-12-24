import 'package:get/get.dart';
import 'package:logger/logger.dart';

initLogger([Logger? logger]) {
  final instance = logger ?? Logger();
  Get.lazyPut<Logger>(() => instance, permanent: true);
}

extension LoggerExtension on GetxController {
  Logger get logger => Get.find();
}
