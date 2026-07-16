import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _captchaController = TextEditingController();

  String? _captchaId;
  String? _captchaImageBase64;
  bool _loadingCaptcha = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCaptcha();
  }

  Future<void> _fetchCaptcha() async {
    setState(() {
      _loadingCaptcha = true;
      _error = null;
    });
    try {
      final data = await ApiService.getCaptcha();
      setState(() {
        _captchaId = data['captcha_id'];
        _captchaImageBase64 = data['image_bytes'];
        _loadingCaptcha = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Cannot load captcha. Make sure backend is running.';
        _loadingCaptcha = false;
      });
    }
  }

  Future<void> _submit() async {
    final mobile = _mobileController.text.trim();
    final captchaAnswer = _captchaController.text.trim();

    if (mobile.length != 10 || !RegExp(r'^[6-9]').hasMatch(mobile)) {
      setState(() => _error = 'Enter a valid 10-digit mobile number starting with 6,7,8,9');
      return;
    }
    if (_captchaId == null || captchaAnswer.isEmpty) {
      setState(() => _error = 'Please enter CAPTCHA');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ApiService.sendOTP(
        mobileNumber: mobile,
        captchaId: _captchaId!,
        captchaAnswer: captchaAnswer,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OtpScreen(mobileNumber: mobile)),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      _fetchCaptcha(); // fetch a fresh captcha after a failed attempt
      _captchaController.clear();
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.location_city, size: 64, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 12),
                const Text(
                  'Urban Smart City',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const Text(
                  'Citizen Complaint Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_android),
                    hintText: 'Enter 10-digit mobile number',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Captcha', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  height: 75,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: _loadingCaptcha
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A8A)),
                                )
                              : _captchaImageBase64 != null
                                  ? Image.memory(
                                      base64Decode(_captchaImageBase64!),
                                      fit: BoxFit.contain,
                                    )
                                  : const Text('Failed to load image', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Get a new captcha',
                        onPressed: _loadingCaptcha ? null : _fetchCaptcha,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _captchaController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.verified_user_outlined),
                    hintText: 'Enter the digits shown above',
                    border: OutlineInputBorder(),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
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
                      : const Text('Send OTP', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
