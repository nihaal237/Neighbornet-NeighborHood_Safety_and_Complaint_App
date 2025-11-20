import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_as_admin_screen.dart';
import 'screens/login_as_police_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/adminLogin': (context) => LoginAsAdminScreen(),
        '/policeLogin': (context) => LoginAsPoliceScreen(),
        '/adminDashboard': (context) => AdminDashboardScreen(),
      },
    );
  }
}
