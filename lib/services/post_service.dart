import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
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