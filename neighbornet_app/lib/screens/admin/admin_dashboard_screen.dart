import 'package:flutter/material.dart';
import 'admin_create_alert_screen.dart';
import 'admin_view_alerts_screen.dart';
import 'manage_profile_screen.dart'; // new import
import '../login_screen.dart'; 

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: const Color(0xFF5279C7),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.admin_panel_settings, size: 28, color: Color(0xFF5279C7)),
            ),
            const SizedBox(width: 12),
            Text(
              "NeighborNet Admin",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: const [
                  Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
                ],
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5279C7), Color(0xFF3E5BA6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 40, color: Color(0xFF5279C7)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Welcome Admin!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.add_alert,
              label: "Create Alert",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCreateAlertScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.list_alt,
              label: "View Alerts",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminViewAlertsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              label: "Manage Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageProfileScreen()),
                );
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.logout,
              label: "Logout",
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/'); // redirects to /login
              },
            ),
          ],
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA5BCDF), Color(0xFFD7E1F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Wrap(
            spacing: 25,
            runSpacing: 25,
            children: [
              _buildHomeCard(
                icon: Icons.add_alert,
                label: "Create Alert",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminCreateAlertScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.list_alt,
                label: "View Alerts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminViewAlertsScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.person,
                label: "Manage Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      onTap: onTap,
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
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFE7F0FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5279C7).withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 48, color: const Color(0xFF5279C7)),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF303030),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
