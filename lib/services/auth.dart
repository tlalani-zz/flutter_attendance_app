import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_attendance/shared/currentconfig.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  ReConfig _currentConfig;
  static final AuthService _singleton = AuthService._internal();

  factory AuthService() {
    return _singleton;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(authResult.user != null) {
        user = authResult.user;
        return true;
      }
    } catch (e) {
      print(e);
      user = null;
      return false;
    }
  }

  void setConfig(ReConfig config) {
    _currentConfig = config;
  }

  FirebaseUser get currentUser => user;
  String get currentUserId => user.uid;
  ReConfig get currentConfig => _currentConfig;

  Future<void> sendPasswordResetEmail(String email) async {
    await this._auth.sendPasswordResetEmail(email: email);
  }


  AuthService._internal();
}