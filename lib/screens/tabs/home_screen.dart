import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foodie/screens/tabs/profile_tab.dart';
import '../../data/restaurant_data.dart';
import '../../models/restaurant.dart';
import '../../services/location_service.dart';
import 'cart_tab.dart';
import 'home_tab.dart';
import 'orders_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userAddress = "Select Location";

  // Load the static list from your data file
  final List<Restaurant> _restaurants = List.from(RestaurantData.list);

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    final locationService = LocationService();
    // Load from disk (Shared Preferences)
    bool hasSavedData = await locationService.loadFromStorage();

    if (hasSavedData && mounted) {
      setState(() {
        _userAddress = locationService.cachedAddress!;
      });

      // Update distances based on the saved location
      if (locationService.cachedPosition != null) {
        _updateDistances(
            locationService.cachedPosition!.latitude,
            locationService.cachedPosition!.longitude
        );
      }
    }
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _restaurants.indexWhere((r) => r.id == id);
      if (index != -1) {
        _restaurants[index].isFavorite = !_restaurants[index].isFavorite;
      }
    });
  }

  // --- 2. UPDATE LOCATION & DISTANCES ---
  void _onLocationChanged(double lat, double lng, String address) {
    // Save new location
    LocationService().manualUpdate(lat, lng, address);

    if (!mounted) return;
    setState(() {
      _userAddress = address;
    });

    // Recalculate distances for your list
    _updateDistances(lat, lng);
  }

  void _updateDistances(double userLat, double userLng) {
    setState(() {
      for (var rest in _restaurants) {
        double distMeters = Geolocator.distanceBetween(userLat, userLng, rest.latitude, rest.longitude);
        rest.distanceText = "${(distMeters / 1000).toStringAsFixed(1)} km";
      }


      _restaurants.sort((a, b) {
        double distA = double.tryParse(a.distanceText?.split(' ')[0] ?? '0') ?? 0;
        double distB = double.tryParse(b.distanceText?.split(' ')[0] ?? '0') ?? 0;
        return distA.compareTo(distB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final List<Widget> pages = [
      HomeTab(
        restaurants: _restaurants,
        onToggleFavorite: _toggleFavorite,
        currentAddress: _userAddress,
        onLocationChanged: _onLocationChanged,
      ),
      const OrdersTab(),
      const CartTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5)
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
          ],
        ),
      ),
    );
  }
}