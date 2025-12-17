import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetails extends StatefulWidget {
  final String postId; // ✅ PASS POST ID (BEST PRACTICE)

  const PostDetails({super.key, required this.postId});

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final TextEditingController _commentController = TextEditingController();
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

  // ✅ ADD COMMENT FUNCTION
  Future<void> comment() async {
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .get();

      if (!userSnap.exists) return;

      final userData = userSnap.data()!;

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
            'userId': user,
            'text': commentText,
            'username': userData['name'],
            'userImage': userData['profileImage'],
            'timestamp': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'commentsCount': FieldValue.increment(1)});

      _commentController.clear();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }

  @override
  void dispose() {
    _commentController.dispose(); // ✅ MEMORY SAFE
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
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                        ),
                        IconButton(
                          onPressed: () => _openComments(),
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

  // ✅ COMMENT BOTTOM SHEET
  void _openComments() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.7, // ✅ FIXED HEIGHT
              child: Column(
                children: [
                  // ✅ DRAG HANDLE
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ✅ COMMENTS LIST (SCROLLABLE)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fetchCommentsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final comments = snapshot.data!.docs;

                        if (comments.isEmpty) {
                          return const Center(
                            child: Text(
                              "No comments yet",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final data =
                                comments[index].data() as Map<String, dynamic>;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: data['userImage'] != null
                                    ? NetworkImage(data['userImage'])
                                    : null,
                                child: data['userImage'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                data['username'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                data['text'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ✅ INPUT FIELD + SEND BUTTON (FIXED, NO OVERFLOW)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Write a comment...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: comment,
                          icon: const Icon(Icons.send, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
