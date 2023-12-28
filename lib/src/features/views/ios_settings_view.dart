import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/config/keys.dart';
import 'package:work_timer/src/data/models/work_day_model.dart';
import 'package:work_timer/src/data/services/task_service.dart';
import 'package:work_timer/src/data/services/work_day_service.dart';
import 'package:work_timer/src/features/ios_app.dart';
import 'package:work_timer/src/features/pages/ios_onboarding_page.dart';
import 'package:work_timer/src/data/config/storage.dart';
import 'package:work_timer/src/ui_kit/shared/app_icon_component.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

import '../../data/models/task_priority_enum.dart';
import '../../ui_kit/ios/ios_section_component.dart';
import '../../ui_kit/shared/gap.dart';

class IOSSettingsView extends StatelessWidget {
  const IOSSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSSettingsController>(
      init: IOSSettingsController(),
      builder: (controller) => Column(
        children: [
          IOSSectionComponent(
            items: [
              IOSSectionItem.withSwitch(
                label: 'Dark theme',
                onTap: controller.toggleApplicationBrightness,
                isActive: controller.isDarkThemeActive,
              ),
              IOSSectionItem.withIcon(
                label: 'Delete all data',
                iconData: CupertinoIcons.delete,
                onTap: controller.showRestoreSettingsConfirmationDialog,
              )
            ],
          ),
          IOSSectionComponent(
            items: [
              IOSSectionItem<Rx<Duration>>.popUp(
                label: 'Default working duration',
                onTap: controller.openChangeWorkingInterval,
                informationObserver: controller.defaultWorkingInterval,
                informationParser: controller.workingIntervalParser,
                iconData: CupertinoIcons.archivebox,
              ),
              IOSSectionItem<Rx<TaskPriorityEnum>>.popUp(
                label: 'Default task priority',
                onTap: controller.openChangePriorityPopUp,
                informationObserver: controller.defaultTaskPriority,
                informationParser: controller.taskPriorityParser,
                iconData: CupertinoIcons.archivebox,
              ),
            ],
          ),
          Gap.v64,
          const AppIconComponent(
            appVersionNumber: AppConstants.latestAppVersion,
          ),
        ],
      ),
    );
  }
}

class IOSSettingsController extends GetxController {
  late final RxBool isDarkThemeActive;
  late final Rx<Duration> defaultWorkingInterval;
  late final Rx<TaskPriorityEnum> defaultTaskPriority;
  late final Rx<Duration> _internalWorkingInterval;
  Worker? _internalWorkingIntervalWorker;
  bool _ignoreDebouncer = true;

  @override
  onInit() {
    super.onInit();
    defaultWorkingInterval = WorkDayService.to.defaultWorkingHoursDuration.obs;
    _internalWorkingInterval = WorkDayService.to.defaultWorkingHoursDuration.obs;

    _internalWorkingIntervalWorker = debounce(_internalWorkingInterval, (callback) {
      if (_ignoreDebouncer) return;
      defaultWorkingInterval.value = callback;
    }, time: 50.milliseconds);

    defaultTaskPriority = TaskService.to.defaultTaskPriority.obs;
    isDarkThemeActive = (IOSAppController.to.brightness == Brightness.values.first).obs;
  }

  @override
  onClose() {
    super.onClose();
    if (!(_internalWorkingIntervalWorker?.disposed ?? true)) {
      _internalWorkingIntervalWorker?.dispose();
    }
    _internalWorkingInterval.dispose();
    defaultWorkingInterval.dispose();
    defaultTaskPriority.dispose();
    isDarkThemeActive.dispose();
  }

  showRestoreSettingsConfirmationDialog(BuildContext context) async {
    await showIOSConfirmationDialog(
      context,
      title: 'Are you sure?',
      description: 'This action will delete everything from your account.',
      onResultHandler: (result, context) async {
        showIOSLoadingOverlay(context);
        final navigator = Navigator.of(context);
        if (!result) {
          if (navigator.canPop()) navigator.pop();
          await hideIOSLoadingOverlay();
          return;
        }

        final keys = storage.getKeys<Iterable<String>>().toList();
        for (final key in keys) {
          await storage.remove(key);
        }
        await storage.erase();
        await hideIOSLoadingOverlay();
        TaskService.to.onInit();
        WorkDayService.to.onInit();
        IOSAppController.to.restart();
        navigator.pushReplacement(CupertinoPageRoute(builder: (_) => const IOSOnboardingPage()));
      },
    );
  }

  void toggleApplicationBrightness(BuildContext context) async {
    IOSAppController.to.toggleApplicationBrightness().then(
      (_) {
        isDarkThemeActive.toggle();
      },
    );
  }

  void openChangePriorityPopUp(BuildContext context) {
    showIOSModalPopUp(context,
        cancelText: 'Dismiss',
        actions: TaskPriorityEnum.values
            .map(
              (e) => IOSActionData(
                label: e.toStringFormatted(),
                isDestructive: e == defaultTaskPriority.value,
              ),
            )
            .toList(), onResultHandler: (result, context) async {
      if (result == null) return;
      showIOSLoadingOverlay(context);
      final parsedFromIndex = TaskPriorityEnum.values[result];
      defaultTaskPriority.value = parsedFromIndex;
      await TaskService.to.setDefaultTaskPriority(parsedFromIndex);
      await hideIOSLoadingOverlay();
    });
  }

  void openChangeWorkingInterval(BuildContext context) {
    _ignoreDebouncer = false;
    showIOSTimerPicker(context, initialTimerDuration: defaultWorkingInterval.value,
        onDurationChanged: (Duration duration) {
      _internalWorkingInterval.value = duration;
    }, onClosed: validateSelectedInterval);
  }

  String taskPriorityParser(_) {
    return defaultTaskPriority.value.toStringFormatted();
  }

  String workingIntervalParser(_) {
    final hours = defaultWorkingInterval.value.inHours;
    final minutes = (defaultWorkingInterval.value.inMinutes % 60).toString().padLeft(2, '0');
    final formattedTime = '$hours:$minutes';
    return formattedTime;
  }

  validateSelectedInterval(BuildContext context, Duration initialTimerDuration, wasConfirmed) async {
    if (!(_internalWorkingIntervalWorker?.disposed ?? true)) {
      _ignoreDebouncer = true;
    }
    final selectedInterval = defaultWorkingInterval.value;
    final isLessThenMinimal = selectedInterval < WorkDayModel.minimalDayDuration;
    final isMoreThenMaximal = selectedInterval > WorkDayModel.maximalDayDuration;
    if (!isLessThenMinimal && !isMoreThenMaximal && wasConfirmed) {
      showIOSLoadingOverlay(context);
      await WorkDayService.to.storeNewDefaultWorkingHours(defaultWorkingInterval.value);
      await hideIOSLoadingOverlay();
      return;
    }
    defaultWorkingInterval.value = initialTimerDuration;
    if (!wasConfirmed) return;
    showIOSAlertDialog(
      context,
      message: 'Working interval must be between 2 - 14 hours',
      title: 'Selected interval was not allowed',
    );
  }
}
