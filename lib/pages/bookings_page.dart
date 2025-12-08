import 'dart:io' show Platform;
import 'dart:async';

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
import '../services/optimized_api_service.dart';
import '../widgets/skeleton_loader.dart';
import 'success_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

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
  bool _isOffline = false; // Added for offline state tracking

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
    _carPlateNumberController.addListener(_updateForm);
    _fetchTowingServices();
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
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _pickupLocationController.dispose();
    _carPlateNumberController.dispose();
    super.dispose();
  }

  void _updateForm() {
    // Only rebuild if mounted to avoid unnecessary rebuilds
    if (mounted) {
      setState(() {
        // Trigger rebuild to update button state
      });
    }
  }

  /// Reusable function to show user-friendly error messages
  void _showErrorMessage(String message) {
    if (!mounted) return;

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Connection Error'),
            content: Text(message),
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
            title: 'Connection Error',
            message: message,
            contentType: ContentType.failure,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  void _updateTotalPrice() {
    // Only rebuild if mounted to avoid unnecessary rebuilds
    if (!mounted) return;

    final newPrice = _selectedService != null
        ? (() {
            final usdPrice = _selectedService!.price;
            final convertedPrice =
                usdPrice * (_currencies[_selectedCurrency]!['rate'] as double);
            final symbol = _currencies[_selectedCurrency]!['symbol'] as String;
            return '$symbol${convertedPrice.toStringAsFixed(2)}';
          })()
        : Provider.of<LocaleProvider>(context, listen: false).translate('toBeDiscussed');

    // Only update state if price actually changed
    if (_totalPrice != newPrice) {
      setState(() {
        _totalPrice = newPrice;
      });
    }
  }

  Future<void> _fetchTowingServices() async {
    print('🔄 Fetching towing services with optimized API...');

    try {
      final optimizedApi = OptimizedApiService();
      final services = await optimizedApi.fetchTowingServices();

      print('✅ Loaded ${services.length} towing services from cache/API');
      services.forEach(
        (service) => print('  - ${service.name}: \$${service.price}'),
      );

      if (mounted) {
        setState(() {
          _towingServices = services;
          _isLoadingServices = false;
          _isOffline = false; // Reset offline state on success
        });
      }
    } catch (e) {
      print('💥 Exception loading towing services: $e');
      print('🔍 Exception type: ${e.runtimeType}');

      if (mounted) {
        // Handle ApiError specifically
        if (e is ApiError) {
          switch (e.type) {
            case ApiErrorType.noInternet:
              setState(() {
                _isLoadingServices = false;
                _isOffline = true;
              });
              _showErrorMessage('No internet connection. Please check and try again.');
              break;
            case ApiErrorType.timeout:
              // For timeouts (likely cold starts), retry automatically after a delay
              print('⏳ Timeout detected, retrying automatically...');
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() {
                  _isLoadingServices = true;
                  _isOffline = false;
                });
                _fetchTowingServices(); // Recursive retry
              }
              break;
            case ApiErrorType.serverError:
            case ApiErrorType.unknown:
              setState(() {
                _isLoadingServices = false;
                _isOffline = true;
              });
              _showErrorMessage('Unable to load services. Please try again.');
              break;
          }
        } else {
          // Fallback for non-ApiError exceptions
          setState(() {
            _isLoadingServices = false;
            _isOffline = true;
          });
          _showErrorMessage('No internet connection. Please check and try again.');
        }
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
    final isAuthenticated = await AuthUtils.checkAuthAndRedirect(
      context,
      {}, // Empty map since we're using easy_localization now
    );
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
        // Clear form fields
        _fullNameController.clear();
        _phoneNumberController.clear();
        _pickupLocationController.clear();
        _carPlateNumberController.clear();
        setState(() {
          _selectedService = null;
          _selectedVehicleMake = null;
          _selectedVehicleModel = null;
          _totalPrice = '';
        });
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
        _showErrorMessage('Failed to book towing service. Please try again.');
      }
    } catch (e) {
      print('💥 Exception during towing booking: $e');
      print('🔍 Exception type: ${e.runtimeType}');

      _showErrorMessage('Failed to book towing service. Please try again.');
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
                localeProvider.translate('towingServiceBooking'),
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
                      localeProvider.translate('pickupLocation'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _pickupLocationController,
                      placeholder: localeProvider.translate('pickupLocationPlaceholder'),
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
                      localeProvider.translate('vehicleBrandModel'),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedVehicleMake ??
                                        localeProvider.translate('vehicleMake'),
                                    style: TextStyle(
                                      color: _selectedVehicleMake != null
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
                                    width: _selectedVehicleModel != null
                                        ? 2
                                        : 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedVehicleModel ??
                                        localeProvider.translate('vehicleModel'),
                                    style: TextStyle(
                                      color: _selectedVehicleModel != null
                                          ? Colors.black
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
                      localeProvider.translate('carPlateNumber'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _carPlateNumberController,
                      placeholder: localeProvider.translate('carPlatePlaceholder'),
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
                      localeProvider.translate('serviceType'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingServices
                        ? const ServiceListSkeletonLoader(itemCount: 5)
                        : _isOffline
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.wifi_slash,
                                      color: CupertinoColors.systemGrey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No internet connection',
                                      style: TextStyle(
                                        color: CupertinoColors.systemGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(
                                          color: CupertinoColors.activeBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isLoadingServices = true;
                                          _isOffline = false;
                                        });
                                        _fetchTowingServices();
                                      },
                                    ),
                                  ],
                                ),
                              )
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedService?.name ??
                                        localeProvider.translate('selectServiceType'),
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
                localeProvider.translate('towingServiceBooking'),
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
                    localeProvider.translate('pickupLocation'),
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
                      hintText: localeProvider.translate('pickupLocationPlaceholder'),
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
                    localeProvider.translate('vehicleBrandModel'),
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
                                      localeProvider.translate('vehicleMake'),
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
                                      localeProvider.translate('vehicleModel'),
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
                    localeProvider.translate('carPlateNumber'),
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
                      hintText: localeProvider.translate('carPlatePlaceholder'),
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
                    localeProvider.translate('serviceType'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingServices
                      ? const ServiceListSkeletonLoader(itemCount: 5)
                      : _isOffline
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.wifi_off,
                                    color: Colors.grey[600],
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No internet connection',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isLoadingServices = true;
                                        _isOffline = false;
                                      });
                                      _fetchTowingServices();
                                    },
                                  ),
                                ],
                              ),
                            )
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
                                      localeProvider.translate('selectServiceType'),
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
}
