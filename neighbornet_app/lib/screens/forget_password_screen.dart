import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  String errorMessage = "";

  final String verifyUrl = "http://127.0.0.1:8000/auth/verify-identity/";

  Future<void> verifyIdentity() async {
    if (emailController.text.isEmpty || phoneController.text.isEmpty) {
      setState(() => errorMessage = "Enter email & phone number");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": emailController.text.trim(),
          "phoneNo": phoneController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushNamed(
          context,
          "/resetPassword",
          arguments: {"email": emailController.text.trim()},
        );
      } else {
        setState(() => errorMessage = data["error"] ?? "Verification failed");
      }
    } catch (e) {
      setState(() => errorMessage = "Server connection error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 44, 83),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 44, 83),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyIdentity,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify"),
            )
          ],
        ),
      ),
    );
  }
}
