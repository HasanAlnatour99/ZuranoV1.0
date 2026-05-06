import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerBookingLookupModel {
  const CustomerBookingLookupModel({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.bookingCode,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.customerPhoneNormalized,
    required this.employeeId,
    required this.employeeName,
    required this.serviceNames,
    required this.totalAmount,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
  });

  final String id;
  final String salonId;
  final String salonName;
  final String bookingCode;
  final String status;
  final String customerName;
  final String customerPhone;
  final String customerPhoneNormalized;
  final String employeeId;
  final String employeeName;
  final List<String> serviceNames;
  final double totalAmount;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? createdAt;

  factory CustomerBookingLookupModel.fromCallableJson(
    Map<String, dynamic> json,
  ) {
    return CustomerBookingLookupModel(
      id: _string(json['bookingId']),
      salonId: _string(json['salonId']),
      salonName: _string(json['salonName']),
      bookingCode: _string(
        json['bookingNumber'] ?? json['bookingCode'],
      ),
      status: _string(json['status']),
      customerName: _string(json['customerName']),
      customerPhone: _string(json['customerPhone']),
      customerPhoneNormalized: _string(json['customerPhoneNormalized']),
      employeeId: _string(json['employeeId']),
      employeeName: _string(json['employeeName']),
      serviceNames: _serviceNames(json['serviceNames'], null),
      totalAmount: _double(json['totalAmount']),
      startAt: _requiredDate(json['startAt']),
      endAt: _requiredDate(json['endAt']),
      createdAt: _date(json['createdAt']),
    );
  }

  factory CustomerBookingLookupModel.fromLookupCallableJson(
    Map<String, dynamic> json,
  ) {
    return CustomerBookingLookupModel(
      id: _string(json['bookingId']),
      salonId: _string(json['salonId']),
      salonName: _string(json['salonName']),
      bookingCode: _string(json['bookingCode']),
      status: _string(json['status']),
      customerName: _string(json['customerName']),
      customerPhone: _string(json['customerPhone']),
      customerPhoneNormalized: _string(json['customerPhoneNormalized']),
      employeeId: _string(json['employeeId']),
      employeeName: _string(json['employeeName']),
      serviceNames: _serviceNames(json['serviceNames'], null),
      totalAmount: _double(json['totalAmount']),
      startAt: _dateFromMillis(json['startAtMs']),
      endAt: _dateFromMillis(json['endAtMs']),
      createdAt: _optionalDateFromMillis(json['createdAtMs']),
    );
  }

  factory CustomerBookingLookupModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CustomerBookingLookupModel(
      id: doc.id,
      salonId: _string(data['salonId']),
      salonName: _string(data['salonName']),
      bookingCode: _publicBookingCode(data),
      status: _string(data['status']),
      customerName: _string(data['customerName']),
      customerPhone: _string(data['customerPhone']),
      customerPhoneNormalized: _string(data['customerPhoneNormalized']),
      employeeId: _string(data['employeeId'] ?? data['barberId']),
      employeeName: _string(data['employeeName'] ?? data['barberName']),
      serviceNames: _serviceNames(data['serviceNames'], data['services']),
      totalAmount: _double(data['totalAmount']),
      startAt: _requiredDate(data['startAt']),
      endAt: _requiredDate(data['endAt']),
      createdAt: _date(data['createdAt']),
    );
  }

  static String _string(Object? value) {
    return value is String ? value.trim() : '';
  }

  static String _publicBookingCode(Map<String, dynamic> data) {
    final n = _string(data['bookingNumber']);
    if (n.isNotEmpty) {
      return n;
    }
    return _string(data['bookingCode']);
  }

  static DateTime _dateFromMillis(Object? value) {
    final ms = _millis(value);
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  static DateTime? _optionalDateFromMillis(Object? value) {
    final ms = _millis(value);
    if (ms <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  static int _millis(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static double _double(Object? value) {
    return value is num ? value.toDouble() : 0;
  }

  static DateTime _requiredDate(Object? value) {
    return _date(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  static List<String> _serviceNames(Object? names, Object? services) {
    if (names is Iterable) {
      return names
          .whereType<String>()
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList(growable: false);
    }

    if (services is Iterable) {
      return services
          .whereType<Map>()
          .map((service) => _string(service['serviceName'] ?? service['name']))
          .where((name) => name.isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }
}
