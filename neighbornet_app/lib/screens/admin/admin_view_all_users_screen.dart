import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminViewAllUsersScreen extends StatefulWidget {
  const AdminViewAllUsersScreen({super.key});

  @override
  State<AdminViewAllUsersScreen> createState() => _AdminViewAllUsersScreenState();
}

class _AdminViewAllUsersScreenState extends State<AdminViewAllUsersScreen> {
  List users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    final url = Uri.parse("http://127.0.0.1:8000/admin/view-users/"); // use correct endpoint
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load users")),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFE2EBF7), 
    appBar: AppBar(
      title: const Text(
        '👥 View All Users',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: Colors.white,
          fontStyle: FontStyle.italic,
        ),
      ),
      backgroundColor: const Color(0xFF5279C7),
      elevation: 5,
    ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? const Center(
                    child: Text(
                      "No Users Found",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        elevation: 5,
                        shadowColor: Colors.black54,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            user["username"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "📧 ${user["email"]}\n📱 ${user["phoneNo"]}\n🏠 ${user["address"]}",
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
