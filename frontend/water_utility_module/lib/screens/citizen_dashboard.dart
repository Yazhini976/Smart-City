import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_city/screens/login_screen.dart' as container_login;
import '../services/auth_service.dart';
import 'modules_screen.dart';

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Utility - Citizen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const container_login.LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Phone: ${auth.phoneNumber}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Services',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  ModuleCard(
                    icon: Icons.water_drop,
                    label: 'Water Utility',
                    moduleId: 1,
                  ),
                  ModuleCard(
                    icon: Icons.solar_power,
                    label: 'Solar Power',
                    moduleId: 2,
                  ),
                  ModuleCard(
                    icon: Icons.air,
                    label: 'Pollution Monitoring',
                    moduleId: 3,
                  ),
                  ModuleCard(
                    icon: Icons.directions_car,
                    label: 'Vehicle Tracking',
                    moduleId: 4,
                  ),
                  ModuleCard(
                    icon: Icons.water,
                    label: 'Water Body Levels',
                    moduleId: 5,
                  ),
                  ModuleCard(
                    icon: Icons.delete,
                    label: 'Garbage Monitoring',
                    moduleId: 6,
                  ),
                  ModuleCard(
                    icon: Icons.lightbulb,
                    label: 'Smart Lighting',
                    moduleId: 7,
                  ),
                  ModuleCard(
                    icon: Icons.wb_sunny,
                    label: 'Weather Sensors',
                    moduleId: 8,
                  ),
                  ModuleCard(
                    icon: Icons.health_and_safety,
                    label: 'Health Management',
                    moduleId: 9,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int moduleId;
  const ModuleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModulesScreen(moduleId: moduleId, moduleName: label),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}