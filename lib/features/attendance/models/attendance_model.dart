import '../../core/constants/app_constants.dart';

class AttendanceModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberCode;
  final DateTime timestamp;
  final AttendanceMethod method;
  final String type; // 'IN' or 'OUT'

  AttendanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberCode,
    required this.timestamp,
    this.method = AttendanceMethod.manual,
    this.type = 'IN',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'memberCode': memberCode,
      'timestamp': timestamp.toIso8601String(),
      'method': method.name,
      'type': type,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AttendanceModel(
      id: docId ?? map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      memberCode: map['memberCode'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      method: AttendanceMethod.values.firstWhere(
        (m) => m.name == map['method'],
        orElse: () => AttendanceMethod.manual,
      ),
      type: map['type'] ?? 'IN',
    );
  }
}
