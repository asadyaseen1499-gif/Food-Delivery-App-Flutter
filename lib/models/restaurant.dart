class MenuItem {
  final String name;
  final String price;
  final String description;
  final String image;

  MenuItem({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String rating;
  final String deliveryTime;
  final String imageUrl;
  final List<String> sliderImages;
  final String tags;
  final String? discount;
  final double latitude;
  final double longitude;
  final String address;
  final String whatsappNumber;

  final List<String> menuCardImages;

  final List<MenuItem> menu;

  String? distanceText;
  bool isFavorite;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.sliderImages,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.whatsappNumber,
    required this.menuCardImages,
    required this.menu,
    this.discount,
    this.isFavorite = false,
    this.distanceText,
  });
}