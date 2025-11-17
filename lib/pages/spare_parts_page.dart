import 'dart:io' show Platform;
import 'dart:async';
import 'package:auto_revop/models/spare_part_model.dart';
import 'package:auto_revop/models/cart_item_model.dart';
import 'package:auto_revop/services/optimized_api_service.dart';
import 'package:auto_revop/widgets/adaptive_button.dart' as widgets;
import 'package:auto_revop/widgets/cart_icon_button.dart';
import 'package:auto_revop/widgets/skeleton_loader.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload data when page becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OptimizedApiService().preloadCriticalData();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventory() async {
    try {
      final optimizedApi = OptimizedApiService();
      final parts = await optimizedApi.fetchSpareParts(
        page: 1,
        limit: 50,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      );

      if (mounted) {
        setState(() {
          _spareParts = parts;
          _filteredSpareParts = parts;
          _isLoading = false;
          _error = null; // Clear any previous error on success
        });
      }
    } catch (e) {
      if (mounted) {
        // Handle ApiError specifically
        if (e is ApiError) {
          switch (e.type) {
            case ApiErrorType.noInternet:
              setState(() {
                _error = 'No internet connection. Please check and try again.';
                _isLoading = false;
              });
              break;
            case ApiErrorType.timeout:
              // For timeouts (likely cold starts), retry automatically after a delay
              print('⏳ Timeout detected, retrying automatically...');
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _fetchInventory(); // Recursive retry
              }
              break;
            case ApiErrorType.serverError:
            case ApiErrorType.unknown:
              setState(() {
                _error = 'Unable to load spare parts. Please try again.';
                _isLoading = false;
              });
              break;
          }
        } else {
          // Fallback for non-ApiError exceptions
          setState(() {
            _error = 'No internet connection. Please check and try again.';
            _isLoading = false;
          });
        }
      }
    }
  }

  void _onSearchChanged() {
    // Debounce search to avoid excessive filtering on every keystroke
    final query = _searchController.text.toLowerCase();

    // Only update if query actually changed and widget is mounted
    if (!mounted) return;

    setState(() {
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

    // Responsive grid columns
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredColumns = screenWidth >= 1200
        ? 4
        : screenWidth >= 768
        ? 3
        : 2;
    final maxCrossAxisExtent = screenWidth / desiredColumns - 16.0;

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
                        ? const SparePartsListSkeletonLoader(itemCount: 5)
                        : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error: $_error'),
                                const SizedBox(height: 16),
                                widgets.adaptiveButton('Retry', () {
                                  setState(() {
                                    _error = null;
                                    _isLoading = true;
                                  });
                                  _fetchInventory();
                                }),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: desiredColumns,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 20.0,
                              childAspectRatio: desiredColumns == 2 ? 0.75 : desiredColumns == 3 ? 0.8 : 0.85,
                            ),
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
                      ? const SparePartsListSkeletonLoader(itemCount: 5)
                      : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: $_error'),
                              const SizedBox(height: 16),
                              widgets.adaptiveButton('Retry', () {
                                setState(() {
                                  _error = null;
                                  _isLoading = true;
                                });
                                _fetchInventory();
                              }),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: desiredColumns,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 20.0,
                            childAspectRatio: desiredColumns == 2 ? 0.75 : desiredColumns == 3 ? 0.8 : 0.85,
                          ),
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
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section - takes up about 60% of the card
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Image.network(
                part.image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          // Content section - takes up about 40% of the card
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name - flexible to prevent overflow
                  Flexible(
                    child: Text(
                      part.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    '\$${part.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  const Spacer(),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        final isInCart = cartProvider.isInCart(part.id);
                        return widgets.adaptiveButton(
                          isInCart
                              ? Provider.of<LocaleProvider>(context).translate('Added To Cart')
                              : Provider.of<LocaleProvider>(context).translate('Add To Cart'),
                          isInCart
                              ? null
                              : () async {
                                  final isAuthenticated =
                                      await AuthUtils.checkAuthAndRedirect(
                                        context,
                                        {},
                                      );
                                  if (isAuthenticated) {
                                    final cartItem = CartItem(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      productId: part.id,
                                      name: part.name,
                                      description: part.description,
                                      image: part.image,
                                      price: part.price,
                                    );
                                    cartProvider.addItem(cartItem);
                                    if (Platform.isIOS) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: const Text('Added to Cart'),
                                            content: Text(
                                              '${part.name} has been added to your cart.',
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          fontSize: 10,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
