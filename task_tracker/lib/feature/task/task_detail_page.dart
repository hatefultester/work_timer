import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskDetailPageController>(
      init: TaskDetailPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('TaskDetailPage'),
          ),
        );
      },
    );
  }
}

class TaskDetailPageController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
