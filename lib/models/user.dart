class User {
  final String id;
  final String email;
  final String name;
  final String course;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.course,
  });

  factory User.fromJson(String id, Map<String, dynamic> json) {
    return User(
      id: id,
      email: json['email'] ?? '',
      name: json['student_name'] ?? json['name'] ?? '',
      course: json['course'] ?? '',
    );
  }
}