import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectDetailPageController>(
      init: ProjectDetailPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('ProjectDetailPage'),
          ),
        );
      },
    );
  }
}

class ProjectDetailPageController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
