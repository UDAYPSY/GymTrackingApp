import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../members/repositories/member_repository.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import 'qr_scanner_screen.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  void _showManualPunchDialog(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.read(membersStreamProvider);

    membersAsync.whenData((members) {
      if (members.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No members enrolled yet.')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Manual Attendance Punch'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (ctx, i) {
                final m = members[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withAlpha(40),
                    child: Text(m.name[0], style: const TextStyle(color: AppTheme.primary)),
                  ),
                  title: Text(m.name),
                  subtitle: Text('${m.memberCode} • ${m.batchName}'),
                  trailing: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(attendanceRepositoryProvider).markAttendance(
                          memberId: m.id,
                          memberName: m.name,
                          memberCode: m.memberCode,
                          method: AttendanceMethod.manual,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Attendance recorded for ${m.name}!'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(todayAttendanceStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Manual Punch', style: TextStyle(color: Colors.white)),
        onPressed: () => _showManualPunchDialog(context, ref),
      ),
      body: Column(
        children: [
          // Header Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: AppTheme.surfaceLight,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Today Check-Ins', style: TextStyle(color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          attendanceAsync.when(
                            data: (list) => Text(
                              '${list.length} Members',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                            ),
                            loading: () => const Text('...'),
                            error: (_, __) => const Text('0'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: AppTheme.surfaceLight,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code_scanner, color: AppTheme.primary, size: 28),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fast Punch', style: TextStyle(color: AppTheme.textSecondary)),
                                  Text('Scan QR', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Punches",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.formatDate(DateTime.now()),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Attendance Log
          Expanded(
            child: attendanceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No attendance records logged today yet.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: records.length,
                  itemBuilder: (ctx, i) {
                    final item = records[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withAlpha(40),
                          child: const Icon(Icons.person, color: AppTheme.primary),
                        ),
                        title: Text(item.memberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${item.memberCode} • ${Formatters.formatTime(item.timestamp)}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.method == AttendanceMethod.qrScan
                                ? AppTheme.secondary.withAlpha(30)
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.method == AttendanceMethod.qrScan ? 'QR SCAN' : 'MANUAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.method == AttendanceMethod.qrScan
                                  ? AppTheme.secondary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
