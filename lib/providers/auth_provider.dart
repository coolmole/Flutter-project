import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app;

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  app.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = result.user!.uid;

      // Fetch user data from Firestore
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = app.User(
          id: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? email,
          course: data['course'] ?? '',   // add this
        );
      } else {
         _currentUser = app.User(id: uid, name: '', email: email, course: '');  // add course
}

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}