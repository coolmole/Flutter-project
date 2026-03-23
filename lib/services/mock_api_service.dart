import 'dart:convert';
import '../models/grade.dart';
import '../models/user.dart';

class MockApiService {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<User> login(String email, String password) async {
    await _delay();
    if (email == 'student@example.com' && password == '123456') {
      // Mock successful login
      return User(
        email: email,
        name: "Juan Dela Cruz",
        course: "B.S. Computer Science",
      );
    }
    throw Exception("Invalid credentials. Use student@example.com / 123456");
  }

  Future<List<Grade>> fetchGrades(String email) async {
    await _delay();
    
    // Mock response payload from instructions
    const String mockResponse = '''
    {
      "student_name": "Juan Dela Cruz",
      "subjects": [
        {
          "name": "ITC 130 - Platform Technologies",
          "grades": { "attendance": 95, "quizzes": 88, "exam": 90, "activities": 92, "projects": 94 }
        },
        {
          "name": "CS 211 - Data Structures & Algorithms",
          "grades": { "attendance": 90, "quizzes": 82, "exam": 78, "activities": 85, "projects": 88 }
        },
        {
          "name": "MATH 201 - Discrete Mathematics",
          "grades": { "attendance": 88, "quizzes": 75, "exam": 80, "activities": 79, "projects": 83 }
        },
        {
          "name": "CS 212 - Object-Oriented Programming",
          "grades": { "attendance": 92, "quizzes": 90, "exam": 87, "activities": 93, "projects": 96 }
        },
        {
          "name": "GE 105 - Purposive Communication",
          "grades": { "attendance": 98, "quizzes": 91, "exam": 85, "activities": 89, "projects": 90 }
        },
        {
          "name": "PE 3 - Physical Education 3",
          "grades": { "attendance": 100, "quizzes": 95, "exam": 92, "activities": 97, "projects": 93 }
        },
        {
          "name": "CS 213 - Computer Organization",
          "grades": { "attendance": 85, "quizzes": 78, "exam": 72, "activities": 80, "projects": 82 }
        },
        {
          "name": "IT 214 - Information Management",
          "grades": { "attendance": 93, "quizzes": 86, "exam": 84, "activities": 88, "projects": 91 }
        }
      ]
    }
    ''';

    final Map<String, dynamic> data = jsonDecode(mockResponse);
    final List<dynamic> subjectsData = data['subjects'];
    
    return subjectsData.map((e) => Grade.fromJson(e)).toList();
  }
}
