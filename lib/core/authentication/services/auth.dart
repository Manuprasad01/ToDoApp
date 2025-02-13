import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //save user info in seperate doc
      _firestore
          .collection('Users')
          .doc(credential.user!.uid)
          .set({'uid': credential.user!.uid, 'email': email});

      return credential.user;
    } catch (e) {
      print('Error occured');
    }
    return null;
  }

   Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // UserCredential credential = await _firebaseAuth
      //     .signInWithEmailAndPassword(email: email, password: password);
      UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      //save user info in seperate doc
      _firestore
          .collection('Users')
          .doc(credential.user!.uid)
          .set({'uid': credential.user!.uid, 'email': email});
      return credential.user;
    } catch (e) {
      print('Error occured');
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}