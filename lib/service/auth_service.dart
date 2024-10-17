import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.message}');
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();

      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      print('Logout failed: ${e.message}');
    }
  }

  User getCurrentUser() {
    return _auth.currentUser!;
  }
}
