
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  File? _imageFile;
  String _bio = "";
  String _name = "";
  String _location = "";
  String? _userId;

  File? get imageFile => _imageFile;
  String get bio => _bio;
  String get name => _name;
  String get location => _location;

  late Box userBox;

  UserProvider() {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    userBox = await Hive.openBox('userBox');
    _loadUserData();
  }

  void _loadUserData() {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) return;

    _name = userBox.get('$_userId-name', defaultValue: '');
    _bio = userBox.get('$_userId-bio', defaultValue: '');
    _location = userBox.get('$_userId-location', defaultValue: '');
    String? imagePath = userBox.get('$_userId-imagePath');

    if (imagePath != null && imagePath.isNotEmpty) {
      _imageFile = File(imagePath);
    }

    notifyListeners();
  }

  Future<void> updateUserProfile(
      File? image, String newBio, String newName, String newLocation) async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) return;

    _imageFile = image;
    _bio = newBio;
    _name = newName;
    _location = newLocation;

    await userBox.put('$_userId-name', _name);
    await userBox.put('$_userId-bio', _bio);
    await userBox.put('$_userId-location', _location);

    if (_imageFile != null) {
      await userBox.put('$_userId-imagePath', _imageFile!.path);
    }

    _loadUserData();
  }

  Future<void> updateProfileImage(File? image) async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) return;

    _imageFile = image;
    if (_imageFile != null) {
      await userBox.put('$_userId-imagePath', _imageFile!.path);
    }

    _loadUserData();
  }

  Future<void> clearUserData() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId == null) return;

    await userBox.delete('$_userId-name');
    await userBox.delete('$_userId-bio');
    await userBox.delete('$_userId-location');
    await userBox.delete('$_userId-imagePath');

    _imageFile = null;
    _bio = "";
    _name = "";
    _location = "";

    notifyListeners();
  }
}
