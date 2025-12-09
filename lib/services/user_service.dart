import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String userId,
    required String name,
    required String email,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profileImage': profileImage,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user document
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  // Update user document
  Future<void> updateUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  // Update user profile image
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  // Stream user document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserDocument(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // Delete user document
  Future<void> deleteUserDocument(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user document: $e');
    }
  }
}
