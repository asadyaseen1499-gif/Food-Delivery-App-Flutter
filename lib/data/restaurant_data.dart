import '../models/restaurant.dart';

class RestaurantData {
  static final List<Restaurant> list = [
    Restaurant(
      id: '1',
      name: "MUSA Cafe",
      rating: "4.5",
      deliveryTime: "20 min",
      imageUrl: "assets/images/resturants/musa/musa.jpg",
      sliderImages: [
        "assets/images/resturants/musa/musa1.jpg",
        "assets/images/resturants/musa/musa2.jpg",
        "assets/images/resturants/musa/musa.jpg",
      ],
      tags: "Burgers • Fast Food",
      discount: "10% OFF",
      latitude: 30.9648,
      longitude: 70.944,
      address: "Main Street, Layyah",
      whatsappNumber: "923228164521",

      menuCardImages: [
        "assets/images/resturants/musa/musa_menu.jpg",
      ],

      // Kept for logic compatibility
      menu: [],
    ),
    // ... Repeat for other restaurants (add menuCardImages to them too)
    Restaurant(
      id: '2',
      name: "The Backyard Grill",
      rating: "4.8",
      deliveryTime: "35 min",
      imageUrl: "assets/images/resturants/back.jpg",
      sliderImages: ["assets/images/food2.avif"],
      tags: "BBQ • Grill",
      latitude: 30.9650,
      longitude: 70.945,
      address: "Layyah Bypass",
      whatsappNumber: "923001234567",
      menuCardImages: ["assets/images/food1.avif"], // Menu Card
      menu: [],
    ),
  ];
}