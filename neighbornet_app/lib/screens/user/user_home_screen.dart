import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String? userEmail;
  bool isLoading = true;
  String? token;

  final String baseUrl = "http://127.0.0.1:8000/api/current-user/";

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchEmail();
  }

  Future<void> loadTokenAndFetchEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access");

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userEmail = data['email']; // adjust if API returns different key
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Invalid/expired token → redirect to login
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        setState(() {
          userEmail = 'Failed to fetch email';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userEmail = 'Error fetching email';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NeighborNet User Dashboard"),
        backgroundColor: const Color.fromARGB(255, 185, 205, 236),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 19, 44, 83),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color.fromARGB(255, 185, 205, 236),
                    child: Icon(Icons.person, size: 40, color: Color(0xFF5279C7)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          userEmail ?? 'No email',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Manage Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text("Submit Crime Report"),
              onTap: () => Navigator.pushNamed(context, '/submitReport'),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("View My Reports"),
              onTap: () => Navigator.pushNamed(context, '/userReports'),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("Community Board"),
              onTap: () => Navigator.pushNamed(context, '/communityBoard'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("My Alerts"),
              onTap: () => Navigator.pushNamed(context, '/userAlerts'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color.fromARGB(255, 19, 44, 83),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildHomeCard(icon: Icons.person, label: "Manage Profile", onTap: () => Navigator.pushNamed(context, '/profile')),
              _buildHomeCard(icon: Icons.report, label: "Submit Report", onTap: () => Navigator.pushNamed(context, '/submitReport')),
              _buildHomeCard(icon: Icons.list_alt, label: "My Reports", onTap: () => Navigator.pushNamed(context, '/userReports')),
              _buildHomeCard(icon: Icons.group, label: "Community Board", onTap: () => Navigator.pushNamed(context, '/communityBoard')),
              _buildHomeCard(icon: Icons.notifications, label: "Alerts", onTap: () => Navigator.pushNamed(context, '/userAlerts')),
              _buildHomeCard(icon: Icons.map, label: "Crime Map", onTap: () => Navigator.pushNamed(context, '/userMap')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 185, 205, 236),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF5279C7)),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF303030))),
          ],
        ),
      ),
    );
  }
}
