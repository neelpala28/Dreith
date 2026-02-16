import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  void followUser(String currentUserId, String targetUserId) async {
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
      final currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
        'following': FieldValue.arrayUnion([targetUserId]),
      });

      //Update Target user's follwers count
      final targetUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId);
      batch.update(targetUserRef, {
        'followersCount': FieldValue.increment(1),
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      await batch.commit();
      print('user $currentUserId followed $targetUserId');
    } catch (e) {
      print('something went wrong: $e');
    }
  }

  void unfollowUser(String currentUserId, String targetUserId) async {
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
      final currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
        'followers': FieldValue.arrayRemove([targetUserId]),
      });

      //Update Target user's follwers count
      final targetUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId);
      batch.update(targetUserRef, {
        'followersCount': FieldValue.increment(-1),
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      await batch.commit();
      print('user $currentUserId unfollowed $targetUserId');
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
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Like
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    }
  }
}
