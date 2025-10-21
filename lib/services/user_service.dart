import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  void followUser(String currentUserId, String targetUserId) async {
    try {
      final targetUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId);

      final currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId);

      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserId]),
        'followersCount': FieldValue.increment(1),
      });

      await currentUserRef.update({
        'following': FieldValue.arrayUnion([targetUserId]),
        'followingCount': FieldValue.increment(1),
      });

      print('user $currentUserId followed $targetUserId');
    } catch (e) {
      print('something went wrong: $e');
    }
  }

  void unfollowUser(String currentUserId, String targetUserId) async {
    try {
      final targetUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId);

      final currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId);

      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserId]),
        'followersCount': FieldValue.increment(-1),
      });

      await currentUserRef.update({
        'following': FieldValue.arrayRemove([targetUserId]),
        'followingCount': FieldValue.increment(-1),
      });

      print('user $currentUserId followed $targetUserId');
    } catch (e) {
      print('something went wrong: $e');
    }
  }

  // ========================
  // Like a Post
  // ========================
  Future<void> toggleLike(String postId, String currentUserId) async {
    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(currentUserId);

    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      // Unlike
      await likeRef.delete();
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'likesCount': FieldValue.increment(-1)});
    } else {
      // Like
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'likesCount': FieldValue.increment(1)});
    }
  }

}
