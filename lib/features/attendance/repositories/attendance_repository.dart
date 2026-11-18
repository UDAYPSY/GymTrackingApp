import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/features/attendance/models/attendance_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final todayAttendanceStreamProvider = StreamProvider<List<AttendanceModel>>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.watchTodayAttendance();
});

class AttendanceRepository {
  CollectionReference? get _attendanceCollection {
    try {
      return FirebaseFirestore.instance.collection(AppConstants.attendanceCollection);
    } catch (_) {
      return null;
    }
  }

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

  Stream<List<AttendanceModel>> watchTodayAttendance() async* {
    yield List.from(_mockAttendance);
    try {
      final collection = _attendanceCollection;
      if (collection != null) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        yield* collection
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
        }).handleError((_) => _mockAttendance);
        return;
      }
    } catch (_) {}
    yield* _mockStreamController.stream;
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
      final collection = _attendanceCollection;
      if (collection != null) {
        await collection.doc(entry.id).set(entry.toMap());
        return;
      }
    } catch (_) {}
    _mockAttendance.insert(0, entry);
    _mockStreamController.add(List.from(_mockAttendance));
  }
}
