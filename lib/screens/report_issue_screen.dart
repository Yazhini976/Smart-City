import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

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
  bool _isLoading = false;
  String _selectedImageSource = 'Camera';

  List<String> get _predefinedIssues {
    switch (widget.moduleId) {
      case 1: // Water Utility
        return ['Pipeline Leakage', 'No Water Supply', 'Dirty Water Supply', 'Low Water Pressure', 'Others'];
      case 2: // Solar Power (Disabled but kept for mapping)
        return ['Panel Damage', 'Inverter Failure', 'Grid Sync Issue', 'Others'];
      case 3: // Pollution Monitoring
        return ['High AQI Alert', 'Industrial Smoke', 'Chemical Odor', 'Others'];
      case 4: // Vehicle Tracking
        return ['Bus Delay', 'Tracking Offline', 'Driver Rash Driving', 'Others'];
      case 5: // Water Body Levels
        return ['Lake Overflow', 'Water Contamination', 'Encroachment', 'Others'];
      case 6: // Garbage Monitoring (Disabled but kept for mapping)
        return ['Overflowing Bin', 'Garbage Truck Skipped', 'Dead Animal', 'Others'];
      case 7: // Smart Lighting
        return ['Streetlight Not Working', 'Daytime Burning', 'Flickering Light', 'Others'];
      case 8: // Weather Sensors
        return ['Sensor Damage', 'Incorrect Readings', 'Others'];
      case 9: // UGSS Monitoring (Corresponds to Health Management in database schema, mapped to UGSS in app)
        return ['Sewage Blockage', 'Manhole Overflow', 'Bad Odor', 'Others'];
      default:
        return ['General Issue', 'Others'];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
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
      String base64Photo = '';
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Photo = base64Encode(bytes);
      }

      final data = {
        'module_id': widget.moduleId,
        'latitude': widget.position.latitude,
        'longitude': widget.position.longitude,
        'street': widget.address['street'] ?? '',
        'area': widget.address['area'] ?? '',
        'city': widget.address['city'] ?? '',
        'title': title, // Will map to 'reason' in backend database
        'description': description,
        'photo_url': base64Photo, // Base64 string to store directly in text field
      };

      final response = await ApiService.createComplaint(data);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Complaint #${response['complaint_id']} submitted successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
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
        title: const Text('Report Local Issue'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location details container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF1E3A8A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Registered Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('Street: ${widget.address['street'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Area: ${widget.address['area'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('City: ${widget.address['city'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Ward: ${widget.address['ward'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown selection
            const Text(
              'Select Issue Category *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedIssue,
              hint: const Text('Choose what describes the issue best'),
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

            // Description field (only for "Others")
            if (_selectedIssue == 'Others') ...[
              const Text(
                'Describe the Issue Details *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otherDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Specify what is wrong',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.edit_note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
            ],

            // Photo attachment
            const Text(
              'Attach Proof Photo (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
            ),
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
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
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
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
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
                    Image.file(_selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      color: Colors.grey.shade100,
                      width: double.infinity,
                      child: Text(
                        'Loaded via $_selectedImageSource',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
