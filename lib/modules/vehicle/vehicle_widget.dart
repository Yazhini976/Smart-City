import 'package:flutter/material.dart';

class VehicleWorkingProcess extends StatelessWidget {
  const VehicleWorkingProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fleet Live Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 12),
        // Stat Cards Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Buses Active',
                value: '24 / 25',
                status: '96% online',
                color: Colors.cyan,
                icon: Icons.directions_bus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Ambulances Active',
                value: '12 / 12',
                status: 'All Online',
                color: Colors.green,
                icon: Icons.emergency,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Utility Fleet',
                value: '12 / 13',
                status: '1 in maintenance',
                color: Colors.cyan,
                icon: Icons.local_shipping,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Avg Speed',
                value: '28 km/h',
                status: 'Optimal Flow',
                color: Colors.green,
                icon: Icons.speed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Active Route Status Card
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
                  Icon(Icons.traffic, color: Color(0xFF00838F)),
                  SizedBox(width: 8),
                  Text(
                    'High Frequency Bus Routes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildRouteRow('Route 10A (Central - Airport)', 'On Schedule', Colors.green),
              const SizedBox(height: 10),
              _buildRouteRow('Route 5D (North Mall - Tech Park)', '2 min Delay', Colors.orange),
              const SizedBox(height: 10),
              _buildRouteRow('Route 23C (Circular Terminal)', 'On Schedule', Colors.green),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRouteRow(String name, String status, Color color) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
