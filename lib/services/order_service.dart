import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final double totalAmount;
  final String date;
  final String status;
  final List<Map<String, String>> items;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.date,
    required this.status,
    required this.items,
    required this.paymentMethod,
  });
}

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Notifies UI when orders change
  final ValueNotifier<List<OrderModel>> ordersNotifier = ValueNotifier([]);

  void placeOrder(double total, List<Map<String, String>> cartItems, String method) {
    // Create a copy of the list
    final currentOrders = List<OrderModel>.from(ordersNotifier.value);

    // Generate Order Data
    final newOrder = OrderModel(
      id: "#${1000 + currentOrders.length + 1}", // Simple ID generation
      totalAmount: total,
      date: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()), // Requires intl package or use DateTime.now().toString()
      status: "Processing",
      items: List.from(cartItems), // Copy items from cart
      paymentMethod: method,
    );

    // Add to top of list
    currentOrders.insert(0, newOrder);

    // Update listeners
    ordersNotifier.value = currentOrders;
  }
}