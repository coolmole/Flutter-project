import 'package:flutter/material.dart';
import '../models/grade.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Grade grade;

  const SubjectDetailScreen({super.key, required this.grade});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(double score) {
    if (score >= 90) return const Color(0xFF10B981); // Emerald
    if (score >= 75) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String _getCategoryRemark(double score) {
    if (score >= 95) return 'Excellent';
    if (score >= 90) return 'Outstanding';
    if (score >= 85) return 'Very Good';
    if (score >= 80) return 'Good';
    if (score >= 75) return 'Satisfactory';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final finalColor = _getCategoryColor(widget.grade.finalGrade);

    final parts = widget.grade.subject.split(' - ');
    final subjectCode = parts.isNotEmpty ? parts[0] : "";
    final subjectTitle = parts.length > 1 ? parts[1] : widget.grade.subject;

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectCode.isNotEmpty ? subjectCode : 'Subject Details'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Subject Info Banner
            Text(
              subjectTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (subjectCode.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subjectCode,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Radial Gauge Hero Container
            Center(
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final animatedGrade = _progressAnimation.value * widget.grade.finalGrade;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? theme.colorScheme.outline : theme.colorScheme.outline.withOpacity(0.6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Radial Gauge Stack
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 10,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: animatedGrade / 100,
                                  strokeWidth: 10,
                                  strokeCap: StrokeCap.round,
                                  valueColor: AlwaysStoppedAnimation<Color>(finalColor),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    animatedGrade.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'FINAL GRADE',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: finalColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: finalColor.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getCategoryRemark(widget.grade.finalGrade),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: finalColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Section Header
            Text(
              'Grade Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown Cards
            _buildCategoryCard(
              context,
              'Attendance',
              widget.grade.attendance,
              Icons.event_available_rounded,
            ),
            _buildCategoryCard(
              context,
              'Quizzes',
              widget.grade.quizzes,
              Icons.quiz_rounded,
            ),
            _buildCategoryCard(
              context,
              'Exam',
              widget.grade.exam,
              Icons.assignment_rounded,
            ),
            _buildCategoryCard(
              context,
              'Activities',
              widget.grade.activities,
              Icons.extension_rounded,
            ),
            _buildCategoryCard(
              context,
              'Projects',
              widget.grade.projects,
              Icons.folder_special_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String label,
    double score,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getCategoryColor(score);
    final remark = _getCategoryRemark(score);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? theme.colorScheme.outline : theme.colorScheme.outline.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    final animatedScore = _progressAnimation.value * score;
                    return Text(
                      animatedScore.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value * (score / 100),
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight: 20%',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  remark,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
