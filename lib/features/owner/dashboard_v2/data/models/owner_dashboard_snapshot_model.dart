import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../../core/firestore/firestore_serializers.dart';

class OwnerDashboardSnapshotModel {
  const OwnerDashboardSnapshotModel({
    required this.id,
    required this.salonId,
    required this.snapshotType,
    required this.dateKey,
    required this.periodId,
    required this.revenueToday,
    required this.bookingsToday,
    required this.pendingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.checkedInEmployees,
    required this.absentEmployees,
    required this.attendanceIssues,
    required this.salesCount,
    required this.averageTicket,
    required this.alertMissingCheckouts,
    required this.alertUnpaidCompletedBookings,
    required this.monthlyRevenue,
    required this.monthlyPayrollCost,
    required this.monthlyExpenses,
    required this.monthlyNetProfit,
    required this.bookingsCount,
    required this.completedBookingsCount,
    required this.conversionRate,
    required this.topEmployeeName,
    required this.topEmployeeRevenue,
    required this.topServiceName,
    required this.topServiceRevenue,
    required this.alertPayrollNeedsApproval,
    required this.alertLowBookingConversion,
    required this.generatedAt,
    required this.updatedAt,
  });

  final String id;
  final String salonId;
  final String snapshotType; // daily | monthly
  final String? dateKey; // YYYY-MM-DD
  final String? periodId; // YYYY-MM

  // Daily
  final double revenueToday;
  final int bookingsToday;
  final int pendingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int checkedInEmployees;
  final int absentEmployees;
  final int attendanceIssues;
  final int salesCount;
  final double averageTicket;
  final int alertMissingCheckouts;
  final int alertUnpaidCompletedBookings;

  // Monthly
  final double monthlyRevenue;
  final double monthlyPayrollCost;
  final double monthlyExpenses;
  final double monthlyNetProfit;
  final int bookingsCount;
  final int completedBookingsCount;
  final double conversionRate;
  final String? topEmployeeName;
  final double topEmployeeRevenue;
  final String? topServiceName;
  final double topServiceRevenue;
  final int alertPayrollNeedsApproval;
  final int alertLowBookingConversion;

  final DateTime? generatedAt;
  final DateTime? updatedAt;

  factory OwnerDashboardSnapshotModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? <String, dynamic>{};
    return OwnerDashboardSnapshotModel(
      id: doc.id,
      salonId: looseStringFromJson(d['salonId']),
      snapshotType: looseStringFromJson(d['snapshotType']),
      dateKey: (d['dateKey'] as String?)?.trim(),
      periodId: (d['periodId'] as String?)?.trim(),
      revenueToday: looseDoubleFromJson(d['revenueToday']),
      bookingsToday: looseIntFromJson(d['bookingsToday']),
      pendingBookings: looseIntFromJson(d['pendingBookings']),
      completedBookings: looseIntFromJson(d['completedBookings']),
      cancelledBookings: looseIntFromJson(d['cancelledBookings']),
      checkedInEmployees: looseIntFromJson(d['checkedInEmployees']),
      absentEmployees: looseIntFromJson(d['absentEmployees']),
      attendanceIssues: looseIntFromJson(d['attendanceIssues']),
      salesCount: looseIntFromJson(d['salesCount']),
      averageTicket: looseDoubleFromJson(d['averageTicket']),
      alertMissingCheckouts: looseIntFromJson(d['alertMissingCheckouts']),
      alertUnpaidCompletedBookings: looseIntFromJson(
        d['alertUnpaidCompletedBookings'],
      ),
      monthlyRevenue: looseDoubleFromJson(d['monthlyRevenue']),
      monthlyPayrollCost: looseDoubleFromJson(d['monthlyPayrollCost']),
      monthlyExpenses: looseDoubleFromJson(d['monthlyExpenses']),
      monthlyNetProfit: looseDoubleFromJson(d['monthlyNetProfit']),
      bookingsCount: looseIntFromJson(d['bookingsCount']),
      completedBookingsCount: looseIntFromJson(d['completedBookingsCount']),
      conversionRate: looseDoubleFromJson(d['conversionRate']),
      topEmployeeName: (d['topEmployeeName'] as String?)?.trim(),
      topEmployeeRevenue: looseDoubleFromJson(d['topEmployeeRevenue']),
      topServiceName: (d['topServiceName'] as String?)?.trim(),
      topServiceRevenue: looseDoubleFromJson(d['topServiceRevenue']),
      alertPayrollNeedsApproval: looseIntFromJson(d['alertPayrollNeedsApproval']),
      alertLowBookingConversion: looseIntFromJson(d['alertLowBookingConversion']),
      generatedAt: FirestoreSerializers.dateTime(d['generatedAt']),
      updatedAt: FirestoreSerializers.dateTime(d['updatedAt']),
    );
  }
}

