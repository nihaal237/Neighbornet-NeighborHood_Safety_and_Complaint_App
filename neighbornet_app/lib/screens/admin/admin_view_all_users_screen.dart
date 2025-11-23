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
  iconTheme: const IconThemeData(
    color: Colors.white, // <-- BACK ARROW COLOR
  ),
  title: const Text(
    'View All Users',
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: Colors.white,
      fontStyle: FontStyle.normal,
    ),
  ),
  backgroundColor: const Color.fromARGB(255, 19, 44, 83),
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
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  itemBuilder: (context, index) {
    final user = users[index];
    
    // Optional: Assign colors based on user role
    Color roleColor;
    String role = user['role'] ?? 'User';
    switch (role.toLowerCase()) {
      case 'admin':
        roleColor = Colors.deepPurple;
        break;
      case 'police':
        roleColor = Colors.blueAccent;
        break;
      default:
        roleColor = Colors.green;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: roleColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: roleColor.withOpacity(0.2),
          child: Text(
            user['username'][0].toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
        ),
        title: Text(
          user['username'],
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(user['email'])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(user['phoneNo'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(user['address'] ?? 'N/A')),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  },
)

      ),
    );
  }
}
