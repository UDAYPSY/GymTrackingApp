import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final MemberModel member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  late MemberModel _currentMember;

  @override
  void initState() {
    super.initState();
    _currentMember = widget.member;
  }

  void _showFreezeDialog() {
    int selectedDays = 15;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Freeze Membership'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Freezing pauses the membership and extends the expiry date by the selected number of days.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDays,
                decoration: const InputDecoration(labelText: 'Pause Duration'),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 Days (1 Week)')),
                  DropdownMenuItem(value: 15, child: Text('15 Days (2 Weeks)')),
                  DropdownMenuItem(value: 30, child: Text('30 Days (1 Month)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedDays = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref
                    .read(memberRepositoryProvider)
                    .freezeMembership(_currentMember.id, selectedDays);
                setState(() {
                  _currentMember = _currentMember.copyWith(
                    isFrozen: true,
                    status: MemberStatus.frozen,
                    endDate: _currentMember.endDate.add(Duration(days: selectedDays)),
                  );
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membership paused for $selectedDays days!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              child: const Text('Confirm Freeze'),
            ),
          ],
        ),
      ),
    );
  }

  void _unfreezeMembership() async {
    await ref.read(memberRepositoryProvider).unfreezeMembership(_currentMember.id);
    setState(() {
      _currentMember = _currentMember.copyWith(
        isFrozen: false,
        status: MemberStatus.active,
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membership reactivated!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _showCollectPaymentDialog() {
    final payController = TextEditingController(text: _currentMember.dueAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Collect Pending Dues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Due: ${Formatters.formatCurrency(_currentMember.dueAmount)}'),
            const SizedBox(height: 12),
            TextField(
              controller: payController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Paying Now (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final paying = double.tryParse(payController.text) ?? 0.0;
              final newPaid = _currentMember.paidAmount + paying;
              final newDue = _currentMember.totalAmount - newPaid;

              final updated = _currentMember.copyWith(
                paidAmount: newPaid,
                dueAmount: newDue > 0 ? newDue : 0.0,
              );

              await ref.read(memberRepositoryProvider).updateMember(updated);
              setState(() => _currentMember = updated);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment of ₹$paying collected!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentMember.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Details',
            onPressed: () {
              Formatters.openWhatsApp(
                phone: _currentMember.phone,
                message:
                    'GymBook Member Card:\nName: ${_currentMember.name}\nCode: ${_currentMember.memberCode}\nPlan: ${_currentMember.planName}\nValid Till: ${Formatters.formatDate(_currentMember.endDate)}',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card with Digital ID Badge
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primary.withAlpha(40),
                        child: Text(
                          _currentMember.name.isNotEmpty
                              ? _currentMember.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentMember.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${_currentMember.memberCode} • ${_currentMember.gender}',
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentMember.phone,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      // QR Code for desk attendance check-in
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: _currentMember.memberCode,
                          version: QrVersions.auto,
                          size: 70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Formatters.makePhoneCall(_currentMember.phone),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Formatters.openWhatsApp(
                              phone: _currentMember.phone,
                              message: 'Hi ${_currentMember.name}, greeting from GymManager!',
                            );
                          },
                          icon: const Icon(Icons.chat, size: 18, color: AppTheme.success),
                          label: const Text('WhatsApp'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Plan & Validity Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Membership Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Plan Name', _currentMember.planName),
                  _buildDetailRow('Batch', _currentMember.batchName),
                  _buildDetailRow('Start Date', Formatters.formatDate(_currentMember.startDate)),
                  _buildDetailRow('End Date', Formatters.formatDate(_currentMember.endDate)),
                  _buildDetailRow(
                    'Status',
                    _currentMember.isFrozen
                        ? 'Frozen'
                        : (_currentMember.hasExpired ? 'Expired' : 'Active'),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Plan Fee', style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            Formatters.formatCurrency(_currentMember.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Paid', style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            Formatters.formatCurrency(_currentMember.paidAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Due', style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            Formatters.formatCurrency(_currentMember.dueAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _currentMember.dueAmount > 0 ? AppTheme.error : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Actions
          if (_currentMember.dueAmount > 0)
            ElevatedButton.icon(
              onPressed: _showCollectPaymentDialog,
              icon: const Icon(Icons.payment),
              label: Text('Collect Dues (${Formatters.formatCurrency(_currentMember.dueAmount)})'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            ),
          const SizedBox(height: 10),

          if (_currentMember.isFrozen)
            ElevatedButton.icon(
              onPressed: _unfreezeMembership,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Unfreeze / Reactivate Membership'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            )
          else
            OutlinedButton.icon(
              onPressed: _showFreezeDialog,
              icon: const Icon(Icons.pause_circle_outline),
              label: const Text('Freeze / Pause Membership'),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
