import 'package:flutter/material.dart';

class UgssWorkingProcess extends StatelessWidget {
  const UgssWorkingProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UGSS Real-Time Telemetry',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        // Stat Cards Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Avg Flow Rate',
                value: '1.4 m/s',
                status: 'Normal',
                color: Colors.green,
                icon: Icons.speed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'System Pressure',
                value: '2.8 Bar',
                status: 'Stable',
                color: Colors.green,
                icon: Icons.compress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Overflow Risk',
                value: 'Low',
                status: '12% probability',
                color: Colors.blue,
                icon: Icons.warning_amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Active Blockages',
                value: '0',
                status: 'Cleared',
                color: Colors.green,
                icon: Icons.plumbing,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Pipeline Health Section
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
                  Icon(Icons.analytics, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text(
                    'Line Segment Diagnostics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildSegmentRow('Main Sewer Line A', '98% Capacity', Colors.green),
              const SizedBox(height: 10),
              _buildSegmentRow('Sub-drain Sector 4', '42% Capacity', Colors.blue),
              const SizedBox(height: 10),
              _buildSegmentRow('Pumping Station Trunk B', '75% Capacity', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSegmentRow(String name, String level, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            level,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
