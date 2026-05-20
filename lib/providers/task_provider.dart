import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  List<TaskItem> _tasks = [];
  final List<TaskItem> _recentlyDeleted = [];

  List<TaskItem> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskItem> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<TaskItem> get allTasks => _tasks;
  List<TaskItem> get recentlyDeletedTasks => List.unmodifiable(_recentlyDeleted);
  int get pendingCount => pendingTasks.length;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference? get _taskCollection => _uid == null
      ? null
      : _firestore.collection('users').doc(_uid).collection('tasks');

  TaskProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadTasks();
      } else {
        _clearCachedTasks();
      }
    });
  }

  void _clearCachedTasks() {
    _tasks.clear();
    _recentlyDeleted.clear();
    notifyListeners();
  }

  // Load tasks from Firestore
  Future<void> loadTasks() async {
    if (_taskCollection == null) return;
    final snapshot = await _taskCollection!.get();
    final docs = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TaskItem.fromMap(data, doc.id);
    }).toList();

    _tasks = docs.where((task) => task.deletedAt == null).toList();
    _recentlyDeleted.clear();
    _recentlyDeleted.addAll(docs.where((task) => task.deletedAt != null));
    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    if (_taskCollection == null) return;
    final doc = await _taskCollection!.add(task.toMap());
    _tasks.add(task.copyWith(id: doc.id));
    notifyListeners();
  }

  Future<void> updateTask(TaskItem updatedTask) async {
    if (_taskCollection == null) return;
    await _taskCollection!.doc(updatedTask.id).update({
      'title': updatedTask.title,
      'description': updatedTask.description,
      'dueDate': updatedTask.dueDate,
      'isCompleted': updatedTask.isCompleted,
    });
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    if (_taskCollection == null) return;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks.removeAt(index);
      final deletedTask = task.copyWith(deletedAt: DateTime.now());
      _recentlyDeleted.insert(0, deletedTask);
      await _taskCollection!.doc(id).update({
        'deletedAt': Timestamp.fromDate(deletedTask.deletedAt!),
      });
      notifyListeners();
    }
  }

  Future<void> restoreTask(String id) async {
    if (_taskCollection == null) return;
    final index = _recentlyDeleted.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _recentlyDeleted.removeAt(index);
      final restored = task.copyWith(deletedAt: null);
      _tasks.add(restored);
      await _taskCollection!.doc(id).update({'deletedAt': null});
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteTask(String id) async {
    if (_taskCollection == null) return;
    _recentlyDeleted.removeWhere((t) => t.id == id);
    await _taskCollection!.doc(id).delete();
    notifyListeners();
  }

  Future<void> clearRecentlyDeleted() async {
    for (final task in _recentlyDeleted) {
      await _taskCollection?.doc(task.id).delete();
    }
    _recentlyDeleted.clear();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (_taskCollection == null) return;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updated = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      _tasks[index] = updated;
      await _taskCollection!.doc(id).update({'isCompleted': updated.isCompleted});
      notifyListeners();
    }
  }
}