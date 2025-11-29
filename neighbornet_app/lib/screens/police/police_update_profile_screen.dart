import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PoliceUpdateProfileScreen extends StatefulWidget {
  final String accessToken;
  final String currentEmail;

  const PoliceUpdateProfileScreen({
    super.key,
    required this.accessToken,
    required this.currentEmail,
  });

  @override
  _PoliceUpdateProfileScreenState createState() => _PoliceUpdateProfileScreenState();
}

class _PoliceUpdateProfileScreenState extends State<PoliceUpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final url = Uri.parse('http://127.0.0.1:8000/police/update-profile/');
    final body = {
      "username": usernameController.text,
      "phoneNo": phoneController.text,
    };
    if (passwordController.text.isNotEmpty) {
      body["password"] = passwordController.text;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.accessToken}",
        },
        body: jsonEncode(body),
      );

      setState(() => isLoading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Profile updated!")),
        );
        passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["detail"] ?? "Error updating profile")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error connecting to server")),
      );
    }
  }

  Widget _buildBlueInput({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 19, 44, 83), // match dashboard AppBar
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 44, 83), // dashboard AppBar shade
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      backgroundColor: const Color(0xFFC7D8F5), // dashboard background shade

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:const Color.fromARGB(255, 19, 44, 83),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Manage Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildBlueInput(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
                            child: Row(
                              children: [
                                const Icon(Icons.email, color: Colors.white70),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.currentEmail,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        _buildBlueInput(
                          child: TextFormField(
                            controller: usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "New Username",
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            ),
                            validator: (value) => value!.isEmpty ? "Please enter username" : null,
                          ),
                        ),

                        _buildBlueInput(
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "New Phone Number",
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.phone, color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            ),
                            validator: (value) => value!.isEmpty ? "Please enter phone number" : null,
                          ),
                        ),

                        _buildBlueInput(
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "New Password (optional)",
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 19, 44, 83),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isLoading ? "Updating..." : "Update Profile",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
