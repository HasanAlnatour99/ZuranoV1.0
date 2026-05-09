import '../../../../core/firestore/firestore_json_helpers.dart';

class Customer {
  const Customer({
    required this.id,
    this.salonId,
    this.authUid,
    required this.fullName,
    required this.phone,
    this.fullNameLower,
    this.email,
    this.notes,
    this.preferredBarberId,
    this.preferredBarberName,
    this.category,
    this.visitCount = 0,
    this.totalSpent = 0,
    this.lastVisitAt,
    this.firstVisitAt,
    this.isActive = true,
    this.isVip = false,
    this.discountPercentage = 0,
    this.searchKeywords = const <String>[],
    this.gender,
    this.birthDate,
    this.source,
    this.tags = const <String>[],
    this.address,
    this.lastServiceName,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String? salonId;
  final String? authUid;
  final String fullName;
  final String phone;
  final String? fullNameLower;
  final String? email;
  final String? notes;
  final String? preferredBarberId;
  final String? preferredBarberName;

  /// Firestore: `new` | `regular` | `vip`
  final String? category;

  final int visitCount;
  final double totalSpent;
  final DateTime? lastVisitAt;
  final DateTime? firstVisitAt;
  final bool isActive;

  /// Owner/admin only; never derived from visit rules.
  final bool isVip;

  /// 0–100; applied automatically at POS when this customer is linked to a sale.
  final double discountPercentage;
  final List<String> searchKeywords;

  /// Optional CRM fields (owner/admin only in UI for now).
  final String? gender;
  final DateTime? birthDate;
  final String? source;
  final List<String> tags;
  final Map<String, dynamic>? address;

  /// Denormalized from last completed sale or booking when available.
  final String? lastServiceName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String? updatedBy;

  // Compatibility aliases while the presentation layer is being migrated.
  String get phoneNumber => phone;
  String get normalizedFullName => normalizeCustomerName(fullName);
  String get resolvedFullNameLower =>
      (fullNameLower?.trim().isNotEmpty == true)
          ? fullNameLower!.trim()
          : normalizeCustomerName(fullName);
  String? get normalizedPhoneNumber => normalizeCustomerPhone(phone);

  int get loyaltyPoints => 0;

  /// Alias aligned with analytics naming (`totalVisits` in Firestore).
  int get totalVisits => visitCount;

  factory Customer.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? addressFrom(Object? v) {
      if (v is Map) {
        return Map<String, dynamic>.from(v);
      }
      if (v is String && v.trim().isNotEmpty) {
        return <String, dynamic>{'line1': v.trim()};
      }
      return null;
    }

    return Customer(
      id: looseStringFromJson(json['id']),
      salonId: nullableLooseStringFromJson(json['salonId']),
      authUid: nullableLooseStringFromJson(json['authUid']),
      fullName: _visibleFullNameFromCustomerJson(json),
      phone:
          nullableLooseStringFromJson(json['phone']) ??
          nullableLooseStringFromJson(json['phoneNumber']) ??
          '',
      fullNameLower: nullableLooseStringFromJson(json['fullNameLower']),
      email: nullableLooseStringFromJson(json['email']),
      notes: nullableLooseStringFromJson(json['notes']),
      preferredBarberId: nullableLooseStringFromJson(json['preferredBarberId']),
      preferredBarberName: nullableLooseStringFromJson(
        json['preferredBarberName'],
      ),
      category: nullableLooseStringFromJson(json['category']) ??
          nullableLooseStringFromJson(json['segment']),
      visitCount: looseIntFromJson(
        json['totalVisits'] ?? json['visitsCount'] ?? json['visitCount'],
      ),
      totalSpent: looseDoubleFromJson(json['totalSpent']),
      lastVisitAt: nullableFirestoreDateTimeFromJson(json['lastVisitAt']),
      firstVisitAt: nullableFirestoreDateTimeFromJson(json['firstVisitAt']),
      isActive: _customerIsActiveFromJson(json),
      isVip:
          trueBoolFromJson(json['isVip']) ||
          (nullableLooseStringFromJson(json['category'])?.toLowerCase() ==
              'vip'),
      discountPercentage: _discountPercentageFromJson(json),
      searchKeywords: stringListFromJson(json['searchKeywords']),
      gender: nullableLooseStringFromJson(json['gender']),
      birthDate: nullableFirestoreDateTimeFromJson(
        json['birthDate'] ?? json['dateOfBirth'],
      ),
      source: nullableLooseStringFromJson(json['source']),
      tags: stringListFromJson(json['tags']),
      address: addressFrom(json['address']),
      lastServiceName: nullableLooseStringFromJson(json['lastServiceName']),
      createdAt: nullableFirestoreDateTimeFromJson(json['createdAt']),
      updatedAt: nullableFirestoreDateTimeFromJson(json['updatedAt']),
      createdBy: nullableLooseStringFromJson(json['createdBy']) ?? '',
      updatedBy: nullableLooseStringFromJson(json['updatedBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'salonId': salonId,
      'authUid': authUid,
      'fullName': fullName,
      'fullNameLower': fullNameLower,
      'phone': phone,
      'email': email,
      'notes': notes,
      'preferredBarberId': preferredBarberId,
      'preferredBarberName': preferredBarberName,
      'category': category,
      'visitCount': visitCount,
      'visitsCount': visitCount,
      'totalVisits': visitCount,
      'totalSpent': totalSpent,
      'lastVisitAt': nullableFirestoreDateTimeToJson(lastVisitAt),
      'firstVisitAt': nullableFirestoreDateTimeToJson(firstVisitAt),
      'isActive': isActive,
      'isVip': isVip,
      'discountPercentage': discountPercentage,
      'searchKeywords': searchKeywords,
      'gender': gender,
      'birthDate': nullableFirestoreDateTimeToJson(birthDate),
      'source': source,
      'tags': tags,
      'address': address,
      if (lastServiceName != null && lastServiceName!.trim().isNotEmpty)
        'lastServiceName': lastServiceName,
      'createdAt': nullableFirestoreDateTimeToJson(createdAt),
      'updatedAt': nullableFirestoreDateTimeToJson(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Name shown in lists and headers (never the Firestore document id / uid).
  String get visibleDisplayName {
    final n = fullName.trim();
    if (n.isNotEmpty) return n;
    return 'Guest';
  }

  Customer copyWith({
    String? id,
    String? salonId,
    String? authUid,
    String? fullName,
    String? phone,
    String? fullNameLower,
    String? email,
    String? notes,
    String? preferredBarberId,
    String? preferredBarberName,
    String? category,
    List<String>? searchKeywords,
    String? gender,
    DateTime? birthDate,
    String? source,
    List<String>? tags,
    Map<String, dynamic>? address,
    String? lastServiceName,
    int? visitCount,
    double? totalSpent,
    DateTime? lastVisitAt,
    DateTime? firstVisitAt,
    bool? isActive,
    bool? isVip,
    double? discountPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Customer(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      authUid: authUid ?? this.authUid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      fullNameLower: fullNameLower ?? this.fullNameLower,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      preferredBarberId: preferredBarberId ?? this.preferredBarberId,
      preferredBarberName: preferredBarberName ?? this.preferredBarberName,
      category: category ?? this.category,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      address: address ?? this.address,
      lastServiceName: lastServiceName ?? this.lastServiceName,
      visitCount: visitCount ?? this.visitCount,
      totalSpent: totalSpent ?? this.totalSpent,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      firstVisitAt: firstVisitAt ?? this.firstVisitAt,
      isActive: isActive ?? this.isActive,
      isVip: isVip ?? this.isVip,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

double _discountPercentageFromJson(Map<String, dynamic> json) {
  final v = json['discountPercentage'];
  if (v == null) return 0;
  final d = looseDoubleFromJson(v);
  if (d < 0) return 0;
  if (d > 100) return 100;
  return d;
}

String _visibleFullNameFromCustomerJson(Map<String, dynamic> json) {
  for (final key in ['displayName', 'customerName', 'nickname', 'fullName']) {
    final v = nullableLooseStringFromJson(json[key])?.trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return '';
}

bool _customerIsActiveFromJson(Map<String, dynamic> json) {
  final status = nullableLooseStringFromJson(json['status'])?.toLowerCase();
  if (status == 'inactive') {
    return false;
  }
  return trueBoolFromJson(json['isActive']);
}

String normalizeCustomerName(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String? normalizeCustomerPhone(String? value) {
  if (value == null) return null;
  final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (normalized.isEmpty) return null;
  return normalized;
}

List<String> buildCustomerSearchKeywords({
  required String fullName,
  String? phoneNumber,
}) {
  final normalizedName = normalizeCustomerName(fullName).toLowerCase();
  final normalizedPhone = normalizeCustomerPhone(phoneNumber);
  final keywords = <String>{};
  final tokens = normalizedName
      .split(' ')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .take(3)
      .toList();

  for (final token in tokens) {
    for (var i = 1; i <= token.length; i++) {
      keywords.add(token.substring(0, i));
    }
  }

  if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
    keywords.add(normalizedPhone);
    for (var i = 3; i <= normalizedPhone.length; i++) {
      keywords.add(normalizedPhone.substring(0, i));
    }
  }

  final out = keywords.toList()..sort();
  if (out.length > 96) {
    return out.take(96).toList();
  }
  return out;
}
