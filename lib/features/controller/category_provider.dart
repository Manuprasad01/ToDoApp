import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    _categories = snapshot.docs.map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'emoji': doc['emoji'] ?? '',
    }).toList();
    notifyListeners();
  }

  Future<void> addCategory(String name, String emoji) async {
    await _firestore.collection('categories').add({
      'name': name,
      'emoji': emoji,
    });
    fetchCategories();
  }
}
