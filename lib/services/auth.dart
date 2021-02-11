import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_attendance/shared/ReConfig.dart';
import 'package:flutter_attendance/shared/constants/http-constants.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  ReConfig _currentConfig;
  Map<dynamic, dynamic> perms;
  static final AuthService _singleton = AuthService._internal();

  factory AuthService() {
    return _singleton;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(authResult.user != null) {
        user = authResult.user;
        await getPerms();
        return true;
      }
      return false;
    } catch (e) {
      user = null;
    }
  }

  void setConfig(ReConfig config) {
    _currentConfig = config;
  }

  FirebaseUser get currentUser => user;
  String get currentUserId => user.uid;
  Future<IdTokenResult> get userIdToken => user != null ? user.getIdToken(refresh: true) : null;
  ReConfig get currentConfig => _currentConfig;
  set currentConfig(ReConfig config) => _currentConfig = config;


  Future<void> sendPasswordResetEmail(String email) async {
    await this._auth.sendPasswordResetEmail(email: email);
  }

  Future<void> getPerms() async {
    try {
      perms = await HttpConstants.getPermissions();
    } catch(e) {
      perms = null;
    }

  }

  Future<String> getUserToken() async {
    return currentUser != null ? (await currentUser.getIdToken(refresh:true)).token : null;
  }


  AuthService._internal();
}