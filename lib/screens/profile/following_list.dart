import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingList extends StatelessWidget {
  final String id;
  const FollowingList({required this.id, super.key});

  Future<List<DocumentSnapshot>> _getFollowingUsers(
    List<String> followingIds,
  ) async {
    if (followingIds.isEmpty) return [];

    // Firestore 'in' queries are limited to 10 items
    // If you have more than 10 following, you'll need to batch the requests
    final batches = <Future<QuerySnapshot>>[];
    const batchSize = 10;

    for (int i = 0; i < followingIds.length; i += batchSize) {
      final batch = followingIds.skip(i).take(batchSize).toList();
      batches.add(
        FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get(),
      );
    }

    final results = await Future.wait(batches);
    final docs = <DocumentSnapshot>[];

    for (final result in results) {
      docs.addAll(result.docs);
    }

    return docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following'), centerTitle: true),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final followingIds = List<String>.from(userData['following'] ?? []);

            if (followingIds.isEmpty) {
              return const Center(
                child: Text(
                  'Not following anyone',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Now get the following user documents
            return FutureBuilder<List<DocumentSnapshot>>(
              future: _getFollowingUsers(followingIds),
              builder: (context, followingSnapshot) {
                if (followingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (followingSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading following: ${followingSnapshot.error}',
                    ),
                  );
                }

                final following = followingSnapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: following.length,
                  itemBuilder: (context, index) {
                    final followingData =
                        following[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: followingData['profileImage'] != null
                              ? NetworkImage(followingData['profileImage'])
                              : null,
                          child: followingData['profileImage'] == null
                              ? Icon(Icons.person, size: 30)
                              : null,
                        ),
                        title: Text(
                          followingData['name'] ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: followingData['username'] != null
                            ? Text('@${followingData['username']}')
                            : null,
                        onTap: () {
                          // Navigate to user profile
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (context) => UserProfile(userId: following[index].id)
                          // ));
                        },
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
