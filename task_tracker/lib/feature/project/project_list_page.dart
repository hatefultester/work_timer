import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracker/core/domain/models/project_model.dart';
import 'package:task_tracker/core/infrastructure/services/project_service.dart';
import 'package:task_tracker/feature/project/project_create_page.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectListPageController>(
      init: ProjectListPageController(),
      builder: (controller) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('ProjectListPage'),
            ),
            body: Obx(
              () {
                final status = controller.status.value;
                final projects = controller.projects.value;
                return switch (status) {
                  ProjectListPageStatus.loading => const Center(child: CircularProgressIndicator()),
                  ProjectListPageStatus.loaded => Center(child: Text('Loaded ${projects.length}')),
                  ProjectListPageStatus.empty => const Center(child: Text('Empty')),
                };
              },
            ),
            floatingActionButton: Builder(builder: (context) {
              return FloatingActionButton(
                onPressed: () => controller.createNewProject(context),
                child: const Icon(Icons.add),
              );
            }));
      },
    );
  }
}

enum ProjectListPageStatus {
  loading,
  loaded,
  empty;
}

class ProjectListPageController extends GetxController {
  Rx<ProjectListPageStatus> status = ProjectListPageStatus.loading.obs;

  Rx<List<ProjectModel>> get projects => ProjectService.to.cacheObservable;

  late Worker statusChecker;

  @override
  void onInit() {
    statusChecker = ever(ProjectService.to.cacheObservable, _checkStatus);
    super.onInit();
  }

  @override
  void onReady() async {
    await ProjectService.to.fetch();
    super.onReady();
  }

  @override
  void onClose() {
    statusChecker.dispose();
    status.close();
    super.onClose();
  }

  _checkStatus(List<ProjectModel> callback) {
    if (callback.isEmpty) {
      status.value = ProjectListPageStatus.empty;
    } else {
      status.value = ProjectListPageStatus.loaded;
    }
  }

  createNewProject(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectCreatePage()));
  }
}
