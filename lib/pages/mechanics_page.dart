import 'dart:io' show Platform;

import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:provider/provider.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
import '../utils/auth_utils.dart'; // For authentication
import '../models/service_model.dart';
import '../providers/translation_provider.dart';
import 'success_page.dart';

class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

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
    'Other',
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
    'Other',
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
    'EUR': {
      'symbol': '€',
      'rate': 0.8604,
    }, // Based on BNR rates: 1443.665 RWF/USD, 1677.899646 RWF/EUR
    'RWF': {
      'symbol': 'RWF',
      'rate': 1443.665,
    }, // Rwandan Franc - BNR buying rate
    'KES': {
      'symbol': 'KES',
      'rate': 129.07,
    }, // Kenyan Shilling - BNR buying rate
    'TZS': {
      'symbol': 'TZS',
      'rate': 2445.0,
    }, // Tanzanian Shilling - BNR buying rate
    'UGX': {
      'symbol': 'UGX',
      'rate': 3429.0,
    }, // Ugandan Shilling - BNR buying rate
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
        final convertedPrice =
            usdPrice * (_currencies[_selectedCurrency]!['rate'] as double);
        final symbol = _currencies[_selectedCurrency]!['symbol'] as String;
        _totalPrice = '$symbol${convertedPrice.toStringAsFixed(2)}';
      } else {
        final localeProvider = Provider.of<LocaleProvider>(context);
        _totalPrice = localeProvider.translate('toBeDiscussed');
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
        data.forEach(
          (service) => print('  - ${service['name']}: \$${service['price']}'),
        );
        setState(() {
          _mechanicServices = data
              .map((json) => Service.fromJson(json))
              .toList();
          _isLoadingServices = false;
        });
      } else {
        print('❌ Failed to load mechanic services: ${response.statusCode}');
        setState(() {
          _isLoadingServices = false;
        });
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text(
                  'Failed to load mechanic services (${response.statusCode})',
                ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Error',
                message:
                    'Failed to load mechanic services (${response.statusCode})',
                contentType: ContentType.failure,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Exception loading mechanic services: $e');
      print('🔍 Exception type: ${e.runtimeType}');
      setState(() {
        _isLoadingServices = false;
      });
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Error loading mechanic services: $e'),
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
    int selectedIndex = currentValue != null
        ? options.indexOf(currentValue)
        : 0;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground,
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
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: options
                      .map(
                        (option) => Center(
                          child: Text(
                            option,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitBooking() async {
    // Check authentication before proceeding
    // Using easy_localization directly
    final isAuthenticated = await AuthUtils.checkAuthAndRedirect(
      context,
      {}, // No longer need translations map
    );
    if (!isAuthenticated) return;

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
      'customIssue': _selectedService?.name == 'Other'
          ? _customIssueController.text
          : null,
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
        // Clear form fields
        _fullNameController.clear();
        _phoneNumberController.clear();
        _locationController.clear();
        _customIssueController.clear();
        setState(() {
          _selectedService = null;
          _selectedVehicleBrand = null;
          _totalPrice = '';
        });
        // Navigate to success page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(
              location: _locationController.text,
              phone: _phoneNumberController.text,
              vehicleBrand: _selectedVehicleBrand,
              selectedLanguage: 'English', // Default for now
            ),
          ),
        );
      } else {
        print('❌ Booking failed with status ${response.statusCode}');
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text(
                  'Failed to book service (Status: ${response.statusCode})',
                ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Error',
                message:
                    'Failed to book service (Status: ${response.statusCode})',
                contentType: ContentType.failure,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Exception during booking: $e');
      print('🔍 Exception type: ${e.runtimeType}');
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Error booking service: $e'),
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
              middle: Text(
                localeProvider.translate('mechanicServiceBooking'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      localeProvider.translate('fullName'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _fullNameController,
                      placeholder: localeProvider.translate('namePlaceholder'),
                      placeholderStyle: TextStyle(color: Colors.grey),
                      style: TextStyle(color: Colors.black),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      padding: EdgeInsets.all(16.0),
                      onChanged: (value) => _updateForm(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localeProvider.translate('phoneNumber'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _phoneNumberController,
                      placeholder: localeProvider.translate('phonePlaceholder'),
                      placeholderStyle: TextStyle(color: Colors.grey),
                      style: TextStyle(color: Colors.black),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      padding: EdgeInsets.all(16.0),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => _updateForm(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localeProvider.translate('vehicleBrand'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
                              _selectedVehicleBrand ?? localeProvider.translate('vehicleBrand'),
                              style: TextStyle(
                                color: _selectedVehicleBrand != null
                                    ? Colors.black
                                    : Colors.grey,
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
                      localeProvider.translate('selectIssue'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingServices
                        ? const Center(child: CupertinoActivityIndicator())
                        : GestureDetector(
                            onTap: () => _showCupertinoPicker(
                              context,
                              [
                                ..._mechanicServices
                                    .map((service) => service.name)
                                    .toList(),
                                'Other',
                              ],
                              _selectedService?.name,
                              (value) {
                                if (value != null) {
                                  if (value == 'Other') {
                                    setState(() {
                                      _selectedService = Service(
                                        id: 'other',
                                        name: 'Other',
                                        type: 'mechanic',
                                        price: 0.0,
                                        currency: 'USD',
                                        isActive: true,
                                        createdAt: '',
                                        updatedAt: '',
                                      );
                                      _updateTotalPrice();
                                    });
                                  } else {
                                    final service = _mechanicServices
                                        .firstWhere((s) => s.name == value);
                                    setState(() {
                                      _selectedService = service;
                                      _updateTotalPrice();
                                    });
                                  }
                                }
                              },
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedService?.name ?? localeProvider.translate('selectIssue'),
                                    style: TextStyle(
                                      color: _selectedService != null
                                          ? Colors.black
                                          : Colors.grey,
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
                      localeProvider.translate('locationPlaceholder'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _locationController,
                      placeholder: localeProvider.translate('locationPlaceholder'),
                      placeholderStyle: TextStyle(color: Colors.grey),
                      style: TextStyle(color: Colors.black),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      padding: EdgeInsets.all(16.0),
                      onChanged: (value) => _updateForm(),
                    ),
                    const SizedBox(height: 24),
                    // Custom Issue Field - only show if "Other" is selected
                    if (_selectedService?.name == 'Other') ...[
                      Text(
                        'Specify your issue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _customIssueController,
                        placeholder: 'Describe your specific issue',
                        placeholderStyle: TextStyle(color: Colors.grey),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        onChanged: (value) => _updateForm(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: adaptiveButton(
                        localeProvider.translate('submitBooking'),
                        _isFormValid ? _submitBooking : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                localeProvider.translate('mechanicServiceBooking'),
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    localeProvider.translate('fullName'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: localeProvider.translate('namePlaceholder'),
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _updateForm(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localeProvider.translate('phoneNumber'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      hintText: localeProvider.translate('phonePlaceholder'),
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _updateForm(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localeProvider.translate('vehicleBrand'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedVehicleBrand != null
                                ? Colors.blue
                                : Colors.grey,
                            width: _selectedVehicleBrand != null ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedVehicleBrand ?? localeProvider.translate('vehicleBrand'),
                            style: TextStyle(
                              color: _selectedVehicleBrand != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localeProvider.translate('selectIssue'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingServices
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onTap: () => _showCupertinoPicker(
                            context,
                            [
                              ..._mechanicServices
                                  .map((service) => service.name)
                                  .toList(),
                              'Other',
                            ],
                            _selectedService?.name,
                            (value) {
                              if (value != null) {
                                if (value == 'Other') {
                                  setState(() {
                                    _selectedService = Service(
                                      id: 'other',
                                      name: 'Other',
                                      type: 'mechanic',
                                      price: 0.0,
                                      currency: 'USD',
                                      isActive: true,
                                      createdAt: '',
                                      updatedAt: '',
                                    );
                                    _updateTotalPrice();
                                  });
                                } else {
                                  final service = _mechanicServices.firstWhere(
                                    (s) => s.name == value,
                                  );
                                  setState(() {
                                    _selectedService = service;
                                    _updateTotalPrice();
                                  });
                                }
                              }
                            },
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedService != null
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: _selectedService != null ? 2 : 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedService?.name ?? localeProvider.translate('selectIssue'),
                                  style: TextStyle(
                                    color: _selectedService != null
                                        ? Colors.black87
                                        : Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  Text(
                    localeProvider.translate('locationPlaceholder'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: localeProvider.translate('locationPlaceholder'),
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _updateForm(),
                  ),
                  const SizedBox(height: 24),
                  // Custom Issue Field - only show if "Other" is selected
                  if (_selectedService?.name == 'Other') ...[
                    Text(
                      'Specify your issue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customIssueController,
                      decoration: InputDecoration(
                        hintText: 'Describe your specific issue',
                        border: const UnderlineInputBorder(),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => _updateForm(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: adaptiveButton(
                      localeProvider.translate('submitBooking'),
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
