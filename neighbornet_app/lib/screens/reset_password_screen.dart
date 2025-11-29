import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = "";

  final String resetUrl = "http://127.0.0.1:8000/auth/reset-password/";

  Future<void> resetPassword(String email) async {
    if (newPasswordController.text.isEmpty) {
      setState(() => errorMessage = "Enter new password");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(resetUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "new_password": newPasswordController.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successful")),
        );
      } else {
        setState(() => errorMessage = data["error"] ?? "Reset failed");
      }
    } catch (e) {
      setState(() => errorMessage = "Server connection error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String email = args["email"];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 44, 83),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 44, 83),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Reset password for: $email",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: "New Password",
                prefixIcon: Icon(Icons.lock),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () => resetPassword(email),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Reset Password"),
            )
          ],
        ),
      ),
    );
  }
}
