import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class PoliceCommunityBoardScreen extends StatefulWidget {
  final String accessToken;

  const PoliceCommunityBoardScreen({Key? key, required this.accessToken})
      : super(key: key);

  @override
  State<PoliceCommunityBoardScreen> createState() =>
      _PoliceCommunityBoardScreenState();
}

class _PoliceCommunityBoardScreenState
    extends State<PoliceCommunityBoardScreen> {
  late Future<List<dynamic>> _postsFuture;
  Map<int, bool> expandedMap = {}; // Handles card expansion

  @override
  void initState() {
    super.initState();
    _postsFuture = getPosts(widget.accessToken);
  }

  String getPostsUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000/community-posts/';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/community-posts/';
    return 'http://127.0.0.1:8000/community-posts/';
  }

  Future<List<dynamic>> getPosts(String token) async {
    final response = await http.get(
      Uri.parse(getPostsUrl()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (body is List) return body;
      if (body is Map && body['results'] is List) return body['results'];
    }

    throw Exception("Failed to load posts (Status ${response.statusCode})");
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = getPosts(widget.accessToken);
    });
    await _postsFuture;
  }

  // ---------------------------------------------------------
  // ⭐ NEW BEAUTIFUL DATE FORMATTER
  // ---------------------------------------------------------
  String _formatDate(String? iso) {
    if (iso == null) return "Unknown date";

    try {
      final date = DateTime.parse(iso).toLocal();
      return DateFormat("MMM dd, yyyy • hh:mm a").format(date);
    } catch (_) {
      return iso;
    }
  }

  // BEAUTIFUL GRADIENT BORDER AROUND AVATAR
  Widget _avatar(String username) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Colors.blueAccent,
          ],
        ),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : "?",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // ⭐ COMMUNITY POST CARD
  // ---------------------------------------------------------
  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final user = post['user'] ?? {};

    final username =
        post['username']?.toString().trim().isNotEmpty == true
            ? post['username']
            : (user['username'] ?? user['email'] ?? "Anonymous User");

    final content = (post['content'] ?? "").toString();
    final date = _formatDate(post['dateTime']);
    final isHighlighted = post['isHighlighted'] == true;
    final postId = post['id'];

    expandedMap.putIfAbsent(postId, () => false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                isHighlighted ? Colors.amber.withOpacity(0.35) : Colors.black26,
            blurRadius: isHighlighted ? 20 : 10,
            spreadRadius: isHighlighted ? 3 : 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              expandedMap[postId] = !(expandedMap[postId]!);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------
                // HEADER SECTION
                // -----------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _avatar(username),
                    const SizedBox(width: 12),

                    // Username + Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isHighlighted)
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 28),
                  ],
                ),

                const SizedBox(height: 12),

                // -----------------------------------
                // CONTENT SECTION (EXPANDABLE)
                // -----------------------------------
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: expandedMap[postId]!
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    content.length > 120
                        ? content.substring(0, 120) + "..."
                        : content,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  secondChild: Text(
                    content,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

                const SizedBox(height: 10),

                // -----------------------------------
                // EXPAND/COLLAPSE LABEL
                // -----------------------------------
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  iconTheme: const IconThemeData(
    color: Colors.white, // <-- makes back arrow white
  ),
  title: const Text(
    'Community Board',
    style: TextStyle(
      color: Colors.white, // <-- makes title text white
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    ),
  ),
  backgroundColor: const Color.fromARGB(255, 19, 44, 83),
  elevation: 5,
),

      backgroundColor: const Color(0xFFC7D8F5),

      body: FutureBuilder<List<dynamic>>(
        future: _postsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Text("Error: ${snap.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            );
          }

          final posts = snap.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF1E3A8A),
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: posts.length,
              itemBuilder: (context, i) => _buildPostCard(posts[i], i),
            ),
          );
        },
      ),
    );
  }
}
