import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';

class PostDetails extends StatelessWidget {
  final String postImageUrl;
  const PostDetails({required this.postImageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('posts')
              .where('imageUrl', isEqualTo: postImageUrl)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Something is wrong'));
            }
            final userPost = snapshot.data!.docs;
            return ListView.builder(
              itemCount: userPost.length,
              itemBuilder: (context, index) {
                var userPosts = userPost[index].data();
                String userId = userPosts['userId'];
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, postsnapshot) {
                    if (!postsnapshot.hasData) {
                      return const SizedBox();
                    }
                    var postData =
                        postsnapshot.data!.data() as Map<String, dynamic>;
                    DateTime postTime = userPosts['timestamp'].toDate();
                    String getConsistentTimeAgo(DateTime dateTime) {
                      final now = DateTime.now();
                      final difference = now.difference(dateTime);

                      if (difference.inDays >= 365) {
                        final years = (difference.inDays / 365).floor();
                        return '$years ${years == 1 ? "year" : "years"} ago';
                      } else if (difference.inDays >= 30) {
                        final months = (difference.inDays / 30).floor();
                        return '$months ${months == 1 ? "month" : "months"} ago';
                      } else if (difference.inDays >= 7) {
                        final weeks = (difference.inDays / 7).floor();
                        return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
                      } else if (difference.inDays >= 0) {
                        return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
                      } else if (difference.inHours > 0) {
                        return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
                      } else if (difference.inMinutes > 0) {
                        return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
                      } else {
                        return 'just now';
                      }
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BackButton(),
                          ListTile(
                            leading: CircleAvatar(
                              maxRadius:
                                  MediaQuery.of(context).size.height * 0.025,
                              backgroundImage: postData['profileImage'] != null
                                  ? NetworkImage(postData['profileImage'])
                                  : null,
                              child: postData['profileImage'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              postData['name'] ?? 'unknown',
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(getConsistentTimeAgo(postTime)),
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                          if (userPosts['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                userPosts['imageUrl'],
                                width: double.infinity,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite_border),
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
                          if (userPosts['caption'] != null)
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                userPosts['caption'],
                                style: TextStyle(fontSize: 18),
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
      ),
    );
  }
}
