// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: looseStringFromJson(json['id']),
  salonId: looseStringFromJson(json['salonId']),
  barberId: looseStringFromJson(json['barberId']),
  customerId: looseStringFromJson(json['customerId']),
  startAt: firestoreDateTimeFromJson(json['startAt']),
  endAt: firestoreDateTimeFromJson(json['endAt']),
  status: _statusFromJson(json['status']),
  barberName: nullableLooseStringFromJson(json['barberName']),
  customerName: nullableLooseStringFromJson(json['customerName']),
  serviceId: nullableLooseStringFromJson(json['serviceId']),
  serviceName: nullableLooseStringFromJson(json['serviceName']),
  serviceNames: json['serviceNames'] == null
      ? const <String>[]
      : stringListFromJson(json['serviceNames']),
  bookingCode: nullableLooseStringFromJson(json['bookingCode']),
  totalAmount: json['totalAmount'] == null
      ? 0
      : looseDoubleFromJson(json['totalAmount']),
  paymentStatus: nullableLooseStringFromJson(json['paymentStatus']),
  paymentMethod: nullableLooseStringFromJson(json['paymentMethod']),
  paidAmount: json['paidAmount'] == null
      ? 0
      : looseDoubleFromJson(json['paidAmount']),
  balanceAmount: json['balanceAmount'] == null
      ? 0
      : looseDoubleFromJson(json['balanceAmount']),
  notes: nullableLooseStringFromJson(json['notes']),
  reportYear: json['reportYear'] == null
      ? 0
      : looseIntFromJson(json['reportYear']),
  reportMonth: json['reportMonth'] == null
      ? 0
      : looseIntFromJson(json['reportMonth']),
  slotStepMinutes: _slotStepFromJson(json['slotStepMinutes']),
  createdAt: nullableFirestoreDateTimeFromJson(json['createdAt']),
  updatedAt: nullableFirestoreDateTimeFromJson(json['updatedAt']),
  cancelledAt: nullableFirestoreDateTimeFromJson(json['cancelledAt']),
  cancelledByRole: nullableLooseStringFromJson(json['cancelledByRole']),
  cancelledByUserId: nullableLooseStringFromJson(json['cancelledByUserId']),
  rescheduledFromBookingId: nullableLooseStringFromJson(
    json['rescheduledFromBookingId'],
  ),
  rescheduledToBookingId: nullableLooseStringFromJson(
    json['rescheduledToBookingId'],
  ),
  operationalState: json['operationalState'] == null
      ? BookingOperationalStates.waiting
      : _operationalStateFromJson(json['operationalState']),
  customerArrivedAt: nullableFirestoreDateTimeFromJson(
    json['customerArrivedAt'],
  ),
  serviceStartedAt: nullableFirestoreDateTimeFromJson(json['serviceStartedAt']),
  serviceCompletedAt: nullableFirestoreDateTimeFromJson(
    json['serviceCompletedAt'],
  ),
  noShowMarkedAt: nullableFirestoreDateTimeFromJson(json['noShowMarkedAt']),
  noShowParty: nullableLooseStringFromJson(json['noShowParty']),
  operationalMarkedByUid: nullableLooseStringFromJson(
    json['operationalMarkedByUid'],
  ),
  operationalMarkedByRole: nullableLooseStringFromJson(
    json['operationalMarkedByRole'],
  ),
  feedbackSubmitted: json['feedbackSubmitted'] as bool? ?? false,
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'salonId': instance.salonId,
  'barberId': instance.barberId,
  'customerId': instance.customerId,
  'startAt': firestoreDateTimeToJson(instance.startAt),
  'endAt': firestoreDateTimeToJson(instance.endAt),
  'status': instance.status,
  'barberName': instance.barberName,
  'customerName': instance.customerName,
  'serviceId': instance.serviceId,
  'serviceName': instance.serviceName,
  'serviceNames': instance.serviceNames,
  'bookingCode': instance.bookingCode,
  'totalAmount': instance.totalAmount,
  'paymentStatus': instance.paymentStatus,
  'paymentMethod': instance.paymentMethod,
  'paidAmount': instance.paidAmount,
  'balanceAmount': instance.balanceAmount,
  'notes': instance.notes,
  'reportYear': instance.reportYear,
  'reportMonth': instance.reportMonth,
  'slotStepMinutes': instance.slotStepMinutes,
  'createdAt': nullableFirestoreDateTimeToJson(instance.createdAt),
  'updatedAt': nullableFirestoreDateTimeToJson(instance.updatedAt),
  'cancelledAt': nullableFirestoreDateTimeToJson(instance.cancelledAt),
  'cancelledByRole': instance.cancelledByRole,
  'cancelledByUserId': instance.cancelledByUserId,
  'rescheduledFromBookingId': instance.rescheduledFromBookingId,
  'rescheduledToBookingId': instance.rescheduledToBookingId,
  'operationalState': instance.operationalState,
  'customerArrivedAt': nullableFirestoreDateTimeToJson(
    instance.customerArrivedAt,
  ),
  'serviceStartedAt': nullableFirestoreDateTimeToJson(
    instance.serviceStartedAt,
  ),
  'serviceCompletedAt': nullableFirestoreDateTimeToJson(
    instance.serviceCompletedAt,
  ),
  'noShowMarkedAt': nullableFirestoreDateTimeToJson(instance.noShowMarkedAt),
  'noShowParty': instance.noShowParty,
  'operationalMarkedByUid': instance.operationalMarkedByUid,
  'operationalMarkedByRole': instance.operationalMarkedByRole,
  'feedbackSubmitted': instance.feedbackSubmitted,
};
