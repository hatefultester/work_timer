import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/extension/task_model_extensions.dart';
import 'package:work_timer/src/features/views/ios_today_view.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

import '../../data/services/device_service.dart';
import '../../ui_kit/shared/progress_bar_component.dart';

class IOSTaskComponent extends StatelessWidget {
  const IOSTaskComponent({super.key});

  IOSTodayController get controller => Get.find<IOSTodayController>();

  @override
  Widget build(BuildContext context) {
    final deviceWidth = DeviceService.to.deviceWidth(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: deviceWidth / 2),
      child: CupertinoContextMenu.builder(
        enableHapticFeedback: true,
        actions: [
          CupertinoContextMenuAction(
            onPressed: () {
              Navigator.pop(context);
              controller.addNewTaskAction(context);
            },
            trailingIcon: CupertinoIcons.create_solid,
            child: const Text('Add new task'),
          ),
          CupertinoContextMenuAction(
            onPressed: () {
              Navigator.pop(context);
              controller.customizeTasksTile(context);
            },
            trailingIcon: CupertinoIcons.circle_righthalf_fill,
            child: const Text('Customize'),
          ),
        ],
        builder: (BuildContext context, Animation<double> animation) {
          return Obx(
            () {
              final backgroundColor = controller.taskBackgroundTileColor.value;
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
                        final completed = controller.workDayTasks.value?.completedTasks.length ?? 0;
                        final label = '$completed/${controller.workDayTasks.value?.length ?? 0}';
                        return ProgressBarComponent(
                          key: ValueKey([progressColor, backgroundColor]),
                          progressColor: progressColor,
                          backgroundColor: backgroundColor.invertColor().toBlackOrWhite(),
                          percentageNotifier: controller.taskDonePercentage,
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
