import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<void> signInAnonymously();
  
  Future<String> signIn(String email, String password);

  Future<String> signUp(String name, String email, String password);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<void> sendPasswordResetEmail(String email);  
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print('signed in anonymously');
    } catch (e) {
      print(e); 
    }
  }  

  @override
  Future<String> signIn(String email, String password) async {
    final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    final User user = result.user;
    return user.uid;
  }

  @override
  Future<String> signUp(String name, String email, String password) async {
    final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final User user = result.user;
    return user.uid;
  }

  @override
  Future<User> getCurrentUser() async {
    final User user = _firebaseAuth.currentUser;
    return user;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    final User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }  
}
