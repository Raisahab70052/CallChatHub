import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class FirestoreProvider extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save or update a user's profile in Firestore after login/signup.
  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String fcmToken,
  }) async {
    // Derive a display name from the email prefix.
    final String name = email
        .split('@')
        .first
        .replaceAll(RegExp(r'[._-]'), ' ')
        .split(' ')
        .map((String s) =>
            s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
        .join(' ')
        .trim();

    await _db.collection('users').doc(uid).set(
      <String, dynamic>{
        'uid': uid,
        'email': email.toLowerCase(),
        'name': name,
        'isOnline': true,
        'fcmToken': fcmToken,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Update only the FCM token for a user (called on token refresh).
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .update(<String, dynamic>{'fcmToken': token});
    } catch (e) {
      debugPrint('[Firestore] updateFcmToken error: $e');
    }
  }

  /// Set the online/offline status when the user opens or closes the app.
  Future<void> setOnlineStatus(String uid, {required bool isOnline}) async {
    try {
      await _db.collection('users').doc(uid).update(<String, dynamic>{
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[Firestore] setOnlineStatus error: $e');
    }
  }

  /// Real-time stream of all users except the current user.
  Stream<List<UserModel>> streamOtherUsers(String currentUid) {
    return _db
        .collection('users')
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs
          .where((QueryDocumentSnapshot doc) => doc.id != currentUid)
          .map((QueryDocumentSnapshot doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Get a single user document by UID.
  Future<UserModel?> getUser(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('[Firestore] getUser error: $e');
      return null;
    }
  }
}
