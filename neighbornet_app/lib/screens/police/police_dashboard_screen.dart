import 'package:flutter/material.dart';
import 'police_alerts_screen.dart';
import 'police_communityboard_screen.dart';

class PoliceDashboardScreen extends StatelessWidget {
  final String accessToken;
  final String currentEmail;

  const PoliceDashboardScreen({
    super.key,
    required this.accessToken,
    required this.currentEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NeighborNet Police Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 22, 22, 22)),
        ),
        backgroundColor: Color.fromARGB(255, 185, 205, 236),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader( 
              decoration: const BoxDecoration(color: const Color.fromARGB(255, 19, 44, 83)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Welcome, Police",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                 
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _drawerTile(
                    icon: Icons.person,
                    text: "Manage Profile",
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    onTap: () => Navigator.pushNamed(context, '/policeUpdateProfile'),
                  ),
                  _drawerTile(
                    icon: Icons.report,
                    text: "View All Reports",
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/policeReports',
                      arguments: {'token': accessToken},
                    ),
                  ),
                  _drawerTile(
                    icon: Icons.map,
                    text: "View Area Statistics",
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    onTap: () => Navigator.pushNamed(context, '/areaStats'),
                  ),
                  _drawerTile(
                    icon: Icons.group,
                    text: "Community Board",
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PoliceCommunityBoardScreen(accessToken: accessToken)),
                    ),
                  ),
                  _drawerTile(
                    icon: Icons.notifications,
                    text: "View Alerts",
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PoliceAlertsScreen(token: accessToken)),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  _drawerTile(
                    icon: Icons.logout,
                    text: "Logout",
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      backgroundColor: const Color.fromARGB(255, 19, 44, 83),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _homeCard(
                icon: Icons.person,
                label: "Manage Profile",
                onTap: () => Navigator.pushNamed(context, '/policeUpdateProfile'),
              ),
              _homeCard(
                icon: Icons.report,
                label: "View Reports",
                onTap: () => Navigator.pushNamed(
                  context,
                  '/policeReports',
                  arguments: {'token': accessToken},
                ),
              ),
              _homeCard(
                icon: Icons.map,
                label: "Area Stats",
                onTap: () => Navigator.pushNamed(context, '/areaStats'),
              ),
              _homeCard(
                icon: Icons.group,
                label: "Community Board",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoliceCommunityBoardScreen(accessToken: accessToken)),
                ),
              ),
              _homeCard(
                icon: Icons.notifications,
                label: "Alerts",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoliceAlertsScreen(token: accessToken)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: onTap,
    );
  }

  Widget _homeCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 185, 205, 236),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(3, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF1E3A8A)),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF303030))),
          ],
        ),
      ),
    );
  }
}
