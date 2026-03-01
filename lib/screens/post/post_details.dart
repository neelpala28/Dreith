import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/services/post_service.dart';
import 'package:dreith/widgets/comments_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetails extends StatefulWidget {
  final String postId; // ✅ PASS POST ID (BEST PRACTICE)

  const PostDetails({super.key, required this.postId});

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final String user = FirebaseAuth.instance.currentUser!.uid;

  // ✅ REALTIME COMMENT STREAM
  Stream<QuerySnapshot> fetchCommentsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) return "${difference.inDays ~/ 365}y ago";
    if (difference.inDays >= 30) return "${difference.inDays ~/ 30}mo ago";
    if (difference.inDays >= 7) return "${difference.inDays ~/ 7}w ago";
    if (difference.inDays >= 1) return "${difference.inDays}d ago";
    if (difference.inHours >= 1) return "${difference.inHours}h ago";
    if (difference.inMinutes >= 1) return "${difference.inMinutes}m ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final postData = snapshot.data!.data() as Map<String, dynamic>;
            final userId = postData['userId'];

            Timestamp ts = postData['timestamp'] ?? Timestamp.now();
            DateTime postTime = ts.toDate();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) return const SizedBox();

                final userData = userSnap.data!.data() as Map<String, dynamic>;

                return ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: BackButton(),
                    ),

                    // ✅ POST HEADER
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userData['profileImage'] != null
                            ? NetworkImage(userData['profileImage'])
                            : null,
                        child: userData['profileImage'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(userData['name'] ?? 'Unknown'),
                      subtitle: Text(getTimeAgo(postTime)),
                    ),

                    // ✅ POST IMAGE
                    if (postData['imageUrl'] != null)
                      Image.network(
                        postData['imageUrl'],
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                    // ✅ ACTION BUTTONS
                    Row(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postId)
                              .collection('likes')
                              .doc(user)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final isLiked = snapshot.data?.exists ?? false;

                            return IconButton(
                              onPressed: () {
                                PostService().toggleLike(widget.postId, user);
                              },
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                            );
                          },
                        ),

                        IconButton(
                          onPressed: _openComments, // ✅ FIXED
                          icon: const Icon(Icons.comment_outlined),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                        ),
                      ],
                    ),

                    // ✅ CAPTION
                    if (postData['caption'] != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          postData['caption'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) => CommentsBottomSheet(postId: widget.postId),
    );
  }
}
