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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await grades.fetchGrades(user.email);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Hello, ${user?.name ?? "Student"}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here is your academic overview.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryCard(
                title: 'Total Subjects',
                value: grades.isLoading ? '...' : grades.grades.length.toString(),
                icon: Icons.book_outlined,
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Average Grade',
                value: grades.isLoading ? '...' : grades.averageGrade.toStringAsFixed(1),
                icon: Icons.bar_chart_outlined,
                color: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                title: 'Pending Tasks',
                value: tasks.pendingCount.toString(),
                icon: Icons.task_alt_outlined,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return _AnimatedSummaryCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
    );
  }
}

class _AnimatedSummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnimatedSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_AnimatedSummaryCard> createState() => _AnimatedSummaryCardState();
}

class _AnimatedSummaryCardState extends State<_AnimatedSummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(_isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 12 : 6,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 32, color: widget.color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
