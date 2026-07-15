// Placeholder file
import 'package:flutter/material.dart';
import '../models/complaint.dart';

class TodoListScreen extends StatelessWidget {
  final List<WorkOrder> orders;
  final VoidCallback onRefresh;

  const TodoListScreen({
    super.key,
    required this.orders,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final todoOrders = orders.where((o) =>
    o.status == 'todo' || o.status == 'in_progress'
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: todoOrders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'All caught up! No pending tasks.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: todoOrders.length,
        itemBuilder: (context, index) {
          final order = todoOrders[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('📋', style: TextStyle(fontSize: 20)),
                ),
              ),
              title: Text(
                order.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Priority: ${order.priority.toUpperCase()}',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Chip(
                label: Text(
                  order.status.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.orange.withOpacity(0.2),
              ),
              onTap: () {
                // Show order details
                _showOrderDetails(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(order.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${order.description}'),
            const SizedBox(height: 8),
            Text('Priority: ${order.priority.toUpperCase()}'),
            Text('Status: ${order.status.toUpperCase().replaceAll('_', ' ')}'),
            Text('Assigned: ${order.assignedAt.day}/${order.assignedAt.month}/${order.assignedAt.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}