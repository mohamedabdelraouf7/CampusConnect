import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthService {
  User? get currentUser;
  Stream<User?> get authStateChanges;
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  
  // Default constructor uses FirebaseAuth.instance
  FirebaseAuthService() : _auth = FirebaseAuth.instance;
  
  // Constructor for testing that accepts a FirebaseAuth instance
  @visibleForTesting
  FirebaseAuthService.withAuth(this._auth);
  
  @override
  User? get currentUser => _auth.currentUser;
  
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
} 