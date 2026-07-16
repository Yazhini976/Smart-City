import 'package:flutter/material.dart';

class WaterWorkingProcess extends StatelessWidget {
  const WaterWorkingProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Utility Supply Telemetry',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        // Stat Cards Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Tank A Level',
                value: '72% Full',
                status: 'Optimal',
                color: Colors.blue,
                icon: Icons.water,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Water Pressure',
                value: '3.2 Bar',
                status: 'Excellent',
                color: Colors.blue,
                icon: Icons.speed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Avg Flow Rate',
                value: '720 KL/d',
                status: 'Stable',
                color: Colors.blue,
                icon: Icons.waves,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Purity Index',
                value: 'pH 7.2',
                status: 'Highly Pure',
                color: Colors.green,
                icon: Icons.health_and_safety,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tank details card
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
                  Icon(Icons.house_siding, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text(
                    'District Distribution Tanks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildTankRow('District Reservoir North', '84% Full', Colors.blue),
              const SizedBox(height: 10),
              _buildTankRow('Elevated Storage Reservoir South', '58% Full', Colors.blue),
              const SizedBox(height: 10),
              _buildTankRow('Central Distribution Center', '92% Full', Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
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

  Widget _buildTankRow(String name, String level, Color color) {
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
