import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchQuery = _searchController.text.trim();
                    });
                  },
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),

          // 🟢 Real-time Results
          if (searchQuery.isNotEmpty)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('name', isGreaterThanOrEqualTo: searchQuery)
                    .snapshots(), // 🔥 real-time stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No user found"));
                  }

                  // ✅ Display results
                  final userData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/userdetails',
                        arguments: userData['userId'],
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userData['profileImage'] != null
                            ? NetworkImage(userData['profileImage'])
                            : null,
                        child: userData['profileImage'] == null
                            ? Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        userData['name'] ?? 'No Name',
                        style: TextStyle(fontSize: 16),
                      ),
                      // subtitle: Text(userData['email'] ?? ''),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
