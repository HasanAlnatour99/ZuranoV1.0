import '../../../../core/firestore/firestore_json_helpers.dart';

class EmployeePerformanceModel {
  const EmployeePerformanceModel({
    required this.employeeId,
    required this.employeeName,
    required this.salesTotal,
    required this.salesCount,
    required this.servicesCount,
    required this.commissionAmount,
  });

  final String employeeId;
  final String employeeName;
  final double salesTotal;
  final int salesCount;
  final int servicesCount;
  final double commissionAmount;

  factory EmployeePerformanceModel.fromJson(Map<String, dynamic> json) {
    return EmployeePerformanceModel(
      employeeId: looseStringFromJson(json['employeeId']),
      employeeName: looseStringFromJson(json['employeeName']),
      salesTotal: looseDoubleFromJson(json['salesTotal']),
      salesCount: looseIntFromJson(json['salesCount']),
      servicesCount: looseIntFromJson(json['servicesCount']),
      commissionAmount: looseDoubleFromJson(json['commissionAmount']),
    );
  }
}

