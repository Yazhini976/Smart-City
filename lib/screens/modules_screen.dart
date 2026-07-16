import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import 'report_issue_screen.dart';
import 'my_complaints_screen.dart';

// Module Widgets
import '../modules/ugss/ugss_widget.dart';
import '../modules/water/water_widget.dart';
import '../modules/pollution/pollution_widget.dart';
import '../modules/vehicle/vehicle_widget.dart';
import '../modules/waterbody/waterbody_widget.dart';
import '../modules/lighting/lighting_widget.dart';
import '../modules/weather/weather_widget.dart';

class ModulesScreen extends StatefulWidget {
  final int moduleId;
  final String moduleName;
  const ModulesScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  bool _locationEnabled = false;
  Position? _currentPosition;
  Map<String, String> _address = {};

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationEnabled = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationEnabled = false);
        return;
      }
    }

    setState(() => _locationEnabled = true);
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      _address = await LocationService.getAddressFromLatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final wardNo = await ApiService.lookupWard(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _address['ward'] = wardNo.toString();
      setState(() {});
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _enableLocation() async {
    await Geolocator.openLocationSettings();
    _checkLocation();
  }

  Widget _getModuleWorkingProcess(int moduleId) {
    switch (moduleId) {
      case 1:
        return const WaterWorkingProcess();
      case 3:
        return const PollutionWorkingProcess();
      case 4:
        return const VehicleWorkingProcess();
      case 5:
        return const WaterbodyWorkingProcess();
      case 7:
        return const LightingWorkingProcess();
      case 8:
        return const WeatherWorkingProcess();
      case 9:
        return const UgssWorkingProcess();
      default:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Telemetry unavailable for this module',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.moduleName),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _locationEnabled ? Icons.location_on : Icons.location_off,
                          color: _locationEnabled ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _locationEnabled ? 'Location Registered' : 'Location Disabled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _locationEnabled ? Colors.green.shade800 : Colors.red.shade800,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (!_locationEnabled)
                          TextButton(
                            onPressed: _enableLocation,
                            child: const Text('Enable'),
                          ),
                      ],
                    ),
                    if (_locationEnabled && _currentPosition != null) ...[
                      const Divider(height: 20),
                      Text(
                        '📌 Coordinates: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🏠 Address: ${_address['street'] ?? ''}, ${_address['area'] ?? ''}, ${_address['city'] ?? ''}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📋 Ward Number: ${_address['ward'] ?? 'Loading...'}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                    if (!_locationEnabled)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please enable location services to report local issues.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Embedded Module Working Process View
            _getModuleWorkingProcess(widget.moduleId),
            const SizedBox(height: 28),

            // Buttons
            ElevatedButton.icon(
              onPressed: (_locationEnabled && _currentPosition != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportIssueScreen(
                            moduleId: widget.moduleId,
                            position: _currentPosition!,
                            address: _address,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.report_problem),
              label: const Text('Report Issue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyComplaintsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('My Complaints', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
                side: const BorderSide(color: Color(0xFF1E3A8A)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
