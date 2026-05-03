import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_serializers.dart';

/// One row under `guestBookings/{bookingCode}` for POS preview + conversion.
class GuestBookingSnapshot {
  const GuestBookingSnapshot({
    required this.bookingCode,
    required this.salonId,
    required this.salonName,
    required this.barberId,
    required this.barberName,
    required this.serviceItems,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.appointmentStartAt,
    required this.appointmentEndAt,
    required this.accountType,
    this.nicknameKey,
    this.guestDisplayName,
    this.authUid,
    this.saleCreated = false,
    this.saleId,
  });

  final String bookingCode;
  final String salonId;
  final String salonName;
  final String barberId;
  final String barberName;
  final List<GuestBookingServiceLine> serviceItems;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String bookingStatus;
  final DateTime appointmentStartAt;
  final DateTime appointmentEndAt;
  final String accountType;
  final String? nicknameKey;
  final String? guestDisplayName;
  final String? authUid;
  final bool saleCreated;
  final String? saleId;

  /// Staff-visible label (never [authUid]).
  String get customerLabel {
    final display = guestDisplayName?.trim() ?? '';
    if (display.isNotEmpty) return display;
    final nk = nicknameKey?.trim() ?? '';
    if (nk.isNotEmpty) return nk;
    return 'Guest';
  }

  factory GuestBookingSnapshot.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final itemsRaw = data['serviceItems'];
    final items = <GuestBookingServiceLine>[];
    if (itemsRaw is List) {
      for (final e in itemsRaw) {
        if (e is Map<String, dynamic>) {
          items.add(GuestBookingServiceLine.fromMap(e));
        } else if (e is Map) {
          items.add(
            GuestBookingServiceLine.fromMap(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    final subtotal = FirestoreSerializers.doubleValue(
      data['subtotal'] ?? data['subtotalAmount'],
    );
    final discount = FirestoreSerializers.doubleValue(data['discountAmount']);
    var total = FirestoreSerializers.doubleValue(data['totalAmount']);
    if (total <= 0 && subtotal > 0) {
      total = (subtotal - discount).clamp(0, double.infinity);
    }
    return GuestBookingSnapshot(
      bookingCode: (data['bookingCode'] as String?)?.trim().isNotEmpty == true
          ? data['bookingCode'] as String
          : doc.id,
      salonId: FirestoreSerializers.string(data['salonId']) ?? '',
      salonName: FirestoreSerializers.string(data['salonName']) ?? '',
      barberId: FirestoreSerializers.string(data['barberId']) ?? '',
      barberName: FirestoreSerializers.string(data['barberName']) ?? '',
      serviceItems: items,
      subtotal: subtotal > 0 ? subtotal : _sumLines(items),
      discountAmount: discount,
      totalAmount: total > 0 ? total : _sumLines(items) - discount,
      paymentMethod:
          FirestoreSerializers.string(data['paymentMethod']) ?? 'unspecified',
      paymentStatus:
          FirestoreSerializers.string(data['paymentStatus']) ?? 'pending',
      bookingStatus: FirestoreSerializers.string(data['bookingStatus']) ?? '',
      appointmentStartAt:
          FirestoreSerializers.dateTime(data['appointmentStartAt']) ??
          FirestoreSerializers.dateTime(data['startAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      appointmentEndAt:
          FirestoreSerializers.dateTime(data['appointmentEndAt']) ??
          FirestoreSerializers.dateTime(data['endAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      accountType: FirestoreSerializers.string(data['accountType']) ?? 'guest',
      nicknameKey: FirestoreSerializers.string(data['nicknameKey']),
      guestDisplayName: FirestoreSerializers.string(data['guestDisplayName']),
      authUid: FirestoreSerializers.string(data['authUid']),
      saleCreated: FirestoreSerializers.boolValue(data['saleCreated']),
      saleId: FirestoreSerializers.string(data['saleId']),
    );
  }

  static double _sumLines(List<GuestBookingServiceLine> lines) {
    return lines.fold<double>(0, (s, e) => s + e.lineTotal);
  }
}

class GuestBookingServiceLine {
  const GuestBookingServiceLine({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.quantity,
    this.durationMinutes,
  });

  final String serviceId;
  final String name;
  final double price;
  final int quantity;
  final int? durationMinutes;

  double get lineTotal => price * quantity;

  factory GuestBookingServiceLine.fromMap(Map<String, dynamic> m) {
    final qty = FirestoreSerializers.intValue(m['quantity'], fallback: 1);
    final q = qty < 1 ? 1 : qty;
    final name =
        FirestoreSerializers.string(m['name']) ??
        FirestoreSerializers.string(m['serviceName']) ??
        '';
    return GuestBookingServiceLine(
      serviceId: FirestoreSerializers.string(m['serviceId']) ?? '',
      name: name,
      price: FirestoreSerializers.doubleValue(m['price']),
      quantity: q,
      durationMinutes: m['durationMinutes'] != null
          ? FirestoreSerializers.intValue(m['durationMinutes'], fallback: 0)
          : null,
    );
  }
}
