import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = "";

  final String signupUrl = "http://127.0.0.1:8000/signup/";

  // Animation variables
  late AnimationController controller;
  List<Offset> positions = [];
  List<double> sizes = [];
  List<Offset> speeds = [];
  final Random random = Random();

  final List<IconData> icons = [
    Icons.shield,
    Icons.alarm,
    Icons.location_on,
    Icons.warning_rounded,
    Icons.notifications_active,
    Icons.security,
    Icons.home,
    Icons.people,
    Icons.chat_bubble,
    Icons.star,
    Icons.favorite,
    Icons.lightbulb,
    Icons.mail,
    Icons.message,
    Icons.map,
    Icons.local_police,
    Icons.house,
    Icons.group,
    Icons.light_mode,
    Icons.star_outline,
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(_updatePositions);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPositions();
      controller.repeat();
    });
  }

  void _setupPositions() {
    final screen = MediaQuery.of(context).size;

    sizes = List.generate(
      icons.length,
      (i) => 18.0 + (i % 8) * 2,
    );

    positions = List.generate(
      icons.length,
      (i) => Offset(
        random.nextDouble() * screen.width,
        random.nextDouble() * screen.height,
      ),
    );

    speeds = List.generate(
      icons.length,
      (i) => Offset(
        0.5 + (i % 4) * 0.2,
        0.4 + (i % 3) * 0.15,
      ),
    );
  }

  void _updatePositions() {
    final screen = MediaQuery.of(context).size;

    setState(() {
      for (int i = 0; i < positions.length; i++) {
        double newX = positions[i].dx + speeds[i].dx;
        double newY = positions[i].dy + speeds[i].dy;

        if (newX > screen.width) newX = 0;
        if (newY > screen.height) newY = 0;

        positions[i] = Offset(newX, newY);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(signupUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "phoneNo": _phoneController.text.trim(),
          "address": _addressController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final data = json.decode(response.body);
        setState(() {
          _errorMessage =
              data['error'] ?? "Signup failed with status code ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection Error. Check server or URL. Details: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 19, 44, 83),
      body: Stack(
        children: [
          // Animated floating icons
          if (positions.isNotEmpty)
            ...List.generate(icons.length, (i) {
              return Positioned(
                left: positions[i].dx,
                top: positions[i].dy,
                child: Icon(
                  icons[i],
                  size: sizes[i],
                  color: Colors.white.withOpacity(0.23),
                ),
              );
            }),

          // Signup box
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 33, 45, 78),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter username";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter email";
                          if (!value.contains("@")) return "Enter a valid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter password";
                          if (value.length < 6) return "Password must be at least 6 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone No",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter phone number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter address";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 20),
                      // Signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF5279C7),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Login redirect
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}