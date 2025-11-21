import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class PoliceAlertsScreen extends StatefulWidget {
  final String token; // JWT token from login
  const PoliceAlertsScreen({super.key, required this.token});

  @override
  State<PoliceAlertsScreen> createState() => _PoliceAlertsScreenState();
}

class _PoliceAlertsScreenState extends State<PoliceAlertsScreen> {
  late Future<List<dynamic>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = getAlerts(widget.token);
  }

  // Determine backend URL depending on platform
  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000/api/police/alerts/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/police/alerts/';
    } else {
      return 'http://localhost:8000/api/police/alerts/';
    }
  }

  Future<List<dynamic>> getAlerts(String token) async {
    final url = getBackendUrl();
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alerts (Status code: ${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      backgroundColor: const Color(0xFFC7D8F5), // same as dashboard
      body: FutureBuilder<List<dynamic>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E3A8A),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No alerts found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    alert['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600, // bold
                      color: Color(0xFF1E3A8A), // dashboard theme color
                    ),
                  ),
                  subtitle: Text(
                    alert['message'] ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert['priority'] ?? '',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
