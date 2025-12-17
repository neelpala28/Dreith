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
                hintText: 'Search by Username or Profession',
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
                    .snapshots(), // 🔥 Fetch all, filter locally
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  // 🔥 Filter locally by name OR profession
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final profession = (data['profession'] ?? '')
                        .toString()
                        .toLowerCase();
                    final query = searchQuery.toLowerCase();

                    return name.contains(query) || profession.contains(query);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("No user found"));
                  }

                  // ✅ Display ALL matching results in a ListView
                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final userData =
                          filteredDocs[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/userdetails',
                            arguments: userData['userId'],
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                userData['profileImage'] != null &&
                                    userData['profileImage']
                                        .toString()
                                        .isNotEmpty
                                ? NetworkImage(userData['profileImage'])
                                : null,
                            child:
                                userData['profileImage'] == null ||
                                    userData['profileImage'].toString().isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            userData['name'] ?? 'No Name',
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle:
                              userData['profession'] != null &&
                                  userData['profession'].toString().isNotEmpty
                              ? Text('#${userData['profession']}')
                              : null, // 🔥 Show profession if available
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
