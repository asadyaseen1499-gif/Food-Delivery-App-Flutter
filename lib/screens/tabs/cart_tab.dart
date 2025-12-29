import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_service/cart_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/resturant_image/universal_image.dart';
import '../place_order/checkout_screen.dart';




class CartTab extends StatelessWidget {
  final bool isBackButtonEnabled;

  const CartTab({super.key, this.isBackButtonEnabled = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // 1. APP BAR
      appBar: AppBar(
        title: Text("My Cart", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        leading: isBackButtonEnabled
            ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => CartService().clearCart(),
          )
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: CartService().cartNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("Your Cart is Empty", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 18)),
                ],
              ),
            );
          }

          // --- CALCULATE BILL ---
          double subtotal = 0;
          for (var item in cartItems) {
            String priceStr = item['price']!.replaceAll(RegExp(r'[^0-9]'), '');
            subtotal += double.tryParse(priceStr) ?? 0;
          }
          double deliveryCharges = 200.0;
          double total = subtotal + deliveryCharges;
          // ---------------------

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            // 2. FIXED IMAGE VISIBILITY
                            child: UniversalImage(
                              imageUrl: item['image']!, // This now handles assets correctly
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name']!,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text("Rs. ${item['price']}", style: const TextStyle(color: Colors.deepOrange)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                            onPressed: () => CartService().removeFromCart(index),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- BILL & CHECKOUT SECTION ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bill Details
                    _buildBillRow("Subtotal", "Rs. ${subtotal.toInt()}"),
                    const SizedBox(height: 10),
                    _buildBillRow("Delivery Fee", "Rs. ${deliveryCharges.toInt()}"),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                    _buildBillRow("Total", "Rs. ${total.toInt()}", isBold: true),

                    const SizedBox(height: 20),

                    // Place Order Button
                    CustomButton(
                      text: "Place Order",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutScreen(totalAmount: total)),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: isBold ? Colors.black : Colors.grey[600], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, color: isBold ? Colors.deepOrange : Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}