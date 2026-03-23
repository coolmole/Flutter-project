import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/grade_provider.dart';
import 'subject_detail_screen.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final grades = context.read<GradeProvider>();
      if (grades.grades.isEmpty && auth.currentUser != null) {
        grades.fetchGrades(auth.currentUser!.email);
      }
    });
  }

  Future<void> _refreshGrades() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      await context.read<GradeProvider>().fetchGrades(auth.currentUser!.email);
    }
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green.shade600;
    if (grade >= 75) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final gradeProvider = context.watch<GradeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshGrades,
          child: Builder(
            builder: (context) {
              if (gradeProvider.isLoading && gradeProvider.grades.isEmpty) {
                return _buildShimmerLoading();
              }

              if (gradeProvider.error != null && gradeProvider.grades.isEmpty) {
                return Center(
                  child: Text(
                    gradeProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (gradeProvider.grades.isEmpty) {
                return const Center(child: Text("No subjects available."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gradeProvider.grades.length,
                itemBuilder: (context, index) {
                  final grade = gradeProvider.grades[index];
                  final color = _getGradeColor(grade.finalGrade);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Theme.of(context).cardColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: color.withOpacity(0.3), width: 1),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SubjectDetailScreen(grade: grade),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                grade.subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                grade.finalGrade.toStringAsFixed(1),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            title: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withAlpha(51),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            trailing: Container(
              height: 30,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withAlpha(51),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        );
      },
    );
  }
}
