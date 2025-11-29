import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNo = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isLoading = false;
  bool _saving = false;

  String? token;

  final profileUrl = "http://127.0.0.1:8000/profile/";
  final updateUrl = "http://127.0.0.1:8000/profile/update/";

  Map<String, dynamic> errors = {};

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchProfile();
  }

  Future<void> _loadTokenAndFetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access");

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse(profileUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _username.text = data["username"] ?? "";
      _email.text = data["email"] ?? "";
      _phoneNo.text = data["phoneNo"] ?? "";
      _address.text = data["address"] ?? "";
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    setState(() {
      _saving = true;
      errors = {};
    });

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "username": _username.text.trim(),
        "email": _email.text.trim(),
        "phoneNo": _phoneNo.text.trim(),
        "address": _address.text.trim(),
        "password": _password.text.trim().isEmpty ? null : _password.text.trim(),
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } else if (response.statusCode == 400) {
      setState(() => errors = data["errors"] ?? {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $data")),
      );
    }

    setState(() => _saving = false);
  }

  Widget _errorText(String field) {
    if (!errors.containsKey(field)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        errors[field],
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Profile",
        style: TextStyle(color: Colors.white)), // ← White text
        backgroundColor: const Color.fromARGB(255, 19, 44, 83),
        iconTheme: const IconThemeData(
    color: Colors.white, // ← Makes back arrow white
  ),
        
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  
                  // Username
                  _errorText("username"),
                  TextField(
                    controller: _username,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Email
                  _errorText("email"),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Phone
                  _errorText("phoneNo"),
                  TextField(
                    controller: _phoneNo,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number (03XXXXXXXXX)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Address
                  _errorText("address"),
                  TextField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  _errorText("password"),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),

                  _saving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  const Color.fromARGB(255, 19, 44, 83),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 40,
                            ),
                          ),
                          child: const Text("Save Changes",style: TextStyle(color: Colors.white)), // ← White text,
                        ),
                ],
              ),
            ),
    );
  }
}
