import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ✅ YOUR MAPBOX TOKEN
const String mapboxAccessToken = "pk.eyJ1IjoiYXNhZDY0MiIsImEiOiJjbWpqbWs2d3QyMzQyM2RxeG13bHpkaHEyIn0.hZJzv1EWKjlgv2A3lJmRpw";

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();

  LatLng _currentCenter = const LatLng(31.5204, 74.3587);
  String _address = "Searching address...";
  bool _isMoving = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentCenter, 15);
        _fetchAddress(_currentCenter.latitude, _currentCenter.longitude);
      }
    } catch (e) {
      print("GPS Error: $e");
    }
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _address = "Fetching...");

    final url = Uri.parse(
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=$mapboxAccessToken"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          String placeName = data['features'][0]['place_name'];
          setState(() {
            _address = placeName;
          });
        } else {
          setState(() => _address = "Unnamed Location");
        }
      } else {
        setState(() => _address = "Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _address = "Check Internet");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() => _isMoving = true);
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  setState(() => _isMoving = false);
                  _currentCenter = event.camera.center;

                  _debounce = Timer(const Duration(milliseconds: 800), () {
                    _fetchAddress(_currentCenter.latitude, _currentCenter.longitude);
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken",
                userAgentPackageName: 'com.example.foodie',
                tileProvider: NetworkTileProvider(),
              ),
            ],
          ),

          // Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(
                  Icons.location_on,
                  size: 50,
                  color: _isMoving ? Colors.deepOrange.withValues(alpha: 0.6) : Colors.deepOrange
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Selected Location", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.deepOrange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: (_isMoving || _address.contains("Fetching") || _address.contains("Error"))
                          ? null
                          : () {
                        Navigator.pop(context, {
                          'lat': _currentCenter.latitude,
                          'lng': _currentCenter.longitude,
                          'address': _address,
                        });
                      },
                      child: const Text("Confirm Location", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}