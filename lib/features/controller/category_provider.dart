import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _firestore
        .collection('categories')
        .where('userId',
            isEqualTo: userId) // Fetch categories for the logged-in user
        .get();

    _categories = snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'emoji': doc['emoji'] ?? '',
            })
        .toList();
    notifyListeners();
  }

  Future<void> addCategory(String name, String emoji) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('categories').add({
      'userId': userId, // Store category under the user's ID
      'name': name,
      'emoji': emoji,
    });
    fetchCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
    _categories.removeWhere((category) => category['id'] == categoryId);
    notifyListeners();
  }
}
