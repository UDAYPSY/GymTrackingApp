import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../models/member_model.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

final membersStreamProvider = StreamProvider<List<MemberModel>>((ref) {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.watchMembers();
});

class MemberRepository {
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection(AppConstants.membersCollection);

  // In-memory mock data for offline preview and automated CI testing
  final List<MemberModel> _mockMembers = [
    MemberModel(
      id: 'm1',
      memberCode: 'GB-101',
      name: 'Rahul Sharma',
      phone: '9876543210',
      email: 'rahul.s@example.com',
      gender: 'Male',
      status: MemberStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      planName: '3 Months Gold',
      totalAmount: 5000,
      paidAmount: 5000,
      dueAmount: 0,
      batchName: 'Morning (6:00 - 7:00 AM)',
    ),
    MemberModel(
      id: 'm2',
      memberCode: 'GB-102',
      name: 'Priya Patel',
      phone: '9823456789',
      email: 'priya.p@example.com',
      gender: 'Female',
      status: MemberStatus.expiringSoon,
      startDate: DateTime.now().subtract(const Duration(days: 28)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      planName: 'Monthly Standard',
      totalAmount: 1800,
      paidAmount: 1000,
      dueAmount: 800,
      batchName: 'Evening (5:00 - 6:00 PM)',
    ),
    MemberModel(
      id: 'm3',
      memberCode: 'GB-103',
      name: 'Amit Verma',
      phone: '9911223344',
      email: 'amit.v@example.com',
      gender: 'Male',
      status: MemberStatus.expired,
      startDate: DateTime.now().subtract(const Duration(days: 40)),
      endDate: DateTime.now().subtract(const Duration(days: 10)),
      planName: 'Monthly Standard',
      totalAmount: 1800,
      paidAmount: 1800,
      dueAmount: 0,
      batchName: 'Morning (7:00 - 8:00 AM)',
    ),
  ];

  final StreamController<List<MemberModel>> _mockStreamController =
      StreamController<List<MemberModel>>.broadcast();

  MemberRepository() {
    _mockStreamController.add(_mockMembers);
  }

  Stream<List<MemberModel>> watchMembers() {
    try {
      return _membersCollection.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _mockMembers;
        }
        return snapshot.docs.map((doc) {
          return MemberModel.fromMap(
            doc.data() as Map<String, dynamic>,
            docId: doc.id,
          );
        }).toList();
      }).handleError((_) {
        return _mockMembers;
      });
    } catch (_) {
      return _mockStreamController.stream;
    }
  }

  Future<void> addMember(MemberModel member) async {
    try {
      await _membersCollection.doc(member.id).set(member.toMap());
    } catch (_) {
      _mockMembers.insert(0, member);
      _mockStreamController.add(List.from(_mockMembers));
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      await _membersCollection.doc(member.id).update(member.toMap());
    } catch (_) {
      final index = _mockMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _mockMembers[index] = member;
        _mockStreamController.add(List.from(_mockMembers));
      }
    }
  }

  Future<void> freezeMembership(String memberId, int days) async {
    final member = _mockMembers.firstWhere(
      (m) => m.id == memberId,
      orElse: () => _mockMembers.first,
    );
    final updated = member.copyWith(
      isFrozen: true,
      status: MemberStatus.frozen,
      endDate: member.endDate.add(Duration(days: days)),
    );
    await updateMember(updated);
  }

  Future<void> unfreezeMembership(String memberId) async {
    final member = _mockMembers.firstWhere(
      (m) => m.id == memberId,
      orElse: () => _mockMembers.first,
    );
    final updated = member.copyWith(
      isFrozen: false,
      status: MemberStatus.active,
    );
    await updateMember(updated);
  }
}
