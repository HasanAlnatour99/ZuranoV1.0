import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/booking/booking_callable_domain_exceptions.dart';
import '../../../core/booking/booking_slot_exception.dart';
import '../../../core/booking/booking_slots.dart';
import '../../../core/constants/booking_status_machine.dart';
import '../../../core/constants/booking_statuses.dart';
import '../../../core/firebase/cloud_functions_region.dart';
import '../../../core/firestore/firestore_page.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_serializers.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/firestore/report_period.dart';
import '../../../core/text/team_member_name.dart';
import 'booking_time_overlap_exception.dart';
import 'models/booking.dart';

/// `salons/{salonId}/bookings/{bookingId}` — reads/writes.
///
/// [createBooking] writes directly to Firestore (requires Firebase Auth).
/// [rescheduleBooking] and [cancelBooking] use HTTPS callables for overlap
/// checks and audit fields on the server.
class BookingRepository {
  BookingRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const Set<String> _validStatuses = {
    BookingStatuses.pending,
    BookingStatuses.confirmed,
    BookingStatuses.completed,
    BookingStatuses.cancelled,
    BookingStatuses.noShow,
    BookingStatuses.rescheduled,
    // Legacy Firestore value; normalized by [BookingStatusMachine.normalize].
    'scheduled',
  };

