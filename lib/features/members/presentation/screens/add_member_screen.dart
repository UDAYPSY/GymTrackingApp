import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _totalAmountController = TextEditingController(text: '2000');
  final _paidAmountController = TextEditingController(text: '2000');
  final _notesController = TextEditingController();

  String _gender = 'Male';
  String _selectedPlan = '1 Month Standard';
  int _planDurationMonths = 1;
  String _selectedBatch = 'Morning (6:00 AM - 7:00 AM)';
  DateTime _startDate = DateTime.now();

  final List<String> _batches = [
    'Morning (6:00 AM - 7:00 AM)',
    'Morning (7:00 AM - 8:00 AM)',
    'Morning (8:00 AM - 9:00 AM)',
    'Evening (5:00 PM - 6:00 PM)',
    'Evening (6:00 PM - 7:00 PM)',
    'Evening (7:00 PM - 8:00 PM)',
    'General / Open All Day',
  ];

  final Map<String, Map<String, dynamic>> _plans = {
    '1 Month Standard': {'months': 1, 'price': 2000.0},
    '3 Months Silver': {'months': 3, 'price': 5000.0},
    '6 Months Gold': {'months': 6, 'price': 9000.0},
    '12 Months Platinum VIP': {'months': 12, 'price': 16000.0},
  };

  DateTime get _endDate => DateTime(
        _startDate.year,
        _startDate.month + _planDurationMonths,
        _startDate.day,
      );

  double get _dueAmount {
    final total = double.tryParse(_totalAmountController.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text) ?? 0.0;
    final due = total - paid;
    return due > 0 ? due : 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPlanChanged(String? newPlan) {
    if (newPlan != null && _plans.containsKey(newPlan)) {
      setState(() {
        _selectedPlan = newPlan;
        _planDurationMonths = _plans[newPlan]!['months'] as int;
        final defaultPrice = _plans[newPlan]!['price'] as double;
        _totalAmountController.text = defaultPrice.toStringAsFixed(0);
        _paidAmountController.text = defaultPrice.toStringAsFixed(0);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final total = double.tryParse(_totalAmountController.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text) ?? 0.0;
    final due = total - paid;

    final newMember = MemberModel(
      id: const Uuid().v4(),
      memberCode: 'GB-${100 + DateTime.now().millisecond}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gender: _gender,
      startDate: _startDate,
      endDate: _endDate,
      planName: _selectedPlan,
      batchName: _selectedBatch,
      totalAmount: total,
      paidAmount: paid,
      dueAmount: due > 0 ? due : 0.0,
      notes: _notesController.text.trim(),
      status: MemberStatus.active,
    );

    await ref.read(memberRepositoryProvider).addMember(newMember);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member "${newMember.name}" enrolled successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll New Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter member name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (WhatsApp) *',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (v) => v == null || v.trim().length < 10
                  ? 'Please enter valid 10-digit phone number'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Selector
            Row(
              children: [
                const Text('Gender: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Male'),
                  selected: _gender == 'Male',
                  onSelected: (val) => setState(() => _gender = 'Male'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Female'),
                  selected: _gender == 'Female',
                  onSelected: (val) => setState(() => _gender = 'Female'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Other'),
                  selected: _gender == 'Other',
                  onSelected: (val) => setState(() => _gender = 'Other'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Membership Plan & Batch
            const Text(
              'Membership & Batch Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              decoration: const InputDecoration(
                labelText: 'Select Membership Plan',
                prefixIcon: Icon(Icons.card_membership),
              ),
              items: _plans.keys.map((plan) {
                return DropdownMenuItem(value: plan, child: Text(plan));
              }).toList(),
              onChanged: _onPlanChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedBatch,
              decoration: const InputDecoration(
                labelText: 'Select Daily Batch',
                prefixIcon: Icon(Icons.schedule),
              ),
              items: _batches.map((b) {
                return DropdownMenuItem(value: b, child: Text(b));
              }).toList(),
              onChanged: (b) => setState(() => _selectedBatch = b ?? _selectedBatch),
            ),
            const SizedBox(height: 14),

            // Start & End Date row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text(Formatters.formatDate(_startDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: AppTheme.textSecondary),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Valid Until', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text(
                        Formatters.formatDate(_endDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Billing & Payment Collection
            const Text(
              'Fee Collection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Fee (₹)'),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Paid Today (₹)'),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _dueAmount > 0 ? AppTheme.error.withAlpha(30) : AppTheme.success.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pending Due Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    Formatters.formatCurrency(_dueAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _dueAmount > 0 ? AppTheme.error : AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (e.g. medical conditions, goals)',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Complete Enrollment'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
