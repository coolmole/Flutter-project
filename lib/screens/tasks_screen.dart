import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

void showTaskFormSheet(BuildContext context, {TaskItem? task}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  void _handleDelete(BuildContext context, TaskItem task) {
    final provider = context.read<TaskProvider>();
    provider.deleteTask(task.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '"${task.title}" moved to Trash',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
          scrolledUnderElevation: 0,
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),
            indicatorColor: theme.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pending'),
                    if (pending.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          pending.length.toString(),
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Completed'),
                    if (completed.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          completed.length.toString(),
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.tertiary, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Trash'),
                    if (recentlyDeleted.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          recentlyDeleted.length.toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Pending Tab
              _buildTaskListTab(
                context,
                tasksList: pending,
                emptyWidget: _buildEmptyState(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'All caught up!',
                  subtitle: 'You have no pending tasks. Enjoy your day!',
                  color: theme.colorScheme.primary,
                ),
                onDelete: _handleDelete,
              ),

              // Completed Tab
              _buildTaskListTab(
                context,
                tasksList: completed,
                emptyWidget: _buildEmptyState(
                  context,
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'No completed tasks',
                  subtitle: 'Start checking off tasks to see them here!',
                  color: theme.colorScheme.tertiary,
                ),
                onDelete: _handleDelete,
              ),

              // Trash Tab
              _buildTrashTab(
                context,
                trashList: recentlyDeleted,
                theme: theme,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showTaskFormSheet(context),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTaskListTab(
    BuildContext context, {
    required List<TaskItem> tasksList,
    required Widget emptyWidget,
    required Function(BuildContext, TaskItem) onDelete,
  }) {
    if (tasksList.isEmpty) return emptyWidget;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: tasksList.length,
      itemBuilder: (context, index) {
        final task = tasksList[index];
        return _TaskCard(
          task: task,
          key: ValueKey(task.id),
          onDelete: () => onDelete(context, task),
        );
      },
    );
  }

  Widget _buildTrashTab(
    BuildContext context, {
    required List<TaskItem> trashList,
    required ThemeData theme,
  }) {
    if (trashList.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.delete_outline_rounded,
        title: 'Trash is empty',
        subtitle: 'Deleted tasks will appear here for recovery.',
        color: theme.colorScheme.onSurface.withOpacity(0.35),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temporarily Saved Tasks',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Empty Trash?'),
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
                            'Empty Trash',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_forever_rounded, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: trashList.length,
            itemBuilder: (context, index) {
              final task = trashList[index];
              return _DeletedTaskCard(
                task: task,
                key: ValueKey('deleted_${task.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 54, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onDelete;

  const _TaskCard({super.key, required this.task, required this.onDelete});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.015))
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: task.isCompleted
                  ? theme.colorScheme.outline.withOpacity(0.3)
                  : (isOverdue ? Colors.red.withOpacity(0.2) : theme.colorScheme.outline.withOpacity(0.6)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark || task.isCompleted ? 0.0 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => showTaskFormSheet(context, task: task),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: InkWell(
              onTap: () {
                _animController.forward().then((_) {
                  context.read<TaskProvider>().toggleTaskCompletion(task.id);
                  _animController.reverse();
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: task.isCompleted ? theme.colorScheme.tertiary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.isCompleted ? theme.colorScheme.tertiary : theme.colorScheme.onSurface.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? theme.colorScheme.onSurface.withOpacity(0.4)
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty && task.description != "No description provided.") ...[
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: isOverdue ? Colors.red : theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(task.dueDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverdue ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.55),
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withOpacity(0.8), size: 22),
              onPressed: () {
                _animController.forward().then((_) {
                  widget.onDelete();
                  _animController.reverse();
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DeletedTaskCard extends StatelessWidget {
  final TaskItem task;

  const _DeletedTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deletedAgo = task.deletedAt != null
        ? _formatTimeAgo(DateTime.now().difference(task.deletedAt!))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color?.withOpacity(0.5) ?? theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.history_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        subtitle: Text(
          'Deleted $deletedAgo',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.35),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.restore_rounded, size: 20, color: theme.colorScheme.tertiary),
              tooltip: 'Restore',
              onPressed: () {
                context.read<TaskProvider>().restoreTask(task.id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${task.title}" restored'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: theme.colorScheme.tertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, size: 20, color: Colors.redAccent),
              tooltip: 'Permanently delete',
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
                        child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.task != null ? 'Edit Task' : 'Create New Task',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            autofocus: widget.task == null,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 18),
          
          // Date & Time Picker Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Time',
                                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: isKeyboardOpen ? 12 : 12),
        ],
      ),
    );
  }
}
