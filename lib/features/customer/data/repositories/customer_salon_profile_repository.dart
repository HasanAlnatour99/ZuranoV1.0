import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../models/customer_review_model.dart';
import '../models/customer_service_public_model.dart';
import '../models/customer_team_member_public_model.dart';
import '../models/salon_public_model.dart';

abstract class CustomerSalonProfileRepository {
  Stream<SalonPublicModel?> watchSalonProfile(String salonId);

  Stream<List<CustomerServicePublicModel>> watchVisibleServices(String salonId);

  /// One-shot load (e.g. recommendations / discovery) — same source as [watchVisibleServices].
  Future<List<CustomerServicePublicModel>> fetchVisibleServices(String salonId);

  Stream<List<CustomerTeamMemberPublicModel>> watchBookableTeamMembers(
    String salonId,
  );

  /// One-shot load (e.g. booking recommendations) — same source as [watchBookableTeamMembers].
  Future<List<CustomerTeamMemberPublicModel>> fetchBookableTeamMembers(
    String salonId,
  );

  Stream<List<CustomerReviewModel>> watchSalonReviews(String salonId);

  Future<void> openPhone(String? phone);

  Future<void> openWhatsApp(String? whatsapp);

  Future<void> openMap(double latitude, double longitude);

  Future<void> shareSalon(SalonPublicModel salon);
}

class FirestoreCustomerSalonProfileRepository
    implements CustomerSalonProfileRepository {
  FirestoreCustomerSalonProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<SalonPublicModel?> watchSalonProfile(String salonId) {
    final id = salonId.trim();
    if (id.isEmpty) {
      return Stream.value(null);
    }
    return _firestore.doc(FirestorePaths.publicSalon(id)).snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        return null;
      }
      return SalonPublicModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<CustomerServicePublicModel>> watchVisibleServices(
    String salonId,
  ) {
    final id = salonId.trim();
    if (id.isEmpty) {
      return Stream.value(const []);
    }
    return _firestore
        .collection(FirestorePaths.publicSalonServicesCollection(id))
        .where('isActive', isEqualTo: true)
        .where('isCustomerVisible', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => CustomerServicePublicModel.fromFirestore(d, id))
              .toList(growable: false);
          list.sort((a, b) {
            final byOrder = a.sortOrder.compareTo(b.sortOrder);
            if (byOrder != 0) {
              return byOrder;
            }
            final c = a.category.toLowerCase().compareTo(
              b.category.toLowerCase(),
            );
            if (c != 0) {
              return c;
            }
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          return list;
        });
  }

  @override
  Future<List<CustomerServicePublicModel>> fetchVisibleServices(
    String salonId,
  ) async {
    final id = salonId.trim();
    if (id.isEmpty) {
      return const [];
    }
    final snap = await _firestore
        .collection(FirestorePaths.publicSalonServicesCollection(id))
        .where('isActive', isEqualTo: true)
        .where('isCustomerVisible', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    final list = snap.docs
        .map((d) => CustomerServicePublicModel.fromFirestore(d, id))
        .toList(growable: false);
    list.sort((a, b) {
      final byOrder = a.sortOrder.compareTo(b.sortOrder);
      if (byOrder != 0) {
        return byOrder;
      }
      final c = a.category.toLowerCase().compareTo(b.category.toLowerCase());
      if (c != 0) {
        return c;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  Stream<List<CustomerTeamMemberPublicModel>> watchBookableTeamMembers(
    String salonId,
  ) {
    final id = salonId.trim();
    if (id.isEmpty) {
      return Stream.value(const []);
    }
    return _firestore
        .collection(FirestorePaths.publicSalonTeamCollection(id))
        .where('isActive', isEqualTo: true)
        .where('allowCustomerBooking', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => CustomerTeamMemberPublicModel.fromFirestore(d, id))
              .toList(growable: false);
          list.sort((a, b) {
            final byOrder = a.sortOrder.compareTo(b.sortOrder);
            if (byOrder != 0) {
              return byOrder;
            }
            return a.displayTitle.toLowerCase().compareTo(
              b.displayTitle.toLowerCase(),
            );
          });
          return list;
        });
  }

  @override
  Future<List<CustomerTeamMemberPublicModel>> fetchBookableTeamMembers(
    String salonId,
  ) async {
    final id = salonId.trim();
    if (id.isEmpty) {
      return const [];
    }
    final snap = await _firestore
        .collection(FirestorePaths.publicSalonTeamCollection(id))
        .where('isActive', isEqualTo: true)
        .where('allowCustomerBooking', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    final list = snap.docs
        .map((d) => CustomerTeamMemberPublicModel.fromFirestore(d, id))
        .toList(growable: false);
    list.sort((a, b) {
      final byOrder = a.sortOrder.compareTo(b.sortOrder);
      if (byOrder != 0) {
        return byOrder;
      }
      return a.displayTitle.toLowerCase().compareTo(
        b.displayTitle.toLowerCase(),
      );
    });
    return list;
  }

  @override
  Stream<List<CustomerReviewModel>> watchSalonReviews(String salonId) {
    final id = salonId.trim();
    if (id.isEmpty) {
      return Stream.value(const []);
    }
    return _firestore
        .collection(FirestorePaths.salonReviews(id))
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => CustomerReviewModel.fromFirestore(d, id))
              .toList(growable: false),
        );
  }

  static String? _cleanPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null;
    }
    final cleaned = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return cleaned.isEmpty ? null : cleaned;
  }

  @override
  Future<void> openPhone(String? phone) async {
    final cleaned = _cleanPhone(phone);
    if (cleaned == null) {
      return;
    }
    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } on Object catch (e, st) {
      debugPrint('openPhone failed: $e\n$st');
    }
  }

  @override
  Future<void> openWhatsApp(String? whatsapp) async {
    final cleaned = _cleanPhone(whatsapp);
    if (cleaned == null) {
      return;
    }
    var digits = cleaned;
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    final appUri = Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent('Hello')}',
    );
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      }
    } on Object catch (e, st) {
      debugPrint('openWhatsApp failed: $e\n$st');
    }
  }

  @override
  Future<void> openMap(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on Object catch (e, st) {
      debugPrint('openMap failed: $e\n$st');
    }
  }

  @override
  Future<void> shareSalon(SalonPublicModel salon) async {
    final buffer = StringBuffer(salon.salonName);
    if (salon.area.trim().isNotEmpty) {
      buffer.write('\n${salon.area}');
    }
    if (salon.phone != null && salon.phone!.trim().isNotEmpty) {
      buffer.write('\n${salon.phone}');
    }
    try {
      await SharePlus.instance.share(
        ShareParams(text: buffer.toString(), subject: salon.salonName),
      );
    } on Object catch (e, st) {
      debugPrint('shareSalon failed: $e\n$st');
    }
  }
}
