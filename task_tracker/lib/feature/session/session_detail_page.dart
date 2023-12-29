import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SessionDetailPageController>(
      init: SessionDetailPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('SessionDetailPage'),
          ),
        );
      },
    );
  }
}

class SessionDetailPageController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
