import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

/// Returns true while Firestore composite indexes exist but are not **Enabled** yet.
bool isFirestoreIndexBuilding(Object error) {
  final combined = _diagnosticText(error).toLowerCase();
  if (!combined.contains('index')) {
    return false;
  }
  final building =
      combined.contains('building') || combined.contains('cannot be used yet');
  if (!building) {
    return false;
  }
  final precondition =
      combined.contains('failed-precondition') ||
      combined.contains('failed_precondition') ||
      (error is FirebaseException && error.code == 'failed-precondition');
  return precondition;
}

String _diagnosticText(Object error) {
  if (error is FirebaseException) {
    return '${error.code} ${error.message ?? ''}';
  }
  return error.toString();
}

/// Emits [fallback] when the stream errors because a composite index is still building.
Stream<T> recoverWhileFirestoreIndexBuilding<T>(Stream<T> stream, T fallback) {
  return stream.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (Object error, StackTrace stackTrace, EventSink<T> sink) {
        if (isFirestoreIndexBuilding(error)) {
          sink.add(fallback);
        } else {
          sink.addError(error, stackTrace);
        }
      },
    ),
  );
}
