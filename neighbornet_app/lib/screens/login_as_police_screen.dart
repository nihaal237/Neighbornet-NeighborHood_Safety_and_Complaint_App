import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'police/police_dashboard_screen.dart';

class LoginAsPoliceScreen extends StatefulWidget {
  const LoginAsPoliceScreen({super.key});

  @override
  State<LoginAsPoliceScreen> createState() => _LoginAsPoliceScreenState();
}

class _LoginAsPoliceScreenState extends State<LoginAsPoliceScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  late AnimationController controller;
  late List<Offset> positions;
  late List<double> sizes;
  late List<Offset> speeds;

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
    Icons.camera_alt,
    Icons.directions_walk,
    Icons.pets,
    Icons.wifi,
    Icons.bolt,
    Icons.sports_basketball,
    Icons.health_and_safety,
    Icons.fire_extinguisher,
    Icons.emergency,
    Icons.sos,
  ];

  final Random random = Random();

  @override
  void initState() {
    super.initState();

    positions = [];
    sizes = [];
    speeds = [];

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(_updatePositions);

    // Delay to ensure MediaQuery context is ready
    Future.delayed(const Duration(milliseconds: 200), () {
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

  Future<void> loginPolice() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Enter both email and password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/police/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      setState(() => isLoading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PoliceDashboardScreen(
              accessToken: data['access'],
              currentEmail: email,
            ),
          ),
        );
      } else {
        _showMessage(data["error"] ?? "Login failed");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Error connecting to server");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 19, 44, 83),
      body: Stack(
        children: [
          // Floating icons background
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

          // Main login form
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Police Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 33, 45, 78),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginPolice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5279C7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
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