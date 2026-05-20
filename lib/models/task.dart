import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  bool isCompleted;
  final DateTime? deletedAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.deletedAt,
  });

  factory TaskItem.fromMap(Map<String, dynamic> data, String id) {
    return TaskItem(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: _parseTimestamp(data['dueDate']),
      isCompleted: data['isCompleted'] ?? false,
      deletedAt: data['deletedAt'] != null ? _parseTimestamp(data['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? deletedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
