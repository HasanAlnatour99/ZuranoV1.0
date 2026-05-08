import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/currency_for_country.dart';
import 'customer_booking_settings.dart';

/// Customer-safe booking details (no internal staff notes or HR fields).
class CustomerBookingDetailsServiceItem {
  const CustomerBookingDetailsServiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    required this.category,
  });

  final String serviceId;
  final String serviceName;
  final double price;
  final int durationMinutes;
  final String category;
}

class CustomerBookingDetailsModel {
  const CustomerBookingDetailsModel({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.salonArea,
    required this.salonPhone,
    required this.salonWhatsapp,
    required this.bookingCode,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    this.customerPhoneNormalized = '',
    required this.employeeId,
    required this.employeeName,
    required this.services,
    required this.serviceNames,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.durationMinutes,
    required this.startAt,
    required this.endAt,
    required this.source,
    required this.customerNote,
    required this.createdAt,
    required this.currencyCode,
    this.updatedAt,
    this.customerId,
    this.feedbackSubmitted = false,
    this.feedbackSubmittedAt,
    this.customerBookingSettings = const CustomerBookingSettings(),
  });

  final String id;
  final String salonId;
  final String salonName;
  final String salonArea;
  final String? salonPhone;
  final String? salonWhatsapp;
  final String bookingCode;
  final String status;
  final String customerName;
  final String customerPhone;
  final String customerPhoneNormalized;
  final String employeeId;
  final String employeeName;
  final List<CustomerBookingDetailsServiceItem> services;
  final List<String> serviceNames;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final int durationMinutes;
  final DateTime startAt;
  final DateTime endAt;
  final String source;
  final String customerNote;
  final String currencyCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerId;
  final bool feedbackSubmitted;
  final DateTime? feedbackSubmittedAt;

  /// From `publicSalons/{salonId}.customerBookingSettings` when present.
  final CustomerBookingSettings customerBookingSettings;

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

  static double _double(Object? value) {
    return value is num ? value.toDouble() : 0;
  }

