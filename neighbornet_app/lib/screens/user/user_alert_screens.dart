import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserAlertsScreen extends StatefulWidget {
  const UserAlertsScreen({super.key});

  @override
  State<UserAlertsScreen> createState() => _UserAlertsScreenState();
}

class _UserAlertsScreenState extends State<UserAlertsScreen> {
  List alerts = [];
  bool _isLoading = true;

  final String alertsUrl = "http://127.0.0.1:8000/alerts/";

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(alertsUrl));

      if (response.statusCode == 200) {
        setState(() {
          alerts = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching alerts.")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA5BCDF),

      appBar: AppBar(
        title: const Text(
          'Top Alerts',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.white,
            fontStyle: FontStyle.normal,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 44, 83),
        elevation: 5,
        iconTheme: const IconThemeData(
    color: Colors.white, // ← Makes back arrow white
  ),
        
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? const Center(
                  child: Text(
                    "No alerts found.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];

                    Color priorityColor;
                    switch (alert["priority"]) {
                      case "High":
                        priorityColor = Colors.red;
                        break;
                      case "Mid":
                        priorityColor = Colors.orange;
                        break;
                      default:
                        priorityColor = Colors.green;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,

                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),

                        title: Text(
                          alert["title"],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(alert["message"]),

                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert["priority"],
                            style: TextStyle(
                                color: priorityColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}