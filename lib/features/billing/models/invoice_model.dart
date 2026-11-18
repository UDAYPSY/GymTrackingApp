import 'package:gym_manager/core/constants/app_constants.dart';

class InvoiceModel {
  final String id;
  final String memberId;
  final String memberName;
  final String invoiceNumber;
  final String planName;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final PaymentStatus status;

  InvoiceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.invoiceNumber,
    required this.planName,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.paymentMethod = PaymentMethod.cash,
    required this.date,
    this.status = PaymentStatus.paid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'invoiceNumber': invoiceNumber,
      'planName': planName,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paymentMethod': paymentMethod.name,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return InvoiceModel(
      id: docId ?? map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      planName: map['planName'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.paid,
      ),
    );
  }
}
