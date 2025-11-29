import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminManageUsersScreen extends StatefulWidget {
  const  AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  List users = [];
  bool isLoading = false;

  final String baseUrl = "http://127.0.0.1:8000"; // backend URL

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/admin/manage-users/");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          users = json.decode(response.body);
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch users.")),
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

  Future<void> deleteUser(int userId) async {
    final url = Uri.parse("$baseUrl/admin/manage-users/$userId/");

    try {
      final response = await http.delete(url);

      final msg = json.decode(response.body)["detail"] ?? "Deleted";

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      if (response.statusCode == 200) {
        fetchUsers();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting user: $e")),
      );
    }
  }

  void editUser(Map user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit user ${user["username"]} (Not implemented)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2EBF7),
      appBar: AppBar(
         iconTheme: const IconThemeData(
    color: Colors.white, // <-- MAKES THE BACK ARROW WHITE
  ),
        backgroundColor:  const Color.fromARGB(255, 19, 44, 83),
        title: const Text(
          'Manage Fake Users Identified by Police',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(
                            user["username"],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              "📧 ${user["email"]}\n📱 ${user["phoneNo"] ?? 'N/A'}\n🏠 ${user["address"] ?? 'N/A'}",
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                             
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: Text(
                                          "Are you sure you want to delete ${user["username"]}?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            deleteUser(user["id"]);
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
