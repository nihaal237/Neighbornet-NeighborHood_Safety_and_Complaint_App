import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();

  bool isAnonymous = false;
  bool isLoading = false;

  List<PlatformFile> pickedFiles = [];

  String apiUrl = "http://127.0.0.1:8000/reports/create/";

  Map<String, dynamic> errors = {};

  Future<void> pickEvidenceFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "png", "pdf", "txt"],
    );

    if (result != null) {
      setState(() {
        pickedFiles = result.files;
      });
    }
  }

  Future<void> submitReport() async {
    setState(() {
      isLoading = true;
      errors = {};
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access");

    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

    request.headers["Authorization"] = "Bearer $token";

    request.fields["title"] = _title.text.trim();
    request.fields["description"] = _description.text.trim();
    request.fields["location"] = _location.text.trim();
    request.fields["isAnonymous"] = isAnonymous.toString();

    if (pickedFiles.isEmpty) {
      setState(() {
        errors["evidences"] = "At least one evidence file is required.";
        isLoading = false;
      });
      return;
    }

        // before sending request, after setting fields...
    for (var file in pickedFiles) {
      if (kIsWeb) {
        // file.bytes is available for FilePicker on Web
        final bytes = file.bytes;
        if (bytes == null) continue; // defensive
        final multipartFile = http.MultipartFile.fromBytes(
          'evidences', 
          bytes,
          filename: file.name,
        );
        request.files.add(multipartFile);
      } else {
        // Mobile/Desktop: use path
        request.files.add(await http.MultipartFile.fromPath(
          'evidences',
          file.path!,
          filename: file.name,
        ));
      }
    }


    // for (var file in pickedFiles) {
    //   request.files.add(await http.MultipartFile.fromPath(
    //     "evidences",
    //     file.path!,
    //   ));
    // }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var data = json.decode(responseBody);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully!")),
      );

      setState(() {
        pickedFiles.clear();
        _title.clear();
        _description.clear();
        _location.clear();
        isAnonymous = false;
      });
    } else if (response.statusCode == 400) {
      setState(() {
        errors = data["errors"];
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $data")));
    }

    setState(() => isLoading = false);
  }

  Widget errorText(String key) {
    if (!errors.containsKey(key)) return const SizedBox.shrink();

    return Text(
      errors[key],
      style: const TextStyle(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA5BCDF),
      appBar: AppBar(
        title: const Text("Submit Crime Report"),
        backgroundColor: const Color(0xFF5279C7),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            errorText("title"),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: "Report Title", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            errorText("description"),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: "Description", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            errorText("location"),
            TextField(
              controller: _location,
              decoration: const InputDecoration(
                  labelText: "Event Location", border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Switch(
                  value: isAnonymous,
                  onChanged: (value) {
                    setState(() => isAnonymous = value);
                  },
                ),
                const Text("Submit as Anonymous")
              ],
            ),

            const SizedBox(height: 20),

            errorText("evidences"),

            ElevatedButton.icon(
              onPressed: pickEvidenceFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text("Pick Evidence Files"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5279C7),
              ),
            ),

            if (pickedFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: pickedFiles
                      .map((file) =>
                          Text(file.name, style: const TextStyle(fontSize: 14)))
                      .toList(),
                ),
              ),

            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5279C7),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                    ),
                    child: const Text("Submit Report"),
                  ),
          ],
        ),
      ),
    );
  }
}
