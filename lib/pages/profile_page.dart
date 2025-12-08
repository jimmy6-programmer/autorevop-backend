import '../widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
import '../utils/auth_utils.dart'; // For authentication utilities
import '../providers/translation_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = "Loading...";
  String _country = "Loading...";
  String _email = "Loading...";
  String _phone = "Loading...";
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final isLoggedIn = await AuthUtils.isLoggedIn();

    if (!isLoggedIn) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
        _fullName = "Not logged in";
        _email = "Not logged in";
        _phone = "Not logged in";
        _country = "Not logged in";
      });
      return;
    }

    // User is logged in, fetch details
    final userData = await AuthUtils.getUserData();
    final token = await AuthUtils.getToken();

    if (token == null) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
        _fullName = "Not logged in";
        _email = "Not logged in";
        _phone = "Not logged in";
        _country = "Not logged in";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final apiUserData = json.decode(response.body);
        setState(() {
          _isLoggedIn = true;
          _fullName = apiUserData['name'] ?? userData?['name'] ?? "Unknown";
          _email = apiUserData['email'] ?? userData?['email'] ?? "Unknown";
          _phone = apiUserData['phone'] ?? "Not provided";
          _country = apiUserData['country'] ?? "Not provided";
          _isLoading = false;
        });
      } else {
        // Fallback to stored user data if API fails
        setState(() {
          _isLoggedIn = true;
          _fullName = userData?['name'] ?? "Unknown";
          _email = userData?['email'] ?? "Unknown";
          _phone = userData?['phone'] ?? "Not provided";
          _country = userData?['country'] ?? "Not provided";
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to stored user data if API fails
      setState(() {
        _isLoggedIn = true;
        _fullName = userData?['name'] ?? "Unknown";
        _email = userData?['email'] ?? "Unknown";
        _phone = userData?['phone'] ?? "Not provided";
        _country = userData?['country'] ?? "Not provided";
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final token = await AuthUtils.getToken();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}/api/auth/delete-account'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await AuthUtils.clearAuthData();

        // Show success message before navigating
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Delay navigation to allow user to see the success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error deleting account')));
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localeProvider.translate('deleteAccount')),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    CupertinoIcons.person,
                    size: 40,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile details card - only show if logged in
            if (_isLoggedIn) ...[
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      localeProvider.translate('fullName'),
                      _fullName,
                    ),
                    const Divider(height: 0),
                    _buildDetailRow(localeProvider.translate('email'), _email),
                    const Divider(height: 0),
                    _buildDetailRow(
                      localeProvider.translate('phoneNumber'),
                      _phone.isEmpty ? "Add number" : _phone,
                    ),
                    const Divider(height: 0),
                    _buildDetailRow(
                      localeProvider.translate('country'),
                      _country,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ] else ...[
              // Show welcome message for not logged in users
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.person_circle,
                        size: 60,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localeProvider.translate('welcomeMessage'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localeProvider.translate('loginPrompt'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],

            const SizedBox(height: 30),

            // Show different buttons based on login status
            if (_isLoggedIn) ...[
              // Delete Account button for logged in users
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () => _showDeleteAccountDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    localeProvider.translate('deleteAccount'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Logout button for logged in users
              adaptiveButton(localeProvider.translate('logout'), () async {
                await AuthUtils.clearAuthData();
                // Navigate to login page and clear navigation stack
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }),
            ] else ...[
              // Login button for not logged in users
              adaptiveButton(localeProvider.translate('login'), () {
                // Since we're in a CupertinoTabView, we need to use a different navigation approach
                Navigator.of(context, rootNavigator: true).pushNamed('/login');
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
