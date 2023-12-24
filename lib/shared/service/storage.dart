import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

initStorage([GetStorage? storage]) {
  final instance = storage ?? GetStorage();
  Get.lazyPut<GetStorage>(() => instance, permanent: true);
}

extension StorageExtension on GetxController {
  GetStorage get storage => Get.find<GetStorage>();
}
