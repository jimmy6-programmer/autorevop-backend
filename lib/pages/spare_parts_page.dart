import 'dart:io' show Platform;
import 'dart:async';
import 'package:auto_revop/models/spare_part_model.dart';
import 'package:auto_revop/models/cart_item_model.dart';
import 'package:auto_revop/services/optimized_api_service.dart';
import 'package:auto_revop/widgets/adaptive_button.dart' as widgets;
// import 'package:auto_revop/widgets/cart_icon_button.dart';
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
    final cartProvider = Provider.of<CartProvider>(context);

    // Responsive grid columns
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredColumns = screenWidth >= 1200
        ? 4
        : screenWidth >= 768
        ? 3
        : 2;
    final maxCrossAxisExtent = screenWidth / desiredColumns - 16.0;

    // Adjust aspect ratio for taller cards on Android
    final childAspectRatio = Platform.isAndroid
        ? (desiredColumns == 2 ? 0.55 : desiredColumns == 3 ? 0.6 : 0.65)
        : (desiredColumns == 2 ? 0.75 : desiredColumns == 3 ? 0.8 : 0.85);

    // Adjust spacing for Android to prevent overflow
    final mainAxisSpacing = Platform.isAndroid ? 15.0 : 20.0;

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => Container(
                            height: 250,
                            color: CupertinoColors.systemBackground,
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: CupertinoColors.separator,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      const Text(
                                        'Select Currency',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: CupertinoColors.label,
                                        ),
                                      ),
                                      const SizedBox(width: 60), // Balance the layout
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 44.0,
                                    onSelectedItemChanged: (int index) {
                                      final currencies = cartProvider.exchangeRates.keys.toList();
                                      cartProvider.setCurrency(currencies[index]);
                                    },
                                    children: cartProvider.exchangeRates.keys.map((currency) {
                                      final isSelected = currency == cartProvider.selectedCurrency;
                                      final displayName = currency == 'RWF' ? 'RWF' : currency;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          displayName,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.label,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cartProvider.selectedCurrency,
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 16,
                            color: CupertinoColors.activeBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? SparePartsListSkeletonLoader(itemCount: 5, crossAxisCount: desiredColumns, childAspectRatio: childAspectRatio, mainAxisSpacing: mainAxisSpacing)
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
                              mainAxisSpacing: mainAxisSpacing,
                              childAspectRatio: childAspectRatio,
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
              // leading: const CartIconButton(),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  child: DropdownButton<String>(
                    value: cartProvider.selectedCurrency,
                    onChanged: (value) => cartProvider.setCurrency(value!),
                    items: cartProvider.exchangeRates.keys.map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency == 'RWF' ? 'RWF (Rwandan Franc)' : currency),
                    )).toList(),
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    dropdownColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? SparePartsListSkeletonLoader(itemCount: 5, crossAxisCount: desiredColumns, childAspectRatio: childAspectRatio, mainAxisSpacing: mainAxisSpacing)
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
                            mainAxisSpacing: mainAxisSpacing,
                            childAspectRatio: childAspectRatio,
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name - flexible to prevent overflow, allows full wrapping
                    Text(
                      part.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Text(
                          cartProvider.formatPrice(part.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemRed,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
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
          ),
        ],
      ),
    );
  }
}
