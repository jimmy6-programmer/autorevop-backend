import 'dart:io' show Platform;
import 'package:auto_revop/models/spare_part_model.dart';
import 'package:auto_revop/pages/checkout_page.dart';
import 'package:auto_revop/services/inventory_service.dart';
import 'package:auto_revop/widgets/adaptive_button.dart' as widgets;


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/auth_utils.dart'; // For authentication

class SparePartsPage extends StatefulWidget {
  final Map<String, String> translations;

  const SparePartsPage({super.key, required this.translations});

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
        _error = e.toString();
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
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              middle: Text(
                widget.translations['partsPage'] ?? 'Parts',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
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
                      placeholder:
                          widget.translations['searchSpareParts'] ??
                          'Search Spare Parts',
                      prefixIcon: const Icon(CupertinoIcons.search),
                      style: const TextStyle(color: CupertinoColors.black),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CupertinoActivityIndicator())
                        : _error != null
                        ? Center(child: Text('Error: $_error'))
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
                widget.translations['partsPage'] ?? 'Parts',
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
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          widget.translations['searchSpareParts'] ??
                          'Search Spare Parts',
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
                      ? Center(child: Text('Error: $_error'))
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
                Center(
                  child: widgets.adaptiveButton(
                    widget.translations['buyNow'] ?? 'Buy Now',
                    () async {
                      // Check authentication before proceeding to checkout
                      final isAuthenticated = await AuthUtils.checkAuthAndRedirect(context, widget.translations);
                      if (isAuthenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              translations: widget.translations,
                              orderedParts: [part],
                              selectedLanguage: 'English', // Default for now
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
