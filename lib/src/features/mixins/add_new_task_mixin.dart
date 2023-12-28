import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/ui_kit/ios/ios_bottom_button_component.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';
import '../../ui_kit/shared/gap.dart';

mixin AddNewTaskMixin on GetxController {
  String? get workDayId;

  Rxn<List<TaskModel>> get workDayTasks;

  void updateTasks(List<TaskModel> newWorkDayTasks);

  void addNewTaskAction(BuildContext context) {
    final initialTask = TaskModel.empty(workDayId);
    showIOSCreationBottomSheet<TaskModel>(
      context,
      initialValue: initialTask,
      onClosed: (context, original, newTask) async {
        Focus.maybeOf(context)?.unfocus();
        if (newTask != null) {
          // updateTasks(newTasks);
          showIOSLoadingOverlay(context);
          TaskService.to.createNewTask(newTask);
          await hideIOSLoadingOverlay();
        }
      },
      view: SizedBox(
        child: GetBuilder<IOSCreateNewTaskController>(
            init: IOSCreateNewTaskController(initialTask),
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task name',
                    ),
                    CupertinoTextField(
                      onChanged: controller.nameChanged,
                      textInputAction: TextInputAction.next,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1), // changes position of shadow
                          ),
                        ],
                        shape: BoxShape.rectangle,
                      ),
                      focusNode: controller.taskNameControllerFocusNode,
                      controller: controller.taskNameController,
                    ),
                    Gap.v16,
                    Text(
                      'Task description',
                    ),
                    CupertinoTextField(
                      maxLines: 3,
                      minLines: 3,
                      onChanged: controller.descriptionChanged,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1), // changes position of shadow
                          ),
                        ],
                        shape: BoxShape.rectangle,
                      ),
                      textInputAction: TextInputAction.done,
                      controller: controller.taskDescriptionController,
                    ),
                    Gap.v32,
                    IOSBottomButtonComponent(label: const Text('Create new task'), callback: controller.saveToggled)
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class IOSCreateNewTaskController extends GetxController {
  IOSCreateNewTaskController(this.model);

  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();

  final FocusNode taskNameControllerFocusNode = FocusNode();

  TaskModel? model;

  @override
  void onInit() {
    super.onInit();
    taskNameController.text = model?.name ?? '';
    taskDescriptionController.text = model?.description ?? '';

    taskNameControllerFocusNode.requestFocus();
  }

  @override
  void onClose() {
    taskNameControllerFocusNode.dispose();
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.onClose();
  }

  void saveToggled(BuildContext context) {
    Navigator.of(context).pop(model);
  }

  void descriptionChanged(String value) {
    model = model?.changeDescription(value);
  }

  void nameChanged(String value) {
    model = model?.changeName(value);
  }
}
