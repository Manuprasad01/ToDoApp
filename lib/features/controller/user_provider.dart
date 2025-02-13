import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  File? _imageFile;
  String _bio = "";
  String _name = "";
  String _location = "";

  File? get imageFile => _imageFile;
  String get bio => _bio;
  String get name => _name;
  String get location => _location;

  void updateUserProfile(File? image, String newBio, String newName, String newLocation) {
    _imageFile = image;
    _bio = newBio;
    _name = newName;
    _location = newLocation;
    notifyListeners();
  }

  void updateProfileImage(File? image) {
    _imageFile = image;
    notifyListeners();
  }
}
