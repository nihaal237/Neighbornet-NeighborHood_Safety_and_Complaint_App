import 'package:flutter/material.dart';
import 'package:neighbornet_app/screens/police/police_area_stats.dart';
import 'package:neighbornet_app/screens/police/police_report_screen.dart';
import 'package:neighbornet_app/screens/user/user_submit_report_screen.dart';
import 'package:neighbornet_app/screens/user/user_view_crime_map.dart';
import 'package:provider/provider.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_as_admin_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/login_as_police_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'theme_provider.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/user_community_board_screen.dart';
import 'screens/user/user_create_community_post_screen.dart';
import 'screens/police/police_dashboard_screen.dart';
import 'screens/police/police_update_profile_screen.dart';
import 'screens/police/police_alerts_screen.dart';
import 'screens/police/police_communityboard_screen.dart';
import 'screens/user/user_alert_screens.dart';
import 'screens/user/user_reports_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/reset_password_screen.dart';

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
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/resetPassword': (context) => const ResetPasswordScreen(),
        '/signup': (context) => const SignupScreen(),
        '/adminLogin': (context) => LoginAsAdminScreen(), 
        '/policeLogin': (context) => const LoginAsPoliceScreen(),
        '/adminDashboard': (context) => const AdminDashboardScreen(),
        '/userHome':(context)=>const UserHomeScreen(),
        '/profile':(context)=>const ProfileScreen(),
        '/communityBoard': (context) => CommunityBoardScreen(),
        '/createPost': (context) => const CreateCommunityPostScreen(),
        '/userAlerts': (context) => const UserAlertsScreen(),
        '/userReports':(context)=>const ReportListScreen(),
        '/submitReport':(context)=>const SubmitReportScreen(),
        '/userMap':(context)=>const CrimeMapScreen(),
        '/areaStats':(context)=>const CrimeMapScreenPolice(),
        '/policeUpdateProfile': (context) => const PoliceUpdateProfileScreen(
              accessToken: '', // placeholder, replaced dynamically
              currentEmail: 'police@example.com',
            ),
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
        if (settings.name == '/policeCommunityBoard') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => PoliceCommunityBoardScreen(accessToken: args['token']),
          );
        }
        return null;
      },
    );
  }
}