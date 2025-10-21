import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('posts').add({
      'caption': caption,
      'commentsCount': 0,
      'imageUrl': imageUrl,
      'likesCount': 0,
      'sharesCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user!.uid,
    });
    print(jsonResponse);
    print("Post created successfully!");
  } catch (e) {
    print("Error creating post: $e");
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? galleryFile;
  final picker = ImagePicker();
  final captionController = TextEditingController();

  // ----------------- BUILD METHOD -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),

              // Title
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: const Text(
                  'Select Image',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              // Image Picker Preview
              Center(
                child: GestureDetector(
                  onTap: () => _showPicker(context),
                  child: galleryFile != null
                      ? Image.file(
                          galleryFile!,
                          height: MediaQuery.of(context).size.height * 0.25,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_search_sharp,
                          size: MediaQuery.of(context).size.height * 0.2,
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Caption label
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: const Text(
                  'Caption',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              // Caption input
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.02,
                ),
                child: TextField(
                  controller: captionController,
                  minLines: 3,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Add a Caption for the post (optional)',
                    hintStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ),

              // Post button
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.7,
                  top: MediaQuery.of(context).size.height * 0.04,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (galleryFile != null) {
                      createPost(galleryFile!, captionController.text);
                      Navigator.of(context).pushNamed('/profile');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select an image")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: const Text('Post'),
                ),
              ),
            ],
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image selected")));
    }
  }
}
