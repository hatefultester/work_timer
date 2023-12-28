import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/features/views/ios_today_view.dart';

import '../../data/models/task_model.dart';
import '../../ui_kit/shared/gap.dart';

class IOSTaskListView extends StatelessWidget {
  const IOSTaskListView({super.key, required this.tasks});

  final Rxn<List<TaskModel>> tasks;

  IOSTodayController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final taskList = tasks.value;
      if (taskList == null || taskList.isEmpty) {
        return const Center(
          child: Text('No tasks'),
        );
      }
      return ListView.separated(
        separatorBuilder: (context, index) => Gap.v8,
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          final task = taskList[index];
          if (task.name.isEmpty && task.description.isEmpty) {
            return const SizedBox.shrink();
          }
          return CupertinoListTile.notched(
            title: Text(task.name),
            subtitle: Text(task.description),
            backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
            backgroundColorActivated: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () =>  controller.onTaskTap(task),
            trailing: task.isCompleted ? Icon(CupertinoIcons.check_mark_circled_solid) : null,
          );
        },
      );
    });
  }
}
