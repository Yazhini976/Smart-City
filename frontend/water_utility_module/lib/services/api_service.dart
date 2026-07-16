import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';

class ApiService {
  static String? _baseUrlOverride;

  static String get baseUrl {
    if (_baseUrlOverride != null) return _baseUrlOverride!;
    try {
      final url = dotenv.env['API_URL'] ?? 'http://172.16.147.44:8081/api';
      print('🌐 Using API_URL: $url');
      return url;
    } catch (_) {
      // dotenv not loaded (e.g. launched from container app)
      return 'http://172.16.147.44:8081/api';
    }
  }

  static void setBaseUrl(String url) {
    _baseUrlOverride = url;
  }

  static String? _authToken;
  static int? _userId;

  static void setAuth(String token, int userId) {
    _authToken = token;
    _userId = userId;
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      if (_userId != null) 'X-User-ID': '$_userId',
    };
  }

  // ============================================
  // AUTH METHODS
  // ============================================

  static Future<Map<String, dynamic>> sendOTP(String phone) async {
    try {
      final url = '$baseUrl/auth/send-otp';
      print('📤 Sending OTP to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Make sure backend is running.'),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Cannot reach backend at $baseUrl. Make sure:\n1. Backend is running\n2. Port 8081 is correct\n3. .env has correct URL');
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String phone, String otp) async {
    try {
      final url = '$baseUrl/auth/verify-otp';
      print('📤 Verifying OTP at: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Make sure backend is running.'),
      );

      print('📥 Verify Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = 'dummy-token-${data['user_id']}';
        _userId = data['user_id'];
        return data;
      } else {
        throw Exception('Invalid OTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Cannot reach backend: $e');
    }
  }

  // ============================================
  // MODULE METHODS
  // ============================================

  static Future<List<Map<String, dynamic>>> getModules() async {
    try {
      final url = '$baseUrl/modules';
      print('📤 Fetching modules from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout.'),
      );

      print('📥 Modules Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading modules: $e');
      // Return dummy data for testing
      return [
        {'module_id': 1, 'module_name': 'Water Utility', 'module_icon': '💧', 'is_active': true},
        {'module_id': 2, 'module_name': 'Solar Power', 'module_icon': '☀️', 'is_active': true},
        {'module_id': 3, 'module_name': 'Pollution Monitoring', 'module_icon': '🌫️', 'is_active': true},
        {'module_id': 4, 'module_name': 'Vehicle Tracking', 'module_icon': '🚗', 'is_active': true},
        {'module_id': 5, 'module_name': 'Water Body Levels', 'module_icon': '🌊', 'is_active': true},
        {'module_id': 6, 'module_name': 'Garbage Monitoring', 'module_icon': '🗑️', 'is_active': true},
        {'module_id': 7, 'module_name': 'Smart Lighting', 'module_icon': '💡', 'is_active': true},
        {'module_id': 8, 'module_name': 'Weather Sensors', 'module_icon': '🌤️', 'is_active': true},
        {'module_id': 9, 'module_name': 'Health Management', 'module_icon': '🏥', 'is_active': true},
      ];
    }
  }

  static Future<int> lookupWard(double lat, double lng) async {
    try {
      final url = '$baseUrl/wards/lookup?latitude=$lat&longitude=$lng';
      print('📤 Looking up ward from: $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ward_no'] ?? 0;
      }
    } catch (e) {
      print('❌ Error looking up ward: $e');
    }
    return 0;
  }

  // ============================================
  // COMPLAINT METHODS
  // ============================================

  static Future<Map<String, dynamic>> createComplaint(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout.'),
      );

      print('📥 Create Complaint Response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create complaint: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Cannot reach backend: $e');
    }
  }

  static Future<List<Complaint>> getUserComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/complaints'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout.'),
      );

      print('📥 User Complaints Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Complaint.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load complaints: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading complaints: $e');
      return [];
    }
  }

  static Future<List<WorkOrder>> getOfficerWorkOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/officer/work-orders'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout.'),
      );

      print('📥 Work Orders Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => WorkOrder.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load work orders: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading work orders: $e');
      return [];
    }
  }

  static Future<void> updateWorkOrder(String id, String status, {String? reason}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/work-orders/$id'),
        headers: _getHeaders(),
        body: jsonEncode({'status': status, 'rejection_reason': reason}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout.'),
      );

      print('📥 Update Work Order Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update work order: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Cannot reach backend: $e');
    }
  }
}