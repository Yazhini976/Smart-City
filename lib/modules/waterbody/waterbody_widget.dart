import 'package:flutter/material.dart';

class WaterbodyWorkingProcess extends StatelessWidget {
  const WaterbodyWorkingProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reservoir & Lake Level Telemetry',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        // Stat Cards Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Lake Chembarambakkam',
                value: '82% Full',
                status: 'Stable inflow',
                color: Colors.blue.shade700,
                icon: Icons.water_damage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Red Hills Lake',
                value: '75% Full',
                status: 'Discharge Open',
                color: Colors.blue.shade700,
                icon: Icons.waves,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Cholavaram Lake',
                value: '64% Full',
                status: 'Stable',
                color: Colors.blue.shade700,
                icon: Icons.water,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Flood Warnings',
                value: 'Green',
                status: '0 active threats',
                color: Colors.green,
                icon: Icons.shield,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Active Reservoir Details Card
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
                  Icon(Icons.query_stats, color: Color(0xFF0277BD)),
                  SizedBox(width: 8),
                  Text(
                    'Water Level Diagnostics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildLakeRow('Lake Chembarambakkam', '8.2m / 10m', 'Normal', Colors.green),
              const SizedBox(height: 10),
              _buildLakeRow('Red Hills Lake', '7.5m / 9.5m', 'Normal', Colors.green),
              const SizedBox(height: 10),
              _buildLakeRow('Cholavaram Reservoir', '4.2m / 6.0m', 'Low Inflow', Colors.blue),
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
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLakeRow(String name, String level, String code, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Text(level, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
