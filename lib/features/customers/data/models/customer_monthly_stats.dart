import '../../../../core/firestore/firestore_json_helpers.dart';

class CustomerMonthlyStats {
  const CustomerMonthlyStats({
    required this.newCustomers,
    required this.returningCustomers,
    required this.activeCustomers,
    required this.vipCustomers,
    required this.totalSpent,
    required this.updatedAt,
  });

  final int newCustomers;
  final int returningCustomers;
  final int activeCustomers;
  final int vipCustomers;
  final double totalSpent;
  final DateTime? updatedAt;

  factory CustomerMonthlyStats.fromJson(Map<String, dynamic> json) {
    return CustomerMonthlyStats(
      newCustomers: looseIntFromJson(json['newCustomers']),
      returningCustomers: looseIntFromJson(json['returningCustomers']),
      activeCustomers: looseIntFromJson(json['activeCustomers']),
      vipCustomers: looseIntFromJson(json['vipCustomers']),
      totalSpent: looseDoubleFromJson(json['totalSpent']),
      updatedAt: nullableFirestoreDateTimeFromJson(json['updatedAt']),
    );
  }
}

