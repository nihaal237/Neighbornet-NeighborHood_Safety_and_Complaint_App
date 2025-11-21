import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminViewAlertsScreen extends StatefulWidget {
  const AdminViewAlertsScreen({super.key});

  @override
  State<AdminViewAlertsScreen> createState() => _AdminViewAlertsScreenState();
}

class _AdminViewAlertsScreenState extends State<AdminViewAlertsScreen> {
  List alerts = [];
  bool _isLoading = true;

  Future<void> fetchAlerts() async {
    final url = Uri.parse("http://127.0.0.1:8000/admin/alerts/");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          alerts = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching alerts: ${response.body}")));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFA5BCDF),
    appBar: AppBar(
      title: const Text(
        '🚨 All Alerts', // added emoji
        style: TextStyle(
          fontSize: 26, // slightly larger
          fontWeight: FontWeight.w600, // semi-bold
          letterSpacing: 1.5, // more spacing
          color: Colors.white, // ensures text is visible
          fontStyle: FontStyle.italic, // optional italic
        ),
      ),
      backgroundColor: const Color(0xFF5279C7),
      elevation: 5,
    ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? const Center(
                  child: Text(
                    "No alerts found.",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
                          borderRadius: BorderRadius.circular(15)),
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
