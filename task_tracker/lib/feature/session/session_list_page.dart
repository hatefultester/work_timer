import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionListPage extends StatelessWidget {
  const SessionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SessionListPageController>(
      init: SessionListPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('SessionListPage'),
          ),
        );
      },
    );
  }
}

class SessionListPageController extends GetxController {


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
