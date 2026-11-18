import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../members/models/member_model.dart';
import '../../members/repositories/member_repository.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _amountController = TextEditingController(text: '2000');
  final _paidController = TextEditingController(text: '2000');
  MemberModel? _selectedMember;
  PaymentMethod _paymentMethod = PaymentMethod.upi;

  void _generatePdfInvoice() async {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member first.')),
      );
      return;
    }

    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final total = double.tryParse(_amountController.text) ?? 0.0;
    final paid = double.tryParse(_paidController.text) ?? 0.0;
    final due = total - paid > 0 ? total - paid : 0.0;

    final primaryColor = PdfColor.fromHex('#FF5722');
    final greyColor = PdfColor.fromHex('#616161');

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GYMMANAGER FITNESS STUDIO',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.Text('Official Membership Invoice / Receipt'),
                      ],
                    ),
                    pw.Text(
                      'ORIGINAL',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: greyColor),
                    ),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Billed To: ${_selectedMember!.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Member ID: ${_selectedMember!.memberCode}'),
                        pw.Text('Phone: ${_selectedMember!.phone}'),
                        pw.Text('Batch: ${_selectedMember!.batchName}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Invoice #: $invoiceNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${Formatters.formatDate(DateTime.now())}'),
                        pw.Text('Mode: ${_paymentMethod.name.toUpperCase()}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Table.fromTextArray(
                  headers: ['Description', 'Validity Period', 'Amount (INR)'],
                  data: [
                    [
                      _selectedMember!.planName,
                      '${Formatters.formatDate(_selectedMember!.startDate)} to ${Formatters.formatDate(_selectedMember!.endDate)}',
                      Formatters.formatCurrency(total),
                    ],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: primaryColor),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Total Amount: ${Formatters.formatCurrency(total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Amount Paid: ${Formatters.formatCurrency(paid)}', style: pw.TextStyle(color: PdfColors.green, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Pending Due: ${Formatters.formatCurrency(due)}', style: pw.TextStyle(color: PdfColors.red, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Thank you for training with GymManager! Maintain consistent workouts for best results.',
                    style: pw.TextStyle(color: greyColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Invoice_${_selectedMember!.memberCode}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Member Invoice')),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members available to bill.'));
          }

          _selectedMember ??= members.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<MemberModel>(
                value: _selectedMember,
                decoration: const InputDecoration(labelText: 'Select Member'),
                items: members.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text('${m.name} (${m.memberCode})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMember = val;
                      _amountController.text = val.totalAmount.toStringAsFixed(0);
                      _paidController.text = val.paidAmount.toStringAsFixed(0);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Invoice Total Amount (₹)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Paid Amount (₹)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (m) => setState(() => _paymentMethod = m ?? _paymentMethod),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _generatePdfInvoice,
                icon: const Icon(Icons.print),
                label: const Text('Preview & Print / Share PDF Invoice'),
              ),
            ],
          );
        },
      ),
    );
  }
}
