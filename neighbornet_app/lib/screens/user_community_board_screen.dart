import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityBoardScreen extends StatefulWidget {
  const CommunityBoardScreen({Key? key}) : super(key: key);

  @override
  State<CommunityBoardScreen> createState() => _CommunityBoardScreenState();
}

class _CommunityBoardScreenState extends State<CommunityBoardScreen> {
  List posts = [];
  bool isLoading = true;
  String? token;

  final String baseUrl = "http://127.0.0.1:8000/community-posts/";

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
  }

  Future<void> loadTokenAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access");

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget buildPostCard(post) {
    bool highlighted = post['isHighlighted'] == true;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
            ),
        ],
        ),
        child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Blue Accent Bar (same as admin)
            Container(
                width: 6,
                height: 55,
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 19, 44, 83),
                borderRadius: BorderRadius.circular(12),
                ),
            ),

            const SizedBox(width: 16),

            // Expanded content
            Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Username
                    Text(
                    post['username'] ?? "Anonymous User",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                    ),
                    ),

                    const SizedBox(height: 8),

                    // Content
                    Text(
                    post['content'] ?? "",
                    style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                    ),
                    ),

                    const SizedBox(height: 12),

                    // Timestamp bottom-right
                    Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                        post['dateTime']
                            .toString()
                            .replaceAll("T", " • ")
                            .substring(0, 19),
                        style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        ),
                    ),
                    )
                ],
                ),
            ),

            // ⭐ Only displayed if highlighted
            if (highlighted) ...[
                const SizedBox(width: 10),
                AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                ),
                child: const Icon(
                    Icons.star,
                    key: ValueKey("highlightedStar"),
                    color: Colors.amber,
                    size: 28,
                ),
                ),
            ]
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
        backgroundColor: const Color.fromARGB(255, 19, 44, 83),
        title: const Text(
            "Community Board",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,color:const Color.fromARGB(255, 240, 233, 233)),
        ),
        actions: [
            IconButton(
            icon: const Icon(Icons.add_comment, size: 28),
            tooltip: "Create Post",
            onPressed: () {
                Navigator.pushNamed(context, '/createPost');
            },
            ),
        ],
        iconTheme: const IconThemeData(
    color: Colors.white, // ← Makes back arrow white
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
                        "No community posts yet.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return buildPostCard(posts[index]);
                      }),
            ),
    );
  }
}
