import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for Firebase to determine user state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate based on login status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.data == null) {
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            Navigator.pushReplacementNamed(context, '/homescreen');
          }
        });

        // While navigating
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
