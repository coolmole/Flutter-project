class User {
  final String email;
  final String name;
  final String course;

  User({
    required this.email,
    required this.name,
    required this.course,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      name: json['student_name'] ?? json['name'] ?? '',
      course: json['course'] ?? '',
    );
  }
}
