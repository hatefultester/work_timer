import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/extension/work_day_model_extension.dart';
import 'package:work_timer/src/features/views/ios_today_view.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

import '../../data/services/device_service.dart';
import '../../ui_kit/shared/progress_bar_component.dart';

class IOSTimerComponent extends StatelessWidget {
  const IOSTimerComponent({super.key});

  IOSTodayController get controller => Get.find<IOSTodayController>();

  @override
  Widget build(BuildContext context) {
    final deviceWidth = DeviceService.to.deviceWidth(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: deviceWidth / 2),
      child: CupertinoContextMenu.builder(
        enableHapticFeedback: true,
        actions: [
          Obx(() {
            final isRunning = controller.isTimerRunning.value;
            return CupertinoContextMenuAction(
              onPressed: () {
                Navigator.pop(context);
                if (isRunning) {
                  controller.stopTimerAction(context);
                } else {
                  controller.startTimerAction(context);
                }
              },
              isDestructiveAction: isRunning,
              trailingIcon: isRunning ? CupertinoIcons.timer : CupertinoIcons.timer_fill,
              child: Text(isRunning ? 'Stop working' : 'Start working'),
            );
          }),
          CupertinoContextMenuAction(
            onPressed: () {
              Navigator.pop(context);
              controller.changeWorkingHoursAction(context);
            },
            trailingIcon: CupertinoIcons.clock_fill,
            child: const Text('Change working duration'),
          ),
          CupertinoContextMenuAction(
            onPressed: () {
              Navigator.pop(context);
              controller.customizeWorkingHoursTile(context);
            },
            trailingIcon: CupertinoIcons.circle_righthalf_fill,
            child: const Text('Customize'),
          ),
        ],
        builder: (BuildContext context, Animation<double> animation) {
          return Obx(
            () {
              final backgroundColor = controller.workDurationBackgroundTileColor.value;
              final Animation<Decoration> boxDecorationAnimation =
                  controller.boxDecorationAnimation(animation, context, backgroundColor: backgroundColor);

              return DefaultTextStyle(
                style: TextStyle(
                  color: backgroundColor.invertColor().toBlackOrWhite(),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration:
                      animation.value < CupertinoContextMenu.animationOpensAt ? boxDecorationAnimation.value : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Obx(
                      () {
                        final progressColor = controller.workDurationProgressColor.value;
                        final day = controller.workDay.value;
                        final duration = Duration(seconds: day?.workedTimeInSeconds ?? 0);
                        final label = duration.toHMS();
                        return ProgressBarComponent(
                          key: ValueKey([progressColor, backgroundColor]),
                          progressColor: progressColor,
                          backgroundColor: backgroundColor.invertColor().toBlackOrWhite(),
                          percentageNotifier: controller.workedHoursPercentage,
                          label: label,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
