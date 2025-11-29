import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CrimeMapScreenPolice extends StatefulWidget {
  const CrimeMapScreenPolice({super.key});

  @override
  State<CrimeMapScreenPolice> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreenPolice> {
  List<Marker> crimeMarkers = [];
  bool loading = true;
  MapController mapController = MapController();
  double currentZoom = 12.0;

  final Map<String, Color> statusColors = {
    "Pending": Colors.red,
    "Processing": Colors.orange,
    "Verified": Colors.blue,
    "Resolved": Colors.green,
    "Rejected": Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    fetchCrimeData();
  }

  Future<void> fetchCrimeData() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/reports/locations/"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Marker> markers = [];

      for (var r in data) {
        final lat = r["latitude"];
        final lng = r["longitude"];
        final status = r["status"] ?? "Pending";

        if (lat == null || lng == null) continue;

        markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(lat, lng),
            child: GestureDetector(
              onTap: () {
                final dateTimeStr = r["dateTime"] ?? "";
                String formattedTime = "Unknown";
                try {
                  final dt = DateTime.parse(dateTimeStr);
                  formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                } catch (_) {}

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(r["title"] ?? "Report"),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(status, style: TextStyle(color: statusColors[status])),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text("Location: ${r["location"] ?? "Unknown"}"),
                          Text("Submitted: $formattedTime"),
                          const SizedBox(height: 10),
                          const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(r["description"] ?? ""),
                          const SizedBox(height: 10),
                          if (r["user_display"] != null)
                            Text(r["user_display"]!, style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
              child: Icon(
                Icons.location_on,
                color: statusColors[status] ?? Colors.black,
                size: 35,
              ),
            ),
          ),
        );
      }

      setState(() {
        crimeMarkers = markers;
        loading = false;
      });
    }
  }

  void zoomIn() {
    currentZoom++;
    mapController.move(mapController.center, currentZoom);
  }

  void zoomOut() {
    currentZoom--;
    mapController.move(mapController.center, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crime Map"),
        backgroundColor: const Color.fromARGB(255, 185, 205, 236),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: LatLng(31.5204, 74.3587),
                    zoom: currentZoom,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    MarkerLayer(markers: crimeMarkers),
                  ],
                ),
                // Zoom buttons
                Positioned(
                  right: 10,
                  top: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomIn",
                        onPressed: zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 5),
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomOut",
                        onPressed: zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
                // Legend
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: statusColors.entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, color: e.value, size: 20),
                                  const SizedBox(width: 5),
                                  Text(e.key),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
