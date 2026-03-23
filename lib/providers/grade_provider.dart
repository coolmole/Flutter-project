import 'package:flutter/material.dart';
import '../models/grade.dart';
import '../services/mock_api_service.dart';

class GradeProvider with ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  
  List<Grade> _grades = [];
  bool _isLoading = false;
  String? _error;

  List<Grade> get grades => _grades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get averageGrade {
    if (_grades.isEmpty) return 0.0;
    double sum = _grades.fold(0, (prev, element) => prev + element.finalGrade);
    return sum / _grades.length;
  }

  Future<void> fetchGrades(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _grades = await _apiService.fetchGrades(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
