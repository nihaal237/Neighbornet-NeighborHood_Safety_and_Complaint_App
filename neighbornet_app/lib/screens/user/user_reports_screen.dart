import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Optional: Full screen image viewer
class FullScreenImage extends StatelessWidget {
  final String url;
  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  bool loading = true;
  List reports = [];
  String? token;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access");

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/userReports/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      reports = json.decode(response.body);
    }

    setState(() => loading = false);
  }

  Future<String?> loadTextFile(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      return utf8.decode(resp.bodyBytes);
    }
    return null;
  }

  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Processing":
        return Colors.blue;
      case "Verified":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132C53),
      appBar: AppBar(
        backgroundColor: const Color(0xFF132C53),
        elevation: 0,
        title: const Text(
          "My Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : reports.isEmpty
              ? const Center(
                  child: Text(
                    "No Reports Submitted Yet",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ExpansionTile(
                        title: Text(
                          report["title"],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                report["location"] ?? "No Location",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: statusColor(report["status"] ?? ""),
                          child: const Icon(Icons.flag, color: Colors.white),
                        ),
                        childrenPadding: const EdgeInsets.all(15),
                        children: [
                          Text(
                            report["description"],
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 20),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 14),
                            decoration: BoxDecoration(
                              color: statusColor(report["status"] ?? ""),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              report["status"],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Evidences",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // SORT EVIDENCES: IMAGES FIRST, TEXT AFTER
                          ...(() {
                            final sorted = [...report["evidences"]];
                            sorted.sort((a, b) {
                              if (a["is_text"] == b["is_text"]) return 0;
                              return a["is_text"] ? 1 : -1;
                            });
                            return sorted.map<Widget>((ev) {
                              final url = ev["file_url"];
                              final isText = ev["is_text"];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                ),
                                child: isText
                                    ? FutureBuilder(
                                        future: loadTextFile(url),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Padding(
                                              padding: EdgeInsets.all(10),
                                              child:
                                                  Text("Loading text file..."),
                                            );
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(snapshot.data ?? ""),
                                          );
                                        },
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FullScreenImage(url: url),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 220,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey[200],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                              );
                            }).toList();
                          })(),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
