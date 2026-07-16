import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/complaint.dart';
import 'login_screen.dart';
import 'work_orders_screen.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> with SingleTickerProviderStateMixin {
  List<WorkOrder> _allOrders = [];
  bool _isLoading = true;
  late TabController _tabController;

  int get _todoCount => _allOrders.where((o) => o.status == 'todo' || o.status == 'in_progress').length;
  int get _completedCount => _allOrders.where((o) => o.status == 'completed').length;
  int get _rejectedCount => _allOrders.where((o) => o.status == 'rejected').length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      _allOrders = await ApiService.getOfficerWorkOrders();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
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
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Officer Work Space', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              auth.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.badge, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Session',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          Text(
                            auth.phoneNumber,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Count row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCountBlock('To Do', _todoCount.toString(), Colors.orange),
                      _buildCountBlock('Completed', _completedCount.toString(), Colors.green),
                      _buildCountBlock('Rejected', _rejectedCount.toString(), Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // TabBar
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1E3A8A),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1E3A8A),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
                Tab(text: 'Rejected'),
              ],
            ),
            // TabBarViews
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        WorkOrdersScreen(
                          orders: _allOrders.where((o) => o.status == 'todo' || o.status == 'in_progress').toList(),
                          onRefresh: _loadOrders,
                        ),
                        WorkOrdersScreen(
                          orders: _allOrders.where((o) => o.status == 'completed').toList(),
                          onRefresh: _loadOrders,
                        ),
                        WorkOrdersScreen(
                          orders: _allOrders.where((o) => o.status == 'rejected').toList(),
                          onRefresh: _loadOrders,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBlock(String label, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
