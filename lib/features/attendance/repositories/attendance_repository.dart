import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../models/attendance_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final todayAttendanceStreamProvider = StreamProvider<List<AttendanceModel>>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.watchTodayAttendance();
});

class AttendanceRepository {
  final CollectionReference _attendanceCollection =
      FirebaseFirestore.instance.collection(AppConstants.attendanceCollection);

  final List<AttendanceModel> _mockAttendance = [
    AttendanceModel(
      id: 'att1',
      memberId: 'm1',
      memberName: 'Rahul Sharma',
      memberCode: 'GB-101',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      method: AttendanceMethod.qrScan,
    ),
    AttendanceModel(
      id: 'att2',
      memberId: 'm2',
      memberName: 'Priya Patel',
      memberCode: 'GB-102',
      timestamp: DateTime.now().subtract(const Duration(minutes: 90)),
      method: AttendanceMethod.manual,
    ),
  ];

  final StreamController<List<AttendanceModel>> _mockStreamController =
      StreamController<List<AttendanceModel>>.broadcast();

  AttendanceRepository() {
    _mockStreamController.add(_mockAttendance);
  }

  Stream<List<AttendanceModel>> watchTodayAttendance() {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      return _attendanceCollection
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _mockAttendance;
        }
        return snapshot.docs.map((doc) {
          return AttendanceModel.fromMap(
            doc.data() as Map<String, dynamic>,
            docId: doc.id,
          );
        }).toList();
      }).handleError((_) {
        return _mockAttendance;
      });
    } catch (_) {
      return _mockStreamController.stream;
    }
  }

  Future<void> markAttendance({
    required String memberId,
    required String memberName,
    required String memberCode,
    AttendanceMethod method = AttendanceMethod.manual,
  }) async {
    final entry = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: memberId,
      memberName: memberName,
      memberCode: memberCode,
      timestamp: DateTime.now(),
      method: method,
    );

    try {
      await _attendanceCollection.doc(entry.id).set(entry.toMap());
    } catch (_) {
      _mockAttendance.insert(0, entry);
      _mockStreamController.add(List.from(_mockAttendance));
    }
  }
}
