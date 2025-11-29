import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminSearchReportsScreen extends StatefulWidget {
  const AdminSearchReportsScreen({super.key});

  @override
  State<AdminSearchReportsScreen> createState() =>
      _AdminSearchReportsScreenState();
}

class _AdminSearchReportsScreenState extends State<AdminSearchReportsScreen> {
  List users = [];
  List reports = [];
  int? selectedUserId;

  String selectedReportType = "all"; // default
  final String baseUrl = "http://127.0.0.1:8000";

  final Map<String, String> reportTypes = {
    "all": "All Reports",
    "anonymous": "Anonymous Reports",
    "deleted": "Deleted User Reports",
    "specific": "Specific User Reports"
  };

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchReports(); // fetch all by default
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/view-users/'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  Future<void> fetchReports({int? userId}) async {
    try {
      String url;
      switch (selectedReportType) {
        case "anonymous":
          url = "$baseUrl/admin/anonymous-reports/";
          break;
        case "deleted":
          url = "$baseUrl/admin/deleted-user-reports/";
          break;
        case "specific":
          if (userId == null) return;
          url = "$baseUrl/admin/user-reports/$userId/";
          break;
        case "all":
        default:
          url = "$baseUrl/admin/all-reports/";
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          reports = json.decode(response.body);
        });
      } else {
        setState(() {
          reports = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching reports: $e");
    }
  }

  String getUserDisplayName(Map report) {
    if (report['isAnonymous'] == true) return "Anonymous";
    if (report['user'] == null) return "Deleted";
    return report['user'];
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'verified':
        return Colors.green;
      case 'resolved':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      appBar: AppBar(
        iconTheme: const IconThemeData(
    color: Colors.white, // <-- BACK ARROW COLOR
  ),
        title: const Text(
          'User Reports',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontStyle: FontStyle.normal,
            color:Colors.white
          ),
        ),
        backgroundColor:  const Color.fromARGB(255, 19, 44, 83),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Report type dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedReportType,
              decoration: InputDecoration(
                labelText: "Select Report Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: reportTypes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReportType = value!;
                  selectedUserId = null;
                  reports = [];
                });
                fetchReports();
              },
            ),

            const SizedBox(height: 12),

            // Specific user dropdown
            if (selectedReportType == "specific")
              DropdownButtonFormField<int>(
                hint: const Text("Select a user"),
                initialValue: selectedUserId,
                decoration: InputDecoration(
                  labelText: "Select User",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: users.map((user) {
                  return DropdownMenuItem<int>(
                    value: user['id'],
                    child: Text(user['username']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserId = value;
                    reports = [];
                  });
                  fetchReports(userId: value);
                },
              ),

            const SizedBox(height: 16),

            // Reports list
            Expanded(
              child: reports.isEmpty
                  ? const Center(
                      child: Text(
                        "No reports available",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            title: Text(
                              report['title'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text(
                                      "Status: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(
                                                report['status'])
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        report['status'],
                                        style: TextStyle(
                                            color: getStatusColor(
                                                report['status']),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "User: ${getUserDisplayName(report)}",
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
