import 'package:get/get.dart';
import 'package:work_timer/src/data/models/work_day_model.dart';
import 'package:work_timer/src/data/config/storage.dart';

class WorkDayService extends GetxService {
  static WorkDayService get to => Get.find();
  late List<WorkDayModel>? _workDaysFromStorage;

  List<WorkDayModel> get workDaysFromStorage => _workDaysFromStorage ?? [];
  late RxBool isSynced = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _startSync();
    _workDaysFromStorage = [];
    final workDays = await WorkDayModelStorage.getWorkDaysFromStorage(storage);
    _workDaysFromStorage = workDays;
    _stopSync();
  }

  @override
  void onClose() {
    _workDaysFromStorage = null;
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
    _workDaysFromStorage = {model, ...workDaysFromStorage}.toList();
    await workDaysFromStorage.storeWorkDaysToStorage(storage);
    _stopSync();
  }
}
