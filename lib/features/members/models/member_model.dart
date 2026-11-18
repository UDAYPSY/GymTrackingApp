import '../../core/constants/app_constants.dart';

class MemberModel {
  final String id;
  final String gymId;
  final String memberCode;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final DateTime? dob;
  final String photoUrl;
  final MemberStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String planName;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String batchName;
  final String notes;
  final bool isFrozen;

  MemberModel({
    required this.id,
    this.gymId = 'default_gym',
    required this.memberCode,
    required this.name,
    required this.phone,
    this.email = '',
    this.gender = 'Male',
    this.dob,
    this.photoUrl = '',
    this.status = MemberStatus.active,
    required this.startDate,
    required this.endDate,
    required this.planName,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    this.batchName = 'General',
    this.notes = '',
    this.isFrozen = false,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(endDate.year, endDate.month, endDate.day);
    return expiry.difference(today).inDays;
  }

  bool get isExpiringSoon => daysRemaining >= 0 && daysRemaining <= 3;
  bool get hasExpired => daysRemaining < 0;

  MemberModel copyWith({
    String? id,
    String? gymId,
    String? memberCode,
    String? name,
    String? phone,
    String? email,
    String? gender,
    DateTime? dob,
    String? photoUrl,
    MemberStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? planName,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    String? batchName,
    String? notes,
    bool? isFrozen,
  }) {
    return MemberModel(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      memberCode: memberCode ?? this.memberCode,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      planName: planName ?? this.planName,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      batchName: batchName ?? this.batchName,
      notes: notes ?? this.notes,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gymId': gymId,
      'memberCode': memberCode,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'photoUrl': photoUrl,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'planName': planName,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'batchName': batchName,
      'notes': notes,
      'isFrozen': isFrozen,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MemberModel(
      id: docId ?? map['id'] ?? '',
      gymId: map['gymId'] ?? 'default_gym',
      memberCode: map['memberCode'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? 'Male',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      photoUrl: map['photoUrl'] ?? '',
      status: MemberStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MemberStatus.active,
      ),
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      planName: map['planName'] ?? 'Monthly',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0.0,
      batchName: map['batchName'] ?? 'General',
      notes: map['notes'] ?? '',
      isFrozen: map['isFrozen'] ?? false,
    );
  }
}
