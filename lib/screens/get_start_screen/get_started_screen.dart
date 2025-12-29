import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../../widgets/location_permission_dialog.dart';
import '../../widgets/custom_button.dart';
import '../login_signup_screens/login_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/food1.avif",
      "title": "Dive into Deliciousness",
      "desc": "Enjoy the juiciest burgers and finest cuisines prepared just for you.",
    },
    {
      "image": "assets/images/food2.avif",
      "title": "Find Restaurants Nearby",
      "desc": "Discover top-rated restaurants around you and explore new flavors today.",
    },
    {
      "image": "assets/images/food3.avif",
      "title": "Delivery at Your Doorstep",
      "desc": "Fast, contactless delivery right to your door. Freshness guaranteed.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPermissionDialog();
    });
  }

  Future<void> _checkAndShowPermissionDialog() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LocationPermissionDialog(
            onAllowed: () {
              LocationService().initLocation();
            },
          ),
        );
      }
    } else {
      LocationService().initLocation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _onboardingData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // BACKGROUND IMAGES
            Listener(
              onPointerDown: (_) => _stopAutoScroll(),
              onPointerUp: (_) => _startAutoScroll(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      image: DecorationImage(
                        image: AssetImage(_onboardingData[index]["image"]!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            // TOP GRADIENT SHADOW
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // BOTTOM GRADIENT OVERLAY
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 0.9],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),

            // CONTENT
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    _onboardingData[_currentPage]["title"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _onboardingData[_currentPage]["desc"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 5),
                        height: 6,
                        width: _currentPage == index ? 25 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFFFF7200) : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // BUTTON (Using CustomButton)
                  CustomButton(
                    text: "Get Started",
                    color: const Color(0xFFFF7200),
                    onPressed: () {
                      _stopAutoScroll();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}