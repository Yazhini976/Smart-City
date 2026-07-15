import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_city/screens/login_screen.dart' as container_login;
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/complaint.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard>
    with SingleTickerProviderStateMixin {
  List<WorkOrder> _allOrders = [];
  bool _isLoading = true;
  late TabController _tabController;

  // Counts
  int get _workOrderCount =>
      _allOrders.where((o) => o.status == 'todo').length;
  int get _todoCount =>
      _allOrders.where((o) => o.status == 'todo' || o.status == 'in_progress').length;
  int get _completedCount =>
      _allOrders.where((o) => o.status == 'completed').length;
  int get _rejectedCount =>
      _allOrders.where((o) => o.status == 'rejected').length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Premium Header ──
            _buildHeader(auth),

            // ── Summary Stat Cards ──
            _buildStatCards(),

            // ── Tab Bar ──
            _buildTabBar(),

            // ── Tab Content ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildWorkOrdersTab(),
                        _buildTodoTab(),
                        _buildCompletedTab(),
                        _buildRejectedTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  HEADER
  // ═════════════════════════════════════════════
  Widget _buildHeader(AuthService auth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Top row – title + logout
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.engineering, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Field Officer Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
                onPressed: _loadOrders,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const container_login.LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Officer info row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Officer!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Phone: ${auth.phoneNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                      SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  SUMMARY STAT CARDS
  // ═════════════════════════════════════════════
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          _buildStatTile(
            icon: Icons.assignment,
            label: 'Work Orders',
            count: _workOrderCount,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFDBEAFE),
          ),
          const SizedBox(width: 10),
          _buildStatTile(
            icon: Icons.pending_actions,
            label: 'To Do',
            count: _todoCount,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFEF3C7),
          ),
          const SizedBox(width: 10),
          _buildStatTile(
            icon: Icons.check_circle,
            label: 'Done',
            count: _completedCount,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFD1FAE5),
          ),
          const SizedBox(width: 10),
          _buildStatTile(
            icon: Icons.cancel,
            label: 'Rejected',
            count: _rejectedCount,
            color: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEE2E2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  TAB BAR
  // ═════════════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1E3A8A),
        unselectedLabelColor: Colors.grey.shade500,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        indicator: BoxDecoration(
          color: const Color(0xFF1E3A8A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            icon: const Icon(Icons.assignment, size: 18),
            text: 'Work Orders',
          ),
          Tab(
            icon: const Icon(Icons.pending_actions, size: 18),
            text: 'To Do',
          ),
          Tab(
            icon: const Icon(Icons.check_circle, size: 18),
            text: 'Completed',
          ),
          Tab(
            icon: const Icon(Icons.cancel, size: 18),
            text: 'Rejected',
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  TAB CONTENTS
  // ═════════════════════════════════════════════

  /// Work Orders Tab – shows all pending (new/todo) orders that can be accepted or rejected
  Widget _buildWorkOrdersTab() {
    final pending = _allOrders.where((o) => o.status == 'todo').toList();
    if (pending.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_turned_in,
        title: 'No Pending Work Orders',
        subtitle: 'All work orders have been processed.',
        color: const Color(0xFF3B82F6),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFF3B82F6),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        itemBuilder: (context, index) =>
            _buildWorkOrderCard(pending[index], showActions: true),
      ),
    );
  }

  /// Todo Tab – shows accepted/in-progress orders
  Widget _buildTodoTab() {
    final todo = _allOrders
        .where((o) => o.status == 'todo' || o.status == 'in_progress')
        .toList();
    if (todo.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: 'All Caught Up!',
        subtitle: 'No pending tasks in your to-do list.',
        color: const Color(0xFF10B981),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFFF59E0B),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todo.length,
        itemBuilder: (context, index) =>
            _buildWorkOrderCard(todo[index], showActions: true),
      ),
    );
  }

  /// Completed Tab
  Widget _buildCompletedTab() {
    final completed =
        _allOrders.where((o) => o.status == 'completed').toList();
    if (completed.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_late,
        title: 'No Completed Orders',
        subtitle: 'Completed work orders will appear here.',
        color: const Color(0xFF10B981),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFF10B981),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: completed.length,
        itemBuilder: (context, index) =>
            _buildWorkOrderCard(completed[index], showActions: false),
      ),
    );
  }

  /// Rejected Tab
  Widget _buildRejectedTab() {
    final rejected =
        _allOrders.where((o) => o.status == 'rejected').toList();
    if (rejected.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No Rejected Orders',
        subtitle: 'Rejected work orders will appear here.',
        color: const Color(0xFFEF4444),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFFEF4444),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rejected.length,
        itemBuilder: (context, index) =>
            _buildWorkOrderCard(rejected[index], showActions: false),
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  WORK ORDER CARD
  // ═════════════════════════════════════════════
  Widget _buildWorkOrderCard(WorkOrder order, {required bool showActions}) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (order.status) {
      case 'todo':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule;
        statusLabel = 'PENDING';
        break;
      case 'in_progress':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.autorenew;
        statusLabel = 'IN PROGRESS';
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusLabel = 'COMPLETED';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusLabel = 'REJECTED';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusLabel = order.status.toUpperCase();
    }

    // Priority color
    Color priorityColor;
    switch (order.priority.toLowerCase()) {
      case 'high':
        priorityColor = const Color(0xFFEF4444);
        break;
      case 'medium':
        priorityColor = const Color(0xFFF59E0B);
        break;
      case 'low':
        priorityColor = const Color(0xFF10B981);
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row – icon + title + status badge
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.description,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Metadata row
                Row(
                  children: [
                    _buildMetaChip(
                      icon: Icons.flag,
                      label: order.priority.toUpperCase(),
                      color: priorityColor,
                    ),
                    const SizedBox(width: 10),
                    _buildMetaChip(
                      icon: Icons.calendar_today,
                      label:
                          '${order.assignedAt.day}/${order.assignedAt.month}/${order.assignedAt.year}',
                      color: Colors.grey.shade600,
                    ),
                    if (order.completedAt != null) ...[
                      const SizedBox(width: 10),
                      _buildMetaChip(
                        icon: Icons.done_all,
                        label:
                            '${order.completedAt!.day}/${order.completedAt!.month}',
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ],
                ),

                // Rejection reason
                if (order.rejectionReason != null &&
                    order.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reason: ${order.rejectionReason}',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          if (showActions &&
              (order.status == 'todo' || order.status == 'in_progress')) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Accept / In Progress button
                  if (order.status == 'todo')
                    Expanded(
                      child: _buildActionButton(
                        label: 'Accept',
                        icon: Icons.check,
                        color: const Color(0xFF3B82F6),
                        onTap: () =>
                            _updateWorkOrder(order, 'in_progress'),
                      ),
                    ),
                  if (order.status == 'todo') const SizedBox(width: 10),

                  // Complete button
                  Expanded(
                    child: _buildActionButton(
                      label: 'Complete',
                      icon: Icons.done_all,
                      color: const Color(0xFF10B981),
                      onTap: () => _updateWorkOrder(order, 'completed'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Reject button
                  Expanded(
                    child: _buildActionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      color: const Color(0xFFEF4444),
                      onTap: () => _showRejectDialog(order),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  EMPTY STATE
  // ═════════════════════════════════════════════
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  ACTIONS
  // ═════════════════════════════════════════════
  Future<void> _updateWorkOrder(WorkOrder order, String status) async {
    try {
      await ApiService.updateWorkOrder(order.workOrderId, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  status == 'completed'
                      ? Icons.check_circle
                      : status == 'in_progress'
                          ? Icons.autorenew
                          : Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Work order ${status.toUpperCase().replaceAll('_', ' ')}!'),
              ],
            ),
            backgroundColor: status == 'completed'
                ? const Color(0xFF10B981)
                : status == 'in_progress'
                    ? const Color(0xFF3B82F6)
                    : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _loadOrders();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRejectDialog(WorkOrder order) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reject Work Order',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejecting: ${order.title}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Please provide a reason for rejection:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter the reason here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a rejection reason'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              try {
                await ApiService.updateWorkOrder(
                  order.workOrderId,
                  'rejected',
                  reason: reasonController.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Work order REJECTED'),
                        ],
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  _loadOrders();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}