import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskCreatePage extends StatelessWidget {
  const TaskCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskCreatePageController>(
      init: TaskCreatePageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('TaskCreatePage'),
          ),
        );
      },
    );
  }
}

class TaskCreatePageController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
