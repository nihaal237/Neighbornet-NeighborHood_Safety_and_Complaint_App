import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PoliceReportsScreen extends StatefulWidget {
  final String accessToken;

  const PoliceReportsScreen({super.key, required this.accessToken});

  @override
  State<PoliceReportsScreen> createState() => _PoliceReportsScreenState();
}

class _PoliceReportsScreenState extends State<PoliceReportsScreen> {
  List reports = [];
  bool isLoading = true;
  Map<int, bool> showEvidences = {}; // Track which report's evidences are shown

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/police/reports/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final fetchedReports = json.decode(response.body) as List;
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
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reports: $e')),
      );
    }
  }

  Future<void> updateStatus(int reportId, String newStatus) async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Widget buildEvidence(Map<String, dynamic> e) {
    final url = (e['file_url'] ?? '') as String;
    if (url.isEmpty) return const SizedBox.shrink();

    if (url.endsWith('.jpg') || url.endsWith('.png')) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          child: Image.network(
            url,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Text("Error loading image"),
          ),
        ),
      );
    } else if (url.endsWith('.txt')) {
      return FutureBuilder<String>(
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
                snapshot.data ?? '',
                style: const TextStyle(fontSize: 14, color: Color(0xFF303030)),
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
      color: Colors.white, // Title white
    ),
  ),
  backgroundColor: const Color.fromARGB(255, 19, 44, 83), // Dark blue
  iconTheme: const IconThemeData(
    color: Colors.white, // Back arrow white
  ),
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
                        color: Color(0xFF303030)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final reportId = report['id'];

                    // Safe access with defaults
                    final title = report['title'] ?? 'No Title';
                    final description = report['description'] ?? 'No Description';
                    final location = report['location'] ?? 'N/A';
                    final status = report['status'] ?? 'Pending';
                    final userDisplay = report['user_display'] ?? 'Anonymous';
                    final dateTime = report['dateTime'] != null
                        ? DateTime.tryParse(report['dateTime'])
                        : null;
                    final formattedDate = dateTime != null
                        ? DateFormat('dd MMM yyyy, hh:mm a')
                            .format(dateTime.toLocal())
                        : "Unknown";
                    final evidences = report['evidences'] ?? [];

                    // Sort evidences: images first, then text
                    final sortedEvidences = [
                      ...evidences.where((e) {
                        final url = (e['file_url'] ?? '') as String;
                        return url.endsWith('.jpg') || url.endsWith('.png');
                      }),
                      ...evidences.where((e) {
                        final url = (e['file_url'] ?? '') as String;
                        return url.endsWith('.txt');
                      }),
                    ].toList();

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF303030))),
                            const SizedBox(height: 4),
                            Text(
                                "$userDisplay | Date: $formattedDate",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text(description,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF303030))),
                            const SizedBox(height: 4),
                            Text("Location: $location",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            const SizedBox(height: 10),

                            // Interactive evidences
                            if (sortedEvidences.isNotEmpty)
                              Column(
                                children: [
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromARGB(255, 19, 44, 83),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showEvidences[reportId] =
                                              !(showEvidences[reportId] ?? false);
                                        });
                                      },
                                      child: Text(
                                        showEvidences[reportId] == true
                                            ? "Hide Evidences"
                                            : "View Evidences",
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (showEvidences[reportId] == true)
                                    SizedBox(
                                      height: 120,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: sortedEvidences
                                            .map<Widget>(
                                                (e) => buildEvidence(e))
                                            .toList(),
                                      ),
                                    ),
                                  const SizedBox(height: 12),

                                  // Status dropdown
                                  Center(
                                    child: Container(
                                      width: 220,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 19, 44, 83),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Column(
                                        children: [
                                          const Text("Status Change",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(height: 6),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                                canvasColor:
                                                    const Color(0xFF1E3A8A)),
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: status,
                                              iconEnabledColor: Colors.white,
                                              dropdownColor:
                                                  const Color.fromARGB(255, 19, 44, 83),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
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
                                                if (value != null)
                                                  updateStatus(reportId, value);
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
