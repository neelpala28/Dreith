import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/widgets/bottom_nav.dart';
import 'package:dreith/screens/home/home_feed_page.dart';
import 'package:dreith/screens/profile/profile_page.dart';
import 'package:dreith/screens/search/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> _pages = [
      // Feed Page
      HomeFeedPage(),
      SearchPage(),
      // Profile Page
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.06,
        backgroundColor: Colors.black,
        title: const Text('Social Feed', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
