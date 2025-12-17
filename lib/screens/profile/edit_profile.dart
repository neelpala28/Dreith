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
        .where('userId', isEqualTo: widget.id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _bioController.text = userData['bio'] ?? '';
      _professionController.text = userData['profession'] ?? '';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      try {
        await FirebaseFirestore.instance.collection('users').doc(docId).update({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "bio": _bioController.text.trim(),
          "profession": _professionController.text.trim(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Profile updated!")));
        Navigator.pop(context);
      } catch (e) {
        print('something went wrong: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: "Name"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: "Email"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(labelText: "Bio"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _professionController,
                          decoration: InputDecoration(labelText: "Profession",),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text("Save"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
