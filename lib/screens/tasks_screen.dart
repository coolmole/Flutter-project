import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

void showTaskFormSheet(BuildContext context, {TaskItem? task}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TaskFormSheet(task: task),
  );
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showRecentlyDeleted = false;

  void _handleDelete(BuildContext context, TaskItem task) {
    final provider = context.read<TaskProvider>();
    provider.deleteTask(task.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '"${task.title}" deleted',
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () {
            provider.restoreTask(task.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final pending = tasks.pendingTasks;
    final completed = tasks.completedTasks;
    final recentlyDeleted = tasks.recentlyDeletedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pending.isNotEmpty) ...[
              const Text(
                'Pending Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 12),
              ...pending.map((task) => _TaskCard(
                task: task,
                key: ValueKey(task.id),
                onDelete: () => _handleDelete(context, task),
              )),
              const SizedBox(height: 24),
            ],
            if (completed.isNotEmpty) ...[
              const Text(
                'Completed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 12),
              ...completed.map((task) => _TaskCard(
                task: task,
                key: ValueKey(task.id),
                onDelete: () => _handleDelete(context, task),
              )),
              const SizedBox(height: 24),
            ],
            if (pending.isEmpty && completed.isEmpty && recentlyDeleted.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No tasks yet. Enjoy your day!"),
                ),
              ),

            // Recently Deleted Section
            if (recentlyDeleted.isNotEmpty) ...[
              const Divider(height: 32),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() => _showRecentlyDeleted = !_showRecentlyDeleted);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_sweep_outlined,
                        size: 20,
                        color: Colors.redAccent.shade100,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recently Deleted (${recentlyDeleted.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent.shade100,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _showRecentlyDeleted ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          color: Colors.redAccent.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Clear All button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear All?'),
                              content: const Text(
                                'This will permanently remove all recently deleted tasks. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<TaskProvider>().clearRecentlyDeleted();
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text(
                                    'Clear All',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: const Text('Clear All'),
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                      ),
                    ),
                    ...recentlyDeleted.map((task) => _DeletedTaskCard(
                      task: task,
                      key: ValueKey('deleted_${task.id}'),
                    )),
                  ],
                ),
                crossFadeState: _showRecentlyDeleted
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskFormSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onDelete;

  const _TaskCard({super.key, required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());

    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: task.isCompleted ? Theme.of(context).disabledColor.withAlpha(13) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: task.isCompleted
                ? Theme.of(context).dividerColor
                : (isOverdue ? Colors.red.shade200 : Colors.transparent),
          ),
        ),
        child: ListTile(
          onTap: () => showTaskFormSheet(context, task: task),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: InkWell(
            onTap: () {
              context.read<TaskProvider>().toggleTaskCompletion(task.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.isCompleted ? 'Done' : 'Ongoing',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(178),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(178),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}

/// Card for tasks in the "Recently Deleted" section with restore & permanent delete.
class _DeletedTaskCard extends StatelessWidget {
  final TaskItem task;

  const _DeletedTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final deletedAgo = task.deletedAt != null
        ? _formatTimeAgo(DateTime.now().difference(task.deletedAt!))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                color: Colors.redAccent.shade100.withOpacity(0.7),
                size: 20,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).disabledColor.withOpacity(0.6),
              ),
            ),
            subtitle: Text(
              'Deleted $deletedAgo',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).disabledColor.withOpacity(0.4),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: Colors.green.shade400,
                  tooltip: 'Restore',
                  onPressed: () {
                    context.read<TaskProvider>().restoreTask(task.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${task.title}" restored'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green.shade700,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined, size: 20),
                  color: Colors.redAccent.shade100,
                  tooltip: 'Permanently remove',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Permanently?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<TaskProvider>().permanentlyDeleteTask(task.id);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inSeconds < 60) return 'just now';
    if (duration.inMinutes < 60) {
      final m = duration.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (duration.inHours < 24) {
      final h = duration.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    final d = duration.inDays;
    return '$d ${d == 1 ? 'day' : 'days'} ago';
  }
}

class _TaskFormSheet extends StatefulWidget {
  final TaskItem? task;
  
  const _TaskFormSheet({this.task});

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 12, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;
    
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (widget.task != null) {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? "No description provided." : _descriptionController.text.trim(),
        dueDate: finalDateTime,
      );
      context.read<TaskProvider>().updateTask(updatedTask);
    } else {
      final newTask = TaskItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? "No description provided." : _descriptionController.text.trim(),
        dueDate: finalDateTime,
      );
      context.read<TaskProvider>().addTask(newTask);
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.task != null ? 'Edit Task' : 'Add New Task',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: widget.task == null,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save Task'),
          ),
          SizedBox(height: isKeyboardOpen ? 16 : 32),
        ],
      ),
    );
  }
}
