import '../id.dart';
import '../models/project_model.dart';
import '../models/session_model.dart';
import '../models/task_model.dart';
import '../models/todo_model.dart';

extension TaskModelListMapper on List<TaskModel> {
  List<TaskModel> get orderByPriority => this..sort((a, b) => a.priority.compareTo(b.priority));

  List<TaskModel> get orderByCreationTime => this..sort((a, b) => a.creationTime.compareTo(b.creationTime));

  List<TaskModel> get orderByEstimatedTime {
    final tasksWithoutEstimatedTime = this.where((task) => !task.withEstimatedTime).toList();
    final tasksWithEstimatedTime = this.where((task) => task.withEstimatedTime).toList();

    tasksWithEstimatedTime.sort((a, b) => a.estimatedTime!.compareTo(b.estimatedTime!));
    return [...tasksWithEstimatedTime, ...tasksWithoutEstimatedTime];
  }

  List<TaskModel> get orderByCompletionStatus {
    final completedTasks = this.where((task) => task.isCompleted).toList();
    final uncompletedTasks = this.where((task) => !task.isCompleted).toList();
    return [...completedTasks, ...uncompletedTasks];
  }

  List<TaskModel> get completedTasks => where((task) => task.isCompleted).toList();

  List<TaskModel> get uncompletedTasks => where((task) => !task.isCompleted).toList();

  List<TaskModel> get tasksWithEstimatedTime => where((task) => task.withEstimatedTime).toList();

  List<TaskModel> get tasksWithoutEstimatedTime => where((task) => !task.withEstimatedTime).toList();

  List<TaskModel> tasksWithPriority(int priority) => where((task) => task.priority == priority).toList();

  List<TaskModel> tasksWithMinimalPriority(int priority) => where((task) => task.priority >= priority).toList();

  List<TaskModel> tasksWithProjectId(ProjectId projectId) => where((task) => task.projectId == projectId).toList();
}

extension ProjectModelListMapper on List<ProjectModel> {
  List<ProjectModel> get orderByCreationTime => this..sort((a, b) => a.creationTime.compareTo(b.creationTime));

  List<ProjectModel> get orderByProjectPriority => this..sort((a, b) => a.priority.compareTo(b.priority));

  List<ProjectModel> projectsWithPriority(int priority) => where((project) => project.priority == priority).toList();

  List<ProjectModel> projectsWithMinimalPriority(int priority) =>
      where((project) => project.priority >= priority).toList();
}

extension ToDoModelListMapper on List<ToDoModel> {
  List<ToDoModel> get orderByCompletionStatus {
    final completedToDos = this.where((toDo) => toDo.isCompleted).toList();
    final uncompletedToDos = this.where((toDo) => !toDo.isCompleted).toList();
    return [...completedToDos, ...uncompletedToDos];
  }

  List<ToDoModel> get orderByCreationTime => this..sort((a, b) => a.creationTime.compareTo(b.creationTime));

  List<ToDoModel> get completedToDos => where((toDo) => toDo.isCompleted).toList();

  List<ToDoModel> get uncompletedToDos => where((toDo) => !toDo.isCompleted).toList();

  List<ToDoModel> toDosWithTaskId(TaskId taskId) => where((toDo) => toDo.taskId == taskId).toList();
}

extension SessionModelListMapper on List<SessionModel> {
  List<SessionModel> get orderByCreationTime => this..sort((a, b) => a.creationTime.compareTo(b.creationTime));

  List<SessionModel> sessionsWithTaskId(TaskId taskId) => where((session) => session.taskId == taskId).toList();
}