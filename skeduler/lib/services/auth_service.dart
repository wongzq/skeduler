import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeduler/models/firestore/user.dart';

class AuthService {
  final FirebaseAuth _authService = FirebaseAuth.instance;

  // Stream: authentication - change user
  Stream<AuthUser> get user {
    return _authService.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // create user object based on FirebaseUser
  AuthUser _userFromFirebaseUser(FirebaseUser firebaseUser) {
    return firebaseUser != null
        ? AuthUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
          )
        : null;
  }

  // Function: log in with email & password
  // returns User if successful
  // returns null if unsuccessful
  Future<String> logInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } catch (e) {
      switch (e.code) {
        case 'ERROR_INVALID_EMAIL':
          return 'Email address is invalid';
          break;
        case 'ERROR_WRONG_PASSWORD':
          return 'Password is incorrect';
          break;
        case 'ERROR_USER_NOT_FOUND':
          return 'Email address is invalid';
          break;
        case 'ERROR_USER_DISABLED':
          return 'This account has been disabled';
          break;
        case 'ERROR_TOO_MANY_REQUESTS':
          return 'Too many requests, please try again later';
          break;
        case 'ERROR_OPERATION_NOT_ALLOWED':
          return 'Operation not allowed';
          break;
        default:
          return 'Log in error';
      }
    }
  }

  // Function: sign up with email & password
  // returns User if successful
  // returns null if unsuccessful
  Future<String> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _authService.createUserWithEmailAndPassword(
          email: email, password: password);

      return null;
    } catch (e) {
      switch (e.code) {
        case 'ERROR_WEAK_PASSWORD':
          return 'Password is not secure enough';
          break;
        case 'ERROR_INVALID_EMAIL':
          return 'Email address is invalid';
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          return 'Email is already in use';
          break;
        default:
          return 'Sign up error';
      }
    }
  }

  Future logOut() async {
    try {
      return await _authService.signOut();
    } catch (e) {
      return null;
    }
  }
}
