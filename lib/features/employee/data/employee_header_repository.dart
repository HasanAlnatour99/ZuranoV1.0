import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore/firestore_paths.dart';
import '../../../features/employee_dashboard/application/employee_workspace_scope.dart';
import 'employee_header_model.dart';

class EmployeeHeaderException implements Exception {
  const EmployeeHeaderException(this.message);
  final String message;

  @override
  String toString() => message;
}

class EmployeeHeaderRepository {
  EmployeeHeaderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Live header: [users/{uid}], [salons/{salonId}], [employees/{employeeId}], and shift
  /// (`shifts/{id}` or `shiftTemplates/{id}` when the shift doc is missing).
  Stream<EmployeeHeaderModel> watchHeader({required EmployeeWorkspaceScope scope}) {
    final controller = StreamController<EmployeeHeaderModel>();

    DocumentSnapshot<Map<String, dynamic>>? userSnap;
    DocumentSnapshot<Map<String, dynamic>>? salonSnap;
    DocumentSnapshot<Map<String, dynamic>>? empSnap;
    DocumentSnapshot<Map<String, dynamic>>? shiftSnap;

    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? salonSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? empSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? shiftSub;

    var boundShiftId = '';

    Future<void> cancelShift() async {
      await shiftSub?.cancel();
      shiftSub = null;
      shiftSnap = null;
      boundShiftId = '';
    }

    void emit() {
      if (salonSnap == null || empSnap == null) {
        return;
      }
      final u = userSnap?.data();
      final salonData = salonSnap!.data() ?? {};
      final empData = empSnap!.data() ?? {};

      final salonName = (salonData['name'] as String?)?.trim();
      final nameFromEmp = (empData['name'] as String?)?.trim();
      final nameFromUser = (u?['name'] as String?)?.trim();
      final displayName = nameFromEmp?.isNotEmpty == true
          ? nameFromEmp!
          : (nameFromUser?.isNotEmpty == true
                ? nameFromUser!
                : scope.displayName);

      final tierRaw = empData['tier']?.toString().trim();
      final photoEmp =
          (empData['avatarUrl'] as String?)?.trim().isNotEmpty == true
          ? empData['avatarUrl'] as String
          : (empData['photoUrl'] as String?)?.trim();
      final photoUser = (u?['photoUrl'] as String?)?.trim();
      final photo = photoEmp?.isNotEmpty == true
          ? photoEmp
          : (photoUser?.isNotEmpty == true ? photoUser : null);

      final shiftData = shiftSnap?.data();
      String? start;
      String? nameEn;
      String? nameAr;
      if (shiftData != null) {
        final st = shiftData['startTime'];
        start = st is String ? st.trim() : st?.toString();
        nameEn = (shiftData['nameEn'] as String?)?.trim();
        nameAr = (shiftData['nameAr'] as String?)?.trim();
        final fallbackName = (shiftData['name'] as String?)?.trim();
        if (nameEn == null || nameEn.isEmpty) {
          nameEn = fallbackName;
        }
        if (nameAr == null || nameAr.isEmpty) {
          nameAr = fallbackName;
        }
      }

      if (!controller.isClosed) {
        controller.add(
          EmployeeHeaderModel(
            employeeId: scope.employeeId,
            name: displayName,
            salonName: salonName?.isNotEmpty == true
                ? salonName!
                : scope.displayName,
            tier: tierRaw?.isNotEmpty == true ? tierRaw : null,
            photoUrl: photo,
            shiftStartTime: start?.isNotEmpty == true ? start : null,
            shiftNameEn: nameEn?.isNotEmpty == true ? nameEn : null,
            shiftNameAr: nameAr?.isNotEmpty == true ? nameAr : null,
            headerAt: DateTime.now(),
          ),
        );
      }
    }

    Future<void> bindShift(String? shiftId) async {
      final trimmed = shiftId?.trim() ?? '';
      if (trimmed.isEmpty) {
        await cancelShift();
        emit();
        return;
      }
      if (trimmed == boundShiftId) {
        emit();
        return;
      }
      await cancelShift();
      boundShiftId = trimmed;

      final shiftRef = _firestore.doc(
        FirestorePaths.salonShift(scope.salonId, trimmed),
      );
      final templateRef = _firestore.doc(
        FirestorePaths.salonShiftTemplate(scope.salonId, trimmed),
      );

      final first = await shiftRef.get();
      final DocumentReference<Map<String, dynamic>> liveRef = first.exists
          ? shiftRef
          : templateRef;

      shiftSub = liveRef.snapshots().listen((snap) {
        shiftSnap = snap;
        emit();
      });
    }

    Future<void> onEmployee(DocumentSnapshot<Map<String, dynamic>> snap) async {
      empSnap = snap;
      final data = snap.data() ?? {};
      final sid =
          (data['shiftId'] as String?)?.trim().isNotEmpty == true
              ? data['shiftId'] as String
              : (data['shiftTemplateId'] as String?)?.trim();
      await bindShift(sid);
      emit();
    }

    userSub = _firestore
        .doc(FirestorePaths.user(scope.uid))
        .snapshots()
        .listen((snap) {
          userSnap = snap;
          emit();
        });

    salonSub = _firestore
        .doc(FirestorePaths.salon(scope.salonId))
        .snapshots()
        .listen((snap) {
          salonSnap = snap;
          emit();
        });

    empSub = _firestore
        .doc(FirestorePaths.salonEmployee(scope.salonId, scope.employeeId))
        .snapshots()
        .listen((snap) {
          unawaited(onEmployee(snap));
        });

    controller.onCancel = () async {
      await userSub?.cancel();
      await salonSub?.cancel();
      await empSub?.cancel();
      await cancelShift();
      if (!controller.isClosed) {
        await controller.close();
      }
    };

    return controller.stream;
  }
}
