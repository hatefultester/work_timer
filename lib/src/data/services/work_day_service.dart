import 'package:get/get.dart';
import 'package:work_timer/src/data/config/logger.dart';
import 'package:work_timer/src/data/models/work_day_model.dart';
import 'package:work_timer/src/data/config/storage.dart';

class WorkDayService extends GetxService {
  static WorkDayService get to => Get.find();
  late List<WorkDayModel>? _workDaysFromStorage;

  List<WorkDayModel> get workDaysFromStorage => _workDaysFromStorage ?? [];
  late RxBool isSynced = false.obs;

  late int? _defaultWorkingHoursInSeconds;

  int get defaultWorkingHoursInSeconds => _defaultWorkingHoursInSeconds ?? 8 * 60 * 60;

  Duration get defaultWorkingHoursDuration => Duration(seconds: defaultWorkingHoursInSeconds);

  @override
  void onInit() async {
    super.onInit();
    _startSync();
    final defaultWorkingHoursStored = storage.read<int?>('working-hours-default');
    _defaultWorkingHoursInSeconds = defaultWorkingHoursStored ?? 8 * 60 * 60;

    _workDaysFromStorage = [];
    final workDays = await WorkDayModelStorage.getWorkDaysFromStorage(storage);
    _workDaysFromStorage = workDays;

    logger.i(_workDaysFromStorage.toString());

    _stopSync();
  }

  @override
  void onClose() {
    _workDaysFromStorage = null;
    _defaultWorkingHoursInSeconds = null;
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

  Future<void> updateWorkDay(WorkDayModel model, {bool backgroundSync = false}) async {
    if (!backgroundSync) {
      _startSync();
    }
    _workDaysFromStorage = workDaysFromStorage.updateWorkDay(model);
    await workDaysFromStorage.storeWorkDaysToStorage(storage);
    if (!backgroundSync) {
      _stopSync();
    }
  }

  Future<void> storeNewDefaultWorkingHours(Duration workingHoursDuration) async {
    if (_defaultWorkingHoursInSeconds == workingHoursDuration.inSeconds) return;
    final seconds = workingHoursDuration.inSeconds;
    _defaultWorkingHoursInSeconds = seconds;
    await storage.write('working-hours-default', seconds);
    await storage.save();
  }
}
