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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshGrades() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      await context.read<GradeProvider>().fetchGrades(auth.currentUser!.email);
    }
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return const Color(0xFF10B981); // Emerald
    if (grade >= 75) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String _getGradeStatus(double grade) {
    if (grade >= 90) return 'Passed';
    if (grade >= 75) return 'Passed';
    return 'Failed';
  }

  @override
  Widget build(BuildContext context) {
    final gradeProvider = context.watch<GradeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredGrades = gradeProvider.grades.where((grade) {
      return grade.subject.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: isDark ? theme.colorScheme.surface : Colors.white,
                ),
              ),
            ),
            
            // Grades List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshGrades,
                child: Builder(
                  builder: (context) {
                    if (gradeProvider.isLoading && gradeProvider.grades.isEmpty) {
                      return _buildShimmerLoading();
                    }

                    if (gradeProvider.error != null && gradeProvider.grades.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              gradeProvider.error!,
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }

                    if (gradeProvider.grades.isEmpty) {
                      return const Center(
                        child: Text("No subjects available.", style: TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }

                    if (filteredGrades.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No matching subjects found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredGrades.length,
                      itemBuilder: (context, index) {
                        final grade = filteredGrades[index];
                        final color = _getGradeColor(grade.finalGrade);
                        final status = _getGradeStatus(grade.finalGrade);

                        // Split code from subject name if possible
                        final parts = grade.subject.split(' - ');
                        final subjectCode = parts.isNotEmpty ? parts[0] : "";
                        final subjectTitle = parts.length > 1 ? parts[1] : grade.subject;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark
                                  ? theme.colorScheme.outline
                                  : theme.colorScheme.outline.withOpacity(0.6),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubjectDetailScreen(grade: grade),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Leading Icon with theme background
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Subject Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (subjectCode.isNotEmpty)
                                          Text(
                                            subjectCode,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          subjectTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Grade Badge (pill style)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: color.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          grade.finalGrade.toStringAsFixed(1),
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: theme.colorScheme.onSurface.withOpacity(0.35),
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
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? theme.colorScheme.outline : theme.colorScheme.outline.withOpacity(0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Shimmer Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Shimmer Text Lines
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Shimmer Badge
                Container(
                  width: 50,
                  height: 45,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
