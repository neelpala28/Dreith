import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final String id;
  const EditProfile({required this.id, super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get();

    if (snapshot.exists) {
      final userData = snapshot.data()!;
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _bioController.text = userData['bio'] ?? '';
      _professionController.text = userData['profession'] ?? '';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    try {
      final uid = widget.id;

      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newBio = _bioController.text.trim();
      final newProfession = _professionController.text.trim();

      /// 1️⃣ Update user document
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "name": newName,
        "email": newEmail,
        "bio": newBio,
        "profession": newProfession,
      });

      /// 2️⃣ Get all posts of this user
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();

      /// 3️⃣ Batch update posts
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in postsSnapshot.docs) {
        batch.update(doc.reference, {
          "username": newName,
        });
      }

      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated!")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), centerTitle: true),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: "Bio"),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _professionController,
                        decoration:
                            const InputDecoration(labelText: "Profession"),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text("Save Changes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
