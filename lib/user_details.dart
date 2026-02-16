import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/screens/post/post_details.dart';
import 'package:dreith/widgets/profile_picture_view.dart';
import 'package:dreith/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  final String id;
  const UserDetails({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton(),
            SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Can't find user details"));
                }
                final user = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final imageUrl = user['profileImage'];
                        if (imageUrl == null || imageUrl.isEmpty) return;

                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                ProfilePictureView(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: user['profileImage'] != null
                            ? NetworkImage(user['profileImage'])
                            : null,
                        child: user['profileImage'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user['name'] ?? 'unknown user',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/followerslist',
                              arguments: id,
                            );
                          },
                          child: SizedBox(
                            height: 50,
                            child: Column(
                              children: [
                                Text(
                                  'followers',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  (user['followersCount'] ?? 0).toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/followinglist',
                              arguments: id,
                            );
                          },
                          child: SizedBox(
                            height: 50,
                            child: Column(
                              children: [
                                Text(
                                  'followings',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  (user['followingCount'] ?? 0).toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Check if current user is following this profile
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUserId)
                          .collection('following')
                          .doc(id)
                          .snapshots(),
                      builder: (context, followSnapshot) {
                        final isFollowing =
                            followSnapshot.hasData &&
                            followSnapshot.data!.exists;

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFollowing
                                  ? [
                                      const Color.fromARGB(255, 0, 0, 0),
                                      const Color.fromARGB(200, 81, 81, 81),
                                    ]
                                  : [Colors.purpleAccent, Colors.pinkAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: currentUserId != id
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: const Color.fromARGB(
                                      0,
                                      139,
                                      111,
                                      111,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    // ✅ Fixed: Correct follow/unfollow logic
                                    if (isFollowing) {
                                      UserService().unfollowUser(
                                        currentUserId,
                                        id,
                                      );
                                    } else {
                                      UserService().followUser(
                                        currentUserId,
                                        id,
                                      );
                                    }
                                  },
                                  child: Text(
                                    isFollowing ? "Unfollow" : "Follow",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : SizedBox(height: 50),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const Divider(),

            // User posts
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('userId', isEqualTo: id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No posts yet'));
                  }
                  final posts = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post =
                            posts[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    PostDetails(postId: posts[index].id),
                              ),
                            );
                          },
                          child: Image.network(
                            post['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
