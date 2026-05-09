import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/booking_operational_states.dart';
import '../../../../core/constants/booking_status_machine.dart';
import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../../../core/firestore/report_period.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const Booking._();

  const factory Booking({
    @JsonKey(fromJson: looseStringFromJson) required String id,
    @JsonKey(fromJson: looseStringFromJson) required String salonId,
    @JsonKey(fromJson: looseStringFromJson) required String barberId,
    @JsonKey(fromJson: looseStringFromJson) required String customerId,
    @JsonKey(
      fromJson: firestoreDateTimeFromJson,
      toJson: firestoreDateTimeToJson,
    )
    required DateTime startAt,
    @JsonKey(
      fromJson: firestoreDateTimeFromJson,
      toJson: firestoreDateTimeToJson,
    )
    required DateTime endAt,
    @JsonKey(fromJson: _statusFromJson) required String status,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? barberName,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? customerName,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? serviceId,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? serviceName,
    @JsonKey(fromJson: stringListFromJson) @Default(<String>[]) List<String> serviceNames,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? bookingCode,
    @JsonKey(fromJson: looseDoubleFromJson) @Default(0) double totalAmount,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? paymentStatus,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? paymentMethod,
    @JsonKey(fromJson: looseDoubleFromJson) @Default(0) double paidAmount,
    @JsonKey(fromJson: looseDoubleFromJson) @Default(0) double balanceAmount,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? notes,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int reportYear,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int reportMonth,
    @JsonKey(fromJson: _slotStepFromJson) int? slotStepMinutes,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? createdAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? updatedAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? cancelledAt,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? cancelledByRole,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? cancelledByUserId,
    @JsonKey(fromJson: nullableLooseStringFromJson)
    String? rescheduledFromBookingId,
    @JsonKey(fromJson: nullableLooseStringFromJson)
    String? rescheduledToBookingId,
    @Default(BookingOperationalStates.waiting)
    @JsonKey(fromJson: _operationalStateFromJson)
    String operationalState,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? customerArrivedAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? serviceStartedAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? serviceCompletedAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? noShowMarkedAt,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? noShowParty,
    @JsonKey(fromJson: nullableLooseStringFromJson)
    String? operationalMarkedByUid,
    @JsonKey(fromJson: nullableLooseStringFromJson)
    String? operationalMarkedByRole,
    /// Set when the customer submits post-visit feedback via [submitCustomerFeedback].
    @Default(false) @JsonKey(name: 'feedbackSubmitted') bool feedbackSubmitted,
  }) = _Booking;

  String get reportPeriodKey => ReportPeriod.periodKey(reportYear, reportMonth);

  factory Booking.forAvailabilityOverlap({
    required String salonId,
    required String barberId,
    required DateTime startAt,
    required DateTime endAt,
    required String status,
  }) {
    return Booking(
      id: '',
      salonId: salonId,
      barberId: barberId,
      customerId: '',
      startAt: startAt,
      endAt: endAt,
      status: BookingStatusMachine.normalize(status),
      serviceNames: const <String>[],
      bookingCode: null,
      totalAmount: 0,
      paymentStatus: null,
      paymentMethod: null,
      paidAmount: 0,
      balanceAmount: 0,
      reportYear: ReportPeriod.yearFrom(startAt),
      reportMonth: ReportPeriod.monthFrom(startAt),
      operationalState: BookingOperationalStates.waiting,
      feedbackSubmitted: false,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(_normalizedBookingJson(json));
}

Map<String, dynamic> _normalizedBookingJson(Map<String, dynamic> json) {
  final startAt =
      FirestoreSerializers.dateTime(json['startAt']) ??
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
      reportYear = ReportPeriod.yearFrom(startAt);
      reportMonth = ReportPeriod.monthFrom(startAt);
    }
  }

  final normalized = Map<String, dynamic>.from(json);
  normalized['startAt'] = startAt;
  normalized['endAt'] =
      FirestoreSerializers.dateTime(json['endAt']) ??
      DateTime.fromMillisecondsSinceEpoch(0);
  normalized['reportYear'] = reportYear;
  normalized['reportMonth'] = reportMonth;
  normalized['status'] = BookingStatusMachine.normalize(
    FirestoreSerializers.string(json['status']),
  );
  normalized['operationalState'] = BookingOperationalStates.normalize(
    FirestoreSerializers.string(json['operationalState']),
  );
  normalized['feedbackSubmitted'] = json['feedbackSubmitted'] == true;
  return normalized;
}

int? _slotStepFromJson(Object? raw) {
  final value = FirestoreSerializers.intValue(raw);
  if (value == 0) {
    return null;
  }
  return value;
}

String _statusFromJson(Object? value) =>
    BookingStatusMachine.normalize(nullableLooseStringFromJson(value));

String _operationalStateFromJson(Object? value) =>
    BookingOperationalStates.normalize(nullableLooseStringFromJson(value));
