import 'package:auto_solutions/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl

class ProfilePage extends StatefulWidget {
  final Map<String, String> translations;

  const ProfilePage({super.key, required this.translations});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = "Loading...";
  String _country = "Loading...";
  String _email = "Loading...";
  String _phone = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      // Handle no token, maybe navigate to login
      setState(() {
        _isLoading = false;
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
        final userData = json.decode(response.body);
        setState(() {
          _fullName = userData['name'] ?? "Unknown";
          _email = userData['email'] ?? "Unknown";
          _phone = userData['phone'] ?? "Not provided";
          _country = userData['country'] ?? "Not provided";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _fullName = "Error loading";
          _email = "Error loading";
          _phone = "Error loading";
          _country = "Error loading";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _fullName = "Error loading";
        _email = "Error loading";
        _phone = "Error loading";
        _country = "Error loading";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: Icon(CupertinoIcons.person, size: 40, color: Colors.grey[700]),
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

            // Profile details card
            Card(
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildDetailRow(widget.translations['fullName'] ?? 'Name', _fullName),
                  const Divider(height: 0),
                  _buildDetailRow(widget.translations['email'] ?? 'Email account', _email),
                  const Divider(height: 0),
                  _buildDetailRow(widget.translations['phoneNumber'] ?? 'Mobile number', _phone.isEmpty ? "Add number" : _phone),
                  const Divider(height: 0),
                  _buildDetailRow(widget.translations['country'] ?? 'Country', _country),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Logout button
            adaptiveButton(
              widget.translations['logout'] ?? 'Logout',
              () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
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