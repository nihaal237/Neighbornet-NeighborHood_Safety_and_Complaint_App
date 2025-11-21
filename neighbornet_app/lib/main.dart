import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_as_admin_screen.dart';
import 'screens/login_as_police_screen.dart';
import 'screens/police_dashboard_screen.dart';
import 'screens/police_update_profile_screen.dart';
import 'screens/police_alerts_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/police_report_screen.dart'; // ✅ Added

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/policeLogin',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/adminLogin': (context) => const LoginAsAdminScreen(),
        '/policeLogin': (context) => const LoginAsPoliceScreen(),
        '/policeUpdateProfile': (context) => const PoliceUpdateProfileScreen(
              accessToken: '',
              currentEmail: 'police@example.com',
            ),
        '/userHome': (context) => const UserHomeScreen(),
      },
      onGenerateRoute: (settings) {
        // Dynamic routing for screens that need token/email
        if (settings.name == '/policeDashboard') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => PoliceDashboardScreen(
              accessToken: args['token'],
              currentEmail: args['email'],
            ),
          );
        }
        if (settings.name == '/alerts') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => PoliceAlertsScreen(token: args['token']),
          );
        }
        if (settings.name == '/policeReports') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => PoliceReportsScreen(accessToken: args['token']),
          );
        }
        return null; // fallback for unknown routes
      },
    );
  }
}
