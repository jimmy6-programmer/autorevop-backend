import 'dart:convert';
import 'package:auto_revop/models/spare_part_model.dart';
import 'package:http/http.dart' as http;

import '../utils/api_utils.dart'; // For getApiBaseUrl

class InventoryService {
  static String get baseUrl => '${getApiBaseUrl()}/api';

  static Future<List<SparePart>> fetchInventory() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/inventory'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => SparePart.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load inventory: Status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Check if it's a network error (offline)
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('There was an error occurred, please check if you are connected to the internet.');
      }
      throw Exception('Error fetching inventory: $e');
    }
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(orderData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create order: Status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserCart(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/cart/$userId'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch cart: Status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  static Future<Map<String, dynamic>> syncCart(String userId, List<Map<String, dynamic>> cartItems) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/cart/sync/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'items': cartItems}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to sync cart: Status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Error syncing cart: $e');
    }
  }
}