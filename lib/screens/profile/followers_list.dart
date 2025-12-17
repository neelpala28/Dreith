import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowersList extends StatelessWidget {
  final String id;
  const FollowersList({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Followers'), centerTitle: true),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('following', arrayContains: id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No followers found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final followers = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final followerData =
                    followers[index].data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: followerData['profileImage'] != null
                          ? NetworkImage(followerData['profileImage'])
                          : null,
                      child: followerData['profileImage'] == null
                          ? Icon(Icons.person, size: 30)
                          : null,
                    ),
                    title: Text(
                      followerData['name'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: followerData['username'] != null
                        ? Text('@${followerData['username']}')
                        : null,
                    onTap: () {
                      // Navigate to user profile
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) => UserProfile(userId: followers[index].id)
                      // ));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
