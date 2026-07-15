import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_utility_module/screens/modules_screen.dart';
import '../models/module.dart';
import '../widgets/module_card.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role; // 'citizen' or 'staff'
  const DashboardScreen({super.key, required this.role});

  void _openModule(BuildContext context, CityModule module) {
    int moduleId;
    switch (module.key) {
      case 'water':
        moduleId = 1;
        break;
      case 'solar':
        moduleId = 2;
        break;
      case 'pollution':
        moduleId = 3;
        break;
      case 'vehicle':
        moduleId = 4;
        break;
      case 'waterbody':
        moduleId = 5;
        break;
      case 'garbage':
        moduleId = 6;
        break;
      case 'lighting':
        moduleId = 7;
        break;
      case 'weather':
        moduleId = 8;
        break;
      case 'ugss':
        moduleId = 9;
        break;
      default:
        moduleId = 1;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModulesScreen(
          moduleId: moduleId,
          moduleName: module.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_city, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Urban Smart City Dashboard',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(role == 'staff' ? 'Staff' : 'Citizen'),
                      backgroundColor: role == 'staff'
                          ? const Color(0xFFEDE7F6)
                          : const Color(0xFFE8F5E9),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
                      tooltip: 'Logout',
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final module = cityModules[index];
                    return ModuleCard(
                      module: module,
                      onTap: () => _openModule(context, module),
                    );
                  },
                  childCount: cityModules.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
