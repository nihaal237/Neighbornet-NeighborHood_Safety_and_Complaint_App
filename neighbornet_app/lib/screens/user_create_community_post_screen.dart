import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  TextEditingController contentController = TextEditingController();
  bool isLoading = false;
  String? token;

  final String url = "http://127.0.0.1:8000/community-posts/create/";

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access");
  }

  Future<void> submitPost() async {
    String text = contentController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post content cannot be empty.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"content": text}),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // return to community board
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA5BCDF),

      appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 19, 44, 83),
  iconTheme: const IconThemeData(
    color: Colors.white, // <-- MAKES THE ARROW WHITE
  ),
  title: const Text(
    "Create Post",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(255, 240, 233, 233),
    ),
  ),
),

      
      

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: contentController,
              maxLines: 7,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Write your post here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Post",
                        style: TextStyle(
                          color: Color(0xFF5279C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
