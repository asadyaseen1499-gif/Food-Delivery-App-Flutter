import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie/screens/tabs/see_all_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/restaurant.dart';
import '../../services/location_service.dart';
import '../../widgets/resturant_image/universal_image.dart';
import '../item_data/burger_detail_screen.dart';
import '../item_data/ice_cream_detail_screen.dart';
import '../item_data/pizza_detail_screen.dart';
import '../resturant_detail/restaurant_detail_screen.dart';
import 'location_picker_screen.dart';


class HomeTab extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Function(String) onToggleFavorite;
  final String currentAddress;
  final Function(double, double, String) onLocationChanged;

  const HomeTab({
    super.key,
    required this.restaurants,
    required this.onToggleFavorite,
    required this.currentAddress,
    required this.onLocationChanged,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLocating = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentAddress == "Select Location") {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);
    final locationService = LocationService();

    if (locationService.cachedAddress != null && locationService.cachedPosition != null) {
      widget.onLocationChanged(
          locationService.cachedPosition!.latitude,
          locationService.cachedPosition!.longitude,
          locationService.cachedAddress!
      );
      if (mounted) setState(() => _isLocating = false);
      return;
    }

    await locationService.initLocation();

    if (locationService.cachedAddress != null && mounted) {
      widget.onLocationChanged(
          locationService.cachedPosition!.latitude,
          locationService.cachedPosition!.longitude,
          locationService.cachedAddress!
      );
    }
    if (mounted) setState(() => _isLocating = false);
  }

  void _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null) {
      widget.onLocationChanged(result['lat'], result['lng'], result['address']);
    }
  }
  void _handleSearch(String query) {
    String term = query.toLowerCase().trim();
    if (term.contains("pizza")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PizzaDetailScreen()));
    } else if (term.contains("burger")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BurgerDetailScreen()));
    } else if (term.contains("ice") || term.contains("cream")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const IceCreamDetailScreen()));
    } else if (term.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No results found for '$query'")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrange,
          statusBarIconBrightness: Brightness.light,
        ),
        title: InkWell(
          onTap: _openMap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Delivering to", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  _isLocating
                      ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Flexible(
                    child: Text(
                      widget.currentAddress,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/images/banner.jpg"),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.deepOrange.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _handleSearch,
                decoration: InputDecoration(
                  hintText: "Try 'Pizza', 'Burger', 'Ice Cream'...",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => _searchController.clear(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            Text(
                "Order Now",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. PIZZA
                _buildCategoryItem("Pizza", Icons.local_pizza, Colors.orange.shade100, Colors.orange, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PizzaDetailScreen()));
                }),

                // 2. BURGER
                _buildCategoryItem("Burger", Icons.lunch_dining, Colors.red.shade100, Colors.red, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BurgerDetailScreen()));
                }),

                // 3. ICE CREAM
                _buildCategoryItem("Ice Cream", Icons.icecream, Colors.blue.shade100, Colors.blue, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const IceCreamDetailScreen()));
                }),

                // 4. DEALS (Placeholder)
                _buildCategoryItem("Deals", Icons.local_offer, Colors.green.shade100, Colors.green, onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deals coming soon!")));
                }),
              ],
            ),

            const SizedBox(height: 30),

            // NEARBY RESTAURANTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Nearby Restaurants", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllScreen(
                      restaurants: widget.restaurants,
                      onToggleFavorite: widget.onToggleFavorite,
                    )));
                  },
                  child: const Text("See All", style: TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),

            const SizedBox(height: 10),

            // HORIZONTAL LIST
            SizedBox(
              height: 260,
              child: widget.restaurants.isEmpty && !_isLocating
                  ? Center(child: Text("No restaurants found", style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: widget.restaurants.take(5).length,
                itemBuilder: (context, index) {
                  final rest = widget.restaurants[index];
                  return _buildHorizontalCard(rest);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color bgColor, Color iconColor, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(Restaurant rest) {
    final hour = DateTime.now().hour;
    final bool isOpen = hour >= 11 && hour < 23;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestaurantDetailScreen(restaurant: rest)),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 15, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: UniversalImage(
                    imageUrl: rest.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(rest.distanceText ?? rest.deliveryTime, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isOpen ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text(isOpen ? "Open" : "Closed", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                if (rest.discount != null)
                  Positioned(
                    bottom: 10, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                      child: Text(rest.discount!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      rest.name,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(rest.rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 4),
                        const Text("•", style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            rest.tags,
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}