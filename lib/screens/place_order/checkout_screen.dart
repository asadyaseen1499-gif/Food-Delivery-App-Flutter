import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/cart_service/cart_service.dart';
import '../../services/location_service.dart';
import '../../services/order_service.dart';
import '../../widgets/app_styles.dart';
import '../../widgets/custom_button.dart';
import '../tabs/home_screen.dart';


class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Map Variables
  final MapController _mapController = MapController();
  LatLng _userLocation = const LatLng(31.5204, 74.3587);
  final String _mapboxToken = "pk.eyJ1IjoiYXNhZDY0MiIsImEiOiJjbWpqbWs2d3QyMzQyM2RxeG13bHpkaHEyIn0.hZJzv1EWKjlgv2A3lJmRpw";

  String _liveAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? "";
    }

    final locationService = LocationService();
    if (locationService.cachedPosition != null) {
      setState(() {
        _userLocation = LatLng(
            locationService.cachedPosition!.latitude,
            locationService.cachedPosition!.longitude
        );
        _liveAddress = locationService.cachedAddress ?? "Unknown Location";
      });
    } else {
      _getAddressFromLatLng(_userLocation);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _liveAddress = "${place.street}, ${place.subLocality ?? place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() => _liveAddress = "Unknown Location");
    }
  }

  void _showPaymentOptions() {
    if (_formKey.currentState!.validate()) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (context) {
          return Container(
            height: 450,
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 25),
                Text("Select Payment Method", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // 1. CASH ON DELIVERY (Places Order)
                _buildPaymentOption(
                    name: "Cash on Delivery",
                    imagePath: "assets/images/cod.png",
                    onTap: () {
                      Navigator.pop(context);
                      _confirmOrder("Cash on Delivery");
                    }
                ),
                const SizedBox(height: 15),

                // 2. JAZZCASH (Show Message)
                _buildPaymentOption(
                    name: "JazzCash",
                    imagePath: "assets/images/jazz.png",
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonMessage("JazzCash");
                    }
                ),
                const SizedBox(height: 15),

                // 3. EASYPAISA (Show Message)
                _buildPaymentOption(
                    name: "Easypaisa",
                    imagePath: "assets/images/easy.jpg",
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonMessage("Easypaisa");
                    }
                ),
              ],
            ),
          );
        },
      );
    }
  }


  void _showComingSoonMessage(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$method payment method will be added soon"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }


  Widget _buildPaymentOption({
    required String name,
    required String imagePath,
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
          ]
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100)
          ),

          child: Image.asset(
            imagePath,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (c,e,s) => const Icon(Icons.payment, size: 30, color: Colors.grey),
          ),
        ),
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _confirmOrder(String paymentMethod) {
    final currentCart = CartService().cartItems;
    OrderService().placeOrder(widget.totalAmount, currentCart, paymentMethod);
    CartService().clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 15),
              Text("Order Placed!", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Your order has been placed via $paymentMethod.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 25),
              CustomButton(
                text: "Go to Home",
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Checkout", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total to Pay", style: GoogleFonts.poppins(fontSize: 16, color: Colors.deepOrange)),
                            Text("Rs. ${widget.totalAmount.toInt()}", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      Text("Contact Details", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _nameController,
                        validator: (val) => val!.isEmpty ? "Name is required" : null,
                        decoration: AppStyles.inputDecoration("Full Name", Icons.person_outline),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val!.isEmpty ? "Phone number is required" : null,
                        decoration: AppStyles.inputDecoration("Mobile Number", Icons.phone_android),
                      ),

                      const SizedBox(height: 25),

                      Text("Delivery Location", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      // Map
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _userLocation,
                                  initialZoom: 15.0,
                                  onMapEvent: (event) {
                                    if (event is MapEventMoveEnd) {
                                      _userLocation = event.camera.center;
                                      _getAddressFromLatLng(_userLocation);
                                    }
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken",
                                    userAgentPackageName: 'com.example.foodie',
                                  ),
                                ],
                              ),
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 30),
                                  child: Icon(Icons.location_on, color: Colors.deepOrange, size: 40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.my_location, color: Colors.deepOrange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _liveAddress,
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: CustomButton(
                              text: "Next",
                              onPressed: _showPaymentOptions,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}