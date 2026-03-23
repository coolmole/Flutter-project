import 'package:flutter/material.dart';
import '../models/grade.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Grade grade;

  const SubjectDetailScreen({super.key, required this.grade});

  Color _getCategoryColor(double score) {
    if (score >= 90) return Colors.green.shade600;
    if (score >= 75) return Colors.orange.shade600;
    return Colors.red.shade600;
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
    final finalColor = _getCategoryColor(grade.finalGrade);

    return Scaffold(
      appBar: AppBar(
        title: Text(grade.subject),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Final Grade Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  finalColor.withOpacity(0.15),
                  finalColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: finalColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Final Grade',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  grade.finalGrade.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: finalColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: finalColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCategoryRemark(grade.finalGrade),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: finalColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Grade Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Category cards
          _buildCategoryCard(context, 'Attendance', grade.attendance,
              Icons.event_available_rounded),
          _buildCategoryCard(
              context, 'Quizzes', grade.quizzes, Icons.quiz_rounded),
          _buildCategoryCard(
              context, 'Exam', grade.exam, Icons.assignment_rounded),
          _buildCategoryCard(
              context, 'Activities', grade.activities, Icons.extension_rounded),
          _buildCategoryCard(context, 'Projects', grade.projects,
              Icons.folder_special_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String label, double score, IconData icon) {
    final color = _getCategoryColor(score);
    final remark = _getCategoryRemark(score);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
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
                    color: color.withOpacity(0.1),
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
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  score.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                remark,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
