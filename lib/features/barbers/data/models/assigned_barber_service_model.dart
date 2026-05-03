/// Joined salon service + per-employee assignment row for Team barber profiles.
class AssignedBarberServiceModel {
  const AssignedBarberServiceModel({
    required this.serviceId,
    required this.sortKeyEnglish,
    required this.nameEn,
    required this.nameAr,
    required this.durationMinutes,
    required this.price,
    required this.resolvedCurrencyCode,
    required this.catalogIsActive,
    required this.assignmentIsActive,
    this.commissionOverridePercent,
  });

  final String serviceId;
  final String sortKeyEnglish;

  /// English catalogue primary line (`serviceName` / `name`).
  final String nameEn;

  /// Arabic display title when stored on the service document.
  final String nameAr;

  final int durationMinutes;
  final num price;

  /// Per-service `currencyCode` when present, otherwise salon/session fallback.
  final String resolvedCurrencyCode;

  /// `salons/.../services/{id}.isActive`
  final bool catalogIsActive;

  /// `assignedServices/{id}.isActive`
  final bool assignmentIsActive;

  final num? commissionOverridePercent;

  String localizedName(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('ar')) {
      final ar = nameAr.trim();
      if (ar.isNotEmpty) return ar;
    }
    final en = nameEn.trim().isNotEmpty
        ? nameEn.trim()
        : sortKeyEnglish.trim();
    return en;
  }

  factory AssignedBarberServiceModel.fromMaps({
    required String serviceId,
    required Map<String, dynamic> serviceData,
    required Map<String, dynamic> assignmentData,
    required String fallbackCurrencyCode,
  }) {
    final name = (serviceData['name'] as String?)?.trim() ?? '';
    final serviceName = (serviceData['serviceName'] as String?)?.trim() ?? '';
    final nameAr = (serviceData['nameAr'] as String?)?.trim() ?? '';
    final enTitle = serviceName.isNotEmpty ? serviceName : name;

    final rawCurrency = (serviceData['currencyCode'] as String?)?.trim();
    final currency = rawCurrency != null && rawCurrency.isNotEmpty
        ? rawCurrency
        : fallbackCurrencyCode;

    final assignmentActiveRaw = assignmentData['isActive'];
    final assignmentIsActive =
        assignmentActiveRaw is bool ? assignmentActiveRaw : true;

    final catalogActiveRaw = serviceData['isActive'];
    final catalogIsActive = catalogActiveRaw is bool ? catalogActiveRaw : true;

    return AssignedBarberServiceModel(
      serviceId: serviceId,
      sortKeyEnglish: enTitle.isNotEmpty ? enTitle : name,
      nameEn: enTitle.isNotEmpty ? enTitle : name,
      nameAr: nameAr,
      durationMinutes: (serviceData['durationMinutes'] is num)
          ? (serviceData['durationMinutes'] as num).round()
          : int.tryParse('${serviceData['durationMinutes']}') ?? 0,
      price: serviceData['price'] is num
          ? serviceData['price'] as num
          : num.tryParse('${serviceData['price']}') ?? 0,
      resolvedCurrencyCode: currency,
      catalogIsActive: catalogIsActive,
      assignmentIsActive: assignmentIsActive,
      commissionOverridePercent:
          assignmentData['commissionOverridePercent'] as num?,
    );
  }
}
