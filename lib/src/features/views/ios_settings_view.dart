import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/features/ios_app.dart';
import 'package:work_timer/src/features/pages/ios_onboarding_page.dart';
import 'package:work_timer/src/data/config/storage.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

import '../../data/models/task_model.dart';
import '../../ui_kit/ios/ios_section_component.dart';

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
              IOSSectionItem<Rx<PriorityEnum>>.popUp(
                label: 'Default task priority',
                onTap: controller.openChangePriorityPopUp,
                informationObserver: controller.defaultTaskPriority,
                informationParser: controller.taskPriorityParser,
                iconData: CupertinoIcons.archivebox,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class IOSSettingsController extends GetxController {
  late RxBool isDarkThemeActive;
  late Rx<Duration> defaultWorkingInterval;
  late Rx<PriorityEnum> defaultTaskPriority;
  late Rx<Duration> _internalWorkingInterval;
  Worker? _internalWorkingIntervalWorker;
  bool _ignoreDebouncer = true;

  @override
  onInit() {
    super.onInit();
    defaultWorkingInterval = const Duration(hours: 8).obs;
    _internalWorkingInterval = const Duration(hours: 8).obs;

    _internalWorkingIntervalWorker = debounce(_internalWorkingInterval, (callback) {
      if (_ignoreDebouncer) return;
      defaultWorkingInterval.value = callback;
    }, time: 50.milliseconds);

    defaultTaskPriority = PriorityEnum.major.obs;
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
        actions: PriorityEnum.values
            .map(
              (e) => IOSActionData(
                label: e.toStringFormatted(),
                isDestructive: e == defaultTaskPriority.value,
              ),
            )
            .toList(), onResultHandler: (result, context) {
      if (result == null) return;
      final parsedFromIndex = PriorityEnum.values[result];
      defaultTaskPriority.value = parsedFromIndex;
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
    final isLessThenMinimal = selectedInterval < const Duration(hours: 2);
    final isMoreThenMaximal = selectedInterval > const Duration(hours: 12);
    if (!isLessThenMinimal && !isMoreThenMaximal && wasConfirmed) {
      // TODO: handle storing
      return;
    }
    defaultWorkingInterval.value = initialTimerDuration;
    if (!wasConfirmed) return;
    showIOSAlertDialog(context,
        message: 'Working interval must be between 2 - 12 hours', title: 'Selected interval was not allowed');
  }
}
