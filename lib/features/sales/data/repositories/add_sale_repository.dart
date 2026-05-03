import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../../core/firestore/report_period.dart';
import '../../../customers/data/models/customer.dart';
import '../../../employees/data/models/employee.dart';
import '../../../users/data/models/app_user.dart';
import '../models/guest_booking_snapshot.dart';
import '../models/sale.dart';
import '../sales_repository.dart';

class AddSaleBookingException implements Exception {
  AddSaleBookingException(this.code);

  final String code;
}

/// Booking-code POS conversion + optional manual sale helper.
class AddSaleRepository {
  AddSaleRepository(this._db, this._salesRepository);

  final FirebaseFirestore _db;
  final SalesRepository _salesRepository;

  String _normalizeBookingCode(String raw) => raw.trim().toUpperCase();

  Future<GuestBookingSnapshot> getBookingByCode({
    required String bookingCode,
    required String salonId,
  }) async {
    final normalizedCode = _normalizeBookingCode(bookingCode);
    if (normalizedCode.isEmpty) {
      throw AddSaleBookingException('empty_code');
    }
    final doc = await _db
        .doc(FirestorePaths.guestBooking(normalizedCode))
        .get();
    if (!doc.exists) {
      throw AddSaleBookingException('not_found');
    }
    final booking = GuestBookingSnapshot.fromFirestore(doc);
    if (booking.salonId != salonId) {
      throw AddSaleBookingException('wrong_salon');
    }
    if (_isCancelled(booking.bookingStatus)) {
      throw AddSaleBookingException('cancelled');
    }
    if (booking.saleCreated || (booking.saleId?.trim().isNotEmpty == true)) {
      throw AddSaleBookingException('sale_exists');
    }
    if (booking.serviceItems.isEmpty) {
      throw AddSaleBookingException('no_services');
    }
    if (booking.totalAmount <= 0) {
      throw AddSaleBookingException('zero_total');
    }
    return booking;
  }

