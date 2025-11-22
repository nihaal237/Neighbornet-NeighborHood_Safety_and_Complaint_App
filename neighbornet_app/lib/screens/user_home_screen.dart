import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NeighborNet User Dashboard"),
        backgroundColor: const Color(0xFF5279C7),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF5279C7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF5279C7)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Manage Profile"),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),

            ListTile(
              leading: const Icon(Icons.report),
              title: const Text("Submit Crime Report"),
              onTap: () {
                Navigator.pushNamed(context, '/submitReport');
              },
            ),

            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("View My Reports"),
              onTap: () {
                Navigator.pushNamed(context, '/reportHistory');
              },
            ),

            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("Community Board"),
              onTap: () {
                Navigator.pushNamed(context, '/communityBoard');
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("My Alerts"),
              onTap: () {
                Navigator.pushNamed(context, '/alerts');
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFA5BCDF),

        child: Center(
            child: Wrap(
            spacing: 20,
            runSpacing: 20,

            children: [
                _buildHomeCard(
                icon: Icons.person,
                label: "Manage Profile",
                onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildHomeCard(
                icon: Icons.report,
                label: "Submit Report",
                onTap: () => Navigator.pushNamed(context, '/submitReport'),
                ),
                _buildHomeCard(
                icon: Icons.list_alt,
                label: "My Reports",
                onTap: () =>  Navigator.pushNamed(context, '/reportHistory'),
                ),
                _buildHomeCard(
                icon: Icons.group,
                label: "Community Board",
                onTap: () => Navigator.pushNamed(context, '/communityBoard'),
                ),
                _buildHomeCard(
                icon: Icons.notifications,
                label: "Alerts",
                onTap: () => Navigator.pushNamed(context, '/alerts'),
                ),
                _buildHomeCard(
                icon: Icons.map,
                label: "Crime Map",
                onTap: () => Navigator.pushNamed(context, '/map'),
                ),
            ],
            ),
        ),
        ),

    );
  }

  Widget _buildHomeCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    }) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Container(
        width: 140,   // smaller card width
        height: 140,  // smaller card height
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
            )
            ],
        ),

        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(icon, size: 40, color: Color(0xFF5279C7)),
            const SizedBox(height: 10),
            Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF303030),
                ),
            ),
            ],
        ),
        ),
    );
    }

  // Reusable grid tile widget
  Widget _buildHomeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Color(0xFF5279C7)),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
