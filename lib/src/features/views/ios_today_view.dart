import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/services/task_service.dart';
import 'package:work_timer/src/data/services/work_day_service.dart';

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
    syncWorker = everAll([TaskService.to.isSynced, WorkDayService.to.isSynced], _syncCallback);
    _syncCallback();
    super.onInit();
  }

  @override
  void onClose() {
    syncWorker.dispose();
    isSynced.dispose();
    super.dispose();
  }

  sync(bool callback) {
    isSynced.value = callback;
  }

  _syncCallback([_]) async {
    if (TaskService.to.isSynced.isDisposed && WorkDayService.to.isSynced.isDisposed) syncWorker.dispose();
    isSynced.value = TaskService.to.isSynced.value && WorkDayService.to.isSynced.value;
  }
}
