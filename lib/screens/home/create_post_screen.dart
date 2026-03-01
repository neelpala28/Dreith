import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> createPost(File imageFile, String caption) async {
  try {
    // Step 1: Upload to Cloudinary directly
    final cloudName = "dhaebbteq";
    final uploadPreset = "post_preset";

    final uploadUrl = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    var request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'posts'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    final imageUrl = jsonResponse['secure_url'];

    // Step 2: Store post in Firestore
    final user = FirebaseAuth.instance.currentUser!;
    final postRef = FirebaseFirestore.instance.collection('posts').doc();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data()!;
    await postRef.set({
      'postId': postRef.id, // store document ID
      'caption': caption,
      'commentsCount': 0,
      'imageUrl': imageUrl,
      'likesCount': 0,
      'sharesCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'username': userData['name'],
      'profileImage': userData['profileImage'],
    });
    debugPrint(jsonResponse);
    debugPrint("Post created successfully!");
  } catch (e) {
    debugPrint("Error creating post: $e");
  }
}

class CreatePostScreen extends StatefulWidget {
  final VoidCallback onPostSuccess;

  const CreatePostScreen({
    super.key,
    required this.onPostSuccess,
  });
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool _isPosting = false;

  Future<void> _handlePost() async {
    if (galleryFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    try {
      setState(() {
        _isPosting = true;
      });

      await createPost(
        galleryFile!,
        captionController.text.trim(),
      );

      if (mounted) {
        widget.onPostSuccess();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to post")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  File? galleryFile;
  final picker = ImagePicker();
  final captionController = TextEditingController();

  // ----------------- BUILD METHOD -----------------
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP ROW (Post Button Only)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _isPosting ? null : _handlePost,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: galleryFile == null
                            ? Colors.grey.shade800
                            : const Color(0xFF6C5CE7),
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Post",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// IMAGE CONTAINER
                GestureDetector(
                  onTap: () => _showPicker(context),
                  child: AspectRatio(
                    aspectRatio: 1, // square preview
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFF1A1A22),
                      ),
                      child: galleryFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.file(
                                galleryFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// CAPTION FIELD
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFF1A1A22),
                  ),
                  child: TextField(
                    controller: captionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Colors.transparent,
                      hintText: "Write a caption...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined,
                      color: Color(0xFF6C5CE7)),
                  title: const Text("Add Location"),
                  onTap: () {},
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tag, color: Color(0xFF6C5CE7)),
                  title: const Text("Tag People"),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- IMAGE PICKER -----------------
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage(ImageSource img) async {
    final XFile? pickedFile = await picker.pickImage(source: img);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        galleryFile = File(file.path);
      });

      // Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('post_image_path', file.path);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image selected")));
    }
  }
}
