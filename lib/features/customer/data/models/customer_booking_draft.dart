import 'customer_service_public_model.dart';

const _unset = Object();

class CustomerBookingDraft {
  const CustomerBookingDraft({
    required this.salonId,
    this.selectedServices = const [],
    this.selectedEmployeeId,
    this.selectedEmployeeName,
    this.anyAvailableEmployee = false,
    this.selectedStartAt,
    this.selectedEndAt,
    this.customerName,
    this.customerPhone,
    this.customerPhoneNormalized,
    this.customerGender,
    this.customerNote,
    this.guestNicknameKey,
    this.guestDisplayName,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.durationMinutes = 0,
  });

  final String salonId;
  final List<CustomerServicePublicModel> selectedServices;
  final String? selectedEmployeeId;
  final String? selectedEmployeeName;
  final bool anyAvailableEmployee;
  final DateTime? selectedStartAt;
  final DateTime? selectedEndAt;
  final String? customerName;
  final String? customerPhone;
  final String? customerPhoneNormalized;
  final String? customerGender;
  final String? customerNote;

  /// Lowercase unique key under `guestProfiles/{guestNicknameKey}`.
  final String? guestNicknameKey;

  /// Human-facing unique nickname (e.g. Hasan-ZR7421).
  final String? guestDisplayName;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final int durationMinutes;

  bool get hasServices => selectedServices.isNotEmpty;
  bool get hasTeamSelection =>
      anyAvailableEmployee ||
      (selectedEmployeeId != null && selectedEmployeeId!.trim().isNotEmpty);
  bool get hasDateTime => selectedStartAt != null && selectedEndAt != null;
  bool get hasCustomerDetails =>
      customerName != null &&
      customerName!.trim().isNotEmpty &&
      customerPhoneNormalized != null &&
      customerPhoneNormalized!.trim().isNotEmpty;

  bool get hasGuestNickname =>
      guestNicknameKey != null &&
      guestNicknameKey!.trim().isNotEmpty &&
      guestDisplayName != null &&
      guestDisplayName!.trim().isNotEmpty;
  int get serviceCount => selectedServices.length;

  List<String> serviceNamesForLanguageCode(String languageCode) =>
      selectedServices
          .map((s) => s.localizedTitleForLanguageCode(languageCode))
          .toList(growable: false);

  CustomerBookingDraft copyWith({
    String? salonId,
    List<CustomerServicePublicModel>? selectedServices,
    Object? selectedEmployeeId = _unset,
    Object? selectedEmployeeName = _unset,
    bool? anyAvailableEmployee,
    Object? selectedStartAt = _unset,
    Object? selectedEndAt = _unset,
    Object? customerName = _unset,
    Object? customerPhone = _unset,
    Object? customerPhoneNormalized = _unset,
    Object? customerGender = _unset,
    Object? customerNote = _unset,
    Object? guestNicknameKey = _unset,
    Object? guestDisplayName = _unset,
    double? subtotal,
    double? discountAmount,
    double? totalAmount,
    int? durationMinutes,
  }) {
    return CustomerBookingDraft(
      salonId: salonId ?? this.salonId,
      selectedServices: selectedServices ?? this.selectedServices,
      selectedEmployeeId: identical(selectedEmployeeId, _unset)
          ? this.selectedEmployeeId
          : selectedEmployeeId as String?,
      selectedEmployeeName: identical(selectedEmployeeName, _unset)
          ? this.selectedEmployeeName
          : selectedEmployeeName as String?,
      anyAvailableEmployee: anyAvailableEmployee ?? this.anyAvailableEmployee,
      selectedStartAt: identical(selectedStartAt, _unset)
          ? this.selectedStartAt
          : selectedStartAt as DateTime?,
      selectedEndAt: identical(selectedEndAt, _unset)
          ? this.selectedEndAt
          : selectedEndAt as DateTime?,
      customerName: identical(customerName, _unset)
          ? this.customerName
          : customerName as String?,
      customerPhone: identical(customerPhone, _unset)
          ? this.customerPhone
          : customerPhone as String?,
      customerPhoneNormalized: identical(customerPhoneNormalized, _unset)
          ? this.customerPhoneNormalized
          : customerPhoneNormalized as String?,
      customerGender: identical(customerGender, _unset)
          ? this.customerGender
          : customerGender as String?,
      customerNote: identical(customerNote, _unset)
          ? this.customerNote
          : customerNote as String?,
      guestNicknameKey: identical(guestNicknameKey, _unset)
          ? this.guestNicknameKey
          : guestNicknameKey as String?,
      guestDisplayName: identical(guestDisplayName, _unset)
          ? this.guestDisplayName
          : guestDisplayName as String?,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  static CustomerBookingDraft empty() =>
      const CustomerBookingDraft(salonId: '');
}
