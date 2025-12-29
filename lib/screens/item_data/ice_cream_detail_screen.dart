import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/ice_cream_data.dart';
import '../../services/cart_service/cart_service.dart';
import '../../widgets/custom_button.dart';
import '../tabs/cart_tab.dart';


class IceCreamDetailScreen extends StatefulWidget {
  const IceCreamDetailScreen({super.key});

  @override
  State<IceCreamDetailScreen> createState() => _IceCreamDetailScreenState();
}

class _IceCreamDetailScreenState extends State<IceCreamDetailScreen> {
  String _selectedSize = "Small";
  int _selectedFlavorIndex = 0;

  // -- DROPDOWN STATE --
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  int get _currentPrice {
    final flavor = IceCreamData.menu[_selectedFlavorIndex];
    final Map<String, int> prices = Map<String, int>.from(flavor['prices']);
    return prices[_selectedSize] ?? 0;
  }

  // --- DROPDOWN LOGIC ---
  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _showDropdown() {
    double width = MediaQuery.of(context).size.width - 40;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 55),
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Theme(
                data: ThemeData(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(Colors.orange),
                    radius: const Radius.circular(10),
                    thickness: WidgetStateProperty.all(6),
                  ),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: IceCreamData.menu.length,
                    itemBuilder: (context, index) {
                      final flavor = IceCreamData.menu[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFlavorIndex = index;
                          });
                          _closeDropdown();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: _selectedFlavorIndex == index ? Colors.grey[50] : Colors.white,
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Text(
                            flavor['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: _selectedFlavorIndex == index ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  @override
  void dispose() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFlavor = IceCreamData.menu[_selectedFlavorIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order Now",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),

      // Floating Cart
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150.0),
        child: ValueListenableBuilder<List<Map<String, String>>>(
          valueListenable: CartService().cartNotifier,
          builder: (context, cartItems, child) {
            if (cartItems.isEmpty) return const SizedBox();
            return FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              heroTag: 'icecream_cart',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartTab(isBackButtonEnabled: true)));
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  Positioned(
                    right: -5, top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Text(
                        cartItems.length.toString(),
                        style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),

      body: GestureDetector(
        onTap: () {
          if (_isDropdownOpen) _closeDropdown();
        },
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
                image: const DecorationImage(
                  image: AssetImage("assets/images/icecream.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Price and Delivery Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Total Price",
                                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)
                            ),
                            Text(
                              "Rs. $_currentPrice",
                              style: GoogleFonts.poppins(color: Colors.deepOrange, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        // 4. CENTERED DELIVERY TIME
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // Center Align
                          children: [
                            Text(
                              "Delivery Time",
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled, color: Colors.deepOrange, size: 18),
                                  const SizedBox(width: 5),
                                  Text(
                                    "30-40 min",
                                    style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Size Selector (Fixed)
                    Text("Select Size", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: IceCreamData.sizes.map((size) {
                        bool isSelected = _selectedSize == size;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedSize = size);
                              if (_isDropdownOpen) _closeDropdown();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.deepOrange : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: Colors.deepOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Dropdown Label
                    Text("Choose Flavor", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // CUSTOM DROPDOWN
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: GestureDetector(
                        onTap: _toggleDropdown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentFlavor['name'],
                                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                              ),
                              Icon(
                                  _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black54
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),

            // 5. BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: CustomButton(
                text: "Add to Cart",
                onPressed: () {
                  final item = IceCreamData.menu[_selectedFlavorIndex];
                  final String name = "${item['name']} Ice Cream ($_selectedSize)";
                  final String price = _currentPrice.toString();
                  const String img = "assets/images/icecream.jpg";

                  // Add to cart silently
                  CartService().addToCart(name, price, img);

                  if (_isDropdownOpen) _closeDropdown();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}