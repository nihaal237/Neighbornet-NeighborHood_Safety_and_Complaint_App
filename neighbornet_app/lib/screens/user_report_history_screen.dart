import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserReportHistoryScreen extends StatefulWidget {
  const UserReportHistoryScreen({super.key});

  @override
  State<UserReportHistoryScreen> createState() =>
      _UserReportHistoryScreenState();
}

class _UserReportHistoryScreenState extends State<UserReportHistoryScreen> {
  bool isLoading = true;
  List reports = [];

  final String apiUrl = "http://127.0.0.1:8000/reports/my/";

  @override
  void initState() {
    super.initState();
    fetchMyReports();
  }

  Future<void> fetchMyReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access");

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          reports = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "processing":
        return Colors.blue;
      case "verified":
        return Colors.green;
      case "resolved":
        return Colors.teal;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA5BCDF),
      appBar: AppBar(
        title: const Text("My Reports"),
        backgroundColor: const Color(0xFF5279C7),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(
                  child: Text(
                    "No reports submitted yet.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final r = reports[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              r["title"],
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // Status
                            Row(
                              children: [
                                const Text("Status: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(r["status"])
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    r["status"],
                                    style: TextStyle(
                                      color: getStatusColor(r["status"]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text("Location: ${r['location']}"),
                            const SizedBox(height: 6),

                            Text("Anonymous: ${r["isAnonymous"] ? "Yes" : "No"}"),

                            const SizedBox(height: 10),

                            const Text(
                              "Description:",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),

                            Text(
                              r["description"],
                              style: const TextStyle(fontSize: 14),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                                "Evidence Files:",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                ),
                                ),
                                const SizedBox(height: 10),

                                if (r["evidences"].isEmpty)
                                const Text("No evidence files"),

                                if (r["evidences"].isNotEmpty)
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: r["evidences"].map<Widget>((e) {
                                    String fileUrl = "http://127.0.0.1:8000${e['file']}";
                                    String filename = e['file'].split('/').last.toLowerCase();

                                    bool isImage = filename.endsWith(".jpg") ||
                                        filename.endsWith(".jpeg") ||
                                        filename.endsWith(".png");

                                    bool isPDF = filename.endsWith(".pdf");
                                    bool isText = filename.endsWith(".txt");

                                    if (isImage) {
                                        // SHOW IMAGE INLINE
                                        return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: GestureDetector(
                                            onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                builder: (_) => Scaffold(
                                                    backgroundColor: Colors.black,
                                                    appBar: AppBar(
                                                    backgroundColor: Colors.black,
                                                    title: const Text("Evidence Image"),
                                                    ),
                                                    body: Center(child: Image.network(fileUrl)),
                                                ),
                                                ),
                                            );
                                            },
                                            child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                                fileUrl,
                                                height: 180,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                            ),
                                            ),
                                        ),
                                        );
                                    }

                                    // NON-IMAGE FILES
                                    return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                        isPDF ? Icons.picture_as_pdf : Icons.description,
                                        color: isPDF ? Colors.red : Colors.blue,
                                        ),
                                        title: Text(filename),
                                        trailing: const Icon(Icons.open_in_new),
                                        onTap: () {
                                        // open file in browser
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                            builder: (_) => Scaffold(
                                                appBar:
                                                    AppBar(title: Text("Open File: $filename")),
                                                body: Center(
                                                child: Text(
                                                    "Open this file in browser:\n\n$fileUrl",
                                                    textAlign: TextAlign.center,
                                                ),
                                                ),
                                            ),
                                            ),
                                        );
                                        },
                                    );
                                    }).toList(),
                                ),

                          ],
                        ),
                      ),
                    );
                  }),
    );
  }
}
