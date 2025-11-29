import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = "";

  final String loginUrl = "http://127.0.0.1:8000/login/";

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

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Enter both email and password";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("access", data["access"]);
        await prefs.setString("refresh", data["refresh"]);

        Navigator.pushReplacementNamed(context, '/userHome');
      } else {
        setState(() {
          _errorMessage = data['error'] ?? "Invalid credentials";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Unable to connect to server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 44, 83),
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
                  color: Colors.white.withOpacity(0.22),
                ),
              );
            }),

          // Login box
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 33, 45, 78),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Forgot Password Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgotPassword");
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF5279C7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14),
                      ),

                    const SizedBox(height: 20),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF5279C7),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
