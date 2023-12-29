import 'package:flutter/material.dart';
import 'package:task_tracker/core/infrastructure/service_locator.dart';

import 'feature/project/project_list_page.dart';

void main() {
  ServiceLocator.initializeServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProjectListPage(),
    );
  }
}
