import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllowed;

  const LocationPermissionDialog({super.key, required this.onAllowed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.white,
      // InsetPadding controls how wide the dialog is
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        // Reduced Padding
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrinks height to fit content
          children: [
            // 1. Icon (Smaller)
            const Icon(
              Icons.location_on_rounded,
              size: 40,
              color: Color(0xFF007A8C),
            ),
            const SizedBox(height: 12), // Reduced spacing

            // 2. Title
            Text(
              "Allow Location Access?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16, // Smaller font
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Subtitle
            Text(
              "Foody needs your location to find nearby restaurants accurately.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // 4. Buttons (Stacked & Compact)

            // ALLOW BUTTON
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCDEEFE),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _handleLocationPermission(context);
                },
                child: Text(
                  "Allow",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // DON'T ALLOW BUTTON
            SizedBox(
              width: double.infinity,
              height: 45, // Reduced height
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Don't allow",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SMART LOGIC ---
  Future<void> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if GPS Hardware is ON
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If OFF, open settings
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. Check Permission Status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Still denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Guide user to App Settings if permanently denied
      await Geolocator.openAppSettings();
      return;
    }

    // 3. Success! Permission Granted & GPS On
    onAllowed();
  }
}