  Future<String> createSaleFromBooking({
    required String bookingCode,
    required String salonId,
    required AppUser actor,
    required Employee performingBarber,
  }) async {
    final normalizedCode = _normalizeBookingCode(bookingCode);
    if (normalizedCode.isEmpty) {
      throw AddSaleBookingException('empty_code');
    }
    final bookingRef = _db.doc(FirestorePaths.guestBooking(normalizedCode));
    final saleRef = _db.collection(FirestorePaths.salonSales(salonId)).doc();

    return _db.runTransaction((transaction) async {
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) {
        throw AddSaleBookingException('not_found');
      }
      final booking = GuestBookingSnapshot.fromFirestore(bookingSnap);
      if (booking.salonId != salonId) {
        throw AddSaleBookingException('wrong_salon');
      }
      if (booking.saleCreated || (booking.saleId?.trim().isNotEmpty == true)) {
        throw AddSaleBookingException('sale_exists');
      }
      if (_isCancelled(booking.bookingStatus)) {
        throw AddSaleBookingException('cancelled');
      }
      if (booking.serviceItems.isEmpty) {
        throw AddSaleBookingException('no_services');
      }
      if (booking.barberId.trim() != performingBarber.id.trim()) {
        throw AddSaleBookingException('barber_mismatch');
      }

      final customerDocId = _customerDocIdFromBooking(booking);
      final visibleName = _visibleCustomerNameFromBooking(booking);
      final customerRef = _db.doc(
        FirestorePaths.salonCustomer(salonId, customerDocId),
      );
      final customerSnap = await transaction.get(customerRef);
      final actorRole = actor.role.trim().toLowerCase();
      final privileged = actorRole == 'owner' || actorRole == 'admin';

      final barberDisplayName = formatTeamMemberName(performingBarber.name);
      final lineItems = <SaleLineItem>[
        for (final line in booking.serviceItems)
          SaleLineItem.withComputedTotal(
            serviceId: line.serviceId.trim().isEmpty
                ? 'booking_service'
                : line.serviceId.trim(),
            serviceName: line.name.trim().isEmpty
                ? 'Service'
                : line.name.trim(),
            employeeId: performingBarber.id,
            employeeName: barberDisplayName,
            quantity: line.quantity,
            unitPrice: line.price,
          ),
      ];

      final subtotal = booking.subtotal > 0
          ? booking.subtotal
          : Sale.subtotalFromLineItems(lineItems);
      final discount = booking.discountAmount.clamp(0, subtotal).toDouble();
      final totalAfter = (subtotal - discount).clamp(0, double.infinity);
      if (totalAfter <= 0) {
        throw AddSaleBookingException('zero_total');
      }

      final soldAt = DateTime.now();
      final payMethod = _mapPaymentMethod(booking.paymentMethod);
      final rate =
          performingBarber.effectiveCommissionRate ??
          performingBarber.commissionRate;

      final authUidTrimmed = booking.authUid?.trim();
      final sale = Sale.create(
        id: saleRef.id,
        salonId: salonId,
        employeeId: performingBarber.id,
        employeeName: barberDisplayName,
        lineItems: lineItems,
        tax: 0,
        discount: discount,
        paymentMethod: payMethod,
        status: SaleStatuses.completed,
        soldAt: soldAt,
        customerId: customerDocId,
        customerName: visibleName,
        customerDisplayName: visibleName,
        customerUid: customerDocId,
        customerAuthUid: authUidTrimmed != null && authUidTrimmed.isNotEmpty
            ? authUidTrimmed
            : null,
        barberImageUrl: performingBarber.avatarUrl,
        createdByUid: actor.uid,
        createdByName: actor.name,
        commissionRateUsed: rate,
      );
      final pay = _paymentSplit(payMethod, sale.total);

      final customerType = booking.accountType.trim().toLowerCase() == 'guest'
          ? 'guest'
          : 'registered';

      final payload = FirestoreWritePayload.withServerTimestampsForCreate({
        ...sale.toJson(),
        'id': saleRef.id,
        'barberId': performingBarber.id,
        'barberName': barberDisplayName,
        if (performingBarber.avatarUrl != null &&
            performingBarber.avatarUrl!.trim().isNotEmpty)
          'barberImageUrl': performingBarber.avatarUrl,
        'commissionPercentage': rate,
        'createdBy': actor.uid,
        'updatedBy': actor.uid,
        'employeeUid': actor.uid,
        'createdByRole': actor.role.trim(),
        'subtotalAmount': subtotal,
        'discountAmount': discount,
        'customerDiscountFromPercent': 0.0,
        'manualDiscountAmount': 0.0,
        'totalAmountAfterDiscount': sale.total,
        'cashAmount': pay.cash,
        'cardAmount': pay.card,
        'approvalStatus': 'approved',
        'dateKey': _saleDateKeyUtc(soldAt),
        'monthKey': ReportPeriod.periodKey(
          ReportPeriod.yearFrom(soldAt),
          ReportPeriod.monthFrom(soldAt),
        ),
        'source': 'booking',
        'bookingCode': normalizedCode,
        'customerType': customerType,
        if (booking.nicknameKey != null &&
            booking.nicknameKey!.trim().isNotEmpty)
          'guestNicknameKey': booking.nicknameKey!.trim(),
        'posPaymentMethod': booking.paymentMethod,
        'posPaymentStatus': booking.paymentStatus,
        'posSaleStatus': booking.paymentStatus == 'paid' ? 'completed' : 'open',
        'customerId': customerDocId,
        'customerUid': customerDocId,
        if (authUidTrimmed != null && authUidTrimmed.isNotEmpty)
          'authUid': authUidTrimmed,
        'customerName': visibleName,
        'customerDisplayName': visibleName,
      });

      transaction.set(saleRef, payload);
      for (final item in sale.lineItems) {
        final itemRef = saleRef.collection('items').doc();
        transaction.set(itemRef, {
          'serviceId': item.serviceId,
          'serviceName': item.serviceName,
          if (item.serviceIcon != null && item.serviceIcon!.trim().isNotEmpty)
            'serviceIcon': item.serviceIcon,
          'price': item.unitPrice,
          'quantity': item.quantity,
          'lineTotal': item.total,
        });
      }

      final nickKey = booking.nicknameKey?.trim() ?? '';
      final keywords = buildCustomerSearchKeywords(
        fullName: visibleName,
        phoneNumber: null,
      );

      if (!customerSnap.exists) {
        transaction.set(customerRef, {
          'salonId': salonId,
          'fullName': visibleName,
          'displayName': visibleName,
          'customerName': visibleName,
          'nickname': visibleName,
          'nicknameKey': nickKey,
          'customerUid': customerDocId,
          'customerId': customerDocId,
          if (authUidTrimmed != null && authUidTrimmed.isNotEmpty)
            'authUid': authUidTrimmed,
          'phone': '',
          'isActive': true,
          'customerType': customerType,
          'source': 'booking',
          'firstBookingCode': normalizedCode,
          'lastBookingCode': normalizedCode,
          'firstSaleId': saleRef.id,
          'lastSaleId': saleRef.id,
          'totalVisits': 1,
          'visitsCount': 1,
          'visitCount': 1,
          'totalSpent': sale.total,
          'lastVisitAt': FieldValue.serverTimestamp(),
          'firstVisitAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': actor.uid,
          'searchKeywords': keywords,
          'category': 'new',
        });
      } else if (privileged) {
        transaction.set(customerRef, {
          'salonId': salonId,
          'fullName': visibleName,
          'displayName': visibleName,
          'customerName': visibleName,
          'nickname': visibleName,
          'nicknameKey': nickKey,
          'customerUid': customerDocId,
          'customerId': customerDocId,
          if (authUidTrimmed != null && authUidTrimmed.isNotEmpty)
            'authUid': authUidTrimmed,
          'customerType': customerType,
          'source': 'booking',
          'lastBookingCode': normalizedCode,
          'lastSaleId': saleRef.id,
          'totalVisits': FieldValue.increment(1),
          'visitsCount': FieldValue.increment(1),
          'visitCount': FieldValue.increment(1),
          'totalSpent': FieldValue.increment(sale.total),
          'lastVisitAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'searchKeywords': keywords,
        }, SetOptions(merge: true));
      } else {
        transaction.update(customerRef, {
          'totalVisits': FieldValue.increment(1),
          'visitsCount': FieldValue.increment(1),
          'visitCount': FieldValue.increment(1),
          'totalSpent': FieldValue.increment(sale.total),
          'lastVisitAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastSaleId': saleRef.id,
          'lastBookingCode': normalizedCode,
        });
      }

      transaction.update(bookingRef, {
        'saleCreated': true,
        'saleId': saleRef.id,
        'customerId': customerDocId,
        'customerUid': customerDocId,
        'customerName': visibleName,
        'customerDisplayName': visibleName,
        'bookingStatus': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return saleRef.id;
    });
  }

  /// Manual POS row using the same sale document shape as [SalesRepository.createSale].
  Future<String> createManualSale({
    required String salonId,
    required String customerName,
    required String barberId,
    required String barberName,
    required List<SaleServiceItemPayload> serviceItems,
    required String paymentMethod,
    required String paymentStatus,
    required AppUser actor,
    required String createdByRole,
    String? barberAvatarUrl,
    double? commissionRatePercent,
  }) async {
    final name = customerName.trim();
    if (name.isEmpty) {
      throw AddSaleBookingException('manual_name_required');
    }
    if (serviceItems.isEmpty) {
      throw AddSaleBookingException('no_services');
    }
    final barberDisplayName = formatTeamMemberName(barberName);
    final lineItems = <SaleLineItem>[
      for (final item in serviceItems)
        SaleLineItem.withComputedTotal(
          serviceId: item.serviceId.trim().isEmpty
              ? 'manual_service'
              : item.serviceId.trim(),
          serviceName: item.name.trim().isEmpty ? 'Service' : item.name.trim(),
          employeeId: barberId.trim(),
          employeeName: barberDisplayName,
          quantity: item.quantity < 1 ? 1 : item.quantity,
          unitPrice: item.price,
        ),
    ];
    final subtotal = Sale.subtotalFromLineItems(lineItems);
    if (subtotal <= 0) {
      throw AddSaleBookingException('zero_total');
    }
    final payMethod = _mapManualPaymentMethod(paymentMethod);
    final soldAt = DateTime.now();
    final pay = _paymentSplit(payMethod, subtotal);
    final saleId = _salesRepository.allocateSaleDocumentId(salonId);
    final sale = Sale.create(
      id: saleId,
      salonId: salonId,
      employeeId: barberId.trim(),
      employeeName: barberDisplayName,
      lineItems: lineItems,
      tax: 0,
      discount: 0,
      paymentMethod: payMethod,
      status: SaleStatuses.completed,
      soldAt: soldAt,
      customerName: name,
      barberImageUrl: barberAvatarUrl,
      createdByUid: actor.uid,
      createdByName: actor.name,
      commissionRateUsed: commissionRatePercent,
    );

    await _salesRepository.createSale(
      salonId,
      sale,
      additionalFields: {
        'barberId': barberId.trim(),
        'barberName': barberDisplayName,
        if (barberAvatarUrl != null && barberAvatarUrl.trim().isNotEmpty)
          'barberImageUrl': barberAvatarUrl.trim(),
        'commissionPercentage': commissionRatePercent ?? 0,
        'createdBy': actor.uid,
        'updatedBy': actor.uid,
        'employeeUid': actor.uid,
        'createdByRole': createdByRole.trim(),
        'subtotalAmount': subtotal,
        'discountAmount': 0.0,
        'customerDiscountFromPercent': 0.0,
        'manualDiscountAmount': 0.0,
        'totalAmountAfterDiscount': sale.total,
        'cashAmount': pay.cash,
        'cardAmount': pay.card,
        'approvalStatus': 'approved',
        'dateKey': _saleDateKeyUtc(soldAt),
        'monthKey': ReportPeriod.periodKey(
          ReportPeriod.yearFrom(soldAt),
          ReportPeriod.monthFrom(soldAt),
        ),
        'source': 'manual',
        'customerType': 'manual',
        'posPaymentStatus': paymentStatus,
        'posSaleStatus': paymentStatus == 'paid' ? 'completed' : 'open',
      },
    );
    return saleId;
  }

  static bool _isCancelled(String status) {
    final s = status.trim().toLowerCase();
    return s == 'cancelled' || s == 'canceled';
  }

  static String _mapPaymentMethod(String raw) {
    final m = raw.trim().toLowerCase();
    if (m == 'card') return SalePaymentMethods.card;
    if (m == 'wallet' || m == 'digital_wallet') {
      return SalePaymentMethods.digitalWallet;
    }
    return SalePaymentMethods.cash;
  }

  static String _mapManualPaymentMethod(String raw) {
    final m = raw.trim().toLowerCase();
    if (m == 'card') return SalePaymentMethods.card;
    if (m == 'wallet') return SalePaymentMethods.digitalWallet;
    return SalePaymentMethods.cash;
  }

  static ({double cash, double card}) _paymentSplit(
    String method,
    double total,
  ) {
    switch (method) {
      case SalePaymentMethods.card:
        return (cash: 0.0, card: total);
      case SalePaymentMethods.digitalWallet:
        return (cash: 0.0, card: total);
      default:
        return (cash: total, card: 0.0);
    }
  }
}

class SaleServiceItemPayload {
  const SaleServiceItemPayload({
    required this.serviceId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  final String serviceId;
  final String name;
  final double price;
  final int quantity;

  Map<String, dynamic> toMap() => {
    'serviceId': serviceId,
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}

String _saleDateKeyUtc(DateTime soldAt) {
  final u = soldAt.toUtc();
  final y = u.year.toString().padLeft(4, '0');
  final m = u.month.toString().padLeft(2, '0');
  final day = u.day.toString().padLeft(2, '0');
  return '$y$m$day';
}

String _customerDocIdFromBooking(GuestBookingSnapshot booking) {
  final authUid = booking.authUid?.trim();
  if (authUid != null && authUid.isNotEmpty) {
    return authUid;
  }
  final nicknameKey = booking.nicknameKey?.trim() ?? '';
  if (nicknameKey.isNotEmpty) {
    return 'guest_${nicknameKey.toLowerCase()}';
  }
  return 'guest_${booking.bookingCode.trim().toLowerCase()}';
}

String _visibleCustomerNameFromBooking(GuestBookingSnapshot booking) {
  final displayName = booking.guestDisplayName?.trim() ?? '';
  if (displayName.isNotEmpty) {
    return displayName;
  }
  final nicknameKey = booking.nicknameKey?.trim() ?? '';
  if (nicknameKey.isNotEmpty) {
    return nicknameKey;
  }
  return 'Guest';
}
