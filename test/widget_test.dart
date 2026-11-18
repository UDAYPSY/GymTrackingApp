import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/core/utils/formatters.dart';
import 'package:gym_manager/features/members/models/member_model.dart';
import 'package:gym_manager/features/billing/models/plan_model.dart';

void main() {
  test('Member expiration calculation test', () {
    final now = DateTime.now();
    final member = MemberModel(
      id: '1',
      memberCode: 'GB-101',
      name: 'Test User',
      phone: '1234567890',
      startDate: now.subtract(const Duration(days: 28)),
      endDate: now.add(const Duration(days: 2)),
      planName: 'Monthly',
      status: MemberStatus.active,
    );
    expect(member.isExpiringSoon, isTrue);
    expect(member.hasExpired, isFalse);
  });

  test('Formatters currency test', () {
    final formatted = Formatters.formatCurrency(2500);
    expect(formatted.contains('2500'), isTrue);
  });

  test('PlanModel test', () {
    final plan = PlanModel(
      id: 'p1',
      name: 'Standard',
      durationMonths: 1,
      price: 2000.0,
    );
    expect(plan.name, equals('Standard'));
    expect(plan.durationMonths, equals(1));
  });

  testWidgets('Smoke widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('GymManager Studio')),
        ),
      ),
    );
    expect(find.text('GymManager Studio'), findsOneWidget);
  });
}
