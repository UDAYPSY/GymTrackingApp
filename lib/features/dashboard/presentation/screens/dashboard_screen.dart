import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../attendance/presentation/screens/attendance_screen.dart';
import '../../attendance/presentation/screens/qr_scanner_screen.dart';
import '../../attendance/repositories/attendance_repository.dart';
import '../../billing/presentation/screens/billing_dashboard_screen.dart';
import '../../billing/presentation/screens/create_invoice_screen.dart';
import '../../members/presentation/screens/add_member_screen.dart';
import '../../members/presentation/screens/members_list_screen.dart';
import '../../members/repositories/member_repository.dart';
import '../../workouts/presentation/screens/workout_planner_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardOverviewTab(),
    MembersListScreen(),
    AttendanceScreen(),
    BillingDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppTheme.primary),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg, color: AppTheme.primary),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppTheme.primary),
            label: 'Billing',
          ),
        ],
      ),
    );
  }
}

class _DashboardOverviewTab extends ConsumerWidget {
  const _DashboardOverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersStreamProvider);
    final attendanceAsync = ref.watch(todayAttendanceStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('GymManager Studio'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            tooltip: 'Workout Master',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutPlannerScreen()),
              );
            },
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (members) {
          final activeCount = members.where((m) => m.status == MemberStatus.active).length;
          final expiringCount = members.where((m) => m.isExpiringSoon).length;
          final totalCollected = members.fold<double>(0.0, (sum, m) => sum + m.paidAmount);
          final totalDue = members.fold<double>(0.0, (sum, m) => sum + m.dueAmount);
          final todayAttendanceCount = attendanceAsync.value?.length ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Expiring Alert Banner if any
              if (expiringCount > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withAlpha(30),
                    border: Border.all(color: AppTheme.warning),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, color: AppTheme.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$expiringCount memberships expiring in the next 1-3 days!',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to members screen with filter
                        },
                        child: const Text('View', style: TextStyle(color: AppTheme.warning)),
                      ),
                    ],
                  ),
                ),

              // KPI Grid Cards
              Row(
                children: [
                  _buildMetricCard(
                    title: 'Active Members',
                    value: '$activeCount',
                    icon: Icons.people,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    title: "Today's Punches",
                    value: '$todayAttendanceCount',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricCard(
                    title: 'Total Collected',
                    value: Formatters.formatCurrency(totalCollected),
                    icon: Icons.currency_rupee,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    title: 'Pending Dues',
                    value: Formatters.formatCurrency(totalDue),
                    icon: Icons.pending_actions,
                    color: AppTheme.error,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    context,
                    label: 'Add Member',
                    icon: Icons.person_add,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddMemberScreen()),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    label: 'Scan QR',
                    icon: Icons.qr_code_scanner,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    label: 'Invoice',
                    icon: Icons.receipt,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    label: 'Workouts',
                    icon: Icons.fitness_center,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WorkoutPlannerScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Members Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Enrolled Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: AppTheme.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...members.take(3).map((m) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withAlpha(40),
                      child: Text(m.name[0], style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${m.memberCode} • ${m.planName}'),
                    trailing: Text(
                      Formatters.formatCurrency(m.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: AppTheme.surfaceLight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withAlpha(50)),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
