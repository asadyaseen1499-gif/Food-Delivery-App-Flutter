import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? cachedPosition;
  String? cachedAddress;
  bool isFetching = false;
  Future<bool> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final double? lat = prefs.getDouble('saved_lat');
      final double? lng = prefs.getDouble('saved_lng');
      final String? addr = prefs.getString('saved_address');

      if (lat != null && lng != null && addr != null) {
        cachedPosition = Position(
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0
        );
        cachedAddress = addr;
        return true;
      }
    } catch (e) {
      print("Error loading saved location: $e");
    }
    return false;
  }
  Future<void> initLocation() async {
    if (isFetching) return;
    isFetching = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          isFetching = false;
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String street = place.street ?? "";
        String area = place.subLocality ?? place.locality ?? "";
        String city = place.locality ?? place.administrativeArea ?? "";
        if (street == area) street = "";

        String finalAddress = "$street $area, $city".trim().replaceAll(RegExp(r'^, |^, |, $'), '');

        // Update Memory
        cachedPosition = position;
        cachedAddress = finalAddress;

        // SAVE TO DISK
        _saveToStorage(position.latitude, position.longitude, finalAddress);
      }
    } catch (e) {
      print("Location Error: $e");
    } finally {
      isFetching = false;
    }
  }

  // --- 3. HELPER TO SAVE DATA ---
  Future<void> _saveToStorage(double lat, double lng, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saved_lat', lat);
    await prefs.setDouble('saved_lng', lng);
    await prefs.setString('saved_address', address);
  }

  // Call this if user manually picks location from map
  Future<void> manualUpdate(double lat, double lng, String address) async {
    cachedPosition = Position(
        latitude: lat, longitude: lng, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
    cachedAddress = address;
    await _saveToStorage(lat, lng, address);
  }
}