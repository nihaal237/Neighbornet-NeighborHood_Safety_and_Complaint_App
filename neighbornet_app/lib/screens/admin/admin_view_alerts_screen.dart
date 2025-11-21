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

  Future<void> deleteAlert(int id) async {
    final url = Uri.parse("http://127.0.0.1:8000/admin/alerts/$id/");
    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        // Successfully deleted
        setState(() => alerts.removeWhere((alert) => alert['id'] == id));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Alert deleted successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting alert: ${response.body}")));
      }
    } catch (e) {
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
          '🚨 All Alerts',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.white,
            fontStyle: FontStyle.italic,
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
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            Container(
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
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteAlert(alert['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
