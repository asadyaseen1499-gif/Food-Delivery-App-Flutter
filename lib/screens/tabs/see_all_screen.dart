import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/restaurant.dart';
import '../../widgets/restaurant_card.dart';
import '../resturant_detail/restaurant_detail_screen.dart';


class SeeAllScreen extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Function(String) onToggleFavorite;

  const SeeAllScreen({
    super.key,
    required this.restaurants,
    required this.onToggleFavorite,
  });

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("All Restaurants", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.restaurants.length,
        itemBuilder: (context, index) {
          final rest = widget.restaurants[index];
          return RestaurantCard(
            name: rest.name,
            rating: rest.rating,
            deliveryTime: rest.deliveryTime,
            imageUrl: rest.imageUrl,
            tags: rest.tags,
            discount: rest.discount,
            isFavorite: rest.isFavorite,
            onHeartTap: () {
              setState(() {
                widget.onToggleFavorite(rest.id);
              });
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(restaurant: rest),
                ),
              );
            },
          );
        },
      ),
    );
  }
}