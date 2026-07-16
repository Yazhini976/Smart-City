import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/officer_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(prefs),
      child: const SmartCityApp(),
    ),
  );
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // If logged in, configure backend authentication headers
    if (auth.isLoggedIn && auth.userId > 0) {
      ApiService.setAuth('dummy-token-${auth.userId}', auth.userId);
    }

    Widget homeScreen;
    if (auth.isLoggedIn) {
      if (auth.userRole == 'officer') {
        homeScreen = const OfficerDashboard();
      } else {
        homeScreen = DashboardScreen(role: auth.userRole);
      }
    } else {
      homeScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Urban Smart City',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: homeScreen,
    );
  }
}
