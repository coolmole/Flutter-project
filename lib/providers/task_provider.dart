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

  final List<TaskItem> _recentlyDeleted = [];

  List<TaskItem> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskItem> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<TaskItem> get allTasks => _tasks;
  List<TaskItem> get recentlyDeletedTasks => List.unmodifiable(_recentlyDeleted);

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

  /// Soft-deletes a task: moves it to the recently deleted list.
  void deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks.removeAt(index);
      _recentlyDeleted.insert(0, task.copyWith(deletedAt: DateTime.now()));
      notifyListeners();
    }
  }

  /// Restores a task from the recently deleted list back to active tasks.
  void restoreTask(String id) {
    final index = _recentlyDeleted.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _recentlyDeleted.removeAt(index);
      // Restore with deletedAt cleared
      _tasks.add(task.copyWith(deletedAt: null));
      notifyListeners();
    }
  }

  /// Permanently removes a task from the recently deleted list.
  void permanentlyDeleteTask(String id) {
    _recentlyDeleted.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Clears all recently deleted tasks.
  void clearRecentlyDeleted() {
    _recentlyDeleted.clear();
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
