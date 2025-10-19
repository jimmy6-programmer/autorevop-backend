import 'package:auto_solutions/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
import '../models/service_model.dart';
import 'success_page.dart';

class MechanicsPage extends StatefulWidget {
  final Map<String, String> translations;

  const MechanicsPage({super.key, required this.translations});

  @override
  _MechanicsPageState createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _customIssueController = TextEditingController();
  String? _selectedVehicleBrand;
  Service? _selectedService;
  String _totalPrice = '';
  String _selectedCurrency = 'USD';
  List<Service> _mechanicServices = [];
  bool _isLoadingServices = true;

  // Popular vehicle Brands
  final List<String> _vehicleBrands = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Volkswagen',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Lexus',
    'Acura',
    'Infiniti',
    'Tesla',
    'Volvo',
    'Jaguar',
    'Land Rover',
    'Porsche',
    'Ferrari',
    'Lamborghini',
    'Maserati',
    'Bentley',
    'Rolls-Royce',
    'Aston Martin',
    'McLaren',
    'Bugatti',
    'Other'
  ];

  // Vehicle issues for mechanic services (matching admin dashboard)
  final List<String> _vehicleIssues = [
    'Engine Problem',
    'Brake Issue',
    'Transmission',
    'Electrical',
    'Suspension',
    'Tire/Wheel',
    'Air Conditioning',
    'Exhaust',
    'Battery',
    'Oil Change',
    'Tuning',
    'Body Work',
    'Other'
  ];

  // Map of issues to prices (in USD) - updated to match the issues
  final Map<String, double> _issuePrices = {
    'Engine Problem': 80.0,
    'Brake Issue': 60.0,
    'Transmission': 120.0,
    'Electrical': 70.0,
    'Suspension': 90.0,
    'Tire/Wheel': 40.0,
    'Air Conditioning': 50.0,
    'Exhaust': 65.0,
    'Battery': 35.0,
    'Oil Change': 25.0,
    'Tuning': 100.0,
    'Body Work': 150.0,
  };

  // Available currencies with their symbols and conversion rates (base USD)
  final Map<String, Map<String, dynamic>> _currencies = {
    'USD': {'symbol': '\$', 'rate': 1.0},
    'EUR': {'symbol': '€', 'rate': 0.8604}, // Based on BNR rates: 1443.665 RWF/USD, 1677.899646 RWF/EUR
    'RWF': {'symbol': 'RWF', 'rate': 1443.665}, // Rwandan Franc - BNR buying rate
    'KES': {'symbol': 'KES', 'rate': 129.07},  // Kenyan Shilling - BNR buying rate
    'TZS': {'symbol': 'TZS', 'rate': 2445.0}, // Tanzanian Shilling - BNR buying rate
    'UGX': {'symbol': 'UGX', 'rate': 3429.0}, // Ugandan Shilling - BNR buying rate
  };

  @override
  void initState() {
    super.initState();
    _customIssueController.addListener(_updateCustomIssueVisibility);
    _fetchMechanicServices();
  }

  @override
  void dispose() {
    _customIssueController.removeListener(_updateCustomIssueVisibility);
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    _customIssueController.dispose();
    super.dispose();
  }

  void _updateCustomIssueVisibility() {
    setState(() {
      // Trigger rebuild if needed, but visibility is handled by _buildCustomIssueField
    });
  }

  void _updateForm() {
    setState(() {
      // Trigger rebuild to update button state
    });
  }

  void _updateTotalPrice() {
    setState(() {
      if (_selectedService != null) {
        final usdPrice = _selectedService!.price;
        final convertedPrice = usdPrice * (_currencies[_selectedCurrency]!['rate'] as double);
        final symbol = _currencies[_selectedCurrency]!['symbol'] as String;
        _totalPrice = '$symbol${convertedPrice.toStringAsFixed(2)}';
      } else {
        _totalPrice = widget.translations['toBeDiscussed'] ?? 'To be discussed';
      }
    });
  }

  Future<void> _fetchMechanicServices() async {
    print('🔄 Fetching mechanic services...');
    final url = '${getApiBaseUrl()}/api/services/type/mechanic';
    print('🌐 Fetching from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('📊 Services response status: ${response.statusCode}');
      print('📄 Services response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Loaded ${data.length} mechanic services');
        data.forEach((service) => print('  - ${service['name']}: \$${service['price']}'));
        setState(() {
          _mechanicServices = data.map((json) => Service.fromJson(json)).toList();
          _isLoadingServices = false;
        });
      } else {
        print('❌ Failed to load mechanic services: ${response.statusCode}');
        setState(() {
          _isLoadingServices = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Failed to load mechanic services (${response.statusCode})',
              contentType: ContentType.failure,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      print('💥 Exception loading mechanic services: $e');
      print('🔍 Exception type: ${e.runtimeType}');
      setState(() {
        _isLoadingServices = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Error loading mechanic services: $e',
            contentType: ContentType.failure,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  bool get _isFormValid {
    return _fullNameController.text.trim().isNotEmpty &&
        _phoneNumberController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty &&
        _selectedVehicleBrand != null &&
        _selectedService != null;
  }

  void _showCupertinoPicker(
    BuildContext context,
    List<String> options,
    String? currentValue,
    Function(String?) onSelected,
  ) {
    int selectedIndex = currentValue != null ? options.indexOf(currentValue) : 0;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Done'),
                      onPressed: () {
                        onSelected(options[selectedIndex]);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: options.map((option) => Center(child: Text(option))).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitBooking() async {
    print('🔄 Starting booking submission...');
    print('📱 API Base URL: ${getApiBaseUrl()}');
    print('👤 Selected Service: ${_selectedService?.name ?? 'None'}');
    print('🆔 Service ID: ${_selectedService?.id ?? 'None'}');

    final bookingData = {
      'type': 'mechanic',
      'fullName': _fullNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'vehicleBrand': _selectedVehicleBrand,
      'serviceId': _selectedService!.id,
      'location': _locationController.text,
      'totalPrice': _totalPrice,
      'currency': _selectedCurrency,
    };

    print('📋 Booking data to send: ${json.encode(bookingData)}');

    try {
      final url = '${getApiBaseUrl()}/api/bookings';
      print('🌐 Making POST request to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      print('📋 Response headers: ${response.headers}');

      if (response.statusCode == 201) {
        print('✅ Booking successful!');
        // Navigate to success page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(
              location: _locationController.text,
              phone: _phoneNumberController.text,
              vehicleBrand: _selectedVehicleBrand,
            ),
          ),
        );
      } else {
        print('❌ Booking failed with status ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Failed to book service (Status: ${response.statusCode})',
              contentType: ContentType.failure,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      print('💥 Exception during booking: $e');
      print('🔍 Exception type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Error booking service: $e',
            contentType: ContentType.failure,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: CupertinoColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.translations['mechanicServiceBooking'] ?? 'Book Mechanic Service',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.translations['fullName'] ?? 'Full Name',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: widget.translations['namePlaceholder'] ?? 'Enter your full name',
                border: const UnderlineInputBorder(),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CupertinoColors.inactiveGray),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CupertinoColors.activeBlue, width: 2),
                ),
                filled: true,
                fillColor: CupertinoColors.white,
              ),
              onChanged: (value) => _updateForm(),
            ),
            const SizedBox(height: 24),
            Text(
              widget.translations['phoneNumber'] ?? 'Phone Number',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: widget.translations['phonePlaceholder'] ?? 'Enter phone number with country code (e.g., +250)',
                border: const UnderlineInputBorder(),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CupertinoColors.inactiveGray),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CupertinoColors.activeBlue, width: 2),
                ),
                filled: true,
                fillColor: CupertinoColors.white,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => _updateForm(),
            ),
            const SizedBox(height: 24),
            Text(
              widget.translations['vehicleBrand'] ?? 'Vehicle Brand',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showCupertinoPicker(
                context,
                _vehicleBrands,
                _selectedVehicleBrand,
                (value) {
                  setState(() {
                    _selectedVehicleBrand = value;
                    _updateForm();
                  });
                },
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedVehicleBrand != null
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.inactiveGray,
                      width: _selectedVehicleBrand != null ? 2 : 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedVehicleBrand ?? (widget.translations['selectVehicleBrand'] ?? 'Select Vehicle Brand'),
                      style: TextStyle(
                        color: _selectedVehicleBrand != null
                            ? CupertinoColors.black
                            : CupertinoColors.inactiveGray,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_down,
                      color: CupertinoColors.inactiveGray,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.translations['selectIssue'] ?? 'Select Issue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _isLoadingServices
                ? const Center(child: CupertinoActivityIndicator())
                : GestureDetector(
                    onTap: () => _showCupertinoPicker(
                      context,
                      _mechanicServices.map((service) => service.name).toList(),
                      _selectedService?.name,
                      (value) {
                        if (value != null) {
                          final service = _mechanicServices.firstWhere(
                            (s) => s.name == value,
                          );
                          setState(() {
                            _selectedService = service;
                            _updateTotalPrice();
                          });
                        }
                      },
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedService != null
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.inactiveGray,
                            width: _selectedService != null ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedService?.name ?? (widget.translations['selectService'] ?? 'Select Service'),
                            style: TextStyle(
                              color: _selectedService != null
                                  ? CupertinoColors.black
                                  : CupertinoColors.inactiveGray,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: CupertinoColors.inactiveGray,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Text(
              widget.translations['locationPlaceholder'] ?? 'Enter your location for service',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: widget.translations['locationPlaceholder'] ?? 'Enter your location for service',
                border: const UnderlineInputBorder(),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CupertinoColors.inactiveGray),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CupertinoColors.activeBlue, width: 2),
                ),
                filled: true,
                fillColor: CupertinoColors.white,
              ),
              onChanged: (value) => _updateForm(),
            ),
            const SizedBox(height: 24),
            Text(
              widget.translations['selectCurrency'] ?? 'Select Currency',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showCupertinoPicker(
                context,
                _currencies.keys.toList(),
                _selectedCurrency,
                (value) {
                  setState(() {
                    _selectedCurrency = value!;
                    _updateTotalPrice();
                  });
                },
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.activeBlue,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCurrency,
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_down,
                      color: CupertinoColors.inactiveGray,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${widget.translations['totalPrice'] ?? 'Total Price'}: $_totalPrice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: adaptiveButton(
                widget.translations['submitBooking'] ?? 'Submit Booking',
                _isFormValid ? _submitBooking : null,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomIssueField() {
    // No longer needed since we use services from database
    return const SizedBox.shrink();
  }
}