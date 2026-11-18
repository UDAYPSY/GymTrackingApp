import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/core/theme/app_theme.dart';
import 'package:gym_manager/core/utils/formatters.dart';
import 'package:gym_manager/features/members/models/member_model.dart';
import 'package:gym_manager/features/billing/models/plan_model.dart';
import 'package:gym_manager/features/workouts/models/workout_model.dart';

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
        totalAmount: 5000.0,
        paidAmount: 3000.0,
        dueAmount: 2000.0,
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

  group('Utility & Model Tests', () {
    test('Formatters should format currency correctly', () {
      expect(Formatters.formatCurrency(2500), equals('₹2500'));
      expect(Formatters.formatCurrency(2500.50), equals('₹2500.50'));
    });

    test('PlanModel should correctly serialize and deserialize', () {
      final plan = PlanModel(
        id: 'p1',
        name: 'Annual VIP',
        durationMonths: 12,
        price: 15000.0,
        admissionFee: 500.0,
      );
      final map = plan.toMap();
      final fromMap = PlanModel.fromMap(map);

      expect(fromMap.name, equals('Annual VIP'));
      expect(fromMap.durationMonths, equals(12));
      expect(fromMap.price, equals(15000.0));
    });

    test('WorkoutPlanModel and ExerciseModel instantiation', () {
      final workout = WorkoutPlanModel(
        id: 'w1',
        title: 'Push Day',
        category: 'Hypertrophy',
        level: 'Intermediate',
        exercises: [
          ExerciseModel(name: 'Bench Press', sets: 4, reps: 10),
        ],
      );
      expect(workout.title, equals('Push Day'));
      expect(workout.exercises.first.name, equals('Bench Press'));
      expect(workout.exercises.first.sets, equals(4));
    });
  });

  group('Widget Presentation Tests', () {
    testWidgets('Renders Theme & App Bar Title cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('GymManager Studio'),
            ),
            body: const Center(
              child: Text('Welcome to GymManager'),
            ),
          ),
        ),
      );

      expect(find.text('GymManager Studio'), findsOneWidget);
      expect(find.text('Welcome to GymManager'), findsOneWidget);
    });
  });
}
