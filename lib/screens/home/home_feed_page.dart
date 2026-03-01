import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/services/post_service.dart';
import 'package:dreith/widgets/comments_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  late final String cuid;

  final int _limit = 10;
  final List<DocumentSnapshot> _posts = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;

  DocumentSnapshot? _lastDocument;

  Future<void> _refreshFeed() async {
    setState(() {
      _posts.clear();
      _lastDocument = null;
      _hasMore = true;
    });

    await _fetchPosts();
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    cuid = user.uid;
    _fetchPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "year" : "years"} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? "" : "s"} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? "" : "s"} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? "" : "s"} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _fetchPosts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        setState(() {
          _posts.addAll(snapshot.docs);
        });
      }

      if (snapshot.docs.length < _limit) {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const SizedBox();
    }
    if (_posts.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          "No posts yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6C5CE7),
      backgroundColor: const Color(0xFF1A1A22),
      onRefresh: _refreshFeed,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 10, bottom: 120),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index < _posts.length) {
            final postDoc = _posts[index];
            final post = postDoc.data() as Map<String, dynamic>;

            final Timestamp? ts = post['timestamp'];
            final DateTime postTime = ts != null ? ts.toDate() : DateTime.now();
            return _PostCard(
              post: post,
              postId: postDoc.id,
              cuid: cuid,
              timeAgo: getTimeAgo(postTime),
              onOpenComments: _openComments,
            );
          }

          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _openComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CommentsBottomSheet(postId: postId),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;
  final String cuid;
  final String timeAgo;
  final Function(String) onOpenComments;

  const _PostCard({
    required this.post,
    required this.postId,
    required this.cuid,
    required this.timeAgo,
    required this.onOpenComments,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isAnimating = false;
  void _handleDoubleTap(bool isLiked) async {
    if (isLiked) return; // ❌ Don't unlike on double tap

    HapticFeedback.lightImpact(); // 🔥 premium feel

    setState(() {
      _isAnimating = true;
    });

    await PostService().toggleLike(widget.postId, widget.cuid);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.post['imageUrl'];
    final String caption = widget.post['caption'] ?? '';
    final String username = widget.post['username'] ?? 'User';
    final String? profileImage = widget.post['profileImage'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage) : null,
                  backgroundColor: Colors.grey.shade800,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
          ),

          /// IMAGE
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('likes')
                .doc(widget.cuid)
                .snapshots(),
            builder: (context, snapshot) {
              bool isLiked = snapshot.data?.exists ?? false;

              return Column(
                children: [
                  /// IMAGE
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onDoubleTap: () => _handleDoubleTap(isLiked),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6C5CE7),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                      AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        scale: _isAnimating ? 1.2 : 0.5,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isAnimating ? 1 : 0,
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFF6C5CE7),
                            size: 100,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// ACTION ROW
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            PostService()
                                .toggleLike(widget.postId, widget.cuid);
                          },
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color:
                                isLiked ? const Color(0xFF6C5CE7) : Colors.grey,
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () => widget.onOpenComments(widget.postId),
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.send_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          /// LIKE COUNT
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('likes')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final likeCount = snapshot.data!.docs.length;

              if (likeCount == 0) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    "$likeCount likes",
                    key: ValueKey(likeCount), // IMPORTANT
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          /// CAPTION
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$username ",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: caption,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
