import 'package:get/get.dart';
import 'package:work_timer/shared/model/work_day_model.dart';
import 'package:work_timer/shared/service/storage.dart';

class WorkDayService extends GetxService {
  static WorkDayService get to => Get.find();
  late List<WorkDayModel> workDaysFromStorage;
  late RxBool isSynced = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _startSync();
    workDaysFromStorage = [];
    final workDays = await WorkDayModelStorage.getWorkDaysFromStorage(storage);
    workDaysFromStorage = workDays;
    _stopSync();
  }

  @override
  void onClose() {
    isSynced.dispose();
    super.onClose();
  }

  WorkDayModel get todayWorkDay {
    final today = DateTime.now().toYMD();
    return workDaysFromStorage.firstWhere((element) => element.workDate.toYMD().isAtSameMomentAs(today));
  }

  void _startSync() {
    isSynced.value = false;
  }

  void _stopSync() {
    isSynced.value = true;
  }

  Future<void> updateWorkDay(WorkDayModel model) async {
    _startSync();
    workDaysFromStorage = {model, ...workDaysFromStorage}.toList();
    await workDaysFromStorage.storeWorkDaysToStorage(storage);
    _stopSync();
  }
}
