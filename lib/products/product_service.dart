import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_model.dart';
import 'package:flutter/foundation.dart';
class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  String get _uid {
    final user = _auth.currentUser;

    debugPrint('CURRENT USER UID: ${user?.uid}');
    debugPrint('CURRENT USER EMAIL: ${user?.email}');

    if (user == null) {
      throw StateError('Please sign in first.');
    }

    return user.uid;
  }
  Stream<List<Product>> watchProducts() {
    final uid = _uid;

    return _products.where('ownerId', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final products = snapshot.docs.map(Product.fromFirestore).toList();

      products.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return products;
    });
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required int quantity,
  }) async {
    final uid = _uid;

    await _products.add({
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'ownerId': uid,
      'price': price,
      'quantity': quantity,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required Product product,
    required String name,
    required String description,
    required String category,
    required double price,
    required int quantity,
  }) async {
    final uid = _uid;
    final reference = _products.doc(product.id);
    final snapshot = await reference.get();

    if (!snapshot.exists || snapshot.data()?['ownerId'] != uid) {
      throw StateError('You are not allowed to edit this product.');
    }

    await reference.update({
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'price': price,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String id) async {
    final uid = _uid;
    final reference = _products.doc(id);
    final snapshot = await reference.get();

    if (!snapshot.exists || snapshot.data()?['ownerId'] != uid) {
      throw StateError('You are not allowed to delete this product.');
    }

    await reference.delete();
  }
}
