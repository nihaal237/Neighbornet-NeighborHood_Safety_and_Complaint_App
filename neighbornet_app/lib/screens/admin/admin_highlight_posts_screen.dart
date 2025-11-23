import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


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
  bool isHighlighted = post['isHighlighted'] ?? false;

  // Format date
  String formattedDate = '';
  if (post['dateTime'] != null && post['dateTime'].isNotEmpty) {
    DateTime dt = DateTime.parse(post['dateTime']);
    formattedDate = DateFormat('MMM dd, yyyy, hh:mm a').format(dt);
  }

  return GestureDetector(
    onTap: () => toggleHighlight(post['id']),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? Colors.amber.withOpacity(0.3)
                : Colors.black.withOpacity(0.07),
            blurRadius: isHighlighted ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isHighlighted ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 6,
                height: 55,
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.amber : const Color(0xFF5279C7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  post['content'] ?? "No Content",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: isHighlighted ? Colors.amber.shade800 : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                splashRadius: 25,
                onPressed: () => toggleHighlight(post['id']),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    isHighlighted ? Icons.star : Icons.star_border,
                    key: ValueKey(isHighlighted),
                    color: isHighlighted ? Colors.amber : Colors.grey.shade500,
                    size: isHighlighted ? 34 : 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "User: ${post['username'] ?? 'Anonymous'}",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA5BCDF),
      appBar: AppBar(
        iconTheme: const IconThemeData(
    color: Colors.white, // <-- BACK ARROW COLOR
  ),
        backgroundColor:  const Color.fromARGB(255, 19, 44, 83),
        elevation: 5,
        title: Row(
          children: const [
            Icon(Icons.forum, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Community Posts",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Colors.white,
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
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