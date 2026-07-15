import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'report_issue_screen.dart';
import 'my_complaints_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Location Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _locationEnabled ? 'Location Enabled' : 'Location Disabled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _locationEnabled ? Colors.green : Colors.red,
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
                      const SizedBox(height: 8),
                      Text('📍 ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
                      const SizedBox(height: 4),
                      Text('🏠 ${_address['street']}, ${_address['area']}, ${_address['city']}'),
                      const SizedBox(height: 4),
                      Text('📋 Ward Number: ${_address['ward'] ?? 'Loading...'}'),
                    ],
                    if (!_locationEnabled)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please enable location to report issues',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
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
                label: const Text('Report Issue', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyComplaintsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('My Complaints', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}