import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionCreatePage extends StatelessWidget {
  const SessionCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SessionCreatePageController>(
      init: SessionCreatePageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('SessionCreatePage'),
          ),
        );
      },
    );
  }
}

class SessionCreatePageController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
