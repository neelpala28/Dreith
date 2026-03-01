import 'package:dreith/api/firebase_api.dart';
import 'package:dreith/screens/home/create_post_screen.dart';
import 'package:dreith/screens/message/message_screen.dart';
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
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await FirebaseApi().initNotification();
    } catch (e) {
      debugPrint("Notification init error: $e");
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _appBarTitles = [
    "Azurra", // 0
    "Messages", // 1
    "Create Post", // 2
    "Search", // 3
    "Profile" // 4
  ];

  List<Widget>? _getAppBarActions() {
    switch (_selectedIndex) {
      case 0:
        return [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.lock_outline_rounded),
            onPressed: () {},
          ),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ];
      case 3:
        return [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
          ),
        ];
      case 4:
        return [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed('/setting');
            },
          ),
        ];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser;

    final List<Widget> pages = [
      const HomeFeedPage(), // 0
      MessageScreen(uid: user?.uid ?? ""), // 1
      CreatePostScreen(onPostSuccess: () {
        setState(() {
          _selectedIndex = 0; // go back to feed
        });
      }), // 2 → Replace with CreatePostScreen()
      const SearchPage(), // 3
      const ProfilePage(), // 4
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.06,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: _getAppBarActions(),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
