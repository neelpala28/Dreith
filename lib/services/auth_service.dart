import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel?> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    }
    return null;
  }
}
