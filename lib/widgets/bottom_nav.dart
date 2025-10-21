// bottom_nav.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      print('Logout error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close account options dialog
                logout(context);
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text('Account Options'),
                    content: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Important: prevents overflow
                      children: [
                        ListTile(
                          leading: Icon(Icons.add),
                          title: Text("Add Account"),
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                            // Add your account addition logic here
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.logout_outlined,
                            color: Colors.red,
                          ),
                          title: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Icon(Icons.person),
          ),
          label: "Profile",
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor:
          Colors.blue, // Changed from white for better visibility
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
    );
  }
}
