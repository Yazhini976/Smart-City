import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _captchaText = '';

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    setState(() {
      _captchaText = List.generate(
        6,
            (_) => chars[random.nextInt(chars.length)],
      ).join('');
    });
  }

  Future<void> _sendOTP() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate CAPTCHA (case-insensitive)
    if (_captchaController.text.trim().toUpperCase() != _captchaText) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid CAPTCHA. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      _generateCaptcha();
      _captchaController.clear();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.sendOTP(_phoneController.text.trim());

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(
              phoneNumber: _phoneController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Water Utility',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Smart City Complaint Management',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your 10-digit phone number',
                    prefixIcon: const Icon(Icons.phone_android),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be exactly 10 digits';
                    }
                    if (!RegExp(r'^[6-9]').hasMatch(value)) {
                      return 'Must start with 6, 7, 8, or 9';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Only numbers allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  "DEBUG CAPTCHA: $_captchaText",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                // CAPTCHA Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CAPTCHA Input Field
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _captchaController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Enter CAPTCHA',
                          hintText: 'Enter code shown',
                          prefixIcon: const Icon(Icons.security),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter CAPTCHA';
                          }
                          if (value.length < 6) {
                            return 'Enter 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // CAPTCHA Display Box
                    GestureDetector(
                      onTap: _generateCaptcha,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue.shade50,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // CAPTCHA Text
                            Text(
                              _captchaText.isEmpty ? '------' : _captchaText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontFamily: 'monospace',
                                color: _captchaText.isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Refresh Button
                            InkWell(
                              onTap: _generateCaptcha,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap CAPTCHA box to refresh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '6 chars',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sms,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'OTP will be sent to your phone number',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}