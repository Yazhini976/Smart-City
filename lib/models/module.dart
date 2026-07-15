import 'package:flutter/material.dart';

class CityModule {
  final String key;
  final String title;
  final String subtitle;
  final String stat;
  final IconData icon;
  final Color accentColor;
  final Color bgColorStart;
  final Color bgColorEnd;

  const CityModule({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.stat,
    required this.icon,
    required this.accentColor,
    required this.bgColorStart,
    required this.bgColorEnd,
  });
}

/// The 9 modules exactly as laid out in the dashboard mock.
/// Each will eventually deep-link into its own standalone
/// Flutter app once those are integrated into this container.
final List<CityModule> cityModules = [
  const CityModule(
    key: 'ugss',
    title: 'UGSS Monitoring',
    subtitle: 'Inflow, Overflow, Blockage Alerts',
    stat: '95% lines normal',
    icon: Icons.plumbing,
    accentColor: Color(0xFF2E7D32),
    bgColorStart: Color(0xFFE8F5E9),
    bgColorEnd: Color(0xFFC8E6C9),
  ),
  const CityModule(
    key: 'water',
    title: 'Water Utility',
    subtitle: 'Flow, Pressure, Tank Level',
    stat: 'Usage: 720 KL/day',
    icon: Icons.water_drop,
    accentColor: Color(0xFF1565C0),
    bgColorStart: Color(0xFFE3F2FD),
    bgColorEnd: Color(0xFFBBDEFB),
  ),
  const CityModule(
    key: 'solar',
    title: 'Solar Power',
    subtitle: 'Generation, Feed-in, Battery',
    stat: '68 kWh generated today',
    icon: Icons.wb_sunny,
    accentColor: Color(0xFFEF6C00),
    bgColorStart: Color(0xFFFFF8E1),
    bgColorEnd: Color(0xFFFFECB3),
  ),
  const CityModule(
    key: 'pollution',
    title: 'Pollution Monitoring',
    subtitle: 'AQI: PM2.5, NO2, CO',
    stat: 'AQI 142 (Moderate)',
    icon: Icons.cloud,
    accentColor: Color(0xFFC62828),
    bgColorStart: Color(0xFFFBE9E7),
    bgColorEnd: Color(0xFFFFCCBC),
  ),
  const CityModule(
    key: 'vehicle',
    title: 'Vehicle Tracking',
    subtitle: 'City Buses, Ambulances, Utility Vehicles',
    stat: '48/50 online',
    icon: Icons.directions_bus,
    accentColor: Color(0xFF00838F),
    bgColorStart: Color(0xFFE0F7FA),
    bgColorEnd: Color(0xFFB2EBF2),
  ),
  const CityModule(
    key: 'waterbody',
    title: 'Water Body Levels',
    subtitle: 'Tanks, Lakes, Reservoirs',
    stat: 'Tank A: 72% full',
    icon: Icons.water,
    accentColor: Color(0xFF0277BD),
    bgColorStart: Color(0xFFE1F5FE),
    bgColorEnd: Color(0xFFB3E5FC),
  ),
  const CityModule(
    key: 'garbage',
    title: 'Garbage Monitoring',
    subtitle: 'Bin Status, Route Completion, Alerts',
    stat: '91% bins emptied',
    icon: Icons.delete,
    accentColor: Color(0xFF2E7D32),
    bgColorStart: Color(0xFFF1F8E9),
    bgColorEnd: Color(0xFFDCEDC8),
  ),
  const CityModule(
    key: 'lighting',
    title: 'Smart Lighting',
    subtitle: 'City Street Lights: Online/Offline',
    stat: '98% ON (Auto Mode)',
    icon: Icons.lightbulb,
    accentColor: Color(0xFFF9A825),
    bgColorStart: Color(0xFFFFFDE7),
    bgColorEnd: Color(0xFFFFF9C4),
  ),
  const CityModule(
    key: 'weather',
    title: 'Weather Sensors',
    subtitle: 'Rainfall, Temp, Humidity, Wind',
    stat: '32°C, 61% RH',
    icon: Icons.cloudy_snowing,
    accentColor: Color(0xFF37474F),
    bgColorStart: Color(0xFFECEFF1),
    bgColorEnd: Color(0xFFCFD8DC),
  ),
];
