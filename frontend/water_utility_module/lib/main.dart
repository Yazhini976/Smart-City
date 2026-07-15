import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/officer_dashboard.dart';
import 'screens/citizen_dashboard.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment loaded successfully');
    print('📱 API_URL: ${dotenv.env['API_URL']}');
  } catch (e) {
    print('❌ Error loading .env: $e');
    // Fallback to default
    dotenv.env['API_URL'] = 'http://10.0.2.2:8081/api';
  }

  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(prefs),
      child: MaterialApp(
        title: 'Water Utility - Smart City',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              if (auth.userRole == 'officer') {
                return const OfficerDashboard();
              }
              return const CitizenDashboard();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}