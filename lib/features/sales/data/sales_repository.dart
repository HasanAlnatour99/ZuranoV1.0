import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/sale_reporting.dart';
import '../../../core/firebase/app_check_storage_prime.dart';
import '../../../core/text/team_member_name.dart';
import '../../../core/firestore/firestore_page.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import 'models/sale.dart';

/// Matches [storage.rules] `request.resource.contentType.matches('image/.*')`.
({String contentType, String fileExtension}) _receiptImageFormat(
  Uint8List bytes,
) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return (contentType: 'image/jpeg', fileExtension: 'jpg');
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return (contentType: 'image/png', fileExtension: 'png');
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return (contentType: 'image/webp', fileExtension: 'webp');
  }
  return (contentType: 'image/jpeg', fileExtension: 'jpg');
}

Sale _saleWithFormattedTeamMemberNames(Sale sale) {
  final items = <SaleLineItem>[
    for (final i in sale.lineItems)
      SaleLineItem(
        serviceId: i.serviceId,
        serviceName: i.serviceName,
        serviceIcon: i.serviceIcon,
        employeeId: i.employeeId,
        employeeName: formatTeamMemberName(i.employeeName),
        quantity: i.quantity,
        unitPrice: i.unitPrice,
        total: i.total,
      ),
  ];
  return Sale(
    id: sale.id,
    salonId: sale.salonId,
    employeeId: sale.employeeId,
    barberId: sale.barberId,
    employeeName: formatTeamMemberName(sale.employeeName),
    lineItems: items,
    serviceNames: sale.serviceNames,
    subtotal: sale.subtotal,
    tax: sale.tax,
    discount: sale.discount,
    total: sale.total,
    paymentMethod: sale.paymentMethod,
    status: sale.status,
    soldAt: sale.soldAt,
    customerId: sale.customerId,
    customerPhoneSnapshot: sale.customerPhoneSnapshot,
    customerDiscountPercentageSnapshot:
        sale.customerDiscountPercentageSnapshot,
    reportYear: sale.reportYear,
    reportMonth: sale.reportMonth,
    customerName: sale.customerName,
    customerDisplayName: sale.customerDisplayName,
    customerUid: sale.customerUid,
    customerAuthUid: sale.customerAuthUid,
    barberImageUrl: sale.barberImageUrl,
    createdByUid: sale.createdByUid,
    createdByName: sale.createdByName,
    commissionRateUsed: sale.commissionRateUsed,
    commissionAmount: sale.commissionAmount,
    receiptPhotoUrl: sale.receiptPhotoUrl,
    receiptStoragePath: sale.receiptStoragePath,
    createdAt: sale.createdAt,
    updatedAt: sale.updatedAt,
  );
}

Map<String, dynamic>? _additionalFieldsWithFormattedBarberName(
  Map<String, dynamic>? additionalFields,
) {
  if (additionalFields == null || additionalFields.isEmpty) {
    return additionalFields;
  }
  final out = Map<String, dynamic>.from(additionalFields);
  final bn = out['barberName'];
  if (bn is String && bn.trim().isNotEmpty) {
    out['barberName'] = formatTeamMemberName(bn);
  }
  return out;
}

