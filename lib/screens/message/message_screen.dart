import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/screens/message/chat_screen.dart';
import 'package:dreith/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final String uid;
  const MessageScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: userRef.get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final followingIds =
              List<String>.from(userSnapshot.data!['following'] ?? []);

          if (followingIds.isEmpty) {
            return const Center(child: Text("No messages yet"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: followingIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                    ),
                    title: Text(user['name'] ?? 'Unknown'),
                    onTap: () async {
                      final chatId = await ChatService().createOrGetChat(
                        currentUserId: currentUser!.uid,
                        otherUserId: user.id,
                      );
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                chatId: chatId, receiverId: user.id)),
                      );
                    },
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
