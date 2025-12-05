import 'dart:io' show Platform;

import 'package:auto_revop/models/spare_part_model.dart';
import 'package:auto_revop/pages/success_page.dart';
import 'package:auto_revop/services/inventory_service.dart';
import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';


class CheckoutPage extends StatefulWidget {
  final List<SparePart> orderedParts;
  final String? selectedLanguage;

  const CheckoutPage({
    super.key,
    required this.orderedParts,
    this.selectedLanguage,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isTermsAccepted = false;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<SparePart> _inventory = [];
  bool _isLoading = true;
  String? _error;
  String _selectedLanguage = 'English';

  // Show Terms and Conditions dialog
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Terms and Conditions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome to Auto RevOp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'By using our automotive marketplace application, you agree to the following terms and conditions:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '1. User Responsibilities',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• You must provide accurate and complete information when creating your account.\n'
                  '• You are responsible for maintaining the confidentiality of your account credentials.\n'
                  '• You agree to use the application only for lawful purposes.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '2. Service Usage',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Our platform connects users with automotive service providers and spare parts.\n'
                  '• We strive to provide accurate information but cannot guarantee the quality of services.\n'
                  '• Users should verify service provider credentials and reviews before booking.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '3. Privacy and Data Protection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• We collect and process personal information in accordance with our Privacy Policy.\n'
                  '• Your data is stored securely and used only for providing our services.\n'
                  '• We do not share your personal information with third parties without your consent.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '4. Payment and Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• All payments are processed securely through our payment partners.\n'
                  '• You agree to pay for services booked through our platform.\n'
                  '• Refunds are subject to the service provider\'s cancellation policy.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '5. Limitation of Liability',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Auto RevOp acts as a platform connecting users with service providers.\n'
                  '• We are not responsible for the quality or outcome of services provided.\n'
                  '• Our liability is limited to the amount paid for services through our platform.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '6. Account Termination',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• We reserve the right to suspend or terminate accounts that violate these terms.\n'
                  '• Users may delete their accounts at any time.\n'
                  '• Upon termination, your right to use the service ceases immediately.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'By agreeing to these terms, you acknowledge that you have read, understood, and accept all the conditions outlined above.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isTermsAccepted = true;
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  // late Map<String, String> translations; // No longer needed with easy_localization

  @override
  void initState() {
    super.initState();
    // Translations are now handled by easy_localization directly
    _selectedLanguage = widget.selectedLanguage ?? 'English';
    _fetchInventory();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventory() async {
    try {
      final inventory = await InventoryService.fetchInventory();
      setState(() {
        _inventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createOrder() async {
    if (widget.orderedParts.isEmpty) return;

    final orderData = {
      'customerName': 'Mobile App Customer', // Temporary name for mobile orders
      'customerPhone': _phoneController.text.trim(),
      'customerEmail': '', // Empty string
      'items': widget.orderedParts.map((part) => {
        'productId': part.id,
        'productName': part.name,
        'quantity': part.quantity,
        'price': part.price,
        'total': part.price * part.quantity,
      }).toList(),
      'totalAmount': widget.orderedParts.fold(0.0, (sum, part) => sum + (part.price * part.quantity)),
      'deliveryLocation': _locationController.text.trim(),
      'status': 'pending',
      'paymentMethod': 'cash',
      'notes': 'Order placed via mobile app',
    };

    try {
      setState(() => _isLoading = true);
      final result = await InventoryService.createOrder(orderData);

      // Navigate to success page with order details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            location: _locationController.text,
            phone: _phoneController.text,
            selectedLanguage: _selectedLanguage,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Show error dialog or snackbar
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Failed to create order: $e'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create order: $e')));
      }
    }
  }

  bool get _isFormValid {
    return _isTermsAccepted &&
        _locationController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalItems = widget.orderedParts.length;
    final totalPrice = widget.orderedParts.fold(0.0, (sum, part) => sum + (part.price * part.quantity));

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: Colors.white,
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              middle: Text(
                'order'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            child: SafeArea(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: totalItems > 0
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '$totalItems item${totalItems > 1 ? 's' : ''}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Icon(
                                                CupertinoIcons.cart,
                                                size: 60,
                                                color: Colors.grey.shade600,
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: CircleAvatar(
                                    backgroundColor: CupertinoColors.white,
                                    child: Icon(
                                      CupertinoIcons.clear,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Order Summary',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "TOTAL ITEMS: $totalItems",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cartProvider.formatPrice(totalPrice),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'subtotal'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                cartProvider.formatPrice(totalPrice),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'shipping'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'free'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'total'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                cartProvider.formatPrice(totalPrice),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CupertinoTextField(
                            controller: _locationController,
                            placeholder: 'location'.tr(),
                            placeholderStyle: TextStyle(color: Colors.black),
                            style: TextStyle(color: Colors.black),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(16.0),
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          CupertinoTextField(
                            controller: _phoneController,
                            placeholder: 'phone'.tr(),
                            placeholderStyle: TextStyle(color: Colors.black),
                            style: TextStyle(color: Colors.black),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(16.0),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => setState(() {}),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: adaptiveButton(
                              'checkout'.tr(),
                              _isFormValid && !_isLoading
                                  ? () => _createOrder()
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CupertinoCheckbox(
                                value: _isTermsAccepted,
                                onChanged: (val) {
                                  setState(() {
                                    _isTermsAccepted = val ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Accept our '.tr(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: TextStyle(
                                          color: CupertinoColors.activeBlue,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _showTermsAndConditions,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'order'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: totalItems > 0
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$totalItems item${totalItems > 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Icon(
                                              Icons.shopping_cart,
                                              size: 60,
                                              color: Colors.grey.shade600,
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Order Summary',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "TOTAL ITEMS: $totalItems",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cartProvider.formatPrice(totalPrice),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'subtotal'.tr(),
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              cartProvider.formatPrice(totalPrice),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'shipping'.tr(),
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'free'.tr(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              cartProvider.formatPrice(totalPrice),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _locationController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'location'.tr(),
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(17, 131, 192, 1),
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => setState(
                            () {},
                          ), // Trigger rebuild to update button state
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'phone'.tr(),
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(17, 131, 192, 1),
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (value) => setState(
                            () {},
                          ), // Trigger rebuild to update button state
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: adaptiveButton(
                            'checkout'.tr(),
                            _isFormValid && !_isLoading
                                ? () => _createOrder()
                                : null, // Disabled when terms or fields are incomplete or loading
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _isTermsAccepted,
                              onChanged: (val) {
                                setState(() {
                                  _isTermsAccepted = val ?? false;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'termsPrefix'.tr(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _showTermsAndConditions,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          );
  }
}
