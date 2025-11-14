import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 150, end: 120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA5BCDF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hoverable logo
            MouseRegion(
              onEnter: (_) => _controller.forward(), // shrink on hover
              onExit: (_) => _controller.reverse(),  // back to normal
              cursor: SystemMouseCursors.click,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CircleAvatar(
                    radius: _scaleAnimation.value,
                    backgroundImage: const AssetImage('assets/images/logo.png'),
                  );
                },
              ),
            ),
            const SizedBox(height: 35),
            // Header text
            const Text(
              "Welcome to NeighborNet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(66, 45, 36, 66),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
                color: Color.fromARGB(255, 21, 25, 48),
              ),
            ),
            const SizedBox(height: 10),
            // Subheader / tagline
            const Text(
              "Connecting neighbors, building communities.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(179, 15, 27, 30),
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 50),
            // Login & Signup buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context,'/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(148, 179, 226, 1),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Signup button
                ElevatedButton(
                  onPressed: () {
                      Navigator.pushNamed(context,'/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Signup",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(148, 179, 226, 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
