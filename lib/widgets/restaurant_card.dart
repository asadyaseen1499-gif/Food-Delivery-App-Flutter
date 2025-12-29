import 'package:flutter/material.dart';
import 'package:foodie/widgets/resturant_image/universal_image.dart';
import 'package:google_fonts/google_fonts.dart';


class RestaurantCard extends StatelessWidget {
  final String name;
  final String rating;
  final String deliveryTime;
  final String imageUrl;
  final String tags;
  final String? discount;
  final bool isFavorite;
  final VoidCallback? onHeartTap;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.tags,
    this.discount,
    this.isFavorite = false,
    this.onHeartTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  // ✅ USE UNIVERSAL IMAGE
                  child: UniversalImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 15, left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(deliveryTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: GestureDetector(
                    onTap: onHeartTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (discount != null)
                  Positioned(
                    bottom: 10, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: const BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.horizontal(right: Radius.circular(10))),
                      child: Text(discount!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(tags, style: TextStyle(color: Colors.grey[500], fontSize: 12), overflow: TextOverflow.ellipsis)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}