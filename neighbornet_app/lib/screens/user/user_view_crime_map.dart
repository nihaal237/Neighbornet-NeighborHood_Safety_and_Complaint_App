import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CrimeMapScreen extends StatefulWidget {
  const CrimeMapScreen({super.key});

  @override
  State<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreen> {
  List<Marker> crimeMarkers = [];
  bool loading = true;
  double currentZoom = 12.0;
  late final MapController _mapController;

  // Data structures to track high-alert area
  Map<String, int> locationCounts = {};
  String? highestCrimeArea;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    fetchCrimeData();
  }

  Future<void> fetchCrimeData() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/reports/locations/"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Marker> markers = [];
        Map<String, int> counts = {};

        for (var r in data) {
          final lat = r["latitude"];
          final lng = r["longitude"];
          final locationName = r["location"] ?? "Unknown";

          if (lat == null || lng == null) continue;

          // Count occurrences for high-alert area
          counts[locationName] = (counts[locationName] ?? 0) + 1;

          // Normal marker
          markers.add(
            Marker(
              width: 40,
              height: 40,
              point: LatLng(lat, lng),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 35,
              ),
            ),
          );
        }

        // Find the location with highest reports
        String? maxArea;
        int maxCount = 0;
        counts.forEach((key, value) {
          if (value > maxCount) {
            maxCount = value;
            maxArea = key;
          }
        });

        // Highlight high-alert area markers differently
        if (maxArea != null) {
          for (var r in data) {
            if (r["location"] == maxArea) {
              final lat = r["latitude"];
              final lng = r["longitude"];
              if (lat != null && lng != null) {
                markers.add(
                  Marker(
                    width: 50,
                    height: 50,
                    point: LatLng(lat, lng),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                );
              }
            }
          }
        }

        setState(() {
          crimeMarkers = markers;
          locationCounts = counts;
          highestCrimeArea = maxArea;
          loading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }
  }

  void _zoomIn() {
    setState(() {
      currentZoom += 1;
      _mapController.move(_mapController.center, currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      currentZoom -= 1;
      _mapController.move(_mapController.center, currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    "Crime Map",
    style: TextStyle(
      color: Colors.white, // Make the title white
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  backgroundColor: const Color.fromARGB(255, 19, 44, 83), // dark blue
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white), // back arrow white
    onPressed: () {
      Navigator.pushReplacementNamed(context, '/userHome');
    },
  ),
),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Map area
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: LatLng(31.5204, 74.3587),
                          zoom: currentZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ),
                          MarkerLayer(markers: crimeMarkers),
                        ],
                      ),
                      Positioned(
                        right: 10,
                        bottom: 20,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              heroTag: "zoomIn",
                              mini: true,
                              onPressed: _zoomIn,
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 10),
                            FloatingActionButton(
                              heroTag: "zoomOut",
                              mini: true,
                              onPressed: _zoomOut,
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // High alert side panel
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blueGrey[50],
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "High Alert Area",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        (highestCrimeArea == null ||
                                highestCrimeArea!.isEmpty)
                            ? const Text("No data available")
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location: $highestCrimeArea",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Reports: ${locationCounts[highestCrimeArea!] ?? 0}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          "All Locations",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: ListView(
                            children: locationCounts.entries
                                .map(
                                  (e) => ListTile(
                                    title: Text(e.key),
                                    trailing: Text("${e.value} reports"),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
