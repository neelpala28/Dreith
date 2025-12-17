import 'package:dreith/widgets/bottom_nav.dart';
import 'package:dreith/screens/home/home_feed_page.dart';
import 'package:dreith/screens/profile/profile_page.dart';
import 'package:dreith/screens/search/search_page.dart';
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

  // ✅ Dynamic Titles
  final List<String> _appBarTitles = ["Dreith", "Search", "Profile"];

  // ✅ Dynamic Actions (optional)
  List<Widget>? _getAppBarActions() {
    switch (_selectedIndex) {
      case 0:
        return [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> pages = [HomeFeedPage(), SearchPage(), ProfilePage()];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      // ✅ Dynamic AppBar
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.06,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
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
