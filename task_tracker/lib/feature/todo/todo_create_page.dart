import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoCreatePage extends StatelessWidget {
  const TodoCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoCreatePageController>(
      init: TodoCreatePageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('TodoCreatePage'),
          ),
        );
      },
    );
  }
}

class TodoCreatePageController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
