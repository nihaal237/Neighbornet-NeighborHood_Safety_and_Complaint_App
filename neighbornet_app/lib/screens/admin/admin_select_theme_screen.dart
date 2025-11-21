import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class AdminSelectThemeScreen extends StatelessWidget {
  const AdminSelectThemeScreen({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return Scaffold(
    backgroundColor: themeProvider.isDarkMode
        ? Colors.grey[900]
        : const Color(0xFFE2EBF7),

    appBar: AppBar(
      title: Row(
        children: const [
          Icon(Icons.color_lens, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "🌓  Select Theme",
            style: TextStyle(
              fontSize: 26,              // Same size as Report Alert
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,        // Same spacing
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFF5279C7),
      elevation: 5,
    ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.brightness_6,
                  size: 60,
                  color: Color(0xFF5279C7),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Toggle between Light and Dark Mode",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(
                    themeProvider.isDarkMode
                        ? "Dark Mode Enabled 🌙"
                        : "Light Mode Enabled ☀️",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeColor: const Color(0xFF5279C7),
                  secondary: const Icon(Icons.dark_mode, color: Color(0xFF5279C7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
