import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/shared/service/task_service.dart';
import 'package:work_timer/shared/service/work_day_service.dart';

class IOSTodayView extends StatelessWidget {
  const IOSTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSTodayController>(
      init: IOSTodayController(),
      builder: (controller) {
        return Obx(
            () => controller.isSynced.value ? Text('Synchronized') : Center(child: CupertinoActivityIndicator()));
      },
    );
  }
}

class IOSTodayController extends GetxController {
  late RxBool isSynced = false.obs;
  late Worker syncWorker;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    syncWorker = everAll([TaskService.to.isSynced, WorkDayService.to.isSynced], _syncCallback);
    _syncCallback();
    super.onReady();
  }

  @override
  void dispose() {
    syncWorker.dispose();
    isSynced.dispose();
    super.dispose();
  }

  sync(bool callback) {
    isSynced.value = callback;
  }

  _syncCallback([_]) async {
    isSynced.value = TaskService.to.isSynced.value && WorkDayService.to.isSynced.value;
  }
}
