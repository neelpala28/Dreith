import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService {
  Future<UserModel?> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    }
    return null;
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Add to current user's following subcollection
      final followingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      batch.set(followingRef, {'followedAt': FieldValue.serverTimestamp()});

      // Add to target user's followers subcollection
      final followerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);

      batch.set(followerRef, {'followedAt': FieldValue.serverTimestamp()});

      // Update current user's following count (writing to own doc - allowed!)
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
        'following': FieldValue.arrayUnion([targetUserId]),
      });

      //Update Target user's follwers count
      final targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'followersCount': FieldValue.increment(1),
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      await batch.commit();
      debugPrint('user $currentUserId followed $targetUserId');
    } catch (e) {
      debugPrint('something went wrong: $e');
    }
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Remove from current user's following subcollection
      final followingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);

      batch.delete(followingRef);

      // Remove from target user's followers subcollection
      final followerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);

      batch.delete(followerRef);

      // Update current user's following count
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
        'following': FieldValue.arrayRemove([targetUserId]),
      });

      //Update Target user's follwers count
      final targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'followersCount': FieldValue.increment(-1),
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      await batch.commit();
      debugPrint('user $currentUserId unfollowed $targetUserId');
    } catch (e) {
      debugPrint('something went wrong: $e');
    }
  }
}
