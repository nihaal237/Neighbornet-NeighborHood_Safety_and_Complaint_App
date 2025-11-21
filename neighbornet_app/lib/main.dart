import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_as_admin_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/login_as_police_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'theme_provider.dart';
import 'screens/profile_screen.dart';
import 'screens/user_community_board_screen.dart';
import 'screens/user_create_community_post_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF5279C7),
        scaffoldBackgroundColor: const Color(0xFFE2EBF7),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF5279C7),
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
<<<<<<< HEAD
        '/signup': (context) => const SignupScreen(),
        '/adminLogin': (context) => LoginAsAdminScreen(), // removed const
        '/policeLogin': (context) => const LoginAsPoliceScreen(),
        '/adminDashboard': (context) => const AdminDashboardScreen(),
        '/userHome':(context)=>const UserHomeScreen(),
        '/profile':(context)=>const ProfileScreen(),
=======
        '/signup': (context)=> const SignupScreen(),
        '/adminLogin': (context) => const LoginAsAdminScreen(),
        '/policeLogin': (context) =>const LoginAsPoliceScreen(),
        '/userHome': (context) => const UserHomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/communityBoard': (context) => CommunityBoardScreen(),
        '/createPost': (context) => const CreateCommunityPostScreen(),
>>>>>>> 45f3b8f1ba8b147eb232bed99497aabd1477aa0d
      },
    );
  }
}
