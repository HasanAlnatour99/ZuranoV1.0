import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../../../core/firestore/report_period.dart';

class SaleLineItem {
  const SaleLineItem({
    required this.serviceId,
    required this.serviceName,
    this.serviceIcon,
    required this.employeeId,
    required this.employeeName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final String serviceId;
  final String serviceName;

  /// Optional category key or icon hint persisted for POS receipts.
  final String? serviceIcon;
  final String employeeId;
  final String employeeName;
  final int quantity;
  final double unitPrice;
  final double total;

  /// Line total is `quantity * unitPrice` (quantity clamps to at least 1).
  factory SaleLineItem.withComputedTotal({
    required String serviceId,
    required String serviceName,
    String? serviceIcon,
    required String employeeId,
    required String employeeName,
    required int quantity,
    required double unitPrice,
  }) {
    final q = quantity < 1 ? 1 : quantity;
    return SaleLineItem(
      serviceId: serviceId,
      serviceName: serviceName,
      serviceIcon: serviceIcon,
      employeeId: employeeId,
      employeeName: employeeName,
      quantity: q,
      unitPrice: unitPrice,
      total: q * unitPrice,
    );
  }

  factory SaleLineItem.fromJson(Map<String, dynamic> json) {
    return SaleLineItem(
      serviceId: FirestoreSerializers.string(json['serviceId']) ?? '',
      serviceName: FirestoreSerializers.string(json['serviceName']) ?? '',
      serviceIcon: FirestoreSerializers.string(json['serviceIcon']),
      employeeId: FirestoreSerializers.string(json['employeeId']) ?? '',
      employeeName: FirestoreSerializers.string(json['employeeName']) ?? '',
      quantity: FirestoreSerializers.intValue(json['quantity'], fallback: 1),
      unitPrice: FirestoreSerializers.doubleValue(json['unitPrice']),
      total: FirestoreSerializers.doubleValue(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      if (serviceIcon != null && serviceIcon!.trim().isNotEmpty)
        'serviceIcon': serviceIcon,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}

class Sale {
  Sale({
    required this.id,
    required this.salonId,
    required this.employeeId,
    String? barberId,
    required this.employeeName,
    required this.lineItems,
    required this.serviceNames,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.soldAt,
    this.customerId,
    this.customerPhoneSnapshot,
    this.customerDiscountPercentageSnapshot = 0,
    int? reportYear,
    int? reportMonth,
    this.customerName,
    this.customerDisplayName,
    this.customerUid,
    this.customerAuthUid,
    this.barberImageUrl,
    this.createdByUid,
    this.createdByName,
    this.commissionRateUsed,
    this.commissionAmount,
    this.receiptPhotoUrl,
    this.receiptStoragePath,
    this.createdAt,
    this.updatedAt,
  }) : barberId = _barberId(barberId, employeeId),
       reportYear = reportYear ?? ReportPeriod.yearFrom(soldAt),
       reportMonth = reportMonth ?? ReportPeriod.monthFrom(soldAt);

  final String id;
  final String salonId;
  final String employeeId;

  /// Same as [employeeId]; stored explicitly for bookings/analytics naming.
  final String barberId;
  final String employeeName;
  final List<SaleLineItem> lineItems;
  final List<String> serviceNames;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;

  /// See [SalePaymentMethods]; stored for reporting and dashboards.
  final String paymentMethod;

  /// See [SaleStatuses]; stored for reporting and void/refund flows.
  final String status;

  final DateTime soldAt;

  /// `customers/{customerId}` when linked to a business customer record.
  final String? customerId;

  /// Phone captured at sale time (optional).
  final String? customerPhoneSnapshot;

  /// Customer-wide discount % applied for this sale (0 when walk-in / none).
  final double customerDiscountPercentageSnapshot;

  /// Denormalized calendar fields for aggregation (derived from [soldAt] when omitted).
  final int reportYear;
  final int reportMonth;

  final String? customerName;

  /// Denormalized display name for POS / lists (preferred over [customerName] when set).
  final String? customerDisplayName;

  /// Same as salon customer document id when linked from booking flow.
  final String? customerUid;

  /// Firebase Auth uid when sale is tied to a guest/customer account (internal only).
  final String? customerAuthUid;

  final String? barberImageUrl;
  final String? createdByUid;
  final String? createdByName;

  /// Commission rate applied when this sale was recorded (percent, e.g. `35`
  /// for 35 %). Stored as a historical snapshot so future payroll/analytics
  /// stay stable if the barber's live `commissionRate` changes later.
  final double? commissionRateUsed;

  /// Absolute commission amount attributed to [barberId] for this sale,
  /// computed at creation time from [commissionRateUsed] and [total].
  final double? commissionAmount;

  /// Download URL for optional receipt photo (Firebase Storage).
  final String? receiptPhotoUrl;

  /// Storage object path for [receiptPhotoUrl] when uploaded via app flows.
  final String? receiptStoragePath;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get reportPeriodKey => ReportPeriod.periodKey(reportYear, reportMonth);

  /// Sum of [lineItems] `total` values.
  static double subtotalFromLineItems(Iterable<SaleLineItem> lineItems) {
    return lineItems.fold<double>(0, (sum, item) => sum + item.total);
  }

  /// `subtotal + tax - discount`
  static double totalFromParts({
    required double subtotal,
    required double tax,
    required double discount,
  }) {
    return subtotal + tax - discount;
  }

  /// Builds [serviceNames] from line items (same order as [lineItems]).
  static List<String> serviceNamesFromLineItems(List<SaleLineItem> lineItems) {
    return lineItems.map((e) => e.serviceName).toList(growable: false);
  }

  /// Creates a sale with [subtotal], [total], and [serviceNames] derived from
  /// [lineItems], [tax], and [discount].
  factory Sale.create({
    String id = '',
    required String salonId,
    required String employeeId,
    required String employeeName,
    required List<SaleLineItem> lineItems,
    double tax = 0,
    double discount = 0,
    String paymentMethod = SalePaymentMethods.cash,
    String status = SaleStatuses.completed,
    required DateTime soldAt,
    String? customerId,
    String? customerPhoneSnapshot,
    double customerDiscountPercentageSnapshot = 0,
    String? customerName,
    String? customerDisplayName,
    String? customerUid,
    String? customerAuthUid,
    String? barberImageUrl,
    String? createdByUid,
    String? createdByName,
    double? commissionRateUsed,
    double? commissionAmount,
    String? receiptPhotoUrl,
    String? receiptStoragePath,
  }) {
    final subtotal = subtotalFromLineItems(lineItems);
    final total = totalFromParts(
      subtotal: subtotal,
      tax: tax,
      discount: discount,
    );
    final serviceNames = serviceNamesFromLineItems(lineItems);
    final resolvedCommission =
        commissionAmount ??
        computeCommissionAmount(total: total, ratePercent: commissionRateUsed);
    return Sale(
      id: id,
      salonId: salonId,
      employeeId: employeeId,
      employeeName: employeeName,
      lineItems: lineItems,
      serviceNames: serviceNames,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paymentMethod: paymentMethod,
      status: status,
      soldAt: soldAt,
      customerId: customerId,
      customerPhoneSnapshot: customerPhoneSnapshot,
      customerDiscountPercentageSnapshot: customerDiscountPercentageSnapshot,
      customerName: customerName,
      customerDisplayName: customerDisplayName,
      customerUid: customerUid,
      customerAuthUid: customerAuthUid,
      barberImageUrl: barberImageUrl,
      createdByUid: createdByUid,
      createdByName: createdByName,
      commissionRateUsed: commissionRateUsed,
      commissionAmount: resolvedCommission,
      receiptPhotoUrl: receiptPhotoUrl,
      receiptStoragePath: receiptStoragePath,
    );
  }

  /// Returns the commission amount for a given [total] and [ratePercent]
  /// (0–100). Returns `null` when the rate is missing or non-positive so
  /// callers can decide how to display a "no commission" case.
  static double? computeCommissionAmount({
    required double total,
    required double? ratePercent,
  }) {
    if (ratePercent == null) return null;
    if (ratePercent <= 0) return 0;
    final clamped = ratePercent > 100 ? 100.0 : ratePercent;
    return total * (clamped / 100);
  }

  static String _barberId(String? barberId, String employeeId) {
    final b = barberId?.trim();
    if (b != null && b.isNotEmpty) {
      return b;
    }
    return employeeId;
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    var soldAt =
        FirestoreSerializers.dateTime(json['soldAt']) ??
        FirestoreSerializers.dateTime(json['createdAt']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    var reportYear = FirestoreSerializers.intValue(json['reportYear']);
    var reportMonth = FirestoreSerializers.intValue(json['reportMonth']);
    if (reportYear == 0 || reportMonth == 0) {
      final fromKey = ReportPeriod.parsePeriodKey(
        FirestoreSerializers.string(json['reportPeriodKey']),
      );
      if (fromKey != null) {
        reportYear = fromKey.$1;
        reportMonth = fromKey.$2;
      } else {
        reportYear = ReportPeriod.yearFrom(soldAt);
        reportMonth = ReportPeriod.monthFrom(soldAt);
      }
    }

    final employeeId =
        (FirestoreSerializers.string(json['employeeId']) ?? '')
            .trim()
            .isNotEmpty
        ? FirestoreSerializers.string(json['employeeId'])!.trim()
        : (FirestoreSerializers.string(json['barberId']) ?? '').trim();

    final barberName = FirestoreSerializers.string(json['barberName']) ?? '';
    final employeeNameRaw = FirestoreSerializers.string(json['employeeName']);
    final employeeName =
        (employeeNameRaw != null && employeeNameRaw.trim().isNotEmpty)
        ? employeeNameRaw.trim()
        : barberName;

    var lineItems = FirestoreSerializers.mapList(
      json['lineItems'],
    ).map(SaleLineItem.fromJson).toList(growable: false);

    var subtotal = FirestoreSerializers.doubleValue(
      json['subtotalAmount'] ?? json['subtotal'],
    );
    var total = FirestoreSerializers.doubleValue(
      json['totalAmountAfterDiscount'] ?? json['total'],
    );
    final rootPrice = FirestoreSerializers.doubleValue(json['price']);

    if (lineItems.isEmpty) {
      final sid = (FirestoreSerializers.string(json['serviceId']) ?? '').trim();
      final sname = (FirestoreSerializers.string(json['serviceName']) ?? '')
          .trim();
      final unit = rootPrice > 0 ? rootPrice : total;
      if (sid.isNotEmpty && unit > 0) {
        lineItems = [
          SaleLineItem.withComputedTotal(
            serviceId: sid,
            serviceName: sname.isNotEmpty ? sname : sid,
            employeeId: employeeId,
            employeeName: employeeName,
            quantity: 1,
            unitPrice: unit,
          ),
        ];
        if (subtotal == 0) {
          subtotal = unit;
        }
        if (total == 0) {
          total = unit;
        }
      }
    }

    var serviceNames = FirestoreSerializers.stringList(json['serviceNames']);
    if (serviceNames.isEmpty && lineItems.isNotEmpty) {
      serviceNames = serviceNamesFromLineItems(lineItems);
    }

    return Sale(
      id: FirestoreSerializers.string(json['id']) ?? '',
      salonId: FirestoreSerializers.string(json['salonId']) ?? '',
      employeeId: employeeId,
      barberId: FirestoreSerializers.string(json['barberId']),
      employeeName: employeeName,
      lineItems: lineItems,
      serviceNames: serviceNames,
      subtotal: subtotal,
      tax: FirestoreSerializers.doubleValue(json['tax']),
      discount: FirestoreSerializers.doubleValue(
        json['discountAmount'] ?? json['discount'],
      ),
      total: total,
      paymentMethod:
          FirestoreSerializers.string(json['paymentMethod']) ??
          SalePaymentMethods.cash,
      status:
          FirestoreSerializers.string(json['status']) ?? SaleStatuses.completed,
      soldAt: soldAt,
      customerId: FirestoreSerializers.string(json['customerId']),
      customerPhoneSnapshot: FirestoreSerializers.string(
        json['customerPhoneSnapshot'],
      ),
      customerDiscountPercentageSnapshot: FirestoreSerializers.doubleValue(
        json['customerDiscountPercentageSnapshot'],
      ),
      reportYear: reportYear,
      reportMonth: reportMonth,
      customerName: FirestoreSerializers.string(json['customerName']),
      customerDisplayName: FirestoreSerializers.string(
        json['customerDisplayName'],
      ),
      customerUid: FirestoreSerializers.string(json['customerUid']),
      customerAuthUid: FirestoreSerializers.string(
        json['authUid'] ?? json['customerAuthUid'],
      ),
      barberImageUrl:
          FirestoreSerializers.string(json['barberImageUrl']) ??
          FirestoreSerializers.string(json['employeeImageUrl']),
      createdByUid: FirestoreSerializers.string(json['createdByUid']),
      createdByName: FirestoreSerializers.string(json['createdByName']),
      commissionRateUsed: json.containsKey('commissionRateUsed')
          ? FirestoreSerializers.doubleValue(json['commissionRateUsed'])
          : null,
      commissionAmount: json.containsKey('commissionAmount')
          ? FirestoreSerializers.doubleValue(json['commissionAmount'])
          : null,
      receiptPhotoUrl: FirestoreSerializers.string(json['receiptPhotoUrl']),
      receiptStoragePath: FirestoreSerializers.string(
        json['receiptStoragePath'],
      ),
      createdAt: FirestoreSerializers.dateTime(json['createdAt']),
      updatedAt: FirestoreSerializers.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'employeeId': employeeId,
      'barberId': barberId,
      'employeeName': employeeName,
      'lineItems': lineItems
          .map((item) => item.toJson())
          .toList(growable: false),
      'serviceNames': serviceNames,
      'subtotal': subtotal,
      'subtotalAmount': subtotal,
      'tax': tax,
      'discount': discount,
      'discountAmount': discount,
      'total': total,
      'totalAmountAfterDiscount': total,
      'customerDiscountPercentageSnapshot': customerDiscountPercentageSnapshot,
      if (customerPhoneSnapshot != null &&
          customerPhoneSnapshot!.trim().isNotEmpty)
        'customerPhoneSnapshot': customerPhoneSnapshot,
      'paymentMethod': paymentMethod,
      'status': status,
      'soldAt': soldAt,
      if (customerId != null && customerId!.trim().isNotEmpty)
        'customerId': customerId,
      'reportYear': reportYear,
      'reportMonth': reportMonth,
      'reportPeriodKey': reportPeriodKey,
      'customerName': customerName,
      if (customerDisplayName != null && customerDisplayName!.trim().isNotEmpty)
        'customerDisplayName': customerDisplayName,
      if (customerUid != null && customerUid!.trim().isNotEmpty)
        'customerUid': customerUid,
      if (customerAuthUid != null && customerAuthUid!.trim().isNotEmpty)
        'authUid': customerAuthUid,
      if (barberImageUrl != null && barberImageUrl!.trim().isNotEmpty)
        'barberImageUrl': barberImageUrl,
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      if (commissionRateUsed != null) 'commissionRateUsed': commissionRateUsed,
      if (commissionAmount != null) 'commissionAmount': commissionAmount,
      if (receiptPhotoUrl != null && receiptPhotoUrl!.trim().isNotEmpty)
        'receiptPhotoUrl': receiptPhotoUrl,
      if (receiptStoragePath != null &&
          receiptStoragePath!.trim().isNotEmpty)
        'receiptStoragePath': receiptStoragePath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
