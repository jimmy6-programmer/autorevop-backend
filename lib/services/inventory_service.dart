import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_solutions/models/spare_part_model.dart';
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
}