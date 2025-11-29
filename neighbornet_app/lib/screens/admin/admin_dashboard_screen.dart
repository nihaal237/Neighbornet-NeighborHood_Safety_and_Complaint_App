import 'package:flutter/material.dart';
import 'admin_create_alert_screen.dart';
import 'admin_view_alerts_screen.dart';
import 'admin_manage_users_screen.dart';
import 'admin_view_all_users_screen.dart';
import 'manage_profile_screen.dart';
import 'admin_search_reports_screen.dart';
import 'admin_select_theme_screen.dart'; 
import 'admin_highlight_posts_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor:  Color.fromARGB(255, 185, 205, 236),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.admin_panel_settings,
                  size: 28, color: Color(0xFF5279C7)),
            ),
            const SizedBox(width: 12),
            const Text(
              "NeighborNet Admin Dashboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color.fromARGB(255, 0, 0, 0),
                shadows: [
                  Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
                ],
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
                  colors: [const Color.fromARGB(255, 19, 44, 83), Color(0xFF3E5BA6)],
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
                    child: Icon(Icons.admin_panel_settings,
                        size: 40, color: Color(0xFF5279C7)),
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
                  MaterialPageRoute(builder: (_) => AdminCreateAlertScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.list_alt,
              label: "View Alerts",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminViewAlertsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.group,
              label: "Manage Fake Users",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminManageUsersScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.visibility,
              label: "View All Users",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminViewAllUsersScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.search,
              label: "Search Reports",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminSearchReportsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              label: "Manage Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageProfileScreen()),
                );
              },
            ),
            _buildDrawerItem(
               icon: Icons.star,
               label: "Highlight Posts",
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminHighlightPostsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.brightness_6,
              label: "Select Theme",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminSelectThemeScreen()),
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
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 19, 44, 83), const Color.fromARGB(255, 19, 44, 83)],
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
                    MaterialPageRoute(builder: (_) => AdminCreateAlertScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.list_alt,
                label: "View Alerts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminViewAlertsScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.group,
                label: "Manage Fake Users",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminManageUsersScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.visibility,
                label: "View All Users",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminViewAllUsersScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.search,
                label: "Search Reports",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminSearchReportsScreen()),
                  );
                },
              ),
              _buildHomeCard(
                icon: Icons.person,
                label: "Manage Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ManageProfileScreen()),
                  );
                },
              ),
              _buildHomeCard(
                 icon: Icons.star,
                 label: "Highlight Posts",
                 onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminHighlightPostsScreen()),
                  );
               },
              ),
              _buildHomeCard(
                icon: Icons.color_lens,
                label: "Select Theme",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminSelectThemeScreen()),
                  );
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  static Widget _buildHomeCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF5279C7),
    Color textColor = const Color(0xFF303030),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 185, 205, 236), Color.fromARGB(255, 185, 205, 236)],
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
                color: iconColor.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
