import 'dart:io' show Platform;
import 'package:auto_revop/models/spare_part_model.dart';
import 'package:auto_revop/models/cart_item_model.dart';
import 'package:auto_revop/services/inventory_service.dart';
import 'package:auto_revop/widgets/adaptive_button.dart' as widgets;
import 'package:auto_revop/widgets/cart_icon_button.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/auth_utils.dart'; // For authentication
import '../providers/translation_provider.dart';
import '../providers/cart_provider.dart';

class SparePartsPage extends StatefulWidget {
  const SparePartsPage({super.key});

  @override
  _SparePartsPageState createState() => _SparePartsPageState();
}

class _SparePartsPageState extends State<SparePartsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SparePart> _spareParts = [];
  List<SparePart> _filteredSpareParts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Translations are now handled by easy_localization directly
    _fetchInventory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventory() async {
    try {
      final parts = await InventoryService.fetchInventory();
      setState(() {
        _spareParts = parts;
        _filteredSpareParts = parts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().contains('connected to the internet')
            ? 'There was an error occurred, please check if you are connected to the internet.'
            : e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredSpareParts = _spareParts.where((part) {
        return part.name.toLowerCase().contains(query) ||
            part.description.toLowerCase().contains(query) ||
            part.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: Colors.white,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.white,
              transitionBetweenRoutes: false,
              // leading: const CartIconButton(),
              middle: Text(
                localeProvider.translate('partsPage'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: localeProvider.translate('searchSpareParts'),
                      placeholderStyle: TextStyle(color: Colors.black),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: Colors.black,
                      ),
                      style: const TextStyle(color: Colors.black),
                      backgroundColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CupertinoActivityIndicator())
                        : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error: $_error'),
                                const SizedBox(height: 16),
                                widgets.adaptiveButton(
                                  'Retry',
                                  () {
                                    setState(() {
                                      _error = null;
                                      _isLoading = true;
                                    });
                                    _fetchInventory();
                                  },
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredSpareParts.length,
                            itemBuilder: (context, index) {
                              final part = _filteredSpareParts[index];
                              return _buildSparePartCard(part);
                            },
                          ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                localeProvider.translate('partsPage'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              leading: const CartIconButton(),
              automaticallyImplyLeading: false,
              actions: const [SizedBox(width: 48)], // Balance the layout
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localeProvider.translate('searchSpareParts'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: $_error'),
                              const SizedBox(height: 16),
                              widgets.adaptiveButton(
                                'Retry',
                                () {
                                  setState(() {
                                    _error = null;
                                    _isLoading = true;
                                  });
                                  _fetchInventory();
                                },
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredSpareParts.length,
                          itemBuilder: (context, index) {
                            final part = _filteredSpareParts[index];
                            return _buildSparePartCard(part);
                          },
                        ),
                ),
              ],
            ),
          );
  }

  Widget _buildSparePartCard(SparePart part) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12.0),
              ),
              image: DecorationImage(
                image: NetworkImage(part.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        part.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ),
                    Text(
                      part.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  part.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${part.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemRed,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final isInCart = cartProvider.isInCart(part.id);
                    return Center(
                      child: widgets.adaptiveButton(
                        isInCart
                            ? Provider.of<LocaleProvider>(
                                context,
                              ).translate('Added To Cart')
                            : Provider.of<LocaleProvider>(
                                context,
                              ).translate('Add To Cart'),
                        isInCart
                            ? null
                            : () async {
                                // Check authentication before adding to cart
                                final isAuthenticated =
                                    await AuthUtils.checkAuthAndRedirect(
                                      context,
                                      {},
                                    );
                                if (isAuthenticated) {
                                  final cartItem = CartItem(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    productId: part.id,
                                    name: part.name,
                                    description: part.description,
                                    image: part.image,
                                    price: part.price,
                                  );
                                  cartProvider.addItem(cartItem);

                                  // Show snackbar feedback
                                  if (Platform.isIOS) {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoAlertDialog(
                                          title: Text('Added to Cart'),
                                          content: Text(
                                            '${part.name} has been added to your cart.',
                                          ),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: Text('OK'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${part.name} added to cart',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
