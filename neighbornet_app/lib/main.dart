import 'package:flutter/material.dart';
import 'package:neighbornet_app/screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_as_admin_screen.dart';
import 'screens/login_as_police_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context)=> const SignupScreen(),
        '/adminLogin': (context) => const LoginAsAdminScreen(),
        '/policeLogin': (context) =>const LoginAsPoliceScreen(),
      },
    );
  }
}