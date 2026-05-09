import '../../../../core/firestore/firestore_json_helpers.dart';

class ServicePerformanceModel {
  const ServicePerformanceModel({
    required this.serviceId,
    required this.serviceName,
    required this.revenue,
    required this.count,
  });

  final String serviceId;
  final String serviceName;
  final double revenue;
  final int count;

  factory ServicePerformanceModel.fromJson(Map<String, dynamic> json) {
    return ServicePerformanceModel(
      serviceId: looseStringFromJson(json['serviceId']),
      serviceName: looseStringFromJson(json['serviceName']),
      revenue: looseDoubleFromJson(json['revenue']),
      count: looseIntFromJson(json['count']),
    );
  }
}

