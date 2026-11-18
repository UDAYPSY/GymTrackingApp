class PlanModel {
  final String id;
  final String name;
  final int durationMonths;
  final double price;
  final double admissionFee;
  final String description;

  PlanModel({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.price,
    this.admissionFee = 0.0,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationMonths': durationMonths,
      'price': price,
      'admissionFee': admissionFee,
      'description': description,
    };
  }

  factory PlanModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return PlanModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      durationMonths: map['durationMonths'] ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      admissionFee: (map['admissionFee'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
    );
  }
}
