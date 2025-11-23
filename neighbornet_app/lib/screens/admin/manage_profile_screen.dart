import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool loading = false;

  final String apiUrl = 'http://127.0.0.1:8000/admin/profile/';
  String currentEmail = '';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentEmail = data['email'] ?? '';
        emailController.text = currentEmail;
      } else {
        _showMessage('Failed to fetch profile');
      }
    } catch (e) {
      _showMessage('Error fetching profile');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> updateProfile() async {
    final newEmail = emailController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Password confirmation check
    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    // Check if data is actually changed
    if (newEmail == currentEmail && newPassword.isEmpty) {
      _showMessage('Nothing changed. Please update email or password.');
      return;
    }

    setState(() => loading = true);

    try {
      Map<String, dynamic> payload = {};
      if (newEmail != currentEmail) payload['email'] = newEmail;
      if (newPassword.isNotEmpty) payload['password'] = newPassword;

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        _showMessage('Profile updated successfully');
        currentEmail = newEmail;
        passwordController.clear();
        confirmPasswordController.clear();
      } else {
        _showMessage('Failed to update profile');
      }
    } catch (e) {
      _showMessage('Error updating profile');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
      ),
    );
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
        'Manage Profile', 
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  width: MediaQuery.of(context).size.width > 500 ? 480 : double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [const Color.fromARGB(255, 19, 44, 83), const Color.fromARGB(255, 19, 44, 83)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Manage Profile",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildTextField(emailController, "Email", false, Icons.email),
                      const SizedBox(height: 20),
                      _buildTextField(passwordController, "New Password", true, Icons.lock),
                      const SizedBox(height: 20),
                      _buildTextField(confirmPasswordController, "Confirm Password", true, Icons.lock_outline),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Update Profile",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5279C7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscureText, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
