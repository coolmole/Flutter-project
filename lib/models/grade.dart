class Grade {
  final String subject;
  final double attendance;
  final double quizzes;
  final double exam;
  final double activities;
  final double projects;

  Grade({
    required this.subject,
    required this.attendance,
    required this.quizzes,
    required this.exam,
    required this.activities,
    required this.projects,
  });

  double get finalGrade => (attendance + quizzes + exam + activities + projects) / 5;

  factory Grade.fromJson(Map<String, dynamic> json) {
    final gradesMap = json['grades'] as Map<String, dynamic>;
    return Grade(
      subject: json['name'],
      attendance: (gradesMap['attendance'] as num).toDouble(),
      quizzes: (gradesMap['quizzes'] as num).toDouble(),
      exam: (gradesMap['exam'] as num).toDouble(),
      activities: (gradesMap['activities'] as num).toDouble(),
      projects: (gradesMap['projects'] as num).toDouble(),
    );
  }
}
