import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.21:8081";

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

  static Future<Map<String, dynamic>> getCaptcha() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/auth/captcha'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout. Make sure backend is running.'),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load captcha');
    }
  }

  static Future<void> sendOTP({
    required String mobileNumber,
    required String captchaId,
    required String captchaAnswer,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': mobileNumber,
        'captcha_id': captchaId,
        'captcha_answer': captchaAnswer,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout. Make sure backend is running.'),
    );

    if (res.statusCode != 200) {
      String errMsg = 'Failed to send OTP';
      try {
        final data = jsonDecode(res.body);
        if (data['error'] != null) errMsg = data['error'];
      } catch (_) {}
      throw Exception(errMsg);
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': mobileNumber,
        'otp': otp,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout.'),
    );

    if (res.statusCode != 200) {
      throw Exception(
        res.body.isNotEmpty ? res.body : 'OTP verification failed',
      );
    }

    final data = jsonDecode(res.body);
    if (data['user_id'] != null) {
      setAuth('dummy-token-${data['user_id']}', data['user_id']);
    }
    return data;
  }

  static Future<void> updateUserRole({
    required int userId,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/update-role'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-ID': '$userId',
        'Authorization': 'Bearer dummy-token-$userId',
      },
      body: jsonEncode({
        'role': role,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout.'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update user profile role');
    }
  }

  // ============================================
  // MODULE METHODS
  // ============================================

  static Future<List<Map<String, dynamic>>> getModules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/modules'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout.'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      // Return dummy data for safety
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
      final response = await http.get(
        Uri.parse('$baseUrl/api/wards/lookup?latitude=$lat&longitude=$lng'),
      ).timeout(const Duration(seconds: 5));

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
    final response = await http.post(
      Uri.parse('$baseUrl/api/complaints'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout.'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create complaint: ${response.statusCode}');
    }
  }

  static Future<List<Complaint>> getUserComplaints() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/complaints'),
      headers: _getHeaders(),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout.'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Complaint.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load complaints: ${response.statusCode}');
    }
  }

  static Future<List<WorkOrder>> getOfficerWorkOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/officer/work-orders'),
      headers: _getHeaders(),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout.'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => WorkOrder.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load work orders: ${response.statusCode}');
    }
  }

  static Future<void> updateWorkOrder(String id, String status, {String? reason}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/work-orders/$id'),
      headers: _getHeaders(),
      body: jsonEncode({'status': status, 'remarks': reason ?? 'Status updated by officer'}),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timeout.'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update work order: ${response.statusCode}');
    }
  }
}