import 'dart:io' show Platform;
import 'package:auto_revop/models/cart_item_model.dart';
import 'package:auto_revop/models/spare_part_model.dart';
import 'package:auto_revop/pages/checkout_page.dart';
import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/translation_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: Colors.white,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.white,
              transitionBetweenRoutes: false,
              middle: Text(
                'Cart',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            child: SafeArea(
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  if (cartProvider.items.isEmpty) {
                    return _buildEmptyCart();
                  }
                  return _buildCartContent(cartProvider, localeProvider);
                },
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Cart',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
            ),
            body: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.items.isEmpty) {
                  return _buildEmptyCart();
                }
                return _buildCartContent(cartProvider, localeProvider);
              },
            ),
          );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.bag,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartProvider cartProvider, LocaleProvider localeProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return _buildCartItem(item, cartProvider);
            },
          ),
        ),
        _buildCartSummary(cartProvider, localeProvider),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  cartProvider.formatPrice(item.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildQuantityButton(
                    icon: CupertinoIcons.minus,
                    onPressed: () {
                      if (item.quantity > 1) {
                        cartProvider.updateQuantity(item.productId, item.quantity - 1);
                      } else {
                        cartProvider.removeItem(item.productId);
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: CupertinoIcons.plus,
                    onPressed: () {
                      cartProvider.updateQuantity(item.productId, item.quantity + 1);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cartProvider.formatPrice(item.price * item.quantity),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider, LocaleProvider localeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                cartProvider.formatPrice(cartProvider.totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Free',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                cartProvider.formatPrice(cartProvider.totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: adaptiveButton(
              'Checkout',
              () {
                // Convert cart items to spare parts for checkout
                final spareParts = cartProvider.items.map((item) {
                  // Create a minimal SparePart object for checkout
                  return SparePart(
                    id: item.productId,
                    name: item.name,
                    category: 'Cart Item',
                    quantity: item.quantity,
                    price: item.price,
                    supplier: 'N/A',
                    description: item.description,
                    image: item.image,
                    status: 'available',
                  );
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      orderedParts: spareParts,
                      selectedLanguage: localeProvider.currentLanguage,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