  static bool _bool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }

  static int _int(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return 0;
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
    if (value is Map) {
      final sec = value['_seconds'] ?? value['seconds'];
      final ns = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
      if (sec is int) {
        final n = ns is int ? ns : int.tryParse('$ns') ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          sec * 1000 + n ~/ 1000000,
          isUtc: true,
        );
      }
    }
    return null;
  }

  static DateTime _requiredDate(Object? value) {
    return _date(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static List<CustomerBookingDetailsServiceItem> _parseServices(
    Object? services,
  ) {
    if (services is! Iterable) {
      return const [];
    }
    return services
        .whereType<Map>()
        .map(
          (m) => CustomerBookingDetailsServiceItem(
            serviceId: _string(m['serviceId']),
            serviceName: _string(m['serviceName'] ?? m['name']),
            price: _double(m['price']),
            durationMinutes: _int(m['durationMinutes']),
            category: _string(m['category']),
          ),
        )
        .where(
          (s) =>
              s.serviceName.isNotEmpty || s.serviceId.isNotEmpty || s.price > 0,
        )
        .toList(growable: false);
  }

  static List<String> _serviceNamesList(Object? names, Object? services) {
    if (names is Iterable) {
      return names
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    final parsed = _parseServices(services);
    return parsed.map((s) => s.serviceName).where((n) => n.isNotEmpty).toList();
  }

  /// Merge [bookingData] with public salon row (may be missing).
  factory CustomerBookingDetailsModel.fromFirestore({
    required String bookingId,
    required Map<String, dynamic> bookingData,
    required SalonPublicSlice publicSalon,
  }) {
    final services = _parseServices(bookingData['services']);
    var serviceNames = _serviceNamesList(
      bookingData['serviceNames'],
      bookingData['services'],
    );
    if (services.isEmpty && serviceNames.isEmpty) {
      final legacyName = _string(bookingData['serviceName']);
      if (legacyName.isNotEmpty) {
        serviceNames = [legacyName];
      }
    }

    final employeeId = _string(
      bookingData['employeeId'] ?? bookingData['barberId'],
    );
    final employeeName = _string(
      bookingData['employeeName'] ?? bookingData['barberName'],
    );

    final salonId = _string(bookingData['salonId']).isNotEmpty
        ? _string(bookingData['salonId'])
        : publicSalon.id;

    final salonName = publicSalon.salonName.isNotEmpty
        ? publicSalon.salonName
        : _string(bookingData['salonName']);

    String? fallbackPhone(Object? v) {
      final s = _string(v);
      return s.isEmpty ? null : s;
    }

    final mergedPhone = (publicSalon.phone?.trim().isNotEmpty == true)
        ? publicSalon.phone?.trim()
        : fallbackPhone(
          bookingData['salonPhone'] ??
              bookingData['phone'] ??
              bookingData['phoneNumber'],
        );

    final mergedWhatsapp = (publicSalon.whatsapp?.trim().isNotEmpty == true)
        ? publicSalon.whatsapp?.trim()
        : fallbackPhone(
          bookingData['salonWhatsapp'] ??
              bookingData['whatsapp'] ??
              bookingData['whatsApp'] ??
              bookingData['whatsappNumber'],
        );

    final mergedArea = publicSalon.area.isNotEmpty
        ? publicSalon.area
        : _string(bookingData['salonArea'] ?? bookingData['area']);

    return CustomerBookingDetailsModel(
      id: bookingId,
      salonId: salonId,
      salonName: salonName,
      salonArea: mergedArea,
      salonPhone: mergedPhone,
      salonWhatsapp: mergedWhatsapp,
      bookingCode: _publicBookingCode(bookingData),
      status: _string(bookingData['status']),
      customerName: _string(bookingData['customerName']),
      customerPhone: _string(bookingData['customerPhone']),
      customerPhoneNormalized: _string(bookingData['customerPhoneNormalized']),
      employeeId: employeeId,
      employeeName: employeeName,
      services: services,
      serviceNames: serviceNames,
      subtotal: _double(bookingData['subtotal']),
      discountAmount: _double(bookingData['discountAmount']),
      totalAmount: _double(bookingData['totalAmount']),
      durationMinutes: _int(bookingData['durationMinutes']),
      startAt: _requiredDate(bookingData['startAt']),
      endAt: _requiredDate(bookingData['endAt']),
      source: _string(bookingData['source']),
      customerNote: _string(bookingData['customerNote']),
      currencyCode: publicSalon.currencyCode,
      createdAt: _date(bookingData['createdAt']),
      updatedAt: _date(bookingData['updatedAt']),
      customerId: () {
        final id = _string(bookingData['customerId']);
        return id.isEmpty ? null : id;
      }(),
      feedbackSubmitted: _bool(bookingData['feedbackSubmitted'], false),
      feedbackSubmittedAt: _date(bookingData['feedbackSubmittedAt']),
      customerBookingSettings: publicSalon.customerBookingSettings,
    );
  }

  /// Parses HTTPS callable JSON (ISO date strings or timestamp maps) into the same shape as Firestore.
  factory CustomerBookingDetailsModel.fromCallablePayload({
    required String bookingId,
    required Map<String, dynamic> bookingData,
    required Map<String, dynamic> publicSalon,
  }) {
    final merged = Map<String, dynamic>.from(bookingData);
    final publicSlice = SalonPublicSlice.fromMap(
      '${publicSalon['id'] ?? ''}'.trim().isNotEmpty
          ? '${publicSalon['id']}'.trim()
          : _string(bookingData['salonId']),
      publicSalon,
    );
    return CustomerBookingDetailsModel.fromFirestore(
      bookingId: bookingId,
      bookingData: merged,
      publicSalon: publicSlice,
    );
  }
}

/// Subset of [SalonPublicModel] fields needed for booking details (no import cycle).
class SalonPublicSlice {
  const SalonPublicSlice({
    required this.id,
    required this.salonName,
    required this.area,
    required this.currencyCode,
    this.phone,
    this.whatsapp,
    this.customerBookingSettings = const CustomerBookingSettings(),
  });

  final String id;
  final String salonName;
  final String area;
  final String currencyCode;
  final String? phone;
  final String? whatsapp;

  /// Parsed from `customerBookingSettings` on `publicSalons/{salonId}`.
  final CustomerBookingSettings customerBookingSettings;

  factory SalonPublicSlice.empty(String salonId) {
    return SalonPublicSlice(
      id: salonId,
      salonName: '',
      area: '',
      currencyCode: resolvedSalonMoneyCurrency(
        salonCurrencyCode: null,
        salonCountryIso: null,
      ),
      phone: null,
      whatsapp: null,
    );
  }

  factory SalonPublicSlice.fromMap(String id, Map<String, dynamic> data) {
    final name = (data['salonName'] as String?)?.trim();
    final area = (data['area'] as String?)?.trim();
    final countryIso = (data['countryCode'] as String?)?.trim();
    final rawCcy = (data['currencyCode'] as String?)?.trim();
    final currencyCode = resolvedSalonMoneyCurrency(
      salonCurrencyCode: rawCcy,
      salonCountryIso:
          (countryIso != null && countryIso.isNotEmpty) ? countryIso : null,
    );
    final rawSettings = data['customerBookingSettings'];
    return SalonPublicSlice(
      id: id,
      salonName: (name != null && name.isNotEmpty) ? name : '',
      area: (area != null && area.isNotEmpty) ? area : '',
      currencyCode: currencyCode,
      phone: ((data['phone'] as String?) ??
              (data['salonPhone'] as String?) ??
              (data['phoneNumber'] as String?))
          ?.trim(),
      whatsapp: ((data['whatsapp'] as String?) ??
              (data['salonWhatsapp'] as String?) ??
              (data['whatsApp'] as String?) ??
              (data['whatsappNumber'] as String?))
          ?.trim(),
      customerBookingSettings: CustomerBookingSettings.fromMap(
        rawSettings is Map<String, dynamic> ? rawSettings : null,
      ),
    );
  }
}
