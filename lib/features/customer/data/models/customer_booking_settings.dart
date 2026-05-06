/// Customer-facing booking policy (loaded from `publicSalons/{salonId}.customerBookingSettings`).
class CustomerBookingSettings {
  const CustomerBookingSettings({
    this.enabled = true,
    this.autoConfirmBookings = false,
    this.allowAnyAvailableEmployee = true,
    this.cancellationCutoffMinutes = 240,
    this.rescheduleCutoffMinutes = 120,
    this.bookingSlotIntervalMinutes = 30,
    this.maxAdvanceBookingDays = 30,
    this.requireBookingCodeForLookup = false,
    this.showPricesToCustomers = true,
    this.allowCustomerNotes = true,
    this.allowCustomerFeedback = true,
    this.minimumNoticeMinutes = 60,
    this.allowSameDayBooking = true,
    this.bufferMinutes = 10,
    this.requireCustomerPhone = true,
    this.requireCustomerName = true,
    this.publicBookingMessage = '',
    this.allowCustomerCancellation = true,
    this.cancellationNoticeHours = 4,
  });

  final bool enabled;
  final bool autoConfirmBookings;
  final bool allowAnyAvailableEmployee;
  final int cancellationCutoffMinutes;
  final int rescheduleCutoffMinutes;
  final int bookingSlotIntervalMinutes;
  final int maxAdvanceBookingDays;

  /// Salon-side toggle for future policy; HTTPS lookup always requires phone + booking code.
  final bool requireBookingCodeForLookup;
  final bool showPricesToCustomers;
  final bool allowCustomerNotes;
  final bool allowCustomerFeedback;

  final int minimumNoticeMinutes;
  final bool allowSameDayBooking;
  final int bufferMinutes;
  final bool requireCustomerPhone;
  final bool requireCustomerName;
  final String publicBookingMessage;
  final bool allowCustomerCancellation;
  final int cancellationNoticeHours;

  factory CustomerBookingSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CustomerBookingSettings();
    }
    final maxDays = _int(
      map['maxBookingDaysAhead'],
      _int(map['maxAdvanceBookingDays'], 30),
    );
    final slot = _int(
      map['slotDurationMinutes'],
      _int(map['bookingSlotIntervalMinutes'], 30),
    );
    final cancelHours = _int(map['cancellationNoticeHours'], 4);
    return CustomerBookingSettings(
      enabled: _bool(
        map['customerBookingEnabled'],
        _bool(map['enabled'], true),
      ),
      autoConfirmBookings: _bool(map['autoConfirmBookings'], false),
      allowAnyAvailableEmployee: _bool(map['allowAnyAvailableEmployee'], true),
      cancellationCutoffMinutes: _int(
        map['cancellationCutoffMinutes'],
        cancelHours * 60,
      ),
      rescheduleCutoffMinutes: _int(map['rescheduleCutoffMinutes'], 120),
      bookingSlotIntervalMinutes: slot <= 0 ? 30 : slot,
      maxAdvanceBookingDays: maxDays <= 0 ? 30 : maxDays,
      requireBookingCodeForLookup: _bool(
        map['requireBookingCodeForLookup'],
        false,
      ),
      showPricesToCustomers: _bool(map['showPricesToCustomers'], true),
      allowCustomerNotes: _bool(map['allowCustomerNotes'], true),
      allowCustomerFeedback: _bool(map['allowCustomerFeedback'], true),
      minimumNoticeMinutes: _int(
        map['minimumNoticeMinutes'],
        60,
      ).clamp(0, 10080),
      allowSameDayBooking: _bool(map['allowSameDayBooking'], true),
      bufferMinutes: _int(map['bufferMinutes'], 10).clamp(0, 240),
      requireCustomerPhone: _bool(map['requireCustomerPhone'], true),
      requireCustomerName: _bool(map['requireCustomerName'], true),
      publicBookingMessage: map['publicBookingMessage'] is String
          ? (map['publicBookingMessage'] as String)
          : '',
      allowCustomerCancellation: _bool(map['allowCustomerCancellation'], true),
      cancellationNoticeHours: cancelHours <= 0 ? 4 : cancelHours,
    );
  }

  static bool _bool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }

  static int _int(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return fallback;
  }

  bool customerDetailsSatisfied({
    required String? customerName,
    required String? customerPhoneNormalized,
  }) {
    final n = customerName?.trim() ?? '';
    final p = customerPhoneNormalized?.trim() ?? '';
    if (requireCustomerName && n.isEmpty) {
      return false;
    }
    if (requireCustomerPhone && p.isEmpty) {
      return false;
    }
    if (!requireCustomerName && !requireCustomerPhone) {
      return n.isNotEmpty || p.isNotEmpty;
    }
    return true;
  }
}
