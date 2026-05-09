import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import 'employee_performance_model.dart';
import 'service_performance_model.dart';

class MonthlyAnalyticsModel {
  const MonthlyAnalyticsModel({
    required this.id,
    required this.salonId,
    required this.periodId,
    required this.year,
    required this.month,
    required this.grossRevenue,
    required this.salesCount,
    required this.bookingsCount,
    required this.completedBookingsCount,
    required this.payrollCost,
    required this.expensesTotal,
    required this.netProfit,
    required this.averageTicket,
    required this.servicesCount,
    required this.customersCount,
    required this.newCustomersCount,
    required this.topEmployees,
    required this.topServices,
    required this.generatedAt,
    required this.updatedAt,
  });

  final String id;
  final String salonId;
  final String periodId;
  final int year;
  final int month;
  final double grossRevenue;
  final int salesCount;
  final int bookingsCount;
  final int completedBookingsCount;
  final double payrollCost;
  final double expensesTotal;
  final double netProfit;
  final double averageTicket;
  final int servicesCount;
  final int customersCount;
  final int newCustomersCount;
  final List<EmployeePerformanceModel> topEmployees;
  final List<ServicePerformanceModel> topServices;
  final DateTime? generatedAt;
  final DateTime? updatedAt;

  factory MonthlyAnalyticsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? <String, dynamic>{};
    final topEmployeesRaw = d['topEmployees'];
    final topServicesRaw = d['topServices'];

    return MonthlyAnalyticsModel(
      id: doc.id,
      salonId: looseStringFromJson(d['salonId']),
      periodId: looseStringFromJson(d['periodId']),
      year: looseIntFromJson(d['year']),
      month: looseIntFromJson(d['month']),
      grossRevenue: looseDoubleFromJson(d['grossRevenue']),
      salesCount: looseIntFromJson(d['salesCount']),
      bookingsCount: looseIntFromJson(d['bookingsCount']),
      completedBookingsCount: looseIntFromJson(d['completedBookingsCount']),
      payrollCost: looseDoubleFromJson(d['payrollCost']),
      expensesTotal: looseDoubleFromJson(d['expensesTotal']),
      netProfit: looseDoubleFromJson(d['netProfit']),
      averageTicket: looseDoubleFromJson(d['averageTicket']),
      servicesCount: looseIntFromJson(d['servicesCount']),
      customersCount: looseIntFromJson(d['customersCount']),
      newCustomersCount: looseIntFromJson(d['newCustomersCount']),
      topEmployees: topEmployeesRaw is List
          ? topEmployeesRaw
              .whereType<Map>()
              .map((m) => EmployeePerformanceModel.fromJson(
                    Map<String, dynamic>.from(m),
                  ))
              .toList(growable: false)
          : const <EmployeePerformanceModel>[],
      topServices: topServicesRaw is List
          ? topServicesRaw
              .whereType<Map>()
              .map((m) => ServicePerformanceModel.fromJson(
                    Map<String, dynamic>.from(m),
                  ))
              .toList(growable: false)
          : const <ServicePerformanceModel>[],
      generatedAt: FirestoreSerializers.dateTime(d['generatedAt']),
      updatedAt: FirestoreSerializers.dateTime(d['updatedAt']),
    );
  }
}

