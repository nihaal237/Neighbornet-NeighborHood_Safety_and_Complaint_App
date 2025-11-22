import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class PoliceCommunityBoardScreen extends StatefulWidget {
  final String accessToken;

  const PoliceCommunityBoardScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<PoliceCommunityBoardScreen> createState() => _CommunityBoardScreenState();
}

class _CommunityBoardScreenState extends State<PoliceCommunityBoardScreen> {
  late Future<List<dynamic>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = getPosts(widget.accessToken);
  }

  // Return base + endpoint depending on platform
  String getPostsUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/community-posts/'; // web / chrome
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/community-posts/'; // Android emulator
    } else {
      return 'http://127.0.0.1:8000/community-posts/'; // iOS simulator / desktop
    }
  }

  Future<List<dynamic>> getPosts(String token) async {
    final url = getPostsUrl();
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      // If API wraps result, adapt here (e.g. { "results": [...] })
      if (data is Map && data['results'] is List) return data['results'];
      return [];
    } else {
      throw Exception('Failed to load posts (status ${response.statusCode})');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = getPosts(widget.accessToken);
    });
    await _postsFuture;
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      // simple readable format: YYYY-MM-DD HH:MM
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Board'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      backgroundColor: const Color(0xFFC7D8F5),
      body: FutureBuilder<List<dynamic>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No posts found.', style: TextStyle(fontSize: 16))),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index] as Map<String, dynamic>;

                // JSON structure from backend (example you shared):
                // {
                //   "id": 4,
                //   "user": { "id":9, "username":"fatima", "email":"..." },
                //   "content": "Keep your doors locked",
                //   "dateTime": "2025-11-10T10:19:47.052005Z",
                //   "isHighlighted": false
                // }
                final user = post['user'] as Map<String, dynamic>?;
                final username = (post['username'] != null && post['username'].toString().trim().isNotEmpty)
    ? post['username'].toString()
    : (user != null && user['username'] != null && user['username'].toString().trim().isNotEmpty)
        ? user['username'].toString()
        : (user != null && user['email'] != null)
            ? user['email'].toString()
            : 'Anonymous User';

// Use username if present, else email if present, else fallback to 'Anonymous User' 
                final content = (post['content'] ?? '').toString();
                final dateStr = _formatDate(post['dateTime']?.toString());

                return Card(
  margin: const EdgeInsets.symmetric(vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  elevation: 3,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1E3A8A),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            // ⭐ Star aligned to the right if highlighted
            if (post['isHighlighted'] == true)
              const Icon(Icons.star, color: Colors.amber, size: 24),
          ],
        ),
        const SizedBox(height: 10),
        Text(content,
            style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    ),
  ),
);

              },
            ),
          );
        },
      ),
    );
  }
}
