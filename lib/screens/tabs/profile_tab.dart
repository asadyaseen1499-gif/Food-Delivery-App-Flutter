import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/auth_service.dart';
import '../login_signup_screens/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final User? user = FirebaseAuth.instance.currentUser;

  void _handleLogout() async {
    final AuthService authService = AuthService();
    await authService.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    child: ClipOval( // Clips the square image to a circle
                      child: CachedNetworkImage(
                        imageUrl: user?.photoURL ?? "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]), // Instant grey box while loading
                        errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Name (Black)
                  Text(
                    user?.displayName ?? "Marian Livera",
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Email (Grey)
                  Text(
                    user?.email ?? "marianli@gmail.com",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- SETTINGS LIST ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListTile(Icons.language, "Language", trailingText: "English (US)"),
                  _buildListTile(Icons.privacy_tip_outlined, "Privacy Policy"),
                  _buildListTile(Icons.settings_outlined, "Setting"),
                  _buildListTile(Icons.help_outline, "Help Center"),

                  // Logout with red styling
                  _buildListTile(Icons.logout, "Log Out", isDestructive: true, onTap: _handleLogout),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildListTile(IconData icon, String title, {String? trailingText, bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Icon Background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : Colors.black87,
                  size: 22
              ),
            ),
            const SizedBox(width: 18),

            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: isDestructive ? Colors.red : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Trailing Text
            if (trailingText != null)
              Text(
                trailingText,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            if (trailingText != null) const SizedBox(width: 10),

            // Arrow
            if (!isDestructive)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}