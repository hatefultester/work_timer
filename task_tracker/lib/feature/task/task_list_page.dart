import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskListPageController>(
      init: TaskListPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('TaskListPage'),
          ),
        );
      },
    );
  }
}

class TaskListPageController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
