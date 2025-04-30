import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Dummy users for testing
  final Map<String, Map<String, dynamic>> _dummyUsers = {
    "test@example.com": {
      "password": "password123",
      "name": "Test User"
    },
    "user@example.com": {
      "password": "password456",
      "name": "Demo User"
    }
  };

  String? _currentUserEmail;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _currentUserEmail != null;

  // Add a callback to notify when a user logs in
  VoidCallback? onUserLogin;

  // Sign in with email and password (dummy)
  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (_dummyUsers.containsKey(email) && _dummyUsers[email]!['password'] == password) {
      _currentUserEmail = email;
      if (onUserLogin != null) onUserLogin!();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Create user with email and password (dummy)
  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (_dummyUsers.containsKey(email)) {
      return false; // User already exists
    }
    _dummyUsers[email] = {"password": password, "name": "New User"};
    _currentUserEmail = email;
    if (onUserLogin != null) onUserLogin!();
    notifyListeners();
    return true;
  }

  // Sign in with Google (dummy)
  Future<bool> signInWithGoogle() async {
    // Always fail for dummy
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    _currentUserEmail = null;
    await _secureStorage.deleteAll();
    notifyListeners();
  }

  // Store user info securely (dummy)
  Future<void> _storeUserInfo(String? email) async {
    if (email != null) {
      await _secureStorage.write(key: 'email', value: email);
    }
  }

  // Get user info (dummy)
  Future<Map<String, String?>> getUserInfo() async {
    return {
      'email': _currentUserEmail,
      'displayName': _currentUserEmail != null ? _dummyUsers[_currentUserEmail]!['name'] : null,
    };
  }
}
