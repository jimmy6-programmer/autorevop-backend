import 'package:auto_solutions/pages/success_page.dart';
import 'package:flutter/material.dart';
import 'package:auto_solutions/models/spare_part_model.dart';
import 'package:auto_solutions/widgets/adaptive_button.dart';
import 'package:auto_solutions/services/inventory_service.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, String> translations;
  final List<SparePart> orderedParts;

  const CheckoutPage({super.key, required this.translations, required this.orderedParts});

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

  @override
  void initState() {
    super.initState();
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

    final part = widget.orderedParts[0];
    final orderData = {
      'customerName': 'Mobile App Customer', // Temporary name for mobile orders
      'customerPhone': _phoneController.text.trim(),
      'customerEmail': '', // Empty string
      'items': [
        {
          'productId': part.id,
          'productName': part.name,
          'quantity': 1,
          'price': part.price,
          'total': part.price,
        }
      ],
      'totalAmount': part.price,
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
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Show error dialog or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: $e')),
      );
    }
  }

  bool get _isFormValid {
    return _isTermsAccepted &&
        _locationController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.orderedParts.isNotEmpty ? widget.orderedParts[0] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.translations['order'] ?? 'Order',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                                child: part != null
                                    ? Image.network(
                                        part.image,
                                        height: 120,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.close, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        part?.name ?? 'Unknown Item',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "QUANTITY: ${part?.quantity ?? 0}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(width: 20),
                Text(
                  "SUPPLIER: ${part?.supplier ?? 'N/A'}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "\$${part?.price.toStringAsFixed(2) ?? '0.00'}",
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
                Text(widget.translations['subtotal'] ?? 'SUBTOTAL', style: const TextStyle(fontSize: 14)),
                Text("\$${part?.price.toStringAsFixed(2) ?? '0.00'}", style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.translations['shipping'] ?? 'SHIPPING', style: const TextStyle(fontSize: 14)),
                Text(widget.translations['free'] ?? 'Free', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.translations['total'] ?? 'TOTAL',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${part?.price.toStringAsFixed(2) ?? '0.00'}",
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
                        decoration: InputDecoration(
                          labelText: widget.translations['location'] ?? 'Delivery Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (value) => setState(() {}), // Trigger rebuild to update button state
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: widget.translations['phone'] ?? 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => setState(() {}), // Trigger rebuild to update button state
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: adaptiveButton(
                          widget.translations['checkout'] ?? 'Checkout →',
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
                                text: widget.translations['termsPrefix'] ?? 'by confirming the order, I accept the ',
                                style: const TextStyle(color: Colors.black, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: widget.translations['termsLink'] ?? 'terms of the user agreement',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}