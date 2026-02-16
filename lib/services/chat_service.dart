import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  Future<String> createOrGetChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final chatId = getChatId(currentUserId, otherUserId);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Just set with merge - will create if doesn't exist, update if it does
    await chatRef.set({
      'members': [currentUserId, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': null,
    }, SetOptions(merge: true));

    return chatId;
  }
}
