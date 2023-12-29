import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracker/core/infrastructure/services/project_service.dart';
import 'package:task_tracker/core/presentation/controller.dart';

import '../../core/domain/models/project_model.dart';

class ProjectCreatePage extends StatelessWidget {
  const ProjectCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectCreatePageController>(
      init: ProjectCreatePageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ProjectCreatePage'),
          ),
          body: Column(
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              Obx(
                () => Slider(
                  value: controller.priority.value,
                  onChanged: controller.priorityChanged,
                  divisions: 10,
                ),
              ),
              ElevatedButton(
                onPressed: () => controller.createProject(context),
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProjectCreatePageController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Rx<double> priority = 0.1.obs;

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priority.close();
    super.onClose();
  }

  void priorityChanged(double value) {
    priority.value = value;
  }

  createProject(BuildContext context) async {
    final navigator = Navigator.of(context);
    final projectName = nameController.text;
    final projectDescription = descriptionController.text;
    final projectPriority = (priority.value * 10).toInt();
    d('Creating project with name: $projectName, description: $projectDescription, priority: $projectPriority');
    final model = ProjectModel.create(
      name: projectName,
      description: projectDescription,
      priority: projectPriority,
    );
    await ProjectService.to.create(model);
    navigator.pop();
  }
}
