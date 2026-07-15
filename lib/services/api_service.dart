import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.0.21:8081";

  static Future<void> sendOTP(String mobileNumber) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': mobileNumber,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send OTP');
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
    );

    if (res.statusCode != 200) {
      throw Exception(
        res.body.isNotEmpty ? res.body : 'OTP verification failed',
      );
    }

    return jsonDecode(res.body);
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
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update user profile role');
    }
  }
}