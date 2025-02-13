import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../authentication/models/signup_model.dart';

class DatabaseService {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('signup');

  Future<int> getNextId() async {
    try {
      QuerySnapshot querySnapshot =
          await _userCollection.orderBy('id', descending: true).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        int lastId = int.parse(querySnapshot.docs.first['id']);
        return lastId + 1;
      } else {
        return 1;
      }
    } catch (e) {
      print("Error getting next ID: $e");
      return 1;
    }
  }

  Future<SignupModel?> getUserByEmail(String email) async {
    QuerySnapshot querySnapshot =
        await _userCollection.where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      return SignupModel.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> addSignUp(SignupModel signup) {
    return _userCollection.doc(signup.id).set(signup.toJson());
  }

  Future<void> updateUserProfile(
      String userId, String imageUrl, String bio) async {
    await _userCollection.doc(userId).update({
      'imageUrl': imageUrl,
      'bio': bio,
    });
  }

  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<SignupModel?> getUser(String userId) async {
    DocumentSnapshot doc = await _userCollection.doc(userId).get();
    if (doc.exists) {
      return SignupModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
