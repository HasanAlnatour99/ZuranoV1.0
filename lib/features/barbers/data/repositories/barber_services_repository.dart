import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../features/employees/data/models/employee.dart';
import '../models/assigned_barber_service_model.dart';

class BarberServicesRepository {
  BarberServicesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _assignmentCollection({
    required String salonId,
    required String employeeId,
  }) {
    return _firestore
        .collection(FirestorePaths.salonEmployees(salonId))
        .doc(employeeId)
        .collection(FirestorePaths.assignedServicesCollection);
  }

  DocumentReference<Map<String, dynamic>> _employeeRef({
    required String salonId,
    required String employeeId,
  }) {
    return _firestore.doc(FirestorePaths.salonEmployee(salonId, employeeId));
  }

  static bool _permissionDenied(Object e) =>
      e is FirebaseException && e.code == 'permission-denied';

  /// Streams assignment rows joined with salon service docs. When the
  /// `assignedServices` subcollection is empty or rules deny access, falls back to
  /// legacy `employee.assignedServiceIds`.
  Stream<List<AssignedBarberServiceModel>> watchAssignedServicesJoined({
    required String salonId,
    required String employeeId,
    required String salonFallbackCurrencyCode,
  }) {
    late final StreamController<List<AssignedBarberServiceModel>> controller;
    var assignDocs =
        const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    DocumentSnapshot<Map<String, dynamic>>? empSnap;
    /// When false, skips `assignedServices` reads (e.g. rules not deployed yet).
    var listenAssignments = false;

    var resolveGen = 0;

    Future<void> scheduleResolve() async {
      final myGen = ++resolveGen;
      try {
        final merged = await _resolveAssignmentsToModels(
          useSubcollection:
              assignDocs.isNotEmpty && listenAssignments,
          assignDocs: assignDocs,
          empSnap: empSnap,
          salonId: salonId,
          salonFallbackCurrencyCode: salonFallbackCurrencyCode,
        );
        if (!controller.isClosed && myGen == resolveGen) {
          controller.add(merged);
        }
      } on Object catch (e, st) {
        if (!controller.isClosed && myGen == resolveGen) {
          controller.addError(e, st);
        }
      }
    }

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subAssignments;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subEmp;

    controller =
        StreamController<List<AssignedBarberServiceModel>>(
          onListen: () {
            subEmp = _employeeRef(
                  salonId: salonId,
                  employeeId: employeeId,
                )
                .snapshots()
                .listen((snapshot) {
                  empSnap = snapshot;
                  unawaited(scheduleResolve());
                });

            unawaited(() async {
              try {
                empSnap = await _employeeRef(
                  salonId: salonId,
                  employeeId: employeeId,
                ).get();

                listenAssignments = false;
                assignDocs = [];
                try {
                  assignDocs =
                      (await _assignmentCollection(
                            salonId: salonId,
                            employeeId: employeeId,
                          )
                          .get())
                          .docs;
                  listenAssignments = true;
                } on FirebaseException catch (e, st) {
                  if (_permissionDenied(e)) {
                    listenAssignments = false;
                    assignDocs = [];
                  } else {
                    if (!controller.isClosed) {
                      controller.addError(e, st);
                    }
                    return;
                  }
                }

                await scheduleResolve();

                if (listenAssignments) {
                  subAssignments =
                      _assignmentCollection(
                            salonId: salonId,
                            employeeId: employeeId,
                          )
                          .snapshots()
                          .listen(
                            (snapshot) {
                              assignDocs = snapshot.docs;
                              listenAssignments = true;
                              unawaited(scheduleResolve());
                            },
                            onError: (Object error, StackTrace stack) {
                              if (_permissionDenied(error)) {
                                listenAssignments = false;
                                assignDocs = [];
                                subAssignments?.cancel();
                                subAssignments = null;
                                unawaited(scheduleResolve());
                                return;
                              }
                              if (!controller.isClosed) {
                                controller.addError(error, stack);
                              }
                            },
                          );
                }
              } on Object catch (e, st) {
                if (!controller.isClosed) controller.addError(e, st);
              }
            }());
          },
          onCancel: () {
            subAssignments?.cancel();
            subEmp?.cancel();
          },
        );

    return controller.stream;
  }

  Future<List<AssignedBarberServiceModel>> _resolveAssignmentsToModels({
    required bool useSubcollection,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> assignDocs,
    required DocumentSnapshot<Map<String, dynamic>>? empSnap,
    required String salonId,
    required String salonFallbackCurrencyCode,
  }) async {
    final servicesCol = _firestore
        .collection(FirestorePaths.salonServices(salonId));

    final requests = <({
      String serviceId,
      Map<String, dynamic> assignmentData,
    })>[];

    if (useSubcollection && assignDocs.isNotEmpty) {
      for (final doc in assignDocs) {
        final assignmentData = doc.data();
        final activeVal = assignmentData['isActive'];
        final isActive = activeVal is bool ? activeVal : true;
        if (!isActive) {
          continue;
        }
        final sidField = (assignmentData['serviceId'] as String?)?.trim();
        final serviceId = sidField != null && sidField.isNotEmpty
            ? sidField
            : doc.id;

        requests.add((serviceId: serviceId, assignmentData: assignmentData));
      }
    } else {
      Employee? employee;
      if (empSnap != null && empSnap.exists && empSnap.data() != null) {
        employee = Employee.fromJson(empSnap.data()!);
      }
      final ids = employee?.assignedServiceIds ?? const <String>[];
      for (final id in ids) {
        final trimmed = id.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        requests.add((
          serviceId: trimmed,
          assignmentData: const <String, dynamic>{'isActive': true},
        ));
      }
    }

    if (requests.isEmpty) {
      return const <AssignedBarberServiceModel>[];
    }

    final result = <AssignedBarberServiceModel>[];

    for (final item in requests) {
      final serviceDoc = await servicesCol.doc(item.serviceId).get();
      if (!serviceDoc.exists || serviceDoc.data() == null) {
        continue;
      }
      result.add(
        AssignedBarberServiceModel.fromMaps(
          serviceId: item.serviceId,
          serviceData: serviceDoc.data()!,
          assignmentData: item.assignmentData,
          fallbackCurrencyCode: salonFallbackCurrencyCode,
        ),
      );
    }

    result.sort(
      (a, b) => a.sortKeyEnglish.toLowerCase().compareTo(
        b.sortKeyEnglish.toLowerCase(),
      ),
    );

    return result;
  }
}
