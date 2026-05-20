import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/grade_provider.dart';
import '../providers/task_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch grades if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final grades = context.read<GradeProvider>();
      if (grades.grades.isEmpty && auth.currentUser != null) {
        grades.fetchGrades(auth.currentUser!.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final grades = context.watch<GradeProvider>();
    final tasks = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await grades.fetchGrades(user.email);
            }
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Greeting & Custom Gradient Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [theme.colorScheme.primary, theme.colorScheme.primaryContainer]
                        : [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Semi-transparent graduation cap icon on background
                    Positioned(
                      right: -10,
                      bottom: -20,
                      child: Icon(
                        Icons.school_rounded,
                        size: 110,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.name ?? "Student",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.course ?? "Academic Program",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section Header: Overview
              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Horizontal Metric Cards Grid (Row with Expanded)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Subjects',
                      value: grades.isLoading ? '...' : grades.grades.length.toString(),
                      icon: Icons.menu_book_rounded,
                      iconColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Average',
                      value: grades.isLoading ? '...' : grades.averageGrade.toStringAsFixed(1),
                      icon: Icons.insights_rounded,
                      iconColor: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'Pending',
                      value: tasks.pendingCount.toString(),
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Upcoming Tasks Quick Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Tasks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Render top 2 pending tasks
              if (tasks.pendingTasks.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 40,
                          color: theme.colorScheme.tertiary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'All tasks completed!',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enjoy your free time.',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...tasks.pendingTasks.take(2).map((task) {
                  final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: theme.colorScheme.tertiary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onChanged: (val) {
                          tasks.toggleTaskCompletion(task.id);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: isOverdue ? Colors.red : theme.colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueDate(task.dueDate),
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              // Academic Performance Greeting Banner
              if (!grades.isLoading && grades.grades.isNotEmpty)
                _buildGradeBanner(context, grades.averageGrade),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeBanner(BuildContext context, double avg) {
    final theme = Theme.of(context);
    String title = "Solid Progress!";
    String subtitle = "Keep pushing to increase your GPA.";
    IconData icon = Icons.thumb_up_alt_rounded;
    Color bannerColor = theme.colorScheme.tertiary;

    if (avg >= 90) {
      title = "Dean's List Tier!";
      subtitle = "Outstanding performance, AJ! Keep it up.";
      icon = Icons.verified_rounded;
      bannerColor = theme.colorScheme.tertiary;
    } else if (avg >= 80) {
      title = "Great Academic Standing!";
      subtitle = "You are doing amazing. Stay focused!";
      icon = Icons.stars_rounded;
      bannerColor = theme.colorScheme.primary;
    } else if (avg < 75) {
      title = "Needs Improvement";
      subtitle = "Try to review weak spots and complete pending tasks.";
      icon = Icons.warning_amber_rounded;
      bannerColor = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bannerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: bannerColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: bannerColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return "Due Today";
    } else if (difference.inDays == 1) {
      return "Due Tomorrow";
    } else if (difference.inDays < 0) {
      return "Overdue";
    } else {
      return "Due in ${difference.inDays} days";
    }
  }
}