  CollectionReference<Map<String, dynamic>> _bookings(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonBookings(salonId));
  }

  static String _dayKeyFromUtc(DateTime dateTime) {
    final utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DocumentReference<Map<String, dynamic>> _customerDoc(String customerId) {
    return _firestore.doc(FirestorePaths.customer(customerId));
  }

  DocumentReference<Map<String, dynamic>> _barberDayLockDoc(
    String salonId,
    String barberId,
    String dayKey,
  ) {
    return _firestore.doc(
      '${FirestorePaths.salon(salonId)}/booking_locks/${barberId}_$dayKey',
    );
  }

  DocumentReference<Map<String, dynamic>> _bookingDoc(
    String salonId,
    String bookingId,
  ) {
    return _bookings(salonId).doc(bookingId);
  }

  /// Creates a booking document under `salons/{salonId}/bookings`.
  ///
  /// Writes core fields plus denormalized report fields for existing queries.
  /// Persists [status] as
  /// [BookingStatuses.confirmed]. [slotStepMinutes] must be `15` or `30`
  /// (UTC grid validation). Overlap is validated in-repository before commit.
  /// Also updates customer `lastBookingAt` transactionally.
  /// Throws [BookingSlotException] for grid violations.
  Future<String> createBooking(
    String salonId,
    Booking booking, {
    required int slotStepMinutes,
    Map<String, dynamic> extraPayload = const <String, dynamic>{},
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    BookingSlots.assertUtcSlotRange(
      booking.startAt,
      booking.endAt,
      slotStepMinutes,
    );
    if (booking.barberId.trim().isEmpty) {
      throw ArgumentError.value(
        booking.barberId,
        'booking.barberId',
        'Barber ID is required.',
      );
    }
    if (booking.customerId.trim().isEmpty) {
      throw ArgumentError.value(
        booking.customerId,
        'booking.customerId',
        'Customer ID is required.',
      );
    }
    final serviceId = booking.serviceId?.trim() ?? '';
    if (serviceId.isEmpty) {
      throw ArgumentError.value(
        booking.serviceId,
        'booking.serviceId',
        'Service ID is required.',
      );
    }
    final docRef = _bookings(salonId).doc();
    final customerRef = _customerDoc(booking.customerId);
    final startAtUtc = booking.startAt.isUtc
        ? booking.startAt
        : booking.startAt.toUtc();
    final endAtUtc = booking.endAt.isUtc
        ? booking.endAt
        : booking.endAt.toUtc();
    final report = ReportPeriod.denormalizedFieldsFor(booking.startAt);
    final dayKey = _dayKeyFromUtc(startAtUtc);
    final lockRef = _barberDayLockDoc(salonId, booking.barberId, dayKey);
    final barberNameRaw = booking.barberName?.trim() ?? '';
    final barberName = formatTeamMemberName(barberNameRaw);
    final serviceName = booking.serviceName?.trim() ?? '';
    final notes = booking.notes?.trim() ?? '';
    final data = <String, dynamic>{
      'id': docRef.id,
      'salonId': salonId,
      'barberId': booking.barberId,
      'customerId': booking.customerId,
      'customerName': booking.customerName?.trim() ?? '',
      'serviceId': serviceId,
      'startAt': Timestamp.fromDate(startAtUtc),
      'endAt': Timestamp.fromDate(endAtUtc),
      'dayKey': dayKey,
      'status': BookingStatuses.confirmed,
      'createdAt': FieldValue.serverTimestamp(),
      ...report,
    };
    if (barberName.isNotEmpty) {
      data['barberName'] = barberName;
    }
    if (serviceName.isNotEmpty) {
      data['serviceName'] = serviceName;
    }
    if (notes.isNotEmpty) {
      data['notes'] = notes;
    }
    if (extraPayload.isNotEmpty) {
      data.addAll(extraPayload);
    }

    await _firestore.runTransaction((tx) async {
      final lockSnap = await tx.get(lockRef);
      final lockData = lockSnap.data() ?? <String, dynamic>{};
      final activeIds = ((lockData['activeBookingIds'] as List?) ?? const [])
          .whereType<String>()
          .toSet();

      for (final id in activeIds) {
        final activeSnap = await tx.get(_bookingDoc(salonId, id));
        final activeData = activeSnap.data();
        if (!activeSnap.exists || activeData == null) {
          continue;
        }
        final status = BookingStatusMachine.normalize(
          FirestoreSerializers.string(activeData['status']),
        );
        if (status == BookingStatuses.cancelled ||
            status == BookingStatuses.noShow) {
          continue;
        }
        final existingStart = FirestoreSerializers.dateTime(
          activeData['startAt'],
        );
        final existingEnd = FirestoreSerializers.dateTime(activeData['endAt']);
        if (existingStart == null || existingEnd == null) {
          continue;
        }
        if (existingStart.isBefore(endAtUtc) &&
            existingEnd.isAfter(startAtUtc)) {
          throw const BookingTimeOverlapException();
        }
      }

      final overlapQuery = _bookings(salonId)
          .where('dayKey', isEqualTo: dayKey)
          .where('barberId', isEqualTo: booking.barberId)
          .where('startAt', isLessThan: Timestamp.fromDate(endAtUtc))
          .orderBy('startAt')
          .limit(80);
      final overlapSnap = await overlapQuery.get();
      for (final candidate in overlapSnap.docs) {
        final candidateData = candidate.data();
        final candidateEnd = FirestoreSerializers.dateTime(
          candidateData['endAt'],
        );
        if (candidateEnd == null || !candidateEnd.isAfter(startAtUtc)) {
          continue;
        }
        final status = BookingStatusMachine.normalize(
          FirestoreSerializers.string(candidateData['status']),
        );
        if (status == BookingStatuses.cancelled ||
            status == BookingStatuses.noShow) {
          continue;
        }
        throw const BookingTimeOverlapException();
      }

      tx.set(docRef, data);
      tx.set(lockRef, {
        'barberId': booking.barberId,
        'dayKey': dayKey,
        'activeBookingIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      tx.set(customerRef, {
        'lastBookingAt': Timestamp.fromDate(startAtUtc),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
    return docRef.id;
  }

  /// One-shot list of bookings for a salon, newest [startAt] first.
  Future<List<Booking>> getBookingsBySalon(
    String salonId, {
    int limit = 100,
  }) async {
    final snapshot = await _bookingsQuery(
      salonId,
      limit: limit,
      startAfter: null,
    ).get();
    return snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
  }

  /// Paged bookings (newest [Booking.startAt] first). Reuses the same scope
  /// rules as [watchBookingsBySalon]. Use [getBookingsNextPage] for more.
  Future<FirestorePage<Booking>> getBookingsPage(
    String salonId, {
    int limit = 40,
    String? barberId,
    String? customerId,
    String? status,
    int? reportYear,
    int? reportMonth,
    DateTime? startFrom,
    DateTime? startTo,
    DocumentSnapshot? startAfter,
  }) async {
    final snapshot = await _bookingsQuery(
      salonId,
      barberId: barberId,
      customerId: customerId,
      status: status,
      reportYear: reportYear,
      reportMonth: reportMonth,
      startFrom: startFrom,
      startTo: startTo,
      limit: limit,
      startAfter: startAfter,
    ).get();
    final docs = snapshot.docs;
    return FirestorePage(
      items: docs.map((d) => Booking.fromJson(d.data())).toList(),
      limit: limit,
      lastDocument: docs.isEmpty ? null : docs.last,
    );
  }

  /// Next page after [previous]; returns an empty page if [!previous.hasMore].
  Future<FirestorePage<Booking>> getBookingsNextPage(
    String salonId,
    FirestorePage<Booking> previous, {
    String? barberId,
    String? customerId,
    String? status,
    int? reportYear,
    int? reportMonth,
    DateTime? startFrom,
    DateTime? startTo,
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
    return getBookingsPage(
      salonId,
      limit: previous.limit,
      barberId: barberId,
      customerId: customerId,
      status: status,
      reportYear: reportYear,
      reportMonth: reportMonth,
      startFrom: startFrom,
      startTo: startTo,
      startAfter: previous.lastDocument,
    );
  }

  /// Live stream of salon bookings for real-time UI (newest [startAt] first).
  ///
  /// Use at most one scope filter: [barberId], [customerId], [status], or
  /// both [reportYear] and [reportMonth]. Optional [startFrom] / [startTo]
  /// apply to `startAt` and may be combined with a single scope filter.
  /// Required composite indexes are listed in `firestore.indexes.json`.
  Stream<List<Booking>> watchBookingsBySalon(
    String salonId, {
    int limit = 100,
    String? barberId,
    String? customerId,
    String? status,
    int? reportYear,
    int? reportMonth,
    DateTime? startFrom,
    DateTime? startTo,
  }) {
    return _bookingsQuery(
      salonId,
      barberId: barberId,
      customerId: customerId,
      status: status,
      reportYear: reportYear,
      reportMonth: reportMonth,
      startFrom: startFrom,
      startTo: startTo,
      limit: limit,
      startAfter: null,
    ).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList(),
    );
  }

  /// Merges editable booking fields and bumps [updatedAt].
  ///
  /// Does not overwrite [createdAt]. Status changes must satisfy
  /// [BookingStatusMachine] rules (reads current document first).
  Future<void> updateBooking(String salonId, Booking booking) async {
    if (booking.id.isEmpty) {
      throw ArgumentError.value(
        booking.id,
        'booking.id',
        'Booking ID is required.',
      );
    }
    final nextStatus = BookingStatusMachine.normalize(booking.status);
    if (!BookingStatusMachine.isKnownStatus(nextStatus)) {
      throw ArgumentError.value(
        booking.status,
        'status',
        'Must be a known booking status.',
      );
    }
    if (nextStatus == BookingStatuses.completed ||
        nextStatus == BookingStatuses.noShow) {
      throw ArgumentError(
        'Completing or no-show bookings must use Cloud Functions '
        '(completeService / markNoShow).',
      );
    }

    final ref = _bookings(salonId).doc(booking.id);
    final snap = await ref.get();
    if (!snap.exists) {
      throw StateError('Booking not found.');
    }
    final currentStatus = BookingStatusMachine.normalize(
      snap.data()?['status'] as String?,
    );
    _assertMutableStatus(currentStatus);
    BookingStatusMachine.assertTransition(currentStatus, nextStatus);
    if (nextStatus == BookingStatuses.cancelled) {
      return cancelBooking(salonId: salonId, bookingId: booking.id);
    }

    final data = Map<String, dynamic>.from(booking.toJson());
    data.remove('createdAt');
    data.remove('updatedAt');
    data['status'] = nextStatus;
    final bn = data['barberName'];
    if (bn is String && bn.trim().isNotEmpty) {
      data['barberName'] = formatTeamMemberName(bn);
    }

    return _bookings(salonId)
        .doc(booking.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(data),
          SetOptions(merge: true),
        );
  }

  /// Reschedules via [bookingReschedule] (transactional overlap validation).
  ///
  /// [slotStepMinutes] must be `15` or `30` and match the UTC grid for the new range.
  Future<void> rescheduleBooking({
    required String salonId,
    required String bookingId,
    required DateTime startAt,
    required DateTime endAt,
    required int slotStepMinutes,
  }) async {
    if (bookingId.isEmpty) {
      throw ArgumentError.value(
        bookingId,
        'bookingId',
        'Booking ID is required.',
      );
    }
    FirestoreWritePayload.assertSalonId(salonId);
    await _assertBookingMutableById(salonId, bookingId);
    BookingSlots.assertUtcSlotRange(startAt, endAt, slotStepMinutes);

    try {
      final callable = appCloudFunctions().httpsCallable('bookingReschedule');
      await callable.call({
        'salonId': salonId,
        'bookingId': bookingId,
        'startAtMs': startAt.millisecondsSinceEpoch,
        'endAtMs': endAt.millisecondsSinceEpoch,
        'slotStepMinutes': slotStepMinutes,
      });
    } on FirebaseFunctionsException catch (e) {
      throw _mapBookingCallableException(e);
    }
  }

  /// Cancels via [bookingCancel] (audit: `cancelledAt`, `cancelledByRole`,
  /// `cancelledByUserId`).
  Future<void> markBookingArrived({
    required String salonId,
    required String bookingId,
  }) async {
    try {
      final callable = appCloudFunctions().httpsCallable('bookingMarkArrived');
      await callable.call({'salonId': salonId, 'bookingId': bookingId});
    } on FirebaseFunctionsException catch (e) {
      throw _mapBookingCallableException(e);
    }
  }

  Future<void> startBookingService({
    required String salonId,
    required String bookingId,
  }) async {
    try {
      final callable = appCloudFunctions().httpsCallable('bookingStartService');
      await callable.call({'salonId': salonId, 'bookingId': bookingId});
    } on FirebaseFunctionsException catch (e) {
      throw _mapBookingCallableException(e);
    }
  }

  Future<void> completeBookingService({
    required String salonId,
    required String bookingId,
  }) async {
    if (bookingId.isEmpty) {
      throw ArgumentError.value(
        bookingId,
        'bookingId',
        'Booking ID is required.',
      );
    }
    FirestoreWritePayload.assertSalonId(salonId);
    final bookingRef = _bookings(salonId).doc(bookingId);

    await _firestore.runTransaction((tx) async {
      final bookingSnap = await tx.get(bookingRef);
      final bookingData = bookingSnap.data();
      if (!bookingSnap.exists || bookingData == null) {
        throw StateError('Booking not found.');
      }
      final currentStatus = BookingStatusMachine.normalize(
        FirestoreSerializers.string(bookingData['status']),
      );
      if (currentStatus == BookingStatuses.completed) {
        return;
      }
      _assertMutableStatus(currentStatus);

      final customerId = (bookingData['customerId'] as String? ?? '').trim();
      if (customerId.isEmpty) {
        throw StateError('Booking has no customer to update.');
      }
      final customerRef = _customerDoc(customerId);
      final customerSnap = await tx.get(customerRef);
      final customerData = customerSnap.data() ?? <String, dynamic>{};

      final currentVisits = FirestoreSerializers.intValue(
        customerData['visitCount'],
      );
      final currentTotalSpent = FirestoreSerializers.doubleValue(
        customerData['totalSpent'],
      );
      final bookingTotal = FirestoreSerializers.doubleValue(
        bookingData['totalPrice'],
      );
      final dayKey = (bookingData['dayKey'] as String? ?? '').trim();
      final barberId = (bookingData['barberId'] as String? ?? '').trim();
      final lockRef = (dayKey.isNotEmpty && barberId.isNotEmpty)
          ? _barberDayLockDoc(salonId, barberId, dayKey)
          : null;

      final now = FieldValue.serverTimestamp();
      tx.set(bookingRef, {
        'status': BookingStatuses.completed,
        'serviceCompletedAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
      tx.set(customerRef, {
        'visitCount': currentVisits + 1,
        'totalSpent': currentTotalSpent + bookingTotal,
        'lastVisitAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
      if (lockRef != null) {
        tx.set(lockRef, {
          'activeBookingIds': FieldValue.arrayRemove([bookingId]),
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    });
  }

  /// [party] is `customer` or `barber`.
  Future<void> markBookingNoShow({
    required String salonId,
    required String bookingId,
    required String party,
  }) async {
    try {
      final callable = appCloudFunctions().httpsCallable('bookingMarkNoShow');
      await callable.call({
        'salonId': salonId,
        'bookingId': bookingId,
        'party': party.toLowerCase(),
      });
    } on FirebaseFunctionsException catch (e) {
      throw _mapBookingCallableException(e);
    }
  }

  Future<void> cancelBooking({
    required String salonId,
    required String bookingId,
  }) async {
    if (bookingId.isEmpty) {
      throw ArgumentError.value(
        bookingId,
        'bookingId',
        'Booking ID is required.',
      );
    }
    FirestoreWritePayload.assertSalonId(salonId);
    await _assertBookingMutableById(salonId, bookingId);
    try {
      final callable = appCloudFunctions().httpsCallable('bookingCancel');
      await callable.call({'salonId': salonId, 'bookingId': bookingId});
    } on FirebaseFunctionsException catch (e) {
      throw _mapBookingCallableException(e);
    }
  }

  /// Merges [status] and bumps [updatedAt].
  ///
  /// Enforces [BookingStatusMachine] transitions against the stored document.
  Future<void> updateBookingStatus({
    required String salonId,
    required String bookingId,
    required String status,
  }) async {
    if (bookingId.isEmpty) {
      throw ArgumentError.value(
        bookingId,
        'bookingId',
        'Booking ID is required.',
      );
    }
    final nextStatus = BookingStatusMachine.normalize(status);
    if (!BookingStatusMachine.isKnownStatus(nextStatus)) {
      throw ArgumentError.value(
        status,
        'status',
        'Must be a known booking status.',
      );
    }
    if (nextStatus == BookingStatuses.cancelled) {
      return cancelBooking(salonId: salonId, bookingId: bookingId);
    }
    if (nextStatus == BookingStatuses.completed ||
        nextStatus == BookingStatuses.noShow) {
      throw ArgumentError(
        'Completing or no-show bookings must use Cloud Functions.',
      );
    }

    final ref = _bookings(salonId).doc(bookingId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw StateError('Booking not found.');
    }
    final currentStatus = BookingStatusMachine.normalize(
      snap.data()?['status'] as String?,
    );
    _assertMutableStatus(currentStatus);
    BookingStatusMachine.assertTransition(currentStatus, nextStatus);

    return _bookings(salonId)
        .doc(bookingId)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate({
            'status': nextStatus,
          }),
          SetOptions(merge: true),
        );
  }

  Never _mapBookingCallableException(FirebaseFunctionsException e) {
    final raw = e.message ?? '';
    final msg = raw.toLowerCase();
    if (e.code == 'failed-precondition' && msg.contains('overlap')) {
      throw const BookingTimeOverlapException();
    }
    if (e.code == 'failed-precondition' && msg.contains('already ended')) {
      throw BookingAlreadyEndedException(raw);
    }
    if (e.code == 'failed-precondition' && msg.contains('already cancelled')) {
      throw BookingAlreadyCancelledException(raw);
    }
    if (e.code == 'failed-precondition' &&
        msg.contains('already rescheduled')) {
      throw BookingAlreadyRescheduledException(raw);
    }
    if (e.code == 'failed-precondition' && msg.contains('state changed')) {
      throw BookingStaleStateException(raw);
    }
    if (e.code == 'invalid-argument' ||
        (e.code == 'failed-precondition' &&
            (msg.contains('slot') || msg.contains('status')))) {
      throw BookingSlotException(e.message ?? 'Invalid booking request.');
    }
    if (e.code == 'not-found') {
      throw StateError('Booking not found.');
    }
    if (e.code == 'permission-denied') {
      if (msg.contains('unauthorized role')) {
        throw BookingUnauthorizedRoleException(raw);
      }
      throw StateError(e.message ?? 'Permission denied.');
    }
    throw e;
  }

  Query<Map<String, dynamic>> _bookingsQuery(
    String salonId, {
    String? barberId,
    String? customerId,
    String? status,
    int? reportYear,
    int? reportMonth,
    DateTime? startFrom,
    DateTime? startTo,
    required int limit,
    DocumentSnapshot? startAfter,
  }) {
    _assertAtMostOneBookingScopeFilter(
      barberId: barberId,
      customerId: customerId,
      status: status,
      reportYear: reportYear,
      reportMonth: reportMonth,
    );

    Query<Map<String, dynamic>> query = _bookings(salonId);

    if (barberId != null && barberId.isNotEmpty) {
      query = query.where('barberId', isEqualTo: barberId);
    }

    if (customerId != null && customerId.isNotEmpty) {
      query = query.where('customerId', isEqualTo: customerId);
    }

    if (status != null && status.isNotEmpty) {
      if (!_validStatuses.contains(status)) {
        throw ArgumentError.value(
          status,
          'status',
          'Must be one of BookingStatuses.',
        );
      }
      query = query.where('status', isEqualTo: status);
    }

    if (reportYear != null && reportMonth != null) {
      query = query
          .where('reportYear', isEqualTo: reportYear)
          .where('reportMonth', isEqualTo: reportMonth);
    }

    if (startFrom != null) {
      query = query.where('startAt', isGreaterThanOrEqualTo: startFrom);
    }

    if (startTo != null) {
      query = query.where('startAt', isLessThanOrEqualTo: startTo);
    }

    // Stable pagination: tie-break equal [startAt] with document id (requires
    // composite indexes including __name__ in firestore.indexes.json). When
    // using [startFrom]/[startTo] range filters, deploy matching indexes
    // (equality scope + startAt bounds + __name__) if the console prompts.
    query = query
        .orderBy('startAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.limit(limit);
  }

  /// Firestore composite indexes support one equality "scope" at a time
  /// (barber, customer, status, or calendar month) plus optional `startAt` bounds.
  static void _assertAtMostOneBookingScopeFilter({
    String? barberId,
    String? customerId,
    String? status,
    int? reportYear,
    int? reportMonth,
  }) {
    var scopeCount = 0;
    if (barberId != null && barberId.isNotEmpty) {
      scopeCount++;
    }
    if (customerId != null && customerId.isNotEmpty) {
      scopeCount++;
    }
    if (status != null && status.isNotEmpty) {
      scopeCount++;
    }
    if (reportYear != null || reportMonth != null) {
      if (reportYear == null || reportMonth == null) {
        throw ArgumentError(
          'reportYear and reportMonth must both be set for monthly filtering.',
        );
      }
      scopeCount++;
    }

    if (scopeCount > 1) {
      throw ArgumentError(
        'Use at most one of: barberId, customerId, status, or reportYear+reportMonth.',
      );
    }
  }

  Stream<Booking?> watchBooking(String salonId, String bookingId) {
    FirestoreWritePayload.assertSalonId(salonId);
    if (bookingId.isEmpty) {
      return Stream.value(null);
    }
    return _bookings(salonId).doc(bookingId).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) {
        return null;
      }
      return Booking.fromJson(data);
    });
  }

  /// Paged customer bookings (`collectionGroup('bookings')`), newest first.
  Future<FirestorePage<Booking>> getCustomerBookingsPage(
    String customerId, {
    int limit = 30,
    DocumentSnapshot? startAfter,
  }) async {
    if (customerId.isEmpty) {
      return FirestorePage(items: const [], limit: limit, lastDocument: null);
    }
    Query<Map<String, dynamic>> query = _firestore
        .collectionGroup('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('startAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.limit(limit).get();
    final docs = snapshot.docs;
    return FirestorePage(
      items: docs.map((d) => Booking.fromJson(d.data())).toList(),
      limit: limit,
      lastDocument: docs.isEmpty ? null : docs.last,
    );
  }

  /// Next page for [getCustomerBookingsPage].
  Future<FirestorePage<Booking>> getCustomerBookingsNextPage(
    String customerId,
    FirestorePage<Booking> previous,
  ) {
    if (!previous.hasMore || previous.lastDocument == null) {
      return Future.value(
        FirestorePage(
          items: const [],
          limit: previous.limit,
          lastDocument: null,
        ),
      );
    }
    return getCustomerBookingsPage(
      customerId,
      limit: previous.limit,
      startAfter: previous.lastDocument,
    );
  }

  /// Busy intervals for a salon day (UTC bounds), without customer PII.
  /// Uses the [bookingDayBusyMask] callable (overlap-safe for [CustomerSlotPlanner]).
  Future<List<Booking>> fetchDayBusyMask({
    required String salonId,
    required DateTime startFromUtc,
    required DateTime startToUtc,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    try {
      final callable = appCloudFunctions().httpsCallable('bookingDayBusyMask');
      final result = await callable.call({
        'salonId': salonId,
        'startFromMs': startFromUtc.millisecondsSinceEpoch,
        'startToMs': startToUtc.millisecondsSinceEpoch,
      });
      final raw = result.data;
      if (raw is! Map) {
        return const [];
      }
      final data = Map<String, dynamic>.from(raw);
      final intervals = data['intervals'];
      if (intervals is! List) {
        return const [];
      }
      final out = <Booking>[];
      for (final item in intervals) {
        if (item is! Map) {
          continue;
        }
        final m = Map<String, dynamic>.from(item);
        final barberId = m['barberId']?.toString() ?? '';
        if (barberId.isEmpty) {
          continue;
        }
        final startMs = _parseMs(m['startAtMs']);
        final endMs = _parseMs(m['endAtMs']);
        final status = BookingStatusMachine.normalize(m['status']?.toString());
        out.add(
          Booking.forAvailabilityOverlap(
            salonId: salonId,
            barberId: barberId,
            startAt: DateTime.fromMillisecondsSinceEpoch(startMs, isUtc: true),
            endAt: DateTime.fromMillisecondsSinceEpoch(endMs, isUtc: true),
            status: status,
          ),
        );
      }
      return out;
    } on FirebaseFunctionsException catch (e) {
      throw StateError(e.message ?? 'bookingDayBusyMask failed.');
    }
  }

  static int _parseMs(Object? v) {
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Future<void> _assertBookingMutableById(
    String salonId,
    String bookingId,
  ) async {
    final ref = _bookings(salonId).doc(bookingId);
    final snap = await ref.get();
    final data = snap.data();
    if (!snap.exists || data == null) {
      throw StateError('Booking not found.');
    }
    final status = BookingStatusMachine.normalize(
      FirestoreSerializers.string(data['status']),
    );
    _assertMutableStatus(status);
  }

  void _assertMutableStatus(String status) {
    if (status == BookingStatuses.completed ||
        status == BookingStatuses.cancelled) {
      throw StateError('Completed or cancelled bookings cannot be modified.');
    }
  }

  /// Customer's bookings across all salons (`collectionGroup('bookings')`).
  Stream<List<Booking>> watchBookingsForCustomer(
    String customerId, {
    int limit = 80,
  }) {
    if (customerId.isEmpty) {
      return Stream.value(const <Booking>[]);
    }
    return _firestore
        .collectionGroup('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('startAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList(),
        );
  }

  /// Returns true when no overlapping booking exists for the barber.
  Future<bool> checkBarberAvailability({
    required String salonId,
    required String barberId,
    required DateTime startAt,
    required DateTime endAt,
    String? excludeBookingId,
  }) async {
    final snapshot = await _bookings(salonId)
        .where('barberId', isEqualTo: barberId)
        .where('startAt', isLessThan: endAt)
        .orderBy('startAt')
        .limit(80)
        .get();

    for (final doc in snapshot.docs) {
      if (excludeBookingId != null && doc.id == excludeBookingId) {
        continue;
      }
      final data = doc.data();
      final existingEnd = FirestoreSerializers.dateTime(data['endAt']);
      if (existingEnd == null) {
        continue;
      }
      final overlaps = existingEnd.isAfter(startAt);
      if (!overlaps) {
        continue;
      }
      final status = BookingStatusMachine.normalize(
        FirestoreSerializers.string(data['status']),
      );
      if (status == BookingStatuses.cancelled ||
          status == BookingStatuses.noShow) {
        continue;
      }
      return false;
    }
    return true;
  }
}
