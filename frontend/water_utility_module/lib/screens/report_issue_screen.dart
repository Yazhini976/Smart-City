import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReportIssueScreen extends StatefulWidget {
  final int moduleId;
  final Position position;
  final Map<String, String> address;
  const ReportIssueScreen({
    super.key,
    required this.moduleId,
    required this.position,
    required this.address,
  });

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? _selectedIssue;
  final TextEditingController _otherDescriptionController = TextEditingController();
  File? _selectedImage;
  String? _photoUrl;
  bool _isLoading = false;
  String _selectedImageSource = 'Camera';

  List<String> get _predefinedIssues {
    switch (widget.moduleId) {
      case 1: // Water Utility
        return ['Pipeline Leakage', 'No Water Supply', 'Dirty Water Supply', 'Low Water Pressure', 'Others'];
      case 2: // Solar Power
        return ['Panel Damage', 'Inverter Failure', 'Grid Sync Issue', 'Others'];
      case 3: // Pollution Monitoring
        return ['High AQI Alert', 'Industrial Smoke', 'Chemical Odor', 'Others'];
      case 4: // Vehicle Tracking
        return ['Bus Delay', 'Tracking Offline', 'Driver Rash Driving', 'Others'];
      case 5: // Water Body Levels
        return ['Lake Overflow', 'Water Contamination', 'Encroachment', 'Others'];
      case 6: // Garbage Monitoring
        return ['Overflowing Bin', 'Garbage Truck Skipped', 'Dead Animal', 'Others'];
      case 7: // Smart Lighting
        return ['Streetlight Not Working', 'Daytime Burning', 'Flickering Light', 'Others'];
      case 8: // Weather Sensors
        return ['Sensor Damage', 'Incorrect Readings', 'Others'];
      case 9: // UGSS Monitoring
        return ['Sewage Blockage', 'Manhole Overflow', 'Bad Odor', 'Others'];
      default:
        return ['General Issue', 'Others'];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, maxWidth: 1024);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImageSource = source == ImageSource.camera ? 'Camera' : 'Gallery';
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue type')),
      );
      return;
    }

    final title = _selectedIssue!;
    String description = title;

    if (title == 'Others') {
      if (_otherDescriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please describe the issue')),
        );
        return;
      }
      description = _otherDescriptionController.text.trim();
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final data = {
        'module_id': widget.moduleId,
        'latitude': widget.position.latitude,
        'longitude': widget.position.longitude,
        'street': widget.address['street'] ?? '',
        'area': widget.address['area'] ?? '',
        'city': widget.address['city'] ?? '',
        'title': title,
        'description': description,
        'photo_url': _photoUrl ?? '',
      };

      final response = await ApiService.createComplaint(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Complaint #${response['complaint_id']} submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final issuesList = _predefinedIssues;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Report Issue'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Location Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text('Street: ${widget.address['street'] ?? 'N/A'}'),
                    const SizedBox(height: 4),
                    Text('Area: ${widget.address['area'] ?? 'N/A'}'),
                    const SizedBox(height: 4),
                    Text('City: ${widget.address['city'] ?? 'N/A'}'),
                    const SizedBox(height: 4),
                    Text('Ward: ${widget.address['ward'] ?? 'N/A'}'),
                    const SizedBox(height: 4),
                    Text('Coordinates: ${widget.position.latitude.toStringAsFixed(6)}, ${widget.position.longitude.toStringAsFixed(6)}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Issue Selection Dropdown
              const Text(
                'Select Issue Type *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedIssue,
                hint: const Text('Choose the issue you are facing'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.error_outline),
                ),
                items: issuesList.map((issue) {
                  return DropdownMenuItem<String>(
                    value: issue,
                    child: Text(issue),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedIssue = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Conditional description input field (only shown if "Others" is selected)
              if (_selectedIssue == 'Others') ...[
                const Text(
                  'Describe the issue *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otherDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Specify the problem details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],

              // Photo section
              const Text('Attach Photo (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Image.file(_selectedImage!, height: 160, width: double.infinity, fit: BoxFit.cover),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        color: Colors.grey.shade100,
                        width: double.infinity,
                        child: Text(
                          'Attached via $_selectedImageSource',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}