class SalesRepository {
  SalesRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _sales(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonSales(salonId));
  }

  Map<String, dynamic> _saleLineItemSubdocPayload(SaleLineItem item) {
    return {
      'serviceId': item.serviceId,
      'serviceName': item.serviceName,
      if (item.serviceIcon != null && item.serviceIcon!.trim().isNotEmpty)
        'serviceIcon': item.serviceIcon,
      'employeeId': item.employeeId,
      'price': item.unitPrice,
      'quantity': item.quantity,
      'lineTotal': item.total,
    };
  }

  /// Writes `sales/{saleId}/items/*` **after** the parent sale document exists.
  ///
  /// Staff Firestore rules validate line-item creates with `get(parent sale)`;
  /// those reads do not see uncommitted parent docs from the same batch/transaction,
  /// so callers must commit the sale document first, then call this method.
  Future<void> commitSaleLineItemSubdocuments({
    required String salonId,
    required String saleId,
    required List<SaleLineItem> lineItems,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final id = saleId.trim();
    if (id.isEmpty || lineItems.isEmpty) {
      return;
    }
    final saleRef = _sales(salonId).doc(id);
    final batch = _firestore.batch();
    for (final item in lineItems) {
      final itemRef = saleRef.collection('items').doc();
      batch.set(itemRef, _saleLineItemSubdocPayload(item));
    }
    await batch.commit();
  }

  /// New Firestore document id under `salons/{salonId}/sales` (for uploads before write).
  String allocateSaleDocumentId(String salonId) => _sales(salonId).doc().id;

  /// Uploads a receipt JPEG to
  /// `salons/{salonId}/sales/{saleId}/receipts/{timestamp}.jpg`.
  Future<({String downloadUrl, String storagePath})> uploadReceiptPhoto({
    required String salonId,
    required String saleId,
    required XFile image,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final sid = salonId.trim();
    final id = saleId.trim();
    final ts = DateTime.now().millisecondsSinceEpoch;
    await primeAppCheckTokenBeforeStorageUpload();
    final bytes = await image.readAsBytes();
    final fmt = _receiptImageFormat(bytes);
    final storagePath =
        'salons/$sid/sales/$id/receipts/$ts.${fmt.fileExtension}';
    final ref = _storage.ref(storagePath);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: fmt.contentType),
    );
    final downloadUrl = await ref.getDownloadURL();
    return (downloadUrl: downloadUrl, storagePath: storagePath);
  }

  /// Persists [sale] under `salons/{salonId}/sales/{saleId}`.
  ///
  /// Prefer building sales with [Sale.create] so [subtotal], [total], and
  /// [serviceNames] stay consistent with [lineItems].
  ///
  /// [additionalFields] are merged into the create payload (e.g. denormalized
  /// `price`, `serviceId`, `barberName` for quick-sale documents).
  Future<String> createSale(
    String salonId,
    Sale sale, {
    Map<String, dynamic>? additionalFields,
  }) async {
    final collection = _sales(salonId);
    final document = sale.id.isEmpty
        ? collection.doc()
        : collection.doc(sale.id);
    final normalized = _saleWithFormattedTeamMemberNames(sale);
    final extras = _additionalFieldsWithFormattedBarberName(additionalFields);
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      ...normalized.toJson(),
      'id': document.id,
      ...?extras,
    });

    final batch = _firestore.batch();
    batch.set(document, payload);
    await batch.commit();

    await commitSaleLineItemSubdocuments(
      salonId: salonId,
      saleId: document.id,
      lineItems: normalized.lineItems,
    );
    return document.id;
  }

  /// Atomically creates the sale, line-item subdocuments, and increments
  /// salon customer visit/spend counters when [linkedCustomerId] is set.
  Future<String> createSaleWithLinkedCustomerStats({
    required String salonId,
    required Sale sale,
    Map<String, dynamic>? additionalFields,
    String? linkedCustomerId,
    String? presetSaleId,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    final sid = salonId.trim();
    final cid = linkedCustomerId?.trim() ?? '';
    final preset = presetSaleId?.trim() ?? '';
    final saleRef = preset.isNotEmpty
        ? _sales(sid).doc(preset)
        : _sales(sid).doc();
    final normalized = _saleWithFormattedTeamMemberNames(sale);
    final saleWithId = Sale(
      id: saleRef.id,
      salonId: normalized.salonId,
      employeeId: normalized.employeeId,
      barberId: normalized.barberId,
      employeeName: normalized.employeeName,
      lineItems: normalized.lineItems,
      serviceNames: normalized.serviceNames,
      subtotal: normalized.subtotal,
      tax: normalized.tax,
      discount: normalized.discount,
      total: normalized.total,
      paymentMethod: normalized.paymentMethod,
      status: normalized.status,
      soldAt: normalized.soldAt,
      customerId: normalized.customerId,
      customerPhoneSnapshot: normalized.customerPhoneSnapshot,
      customerDiscountPercentageSnapshot:
          normalized.customerDiscountPercentageSnapshot,
      reportYear: normalized.reportYear,
      reportMonth: normalized.reportMonth,
      customerName: normalized.customerName,
      barberImageUrl: normalized.barberImageUrl,
      createdByUid: normalized.createdByUid,
      createdByName: normalized.createdByName,
      commissionRateUsed: normalized.commissionRateUsed,
      commissionAmount: normalized.commissionAmount,
      receiptPhotoUrl: normalized.receiptPhotoUrl,
      receiptStoragePath: normalized.receiptStoragePath,
    );
    final extras = _additionalFieldsWithFormattedBarberName(additionalFields);
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      ...saleWithId.toJson(),
      'id': saleRef.id,
      ...?extras,
    });

    return _firestore.runTransaction((transaction) async {
      if (cid.isNotEmpty) {
        final customerRef = _firestore
            .collection(FirestorePaths.salons)
            .doc(sid)
            .collection(FirestorePaths.customers)
            .doc(cid);
        final cSnap = await transaction.get(customerRef);
        if (cSnap.exists) {
          final data = cSnap.data();
          final firstVisitRaw = data?['firstVisitAt'];
          final updates = <String, dynamic>{
            'totalVisits': FieldValue.increment(1),
            'visitsCount': FieldValue.increment(1),
            'visitCount': FieldValue.increment(1),
            'totalSpent': FieldValue.increment(saleWithId.total),
            'lastVisitAt': Timestamp.fromDate(saleWithId.soldAt),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          if (firstVisitRaw == null) {
            updates['firstVisitAt'] = Timestamp.fromDate(saleWithId.soldAt);
          }
          transaction.update(customerRef, updates);
        }
      }

      transaction.set(saleRef, payload);
      return saleRef.id;
    }).then((committedSaleId) async {
      await commitSaleLineItemSubdocuments(
        salonId: sid,
        saleId: committedSaleId,
        lineItems: saleWithId.lineItems,
      );
      return committedSaleId;
    });
  }

  /// All sales for the salon, newest first.
  Future<List<Sale>> getSalesBySalon(
    String salonId, {
    DateTime? soldFrom,
    DateTime? soldTo,
    int limit = 100,
  }) async {
    final snapshot = await _salesQuery(
      salonId,
      soldFrom: soldFrom,
      soldTo: soldTo,
      limit: limit,
      startAfter: null,
    ).get();

    return snapshot.docs.map((doc) => Sale.fromJson(doc.data())).toList();
  }

  /// Sales attributed to [employeeId] (primary employee on the sale document).
  Future<List<Sale>> getSalesByEmployee(
    String salonId,
    String employeeId, {
    DateTime? soldFrom,
    DateTime? soldTo,
    int? reportYear,
    int? reportMonth,
    int limit = 100,
  }) async {
    if (employeeId.isEmpty) {
      throw ArgumentError.value(
        employeeId,
        'employeeId',
        'Employee ID is required.',
      );
    }

    final snapshot = await _salesQuery(
      salonId,
      employeeId: employeeId,
      reportYear: reportYear,
      reportMonth: reportMonth,
      soldFrom: soldFrom,
      soldTo: soldTo,
      limit: limit,
      startAfter: null,
    ).get();

    return snapshot.docs.map((doc) => Sale.fromJson(doc.data())).toList();
  }

  /// Sales whose [Sale.soldAt] falls on the same local calendar day as [day].
  Future<List<Sale>> getDailySales(
    String salonId,
    DateTime day, {
    int limit = 500,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    return getSalesBySalon(salonId, soldFrom: start, soldTo: end, limit: limit);
  }

  Future<void> updateSale(String salonId, Sale sale) {
    return _sales(salonId)
        .doc(sale.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(sale.toJson()),
          SetOptions(merge: true),
        );
  }

  /// Paged sales (newest [Sale.soldAt] first). Use [getSalesNextPage] with
  /// [FirestorePage.lastDocument] for more.
  Future<FirestorePage<Sale>> getSalesPage(
    String salonId, {
    String? employeeId,
    int? reportYear,
    int? reportMonth,
    DateTime? soldFrom,
    DateTime? soldTo,
    int limit = 40,
    DocumentSnapshot? startAfter,
  }) async {
    final snapshot = await _salesQuery(
      salonId,
      employeeId: employeeId,
      reportYear: reportYear,
      reportMonth: reportMonth,
      soldFrom: soldFrom,
      soldTo: soldTo,
      limit: limit,
      startAfter: startAfter,
    ).get();
    final docs = snapshot.docs;
    return FirestorePage(
      items: docs.map((d) => Sale.fromJson(d.data())).toList(),
      limit: limit,
      lastDocument: docs.isEmpty ? null : docs.last,
    );
  }

  /// Next page after [previous]; returns an empty page if [!previous.hasMore].
  Future<FirestorePage<Sale>> getSalesNextPage(
    String salonId,
    FirestorePage<Sale> previous, {
    String? employeeId,
    int? reportYear,
    int? reportMonth,
    DateTime? soldFrom,
    DateTime? soldTo,
  }) {
    if (!previous.hasMore || previous.lastDocument == null) {
      return Future.value(
        FirestorePage(
          items: const [],
          limit: previous.limit,
          lastDocument: null,
        ),
      );
    }
    return getSalesPage(
      salonId,
      employeeId: employeeId,
      reportYear: reportYear,
      reportMonth: reportMonth,
      soldFrom: soldFrom,
      soldTo: soldTo,
      limit: previous.limit,
      startAfter: previous.lastDocument,
    );
  }

  Future<Sale?> getSale(String salonId, String saleId) async {
    final snapshot = await _sales(salonId).doc(saleId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }

    return Sale.fromJson(data);
  }

  Stream<List<Sale>> watchSales(
    String salonId, {
    String? employeeId,
    int? reportYear,
    int? reportMonth,
    DateTime? soldFrom,
    DateTime? soldTo,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _salesQuery(
      salonId,
      employeeId: employeeId,
      reportYear: reportYear,
      reportMonth: reportMonth,
      soldFrom: soldFrom,
      soldTo: soldTo,
      limit: limit,
      startAfter: null,
    );

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Sale.fromJson(doc.data())).toList(),
    );
  }

  Query<Map<String, dynamic>> _salesQuery(
    String salonId, {
    String? employeeId,
    int? reportYear,
    int? reportMonth,
    DateTime? soldFrom,
    DateTime? soldTo,
    required int limit,
    DocumentSnapshot? startAfter,
  }) {
    Query<Map<String, dynamic>> query = _sales(salonId);

    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }

    if (reportYear != null && reportMonth != null) {
      query = query
          .where('reportYear', isEqualTo: reportYear)
          .where('reportMonth', isEqualTo: reportMonth);
    }

    if (soldFrom != null) {
      query = query.where('soldAt', isGreaterThanOrEqualTo: soldFrom);
    }

    if (soldTo != null) {
      query = query.where('soldAt', isLessThanOrEqualTo: soldTo);
    }

    query = query.orderBy('soldAt', descending: true);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.limit(limit);
  }

  /// Completed sales for one employee in `[startDate, endDate)` (end exclusive),
  /// ordered by [Sale.soldAt] descending. Requires a Firestore composite index on
  /// `employeeId`, `status`, `soldAt`.
  Stream<List<Sale>> watchEmployeeCompletedSalesByDateRange({
    required String salonId,
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 400,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    final eid = employeeId.trim();
    if (eid.isEmpty) {
      return Stream.value(const <Sale>[]);
    }
    if (!endDate.isAfter(startDate)) {
      return Stream.value(const <Sale>[]);
    }
    final query = _sales(salonId)
        .where('employeeId', isEqualTo: eid)
        .where('status', isEqualTo: SaleStatuses.completed)
        .where('soldAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('soldAt', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('soldAt', descending: true)
        .limit(limit);

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((d) => Sale.fromJson(d.data())).toList(),
    );
  }

  /// Same filter as [watchEmployeeCompletedSalesByDateRange] for one-off loads
  /// (e.g. model prompts).
  Future<List<Sale>> getEmployeeCompletedSalesForAnalysis({
    required String salonId,
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 400,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final eid = employeeId.trim();
    if (eid.isEmpty) {
      return const <Sale>[];
    }
    if (!endDate.isAfter(startDate)) {
      return const <Sale>[];
    }
    final snapshot = await _sales(salonId)
        .where('employeeId', isEqualTo: eid)
        .where('status', isEqualTo: SaleStatuses.completed)
        .where('soldAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('soldAt', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('soldAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => Sale.fromJson(d.data())).toList();
  }
}
