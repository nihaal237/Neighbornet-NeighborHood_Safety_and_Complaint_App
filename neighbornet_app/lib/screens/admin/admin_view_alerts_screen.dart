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
  iconTheme: const IconThemeData(
    color: Colors.white, // <-- BACK ARROW COLOR
  ),
  title: const Text(
    'All Alerts',
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
    IconData priorityIcon;

    switch (alert["priority"]) {
      case "High":
        priorityColor = Colors.red;
        priorityIcon = Icons.warning_amber_rounded;
        break;
      case "Mid":
        priorityColor = Colors.orange;
        priorityIcon = Icons.report_problem;
        break;
      default:
        priorityColor = Colors.green;
        priorityIcon = Icons.check_circle_outline;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border(
          left: BorderSide(
            color: priorityColor,
            width: 6, // priority indicator bar
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: priorityColor.withOpacity(0.2),
          child: Icon(priorityIcon, color: priorityColor, size: 26),
        ),
        title: Text(
          alert["title"],
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            alert["message"],
            style: const TextStyle(fontSize: 15),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => deleteAlert(alert['id']),
        ),
      ),
    );
  },
),

    );
  }
}
