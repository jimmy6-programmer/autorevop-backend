import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:provider/provider.dart';
import '../widgets/adaptive_button.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
import '../utils/auth_utils.dart'; // For authentication
import '../providers/translation_provider.dart';

class DetailingPage extends StatefulWidget {
  const DetailingPage({super.key});

  @override
  _DetailingPageState createState() => _DetailingPageState();
}

class _DetailingPageState extends State<DetailingPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedVehicleType;
  String? _selectedPlanType;
  String? _selectedCurrency = 'USD';
  Map<String, double> _planPrices = {
    'Basic': 0.0,
    'Standard': 0.0,
    'Premium': 0.0,
  };

  final List<String> _vehicleTypes = [
    'Small Car (Sedan/Hatchback)',
    'SUV/Crossover',
  ];

  final List<String> _planTypes = [
    'Basic',
    'Standard',
    'Premium'
  ];

  final Map<String, String> _planDescriptions = {
    'Basic': 'Exterior cleaning only',
    'Standard': 'Exterior + interior cleaning',
    'Premium': 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)',
  };

  final Map<String, double> _exchangeRates = {
    'AED': 3.672,
    'AOA': 921.0,
    'AUD': 1.529,
    'BIF': 2951.0,
    'BRL': 5.286,
    'CAD': 1.405,
    'CHF': 0.795,
    'CNH': 7.099,
    'CNY': 7.098,
    'CZK': 20.78,
    'DKK': 6.418,
    'EGP': 47.08,
    'ETB': 155.9,
    'EUR': 0.862,
    'GBP': 0.76,
    'GHS': 10.93,
    'GNF': 8677.0,
    'HKD': 7.76,
    'HUF': 330.5,
    'IDR': 16650.0,
    'ILS': 3.219,
    'INR': 88.47,
    'JPY': 154.3,
    'JOD': 0.708,
    'KES': 128.9,
    'KMF': 422.0,
    'KRW': 1456.0,
    'KWD': 0.306,
    'LSL': 17.09,
    'LYD': 5.45,
    'MAD': 9.22,
    'MRO': 357.0,
    'MUR': 45.75,
    'MWK': 1729.0,
    'MZN': 63.95,
    'NGN': 1438.0,
    'NOK': 10.08,
    'PKR': 282.0,
    'PLN': 3.636,
    'QAR': 3.638,
    'RUB': 80.62,
    'RWF': 1455.74,
    'SAR': 3.75,
    'SDG': 599.0,
    'SEK': 9.47,
    'SGD': 1.299,
    'SSP': 4550.0,
    'SZL': 17.09,
    'TRY': 42.29,
    'TZS': 2425.0,
    'UGX': 3560.0,
    'USD': 1.0, // Base currency
    'XAF': 561.0,
    'XDR': 0.733,
    'XOF': 561.0,
    'ZAR': 17.09,
    'ZMW': 22.57,
    'ZIG': 379.0,
  };

  @override
  void dispose() {
    _phoneController.removeListener(_updateButtonState);
    _locationController.removeListener(_updateButtonState);
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _phoneController.text.trim().isNotEmpty &&
           _locationController.text.trim().isNotEmpty &&
           _selectedVehicleType != null &&
           _selectedPlanType != null;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to update button state when form changes
    _phoneController.addListener(_updateButtonState);
    _locationController.addListener(_updateButtonState);
    _fetchPlanPrices();
  }

  Future<void> _fetchPlanPrices() async {
    try {
      final url = '${getApiBaseUrl()}/api/services/detailing-plans';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _planPrices = {
            'Basic': (data['basicPrice'] ?? 0.0).toDouble(),
            'Standard': (data['standardPrice'] ?? 0.0).toDouble(),
            'Premium': (data['premiumPrice'] ?? 0.0).toDouble(),
          };
        });
      }
    } catch (e) {
      print('Error fetching plan prices: $e');
    }
  }

  double get _convertedPrice {
    if (_selectedPlanType == null) return 0.0;
    final basePrice = _planPrices[_selectedPlanType] ?? 0.0;
    final rate = _exchangeRates[_selectedCurrency] ?? 1.0;
    return basePrice * rate;
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _submitDetailingRequest() async {
    // Check authentication before proceeding
    final isAuthenticated = await AuthUtils.checkAuthAndRedirect(
      context,
      {}, // No longer need translations map
    );
    if (!isAuthenticated) return;

    final detailingData = {
      'type': 'detailing',
      'fullName': 'Customer', // Add a default name since detailing doesn't require name
      'phoneNumber': _phoneController.text,
      'vehicleType': _selectedVehicleType,
      'planType': _selectedPlanType,
      'location': _locationController.text,
      'totalPrice': _convertedPrice.toStringAsFixed(2),
      'currency': _selectedCurrency,
    };

    try {
      final url = '${getApiBaseUrl()}/api/bookings';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(detailingData),
      );

      if (response.statusCode == 201) {
        // Clear form fields
        _phoneController.clear();
        _locationController.clear();
        setState(() {
          _selectedVehicleType = null;
          _selectedPlanType = null;
          _selectedCurrency = 'USD';
        });

        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Success!'),
                content: Text('Detailing service request submitted successfully. We will contact you soon.'),
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
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Detailing service request submitted successfully. We will contact you soon.',
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text('Failed to submit detailing request. Please try again.'),
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
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Failed to submit detailing request. Please try again.',
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (e) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Network error. Please check your connection and try again.'),
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
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Network error. Please check your connection and try again.',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: CupertinoColors.white,
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                'Car Detailing Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              backgroundColor: CupertinoColors.white,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      localeProvider.translate('detailingPageTitle'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localeProvider.translate('detailingPageDescription'),
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CupertinoColors.systemGrey4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localeProvider.translate('requestDetailingService'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localeProvider.translate('phoneNumber'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: _phoneController,
                            placeholder: 'Enter your phone number',
                            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey), // Black placeholder
                            style: TextStyle(color: CupertinoColors.black), // Black input text
                            keyboardType: TextInputType.phone,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white, // White background for dark mode
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CupertinoColors.systemGrey),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localeProvider.translate('vehicleType'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showCupertinoPicker(
                              context,
                              _vehicleTypes,
                              _selectedVehicleType,
                              (value) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                              },
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white, // White background for dark mode
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CupertinoColors.systemGrey4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedVehicleType ?? localeProvider.translate('selectVehicleType'),
                                    style: TextStyle(
                                      color: _selectedVehicleType != null
                                          ? CupertinoColors.black // Black text for selected
                                          : CupertinoColors.black.withOpacity(0.6), // Black placeholder
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Plan Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showCupertinoPicker(
                              context,
                              _planTypes,
                              _selectedPlanType,
                              (value) {
                                setState(() {
                                  _selectedPlanType = value;
                                });
                              },
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white, // White background for dark mode
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CupertinoColors.systemGrey4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedPlanType ?? 'Select Plan Type',
                                    style: TextStyle(
                                      color: _selectedPlanType != null
                                          ? CupertinoColors.black // Black text for selected
                                          : CupertinoColors.black.withOpacity(0.6), // Black placeholder
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Plan Description Box
                          if (_selectedPlanType != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CupertinoColors.systemGrey4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plan Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _planDescriptions[_selectedPlanType] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.secondaryLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Cost Box with Currency Conversion
                          if (_selectedPlanType != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CupertinoColors.systemBlue.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cost',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoColors.label,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: CupertinoColors.systemGrey4),
                                        ),
                                        child: GestureDetector(
                                          onTap: () => _showCupertinoPicker(
                                            context,
                                            _exchangeRates.keys.toList(),
                                            _selectedCurrency,
                                            (value) {
                                              setState(() {
                                                _selectedCurrency = value;
                                              });
                                            },
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _selectedCurrency ?? 'RWF',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: CupertinoColors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                CupertinoIcons.chevron_down,
                                                size: 16,
                                                color: CupertinoColors.systemGrey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${_convertedPrice.toStringAsFixed(2)} ${_selectedCurrency}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            localeProvider.translate('serviceLocation'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: _locationController,
                            placeholder: localeProvider.translate('enterServiceLocation'),
                            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey), // Black placeholder
                            style: TextStyle(color: CupertinoColors.black), // Black input text
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white, // White background for dark mode
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CupertinoColors.systemGrey),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: adaptiveButton(
                              localeProvider.translate('requestService'),
                              _isFormValid ? _submitDetailingRequest : null,
                              isEnabled: _isFormValid,
                            ),
                          ),
                        ],
                      ),
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
              title: const Text(
                'Car Detailing Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black87),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    localeProvider.translate('detailingPageTitle'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeProvider.translate('detailingPageDescription'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localeProvider.translate('requestDetailingService'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localeProvider.translate('phoneNumber'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            style: TextStyle(color: Colors.black), // Black input text
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Black placeholder
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white, // White background for dark mode
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localeProvider.translate('vehicleType'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedVehicleType,
                            style: TextStyle(color: Colors.black), // Black text for selected value
                            decoration: InputDecoration(
                              hintText: localeProvider.translate('selectVehicleType'),
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Black placeholder
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white, // White background for dark mode
                            ),
                            items: _vehicleTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type, style: TextStyle(color: Colors.black)), // Black dropdown text
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedVehicleType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Plan Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedPlanType,
                            style: TextStyle(color: Colors.black), // Black text for selected value
                            decoration: InputDecoration(
                              hintText: 'Select Plan Type',
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Black placeholder
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white, // White background for dark mode
                            ),
                            items: _planTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type, style: TextStyle(color: Colors.black)), // Black dropdown text
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPlanType = value;
                              });
                            },
                          ),
                          // Plan Description Box
                          if (_selectedPlanType != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plan Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _planDescriptions[_selectedPlanType] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Cost Box with Currency Conversion
                          if (_selectedPlanType != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cost',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: _selectedCurrency,
                                        style: TextStyle(color: Colors.black),
                                        underline: Container(
                                          height: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                        items: _exchangeRates.keys.map((currency) {
                                          return DropdownMenuItem<String>(
                                            value: currency,
                                            child: Text(currency),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCurrency = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${_convertedPrice.toStringAsFixed(2)} ${_selectedCurrency}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            localeProvider.translate('serviceLocation'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _locationController,
                            style: TextStyle(color: Colors.black), // Black input text
                            decoration: InputDecoration(
                              hintText: localeProvider.translate('enterServiceLocation'),
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Black placeholder
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white, // White background for dark mode
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: adaptiveButton(
                              localeProvider.translate('requestDetailingService'),
                              _isFormValid ? _submitDetailingRequest : null,
                              isEnabled: _isFormValid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}