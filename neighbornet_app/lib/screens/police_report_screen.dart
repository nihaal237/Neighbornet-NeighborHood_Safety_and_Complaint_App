import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PoliceReportsScreen extends StatefulWidget {
  final String accessToken;

  const PoliceReportsScreen({super.key, required this.accessToken});

  @override
  State<PoliceReportsScreen> createState() => _PoliceReportsScreenState();
}

class _PoliceReportsScreenState extends State<PoliceReportsScreen> {
  List reports = [];
  bool isLoading = true;

  Map<int, bool> showEvidences = {}; // Null-safe map

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/police/reports/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final fetchedReports = json.decode(response.body);
      setState(() {
        reports = fetchedReports;
        for (var report in reports) {
          showEvidences.putIfAbsent(report['id'], () => false);
        }
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load reports')),
      );
    }
  }

  Future<void> updateStatus(int reportId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/police/reports/$reportId/status/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({"status": newStatus}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated')),
      );
      fetchReports();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  Widget buildEvidence(dynamic e) {
    final url = e['file_url'];
    if (url == null) return const SizedBox.shrink();

    if (url.endsWith('.jpg') || url.endsWith('.png')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Image.network(
          url,
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Text("Error loading image"),
        ),
      );
    } else if (url.endsWith('.txt')) {
      return FutureBuilder(
        future: fetchTextFile(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading text...");
          } else if (snapshot.hasError) {
            return Text("Error loading text: ${snapshot.error}");
          } else {
            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.grey[200],
              child: Text(
                snapshot.data.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF303030),
                ),
              ),
            );
          }
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          url,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E3A8A)),
        ),
      );
    }
  }

  Future<String> fetchTextFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return response.body;
    throw Exception('Failed to load text file');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Police Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      backgroundColor: const Color(0xFFC7D8F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(
                  child: Text(
                    'No reports available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF303030),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final reportId = report['id'];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Report title left-aligned, bold, darker color
                            Text(
                              report['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF303030),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              report['description'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF303030),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Location: ${report['location'] ?? 'N/A'}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (report['evidences'] != null &&
                                report['evidences'].isNotEmpty)
                              Column(
                                children: [
                                  // Centered View Evidences button
                                  Center(
                                    child: Container(
                                      width: 200,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1E3A8A),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showEvidences.putIfAbsent(
                                                reportId, () => false);
                                            showEvidences[reportId] =
                                                !(showEvidences[reportId]!);
                                          });
                                        },
                                        child: Text(
                                          showEvidences[reportId] == true
                                              ? "Hide Evidences"
                                              : "View Evidences",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (showEvidences[reportId] == true)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: report['evidences']
                                          .map<Widget>((e) => buildEvidence(e))
                                          .toList(),
                                    ),
                                  const SizedBox(height: 12),
                                  // Status Change centered, white text + dropdown
                                  Center(
                                    child: Container(
                                      width: 220,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E3A8A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Status Change",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 6),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              canvasColor:
                                                  const Color(0xFF1E3A8A),
                                            ),
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: report['status'],
                                              iconEnabledColor: Colors.white,
                                              dropdownColor:
                                                  const Color(0xFF1E3A8A),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                    value: 'Pending',
                                                    child: Text('Pending',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))),
                                                DropdownMenuItem(
                                                    value: 'Processing',
                                                    child: Text('Processing',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))),
                                                DropdownMenuItem(
                                                    value: 'Verified',
                                                    child: Text('Verified',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))),
                                                DropdownMenuItem(
                                                    value: 'Resolved',
                                                    child: Text('Resolved',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))),
                                                DropdownMenuItem(
                                                    value: 'Rejected',
                                                    child: Text('Rejected',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  updateStatus(reportId, value);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
