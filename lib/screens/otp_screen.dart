import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'officer_dashboard.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final data = await ApiService.verifyOtp(
        mobileNumber: widget.mobileNumber,
        otp: otp,
      );

      final bool isOfficer = data['is_officer'] == true;
      final int userId = data['user_id'] ?? 0;

      if (!mounted) return;

      if (isOfficer) {
        _showRoleDialog(userId);
      } else {
        await _saveSession(userId, widget.mobileNumber, 'citizen');
        _goToDashboard('citizen');
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _saveSession(int userId, String phone, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', role);
    await prefs.setInt('user_id', userId);
    await prefs.setString('phone_number', phone);
  }

  void _showRoleDialog(int userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Switch Profile'),
        content: const Text('This phone number is registered as staff. How would you like to continue?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _submitting = true);
              try {
                await ApiService.updateUserRole(userId: userId, role: 'citizen');
              } catch (_) {
                // Role update is best-effort; proceed to dashboard anyway
              }
              await _saveSession(userId, widget.mobileNumber, 'citizen');
              if (mounted) {
                setState(() => _submitting = false);
                _goToDashboard('citizen');
              }
            },
            child: const Text('Login as Citizen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _submitting = true);
              try {
                await ApiService.updateUserRole(userId: userId, role: 'officer');
              } catch (_) {
                // Role update is best-effort; proceed to dashboard anyway
              }
              await _saveSession(userId, widget.mobileNumber, 'officer');
              if (mounted) {
                setState(() => _submitting = false);
                _goToDashboard('officer');
              }
            },
            child: const Text('Login as Staff'),
          ),
        ],
      ),
    );
  }

  void _goToDashboard(String role) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final userId = prefs.getInt('user_id') ?? 0;
    ApiService.setAuth('dummy-token-$userId', userId);

    final auth = Provider.of<AuthService>(context, listen: false);
    auth.setSession(userId, widget.mobileNumber, role);

    if (role == 'officer') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const OfficerDashboard(),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.sms_outlined, size: 56, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to ${widget.mobileNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
