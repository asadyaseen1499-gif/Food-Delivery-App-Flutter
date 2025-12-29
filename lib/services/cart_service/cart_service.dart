import 'package:flutter/material.dart';
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();
  final ValueNotifier<List<Map<String, String>>> cartNotifier = ValueNotifier([]);
  List<Map<String, String>> get cartItems => cartNotifier.value;
  int get cartCount => cartNotifier.value.length;

  void addToCart(String name, String price, String image) {
    final newList = List<Map<String, String>>.from(cartNotifier.value);
    newList.add({
      'name': name,
      'price': price,
      'image': image,
    });
    cartNotifier.value = newList; // Notify listeners
  }

  void removeFromCart(int index) {
    final newList = List<Map<String, String>>.from(cartNotifier.value);
    newList.removeAt(index);
    cartNotifier.value = newList;
  }

  void clearCart() {
    cartNotifier.value = [];
  }
}