enum MemberStatus {
  active,
  expiringSoon,
  expired,
  frozen,
}

enum PaymentMethod {
  cash,
  upi,
  card,
  bankTransfer,
}

enum PaymentStatus {
  paid,
  partial,
  due,
}

enum AttendanceMethod {
  qrScan,
  manual,
  biometric,
}

class AppConstants {
  static const String appName = 'GymManager';
  static const String currencySymbol = '₹';
  static const String supportPhone = '+919999999999';

  // Collection names in Cloud Firestore
  static const String gymsCollection = 'gyms';
  static const String membersCollection = 'members';
  static const String plansCollection = 'plans';
  static const String invoicesCollection = 'invoices';
  static const String attendanceCollection = 'attendance';
  static const String workoutsCollection = 'workouts';
  static const String expensesCollection = 'expenses';
  static const String enquiriesCollection = 'enquiries';
}
