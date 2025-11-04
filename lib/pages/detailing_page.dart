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
  String? _selectedServiceType;

  final List<String> _vehicleTypes = [
    'Small Car (Sedan/Hatchback)',
    'SUV/Crossover',
    'Truck/Pickup',
    'Van/Minivan'
  ];

  final List<String> _serviceTypes = [
    'Exterior Cleaning',
    'Interior Cleaning',
    'General Cleaning'
  ];

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
           _selectedServiceType != null;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to update button state when form changes
    _phoneController.addListener(_updateButtonState);
    _locationController.addListener(_updateButtonState);
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
      'serviceType': _selectedServiceType,
      'location': _locationController.text,
      'totalPrice': '0', // Default price for detailing
      'currency': 'USD',
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
          _selectedServiceType = null;
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
                            localeProvider.translate('serviceType'),
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
                              _serviceTypes,
                              _selectedServiceType,
                              (value) {
                                setState(() {
                                  _selectedServiceType = value;
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
                                    _selectedServiceType ?? localeProvider.translate('selectServiceType'),
                                    style: TextStyle(
                                      color: _selectedServiceType != null
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
                            value: _selectedVehicleType,
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
                            localeProvider.translate('serviceType'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedServiceType,
                            style: TextStyle(color: Colors.black), // Black text for selected value
                            decoration: InputDecoration(
                              hintText: localeProvider.translate('selectServiceType'),
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
                            items: _serviceTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type, style: TextStyle(color: Colors.black)), // Black dropdown text
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedServiceType = value;
                              });
                            },
                          ),
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