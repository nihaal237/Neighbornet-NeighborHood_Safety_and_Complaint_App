import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late MapController _mapController;
  double _currentZoom = 13.0;

  LatLng? pickedLocation;
  PlatformFile? txtFile;
  PlatformFile? imgFile;

  bool _isSubmitting = false;
  String? token;

  // Default Lahore coordinates
  final LatLng _lahoreLatLng = LatLng(31.5497, 74.3436);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access");
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _pickTxtFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      txtFile = result.files.first;
      setState(() {});
    }
  }

  Future<void> _pickImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      imgFile = result.files.first;
      setState(() {});
    }
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        pickedLocation == null ||
        txtFile == null ||
        imgFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Fill all fields and select files & location")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    var uri = Uri.parse("http://127.0.0.1:8000/submitReport/");
    var request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Add form fields
    request.fields['title'] = _titleController.text.trim();
    request.fields['description'] = _descController.text.trim();
    request.fields['location'] = _locationController.text.trim();
    request.fields['latitude'] = pickedLocation!.latitude.toString();
    request.fields['longitude'] = pickedLocation!.longitude.toString();

    // Add files using fromBytes (works on Web & Mobile)
    if (txtFile != null && txtFile!.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'txt_file',
          txtFile!.bytes!,
          filename: txtFile!.name,
        ),
      );
    }

    if (imgFile != null && imgFile!.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'img_file',
          imgFile!.bytes!,
          filename: imgFile!.name,
        ),
      );
    }

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report submitted successfully!")),
        );
        // Clear fields
        _titleController.clear();
        _descController.clear();
        _locationController.clear();
        txtFile = null;
        imgFile = null;
        pickedLocation = null;
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to submit. Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      if (_currentZoom > 18) _currentZoom = 18;
      _mapController.move(pickedLocation ?? _lahoreLatLng, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      if (_currentZoom < 10) _currentZoom = 10;
      _mapController.move(pickedLocation ?? _lahoreLatLng, _currentZoom);
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Submit Report",
        style: TextStyle(
          color: Colors.white, // Title text color
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 19, 44, 83),
      iconTheme: const IconThemeData(
        color: Colors.white, // Back arrow color
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Manual location
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: "Location (optional manual)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Map picker
          SizedBox(
            height: 300,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _lahoreLatLng,
                zoom: _currentZoom,
                minZoom: 10,
                maxZoom: 18,
                onTap: (tapPosition, point) {
                  setState(() {
                    pickedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.neighbornet_app',
                ),
                if (pickedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: pickedLocation!,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Zoom buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: _zoomIn, icon: const Icon(Icons.zoom_in)),
              IconButton(onPressed: _zoomOut, icon: const Icon(Icons.zoom_out)),
            ],
          ),
          const SizedBox(height: 12),

          // TXT file picker
          ElevatedButton(
            onPressed: _pickTxtFile,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5279C7)),
            child: const Text("Select TXT File"),
          ),
          if (txtFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text("Selected TXT: ${txtFile!.name}"),
            ),
          const SizedBox(height: 8),

          // Image file picker
          ElevatedButton(
            onPressed: _pickImageFile,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5279C7)),
            child: const Text("Select Image (PNG / JPG)"),
          ),
          if (imgFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text("Selected Image: ${imgFile!.name}"),
            ),
          const SizedBox(height: 20),

          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5279C7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Submit Report"),
                ),
        ],
      ),
    ),
  );
}

}