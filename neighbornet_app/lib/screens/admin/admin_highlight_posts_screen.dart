import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminHighlightPostsScreen extends StatefulWidget {
  const AdminHighlightPostsScreen({Key? key}) : super(key: key);

  @override
  State<AdminHighlightPostsScreen> createState() =>
      _AdminHighlightPostsScreenState();
}

class _AdminHighlightPostsScreenState extends State<AdminHighlightPostsScreen>
    with SingleTickerProviderStateMixin {
  List posts = [];
  bool isLoading = true;

  final String baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/admin/community-posts/'));

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load posts")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> toggleHighlight(int postId) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/admin/community-posts/$postId/highlight/'));

      if (response.statusCode == 200) {
        final updated = json.decode(response.body);

        if (!mounted) return;

        setState(() {
          posts = posts.map((post) {
            if (post['id'] == updated['id']) {
              post['isHighlighted'] = updated['isHighlighted'];
            }
            return post;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(updated['isHighlighted']
                  ? "Post Highlighted"
                  : "Highlight Removed")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update highlight")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget buildPostCard(post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Blue Accent Bar
            Container(
              width: 6,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF5279C7),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),

            // Post Content
            Expanded(
              child: Text(
                post['content'] ?? "No Content",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),

            // Highlight Star
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  post['isHighlighted'] == true
                      ? Icons.star
                      : Icons.star_border,
                  key: ValueKey(post['isHighlighted']),
                  color: post['isHighlighted'] == true
                      ? Colors.amber
                      : Colors.grey.shade500,
                  size: 30,
                ),
              ),
              onPressed: () => toggleHighlight(post['id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFA5BCDF),  // Same background as Report Alert

    appBar: AppBar(
      backgroundColor: const Color(0xFF5279C7),
      elevation: 5,

      title: Row(
        children: const [
          Icon(Icons.forum, color: Colors.white),     
          SizedBox(width: 10),
          Text(
            "💬  Community Posts",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: const Color(0xFF5279C7),
              onRefresh: fetchPosts,
              child: posts.isEmpty
                  ? const Center(
                      child: Text(
                      "No posts available",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ))
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return buildPostCard(posts[index]);
                      },
                    ),
            ),
    );
  }
}
