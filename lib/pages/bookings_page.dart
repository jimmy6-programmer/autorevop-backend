import 'dart:io' show Platform;

import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
import '../utils/auth_utils.dart'; // For authentication
import '../models/service_model.dart';
import 'success_page.dart';

class BookingsPage extends StatefulWidget {
  final Map<String, String> translations;

  const BookingsPage({required this.translations, super.key});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _pickupLocationController =
      TextEditingController();
  final TextEditingController _carPlateNumberController =
      TextEditingController();
  Service? _selectedService;
  String? _selectedVehicleMake;
  String? _selectedVehicleModel;
  String _totalPrice = '';
  String _selectedCurrency = 'USD';
  List<Service> _towingServices = [];
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

  // Vehicle models by make
  final Map<String, List<String>> _vehicleModels = {
    'Toyota': [
      'Camry',
      'Corolla',
      'RAV4',
      'Highlander',
      'Prius',
      'Tacoma',
      'Tundra',
      '4Runner',
      'Sienna',
      'Avalon',
      'Yaris',
      'C-HR',
      'Land Cruiser',
      'Sequoia',
      'Venza',
    ],
    'Honda': [
      'Civic',
      'Accord',
      'CR-V',
      'Pilot',
      'HR-V',
      'Fit',
      'Odyssey',
      'Ridgeline',
      'Passport',
      'Insight',
      'Clarity',
    ],
    'Ford': [
      'F-150',
      'Explorer',
      'Escape',
      'Mustang',
      'Focus',
      'Fusion',
      'Edge',
      'Ranger',
      'Bronco',
      'Expedition',
      'Transit',
      'EcoSport',
    ],
    'Chevrolet': [
      'Silverado',
      'Equinox',
      'Malibu',
      'Traverse',
      'Tahoe',
      'Suburban',
      'Colorado',
      'Cruze',
      'Impala',
      'Camaro',
      'Corvette',
      'Blazer',
    ],
    'Nissan': [
      'Altima',
      'Sentra',
      'Rogue',
      'Pathfinder',
      'Titan',
      'Frontier',
      'Maxima',
      'Murano',
      'Kicks',
      'Versa',
      'Armada',
      '370Z',
    ],
    'BMW': [
      '3 Series',
      '5 Series',
      'X3',
      'X5',
      'X1',
      '7 Series',
      'X7',
      'i3',
      'i8',
      'M3',
      'M5',
      'Z4',
    ],
    'Mercedes-Benz': [
      'C-Class',
      'E-Class',
      'S-Class',
      'GLC',
      'GLE',
      'A-Class',
      'CLA',
      'GLA',
      'GLB',
      'G-Class',
      'Sprinter',
    ],
    'Audi': [
      'A3',
      'A4',
      'A6',
      'Q5',
      'Q7',
      'Q3',
      'A5',
      'A7',
      'TT',
      'R8',
      'Q8',
      'e-tron',
    ],
    'Volkswagen': [
      'Jetta',
      'Passat',
      'Tiguan',
      'Atlas',
      'Golf',
      'Arteon',
      'ID.4',
      'Touareg',
      'Beetle',
    ],
    'Hyundai': [
      'Elantra',
      'Sonata',
      'Tucson',
      'Palisade',
      'Kona',
      'Venue',
      'Accent',
      'Veloster',
      'Nexo',
    ],
    'Kia': [
      'Sportage',
      'Sorento',
      'Telluride',
      'Soul',
      'Forte',
      'Optima',
      'Rio',
      'Stinger',
      'Carnival',
      'Seltos',
    ],
    'Mazda': [
      'CX-5',
      'CX-9',
      'Mazda3',
      'Mazda6',
      'CX-30',
      'CX-3',
      'MX-5 Miata',
      'CX-50',
    ],
    'Subaru': [
      'Outback',
      'Forester',
      'Crosstrek',
      'Ascent',
      'Impreza',
      'Legacy',
      'WRX',
      'BRZ',
      'XV',
    ],
    'Lexus': ['RX', 'GX', 'LX', 'ES', 'LS', 'NX', 'UX', 'IS', 'RC', 'LC'],
    'Acura': ['MDX', 'RDX', 'TLX', 'ILX', 'RLX', 'NSX'],
    'Infiniti': ['QX60', 'QX80', 'QX50', 'Q50', 'Q60', 'QX30'],
    'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck'],
    'Volvo': ['XC90', 'XC60', 'XC40', 'S90', 'S60', 'V90', 'V60'],
    'Jaguar': ['F-PACE', 'E-PACE', 'XE', 'XF', 'XJ', 'F-TYPE', 'I-PACE'],
    'Land Rover': [
      'Range Rover',
      'Discovery',
      'Defender',
      'Evoque',
      'Velar',
      'Sport',
    ],
    'Porsche': [
      '911',
      'Cayenne',
      'Macan',
      'Panamera',
      'Taycan',
      'Boxster',
      'Cayman',
    ],
    'Ferrari': ['488', 'Portofino', 'Roma', 'SF90', '812', 'F8', 'GTC4Lusso'],
    'Lamborghini': ['Huracan', 'Urus', 'Aventador', 'Gallardo', 'Murcielago'],
    'Maserati': [
      'Ghibli',
      'Quattroporte',
      'Levante',
      'GranTurismo',
      'GranCabrio',
    ],
    'Bentley': ['Continental GT', 'Bentayga', 'Flying Spur', 'Mulsanne'],
    'Rolls-Royce': ['Ghost', 'Dawn', 'Wraith', 'Cullinan'],
    'Aston Martin': ['DB11', 'Vantage', 'DBS', 'Rapide', 'Valhalla'],
    'McLaren': ['720S', '570S', '600LT', 'Senna', 'Speedtail'],
    'Bugatti': ['Chiron', 'Divo', 'Centodieci'],
    'Other': ['Other'],
  };

  // Map of service types to prices (in USD)
  final Map<String, double> _servicePrices = {
    'standardVehicleTowing': 50.0,
    'accidentRecoveryTowing': 100.0,
    'longDistanceTowing': 150.0,
    'motorcycleTowing': 40.0,
    'batteryJumpStartFuelDelivery': 25.0,
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

  // Display names for service types
  final Map<String, String> _serviceDisplayNames = {
    'standardVehicleTowing': 'Standard Vehicle Towing',
    'accidentRecoveryTowing': 'Accident Recovery Towing',
    'longDistanceTowing': 'Long-Distance Towing',
    'motorcycleTowing': 'Motorcycle Towing',
    'batteryJumpStartFuelDelivery': 'Battery Jump-Start & Fuel Delivery',
  };

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

  @override
  void initState() {
    super.initState();
    _carPlateNumberController.addListener(_updateForm);
    _fetchTowingServices();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _pickupLocationController.dispose();
    _carPlateNumberController.dispose();
    super.dispose();
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
        _totalPrice = widget.translations['toBeDiscussed'] ?? 'To be discussed';
      }
    });
  }

  Future<void> _fetchTowingServices() async {
    print('🔄 Fetching towing services...');
    final url = '${getApiBaseUrl()}/api/services/type/towing';
    print('🌐 Fetching from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('📊 Towing services response status: ${response.statusCode}');
      print('📄 Towing services response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Loaded ${data.length} towing services');
        data.forEach(
          (service) => print('  - ${service['name']}: \$${service['price']}'),
        );
        setState(() {
          _towingServices = data.map((json) => Service.fromJson(json)).toList();
          _isLoadingServices = false;
        });
      } else {
        print('❌ Failed to load towing services: ${response.statusCode}');
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
                  'Failed to load towing services (${response.statusCode})',
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
                    'Failed to load towing services (${response.statusCode})',
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
      print('💥 Exception loading towing services: $e');
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
              content: Text('Error loading towing services: $e'),
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
              message: 'Error loading towing services: $e',
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
        _pickupLocationController.text.trim().isNotEmpty &&
        _selectedVehicleMake != null &&
        _selectedVehicleModel != null &&
        _carPlateNumberController.text.trim().isNotEmpty &&
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
                      .map((option) => Center(child: Text(option)))
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
    final isAuthenticated = await AuthUtils.checkAuthAndRedirect(context, widget.translations);
    if (!isAuthenticated) return;

    print('🔄 Starting towing booking submission...');
    print('📱 API Base URL: ${getApiBaseUrl()}');
    print('🚗 Selected Service: ${_selectedService?.name ?? 'None'}');
    print('🆔 Service ID: ${_selectedService?.id ?? 'None'}');

    final bookingData = {
      'type': 'towing',
      'fullName': _fullNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'vehicleBrand': _selectedVehicleMake,
      'vehicleModel': _selectedVehicleModel,
      'carPlateNumber': _carPlateNumberController.text,
      'serviceId': _selectedService!.id,
      'pickupLocation': _pickupLocationController.text,
      'location': _pickupLocationController
          .text, // Use pickup location as general location
      'totalPrice': _totalPrice,
      'currency': _selectedCurrency,
    };

    print('📋 Towing booking data to send: ${json.encode(bookingData)}');

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
        print('✅ Towing booking successful!');
        // Navigate to success page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(
              location: _pickupLocationController.text,
              phone: _phoneNumberController.text,
              vehicleBrand: _selectedVehicleMake,
              selectedLanguage: 'English', // Default for now
            ),
          ),
        );
      } else {
        print('❌ Towing booking failed with status ${response.statusCode}');
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text(
                  'Failed to book towing service (Status: ${response.statusCode})',
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
                    'Failed to book towing service (Status: ${response.statusCode})',
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
      print('💥 Exception during towing booking: $e');
      print('🔍 Exception type: ${e.runtimeType}');
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Error booking towing service: $e'),
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
              message: 'Error booking towing service: $e',
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
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              middle: Text(
                widget.translations['towingServiceBooking'] ??
                    'Book Towing Service',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
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
                      widget.translations['fullName'] ?? 'Full Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _fullNameController,
                      placeholder:
                          widget.translations['namePlaceholder'] ??
                          'Enter your full name',
                      padding: EdgeInsets.all(16.0),
                      onChanged: (value) => _updateForm(),
                    ),
                const SizedBox(height: 24),
                Text(
                  widget.translations['phoneNumber'] ?? 'Phone Number',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _phoneNumberController,
                  placeholder:
                      widget.translations['phonePlaceholder'] ??
                      'Enter phone number with country code (e.g., +250)',
                  padding: EdgeInsets.all(16.0),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _updateForm(),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.translations['pickupLocation'] ?? 'Pickup Location',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _pickupLocationController,
                  placeholder:
                      widget.translations['pickupLocationPlaceholder'] ??
                      'Enter pickup location',
                  padding: EdgeInsets.all(16.0),
                  onChanged: (value) => _updateForm(),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.translations['vehicleBrandModel'] ??
                      'Vehicle Brand & Model',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCupertinoPicker(
                          context,
                          _vehicleBrands,
                          _selectedVehicleMake,
                          (value) {
                            setState(() {
                              _selectedVehicleMake = value;
                              _selectedVehicleModel =
                                  null; // Reset model when make changes
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
                                color: _selectedVehicleMake != null
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.inactiveGray,
                                width: _selectedVehicleMake != null ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedVehicleMake ??
                                    (widget.translations['vehicleMake'] ??
                                        'Select Make'),
                                style: TextStyle(
                                  color: _selectedVehicleMake != null
                                      ? CupertinoColors.label
                                      : CupertinoColors.secondaryLabel,
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectedVehicleMake != null
                            ? () => _showCupertinoPicker(
                                context,
                                _vehicleModels[_selectedVehicleMake] ?? [],
                                _selectedVehicleModel,
                                (value) {
                                  setState(() {
                                    _selectedVehicleModel = value;
                                    _updateForm();
                                  });
                                },
                              )
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedVehicleModel != null
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.inactiveGray,
                                width: _selectedVehicleModel != null ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedVehicleModel ??
                                    (widget.translations['vehicleModel'] ??
                                        'Select Model'),
                                style: TextStyle(
                                  color: _selectedVehicleModel != null
                                      ? CupertinoColors.label
                                      : CupertinoColors.secondaryLabel,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_down,
                                color: _selectedVehicleMake != null
                                    ? CupertinoColors.inactiveGray
                                    : CupertinoColors.systemGrey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  widget.translations['carPlateNumber'] ?? 'Car Plate Number',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _carPlateNumberController,
                  placeholder:
                      widget.translations['carPlatePlaceholder'] ??
                      'Enter car plate number',
                  padding: EdgeInsets.all(16.0),
                  onChanged: (value) => _updateForm(),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.translations['serviceType'] ?? 'Service Type',
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
                          _towingServices
                              .map((service) => service.name)
                              .toList(),
                          _selectedService?.name,
                          (value) {
                            if (value != null) {
                              final service = _towingServices.firstWhere(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedService?.name ??
                                    (widget.translations['selectServiceType'] ??
                                        'Select Service Type'),
                                style: TextStyle(
                                  color: _selectedService != null
                                      ? CupertinoColors.label
                                      : CupertinoColors.secondaryLabel,
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
                        widget.translations['selectCurrency'] ?? 'Select Currency',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
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
                            color: CupertinoColors.label,
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
                    color: CupertinoColors.label,
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
        )
      ) : Scaffold(
          appBar: AppBar(
            title: Text(
              widget.translations['towingServiceBooking'] ??
                  'Book Towing Service',
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
                  widget.translations['fullName'] ?? 'Full Name',
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
                      hintText:
                          widget.translations['namePlaceholder'] ??
                          'Enter your full name',
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.activeBlue,
                          width: 2,
                        ),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      hintText:
                          widget.translations['phonePlaceholder'] ??
                          'Enter phone number with country code (e.g., +250)',
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.activeBlue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: CupertinoColors.white,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _updateForm(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.translations['pickupLocation'] ?? 'Pickup Location',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pickupLocationController,
                    decoration: InputDecoration(
                      hintText:
                          widget.translations['pickupLocationPlaceholder'] ??
                          'Enter pickup location',
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.activeBlue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: CupertinoColors.white,
                    ),
                    onChanged: (value) => _updateForm(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.translations['vehicleBrandModel'] ??
                        'Vehicle Brand & Model',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCupertinoPicker(
                            context,
                            _vehicleBrands,
                            _selectedVehicleMake,
                            (value) {
                              setState(() {
                                _selectedVehicleMake = value;
                                _selectedVehicleModel =
                                    null; // Reset model when make changes
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
                                  color: _selectedVehicleMake != null
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.inactiveGray,
                                  width: _selectedVehicleMake != null ? 2 : 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedVehicleMake ??
                                      (widget.translations['vehicleMake'] ??
                                          'Select Make'),
                                  style: TextStyle(
                                    color: _selectedVehicleMake != null
                                        ? Colors.black87
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectedVehicleMake != null
                              ? () => _showCupertinoPicker(
                                  context,
                                  _vehicleModels[_selectedVehicleMake] ?? [],
                                  _selectedVehicleModel,
                                  (value) {
                                    setState(() {
                                      _selectedVehicleModel = value;
                                      _updateForm();
                                    });
                                  },
                                )
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedVehicleModel != null
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.inactiveGray,
                                  width: _selectedVehicleModel != null ? 2 : 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedVehicleModel ??
                                      (widget.translations['vehicleModel'] ??
                                          'Select Model'),
                                  style: TextStyle(
                                    color: _selectedVehicleModel != null
                                        ? Colors.black87
                                        : Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  color: _selectedVehicleMake != null
                                      ? CupertinoColors.inactiveGray
                                      : CupertinoColors.systemGrey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.translations['carPlateNumber'] ?? 'Car Plate Number',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _carPlateNumberController,
                    decoration: InputDecoration(
                      hintText:
                          widget.translations['carPlatePlaceholder'] ??
                          'Enter car plate number',
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CupertinoColors.activeBlue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: CupertinoColors.white,
                    ),
                    onChanged: (value) => _updateForm(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.translations['serviceType'] ?? 'Service Type',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingServices
                      ? const Center(child: CupertinoActivityIndicator())
                      : GestureDetector(
                          onTap: () => _showCupertinoPicker(
                            context,
                            _towingServices
                                .map((service) => service.name)
                                .toList(),
                            _selectedService?.name,
                            (value) {
                              if (value != null) {
                                final service = _towingServices.firstWhere(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedService?.name ??
                                      (widget.translations['selectServiceType'] ??
                                          'Select Service Type'),
                                  style: TextStyle(
                                    color: _selectedService != null
                                        ? Colors.black87
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
                    widget.translations['selectCurrency'] ?? 'Select Currency',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
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
                              color: Colors.black87,
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
                      color: Colors.black87,
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
}
