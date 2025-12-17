import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  String cuid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index].data() as Map<String, dynamic>;
              String userId = post['userId'];

              // Always a Timestamp now
              DateTime postTime = post['timestamp'].toDate();
              String getConsistentTimeAgo(DateTime dateTime) {
                final now = DateTime.now();
                final difference = now.difference(dateTime);

                if (difference.inDays >= 365) {
                  // Years ago
                  final years = (difference.inDays / 365).floor();
                  return '$years ${years == 1 ? "year" : "years"} ago';
                } else if (difference.inDays >= 30) {
                  // Months ago (approx 30 days = 1 month)
                  final months = (difference.inDays / 30).floor();
                  return '$months ${months == 1 ? "month" : "months"} ago';
                } else if (difference.inDays >= 7) {
                  // Weeks ago
                  final weeks = (difference.inDays / 7).floor();
                  return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
                } else if (difference.inDays > 0) {
                  // Days ago
                  return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
                } else if (difference.inHours > 0) {
                  // Hours ago
                  return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
                } else if (difference.inMinutes > 0) {
                  // Minutes ago
                  return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
                } else {
                  return 'Just now';
                }
              }

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }
                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            maxRadius:
                                MediaQuery.of(context).size.height * 0.033,
                            backgroundImage: userData['profileImage'] != null
                                ? NetworkImage(userData['profileImage'])
                                : null,
                            child: userData['profileImage'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(userData['name'] ?? 'Unknown'),
                          subtitle: Text(getConsistentTimeAgo(postTime)),

                          trailing: const Icon(Icons.more_vert),
                        ),

                        if (post['imageUrl'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post['imageUrl'],
                              width: double.infinity,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post['postId'])
                                    .collection('likes')
                                    .doc(cuid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  bool isLiked = snapshot.data?.exists ?? false;

                                  return IconButton(
                                    onPressed: () {
                                      UserService().toggleLike(
                                        post['postId'],
                                        cuid,
                                      );
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
                                onPressed: () {},
                                icon: const Icon(Icons.comment_outlined),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share_outlined),
                              ),
                            ],
                          ),
                        ),

                        if (post['caption'] != null)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              post['caption'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
