import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
      backgroundColor: const Color.fromARGB(255, 19, 44, 83),
      body: Stack(
        children: [
          // 🌟 ANIMATED BACKGROUND
          const MovingIconsBackground(),

          // 🌟 MAIN UI CONTENT
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    onEnter: (_) => _controller.forward(),
                    onExit: (_) => _controller.reverse(),
                    cursor: SystemMouseCursors.click,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CircleAvatar(
                          radius: _scaleAnimation.value,
                          backgroundImage:
                              const AssetImage('assets/images/logo.png'),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Welcome to NeighborNet!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                            color: Color.fromARGB(255, 29, 76, 134),
                            offset: Offset(2, 2),
                            blurRadius: 4)
                      ],
                      color:  Color.fromARGB(255, 215, 212, 223),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Connecting neighbors, building communities.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 215, 212, 223),
                        fontStyle: FontStyle.italic),
                  ),

                  const SizedBox(height: 50),

                  // MAIN BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor:  Color.fromARGB(255, 227, 224, 235),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(37, 40, 45, 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor:  Color.fromARGB(255, 227, 224, 235),
                        ),
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(37, 40, 45, 1),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 45),
                ],
              ),
            ),
          ),

          // 🌟 TOP RIGHT ADMIN + POLICE BUTTONS
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/adminLogin');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor:  Color.fromARGB(255, 227, 224, 235),
                      ),
                      child: const Text(
                        "Login as Admin",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 49, 73, 112)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/policeLogin');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor:  Color.fromARGB(255, 227, 224, 235),
                      ),
                      child: const Text(
                        "Login as Police",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 49, 73, 112)),
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

//
// ------------------------------------------------------------
//  ⭐ FLOATING NEIGHBORNET THEMED ICONS BACKGROUND
// ------------------------------------------------------------
//

class MovingIconsBackground extends StatefulWidget {
  const MovingIconsBackground({super.key});

  @override
  State<MovingIconsBackground> createState() => _MovingIconsBackgroundState();
}

class _MovingIconsBackgroundState extends State<MovingIconsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ⭐ MORE ICONS ADDED HERE ⭐
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

    // EXTRA ICONS
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

  late List<Offset> positions=[];
  late List<Offset> speeds=[];

  late final List<double> sizes = List.generate(
    icons.length,
    (i) => 18.0 + (i % 8) * 2,
  );

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(hours: 1))
          ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      positions = List.generate(
        icons.length,
        (i) => Offset(
          (i * 45) % screenWidth,
          (i * 80) % screenHeight,
        ),
      );

      speeds = List.generate(
        icons.length,
        (i) => Offset(
          0.5 + (i % 4) * 0.2,
          0.4 + (i % 3) * 0.15,
        ),
      );
    });

    _controller.addListener(_updatePositions);
  }

  void _updatePositions() {
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      for (int i = 0; i < positions.length; i++) {
        double newX = positions[i].dx + speeds[i].dx;
        double newY = positions[i].dy + speeds[i].dy;

        if (newX > screenWidth || newX < 0) {
          speeds[i] = Offset(-speeds[i].dx, speeds[i].dy);
        }
        if (newY > screenHeight || newY < 0) {
          speeds[i] = Offset(speeds[i].dx, -speeds[i].dy);
        }

        positions[i] = Offset(newX, newY);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          for (int i = 0; i < icons.length; i++)
            Positioned(
              left: positions[i].dx,
              top: positions[i].dy,
              child: Icon(
                icons[i],
                size: sizes[i],
                color: Colors.white.withOpacity(0.25),
              ),
            )
        ],
      ),
    );
  }
}