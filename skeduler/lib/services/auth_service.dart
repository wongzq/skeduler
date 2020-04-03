import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/services/database_service.dart';

class AuthService {
  final FirebaseAuth _authService = FirebaseAuth.instance;

  /// Stream: authentication - change user
  Stream<AuthUser> get user {
    return _authService.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  /// create user object based on FirebaseUser
  AuthUser _userFromFirebaseUser(FirebaseUser firebaseUser) {
    return firebaseUser != null
        ? AuthUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
          )
        : null;
  }

  /// Function: log in with email & password
  /// returns User if successful
  /// returns null if unsuccessful
  Future logInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _authService.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Function: sign up with email & password
  /// returns User if successful
  /// returns null if unsuccessful
  Future signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      AuthResult result = await _authService.createUserWithEmailAndPassword(
          email: email, password: password);

      /// create a new document for the user with the uid
      await DatabaseService(userId: result.user.uid).setUserData(email, name);

      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future logOut() async {
    try {
      return await _authService.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
