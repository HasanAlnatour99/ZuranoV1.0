class LastBookedModel {
  const LastBookedModel({
    required this.bookingCode,
    required this.customerPhone,
    required this.salonId,
    required this.salonName,
    required this.bookingDateText,
    required this.savedAt,
    this.serviceName,
    this.bookingId,
  });

  final String bookingCode;
  final String customerPhone;
  final String salonId;
  final String salonName;
  final String? serviceName;
  final String bookingDateText;
  final String? bookingId;
  final DateTime savedAt;

  Map<String, dynamic> toJson() {
    return {
      'bookingCode': bookingCode,
      'customerPhone': customerPhone,
      'salonId': salonId,
      'salonName': salonName,
      'serviceName': serviceName,
      'bookingDateText': bookingDateText,
      'bookingId': bookingId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory LastBookedModel.fromJson(Map<String, dynamic> json) {
    final ts = json['savedAt'];
    DateTime parseTs() {
      if (ts is String && ts.trim().isNotEmpty) {
        return DateTime.tryParse(ts.trim()) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return LastBookedModel(
      bookingCode: (json['bookingCode'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      salonId: (json['salonId'] ?? '').toString(),
      salonName: (json['salonName'] ?? '').toString(),
      serviceName: json['serviceName']?.toString(),
      bookingDateText: (json['bookingDateText'] ?? '').toString(),
      bookingId: json['bookingId']?.toString(),
      savedAt: parseTs(),
    );
  }
}

