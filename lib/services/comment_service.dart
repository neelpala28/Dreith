import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentService {
  static Future<void> addComment({
    required String postId,
    required String userId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userSnap.exists) return;

    final userData = userSnap.data()!;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': userId,
      'text': text.trim(),
      'username': userData['name'],
      'userImage': userData['profileImage'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({
      'commentsCount': FieldValue.increment(1),
    });
  }
static Future<void> deleteComment({
  required String postId,
  required String commentId,
}) async {
  try {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(postId);

    // delete comment
    await postRef
        .collection('comments')
        .doc(commentId)
        .delete();

    // decrement comment count
    await postRef.update({
      'commentsCount': FieldValue.increment(-1),
    });
  } catch (e) {
    debugPrint('Error deleting comment: $e');
  }
}
}