import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  static const String _currencyKey = 'selected_currency';
  List<CartItem> _items = [];
  String _selectedCurrency = 'USD';

  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'AED': 3.6725,
    'AOA': 800.0,
    'AUD': 1.5,
    'BIF': 2800.0,
    'BRL': 5.0,
    'CAD': 1.35,
    'CHF': 0.91,
    'CNH': 7.25,
    'CNY': 7.25,
    'CZK': 23.5,
    'DKK': 6.8,
    'EGP': 30.9,
    'ETB': 57.0,
    'EUR': 0.92,
    'GBP': 0.765,
    'GHS': 12.0,
    'GNF': 8600.0,
    'HKD': 7.8,
    'HUF': 350.0,
    'IDR': 15000.0,
    'ILS': 3.7,
    'INR': 83.0,
    'JPY': 145.0,
    'JOD': 0.71,
    'KES': 129.0,
    'KMF': 450.0,
    'KRW': 1300.0,
    'KWD': 0.31,
    'LSL': 18.0,
    'LYD': 4.8,
    'MAD': 10.0,
    'MRO': 36.0,
    'MUR': 45.0,
    'MWK': 1700.0,
    'MZN': 64.0,
    'NGN': 750.0,
    'NOK': 10.5,
    'PKR': 278.0,
    'PLN': 4.0,
    'QAR': 3.64,
    'RUB': 90.0,
    'SAR': 3.75,
    'SDG': 600.0,
    'SEK': 10.5,
    'SGD': 1.35,
    'SSP': 1300.0,
    'SZL': 18.0,
    'TRY': 28.0,
    'TZS': 2300.0,
    'UGX': 3700.0,
    'XAF': 600.0,
    'XDR': 0.73,
    'XOF': 600.0,
    'ZAR': 18.0,
    'ZMW': 25.0,
    'ZIG': 13.0,
    'RWF': 1456.015,
  };

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get selectedCurrency => _selectedCurrency;

  Map<String, double> get exchangeRates => _exchangeRates;

  double convertPrice(double usdPrice) {
    double selectedRate = _exchangeRates[_selectedCurrency]!;
    return usdPrice * selectedRate;
  }

  String formatPrice(double usdPrice) {
    double converted = convertPrice(usdPrice);
    return '${_selectedCurrency} ${converted.toStringAsFixed(2)}';
  }

  double get totalPriceConverted => _items.fold(0.0, (sum, item) => sum + convertPrice(item.totalPrice));

  CartProvider() {
    _loadCartFromStorage();
    _loadCurrencyFromStorage();
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }

  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  Future<void> _loadCurrencyFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currency = prefs.getString(_currencyKey);
      if (currency != null && _exchangeRates.containsKey(currency)) {
        _selectedCurrency = currency;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading currency from storage: $e');
    }
  }

  Future<void> _saveCurrencyToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, _selectedCurrency);
    } catch (e) {
      debugPrint('Error saving currency to storage: $e');
    }
  }

  void setCurrency(String currency) {
    if (_exchangeRates.containsKey(currency)) {
      _selectedCurrency = currency;
      _saveCurrencyToStorage();
      notifyListeners();
    }
  }

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    _saveCartToStorage();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveCartToStorage();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
        _saveCartToStorage();
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartToStorage();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  CartItem? getItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}