import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

initStorage([GetStorage? storage]) {
  final instance = storage ?? GetStorage();
  Get.lazyPut<GetStorage>(() => instance, permanent: true);
}

extension StorageControllerExtension on GetxController {
  GetStorage get storage => Get.find<GetStorage>();
}

extension StorageServiceExtension on GetxService {
  GetStorage get storage => Get.find<GetStorage>();
}
