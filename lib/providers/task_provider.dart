import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<TaskItem> _tasks = [
    TaskItem(
      id: "1",
      title: "Complete Flutter Assignment",
      description: "Implement the login and dashboard screens with animations.",
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    TaskItem(
      id: "2",
      title: "Study for Math Quiz",
      description: "Review chapters 4 and 5.",
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  List<TaskItem> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskItem> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<TaskItem> get allTasks => _tasks;

  int get pendingCount => pendingTasks.length;

  void addTask(TaskItem task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(TaskItem updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
    }
  }
}
