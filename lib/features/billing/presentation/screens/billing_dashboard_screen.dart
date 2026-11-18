import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/core/theme/app_theme.dart';
import 'package:gym_manager/core/utils/formatters.dart';
import 'package:gym_manager/features/members/repositories/member_repository.dart';
import 'package:gym_manager/features/billing/models/invoice_model.dart';
import 'package:gym_manager/features/billing/presentation/screens/create_invoice_screen.dart';

class BillingDashboardScreen extends ConsumerWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee & Billing Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Create Invoice',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Invoice', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
          );
        },
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (members) {
          final totalCollected = members.fold<double>(
            0.0,
            (sum, m) => sum + m.paidAmount,
          );
          final totalDue = members.fold<double>(
            0.0,
            (sum, m) => sum + m.dueAmount,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Financial Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppTheme.surfaceLight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Collected', style: TextStyle(color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.formatCurrency(totalCollected),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.success,
                              ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Outstanding Dues', style: TextStyle(color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.formatCurrency(totalDue),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Members with Pending Dues',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final dueMembers = members.where((m) => m.dueAmount > 0).toList();
                      for (var m in dueMembers) {
                        Formatters.openWhatsApp(
                          phone: m.phone,
                          message:
                              'Dear ${m.name}, reminder from GymManager: Pending fee balance is ₹${m.dueAmount}. Kindly clear your dues.',
                        );
                      }
                    },
                    icon: const Icon(Icons.send, size: 16, color: AppTheme.secondary),
                    label: const Text('Remind All Dues', style: TextStyle(color: AppTheme.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...members.where((m) => m.dueAmount > 0).map((m) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.error.withAlpha(40),
                      child: const Icon(Icons.money_off, color: AppTheme.error),
                    ),
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Due: ${Formatters.formatCurrency(m.dueAmount)} • ${m.planName}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.chat, color: AppTheme.success),
                      tooltip: 'Send WhatsApp Payment Link',
                      onPressed: () {
                        Formatters.openWhatsApp(
                          phone: m.phone,
                          message:
                              'Hi ${m.name}, your membership payment has a pending balance of ${Formatters.formatCurrency(m.dueAmount)}. Please pay via UPI or at the gym desk.',
                        );
                      },
                    ),
                  ),
                );
              }),

              if (members.where((m) => m.dueAmount > 0).isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'All dues cleared! Great job!',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
