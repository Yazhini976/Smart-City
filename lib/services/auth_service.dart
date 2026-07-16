import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences prefs;
  bool _isLoggedIn = false;
  String _userRole = 'citizen';
  int _userId = 0;
  String _phoneNumber = '';

  AuthService(this.prefs) {
    _loadSession();
  }

  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  int get userId => _userId;
  String get phoneNumber => _phoneNumber;

  void _loadSession() {
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _userRole = prefs.getString('user_role') ?? 'citizen';
    _userId = prefs.getInt('user_id') ?? 0;
    _phoneNumber = prefs.getString('phone_number') ?? '';
  }

  void setSession(int userId, String phone, String role) {
    _userId = userId;
    _phoneNumber = phone;
    _userRole = role;
    _isLoggedIn = true;
    prefs.setBool('is_logged_in', true);
    prefs.setString('user_role', role);
    prefs.setInt('user_id', userId);
    prefs.setString('phone_number', phone);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = 'citizen';
    _userId = 0;
    _phoneNumber = '';
    prefs.remove('is_logged_in');
    prefs.remove('user_role');
    prefs.remove('user_id');
    prefs.remove('phone_number');
    notifyListeners();
  }
}
