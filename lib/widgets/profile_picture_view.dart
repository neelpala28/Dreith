import 'package:flutter/material.dart';

class ProfilePictureView extends StatelessWidget {
  final String? imageUrl;
  const ProfilePictureView({required this.imageUrl, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: '',
            child: ClipOval(
              child: Image.network(
                imageUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
