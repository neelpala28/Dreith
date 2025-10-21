import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/screens/post/post_details.dart';
import 'package:dreith/widgets/profile_picture_view.dart';
import 'package:dreith/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final cuid = FirebaseAuth.instance.currentUser?.uid;
  Future<void> profileImage(File imageFile) async {
    try {
      // Step 1: Upload to Cloudinary directly
      final cloudName = "dhaebbteq";
      final uploadPreset = "post_preset";

      final uploadUrl = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      var request = http.MultipartRequest('POST', uploadUrl)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'pImage'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      final imageUrl = jsonResponse['secure_url'];

      // Save image URL in Firestore
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "profileImage": imageUrl,
      }, SetOptions(merge: true));
      setState(() {
        netwrokImageUrl = imageUrl;
      });
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  File? galleryFile;
  final picker = ImagePicker();
  String? netwrokImageUrl;

  @override
  void initState() {
    super.initState();
    loadUserData(); // ✅ Load data on screen start
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? email = prefs.getString('email');

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        String? firestoreName = data['name'];
        String? firestoreEmail = data['email'];
        String? profileImageUrl = data['profileImage'];
        String? firestoreBio = data['bio'];

        Provider.of<UserProvider>(context, listen: false).setUser(
          UserModel(
            name: firestoreName ?? username ?? '',
            email: firestoreEmail ?? email ?? '',
            bio: firestoreBio ?? '',
          ),
        );

        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          setState(() {
            netwrokImageUrl = profileImageUrl;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("No user information available")),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createpost');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add_a_photo),
      ),

      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Row (Photo + Name + Email) ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPicker(context: context),
                    child: Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.03,
                      ),
                      child: GestureDetector(
                        onLongPress: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                              pageBuilder: (_, __, ___) =>
                                  ProfilePictureView(imageUrl: netwrokImageUrl),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.07,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              (netwrokImageUrl != null &&
                                  netwrokImageUrl!.isNotEmpty)
                              ? NetworkImage(netwrokImageUrl!)
                              : null,
                          child:
                              (netwrokImageUrl == null ||
                                  netwrokImageUrl!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size:
                                      MediaQuery.of(context).size.height * 0.07,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // Name + Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20),
                        // Text(
                        //   user.email,
                        //   style: TextStyle(
                        //     fontSize: MediaQuery.of(context).size.height * 0.02,
                        //     color: Colors.grey[700],
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        //// --- Followers & Following ---
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(cuid) // current user
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            int followersCount = data?['followersCount'] ?? 0;
                            int followingCount = data?['followingCount'] ?? 0;

                            return SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/followerslist',
                                        arguments: cuid,
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Followers",
                                          style: TextStyle(fontSize: 16),
                                        ),

                                        Text(
                                          followersCount.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/followinglist',
                                        arguments: cuid,
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Following",
                                          style: TextStyle(fontSize: 16),
                                        ),

                                        Text(
                                          followingCount.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // --- Bio (below Row) ---
              if (user.bio != null && user.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
                  child: Text(
                    user.bio!,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      color: Colors.white,
                    ),
                  ),
                ),

              // --- Edit Profile Button (below bio) ---
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: 140,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/editprofile',
                        arguments: cuid,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(20, 105, 116, 121),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 4),
                        Text('Edit Profile', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Divider(thickness: 0.2),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No posts yet"));
                    }

                    final posts = snapshot.data!.docs;

                    return Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03,
                      ),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 2,
                            ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post =
                              posts[index].data() as Map<String, dynamic>;
                          print("Post loaded: ${post['imageUrl']}"); // 🔎 Debug

                          return GestureDetector(
                            onTap: () {
                              print('tapped');
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: Duration(
                                    milliseconds: 500,
                                  ),
                                  pageBuilder: (_, __, ___) => PostDetails(
                                    postImageUrl: post['imageUrl'],
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              post['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("Image failed: ${post['imageUrl']}");
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
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
      ),
    );
  }

  void _showPicker({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
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
                title: const Text('camera'),
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

  Future getImage(ImageSource img) async {
    final pickedFile = await picker.pickImage(source: img);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      setState(() {
        galleryFile = file;
      });

      // 🔥 Upload to Cloudinary instead of saving locally
      await profileImage(file);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nothing is selected")));
    }
  }
}
