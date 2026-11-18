import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/features/members/models/member_model.dart';
import 'package:gym_manager/main.dart';

void main() {
  group('MemberModel Unit Tests', () {
    test('Member expiration calculation should identify expiring and expired members', () {
      final now = DateTime.now();

      // Expiring in 2 days
      final expiringMember = MemberModel(
        id: '1',
        memberCode: 'GB-101',
        name: 'Test User',
        phone: '1234567890',
        startDate: now.subtract(const Duration(days: 28)),
        endDate: now.add(const Duration(days: 2)),
        planName: 'Monthly',
      );
      expect(expiringMember.isExpiringSoon, isTrue);
      expect(expiringMember.hasExpired, isFalse);

      // Expired 5 days ago
      final expiredMember = MemberModel(
        id: '2',
        memberCode: 'GB-102',
        name: 'Expired User',
        phone: '1234567890',
        startDate: now.subtract(const Duration(days: 35)),
        endDate: now.subtract(const Duration(days: 5)),
        planName: 'Monthly',
      );
      expect(expiredMember.hasExpired, isTrue);
      expect(expiredMember.isExpiringSoon, isFalse);
    });

    test('MemberModel serialization toMap and fromMap should be consistent', () {
      final member = MemberModel(
        id: 'test_id',
        memberCode: 'GB-999',
        name: 'Alex Hunter',
        phone: '9876543210',
        gender: 'Male',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
        planName: '3 Months Gold',
        totalAmount: 5000,
        paidAmount: 3000,
        dueAmount: 2000,
        status: MemberStatus.active,
      );

      final map = member.toMap();
      final restored = MemberModel.fromMap(map);

      expect(restored.id, equals(member.id));
      expect(restored.memberCode, equals(member.memberCode));
      expect(restored.name, equals(member.name));
      expect(restored.dueAmount, equals(2000.0));
      expect(restored.status, equals(MemberStatus.active));
    });
  });

  group('Widget Tests', () {
    testWidgets('GymManagerApp renders Dashboard and bottom navigation destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: GymManagerApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard header elements
      expect(find.text('GymManager Studio'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);

      // Verify bottom navigation labels
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
    });
  });
}
