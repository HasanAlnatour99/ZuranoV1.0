import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/break_allowance_math.dart';

@immutable
class BreakTimerArgs {
  const BreakTimerArgs({
    required this.breakOutAt,
    required this.remainingAllowanceMinutes,
    this.shiftStart,
    this.shiftEnd,
  });

  /// Start of the current open break (`breakOut` punch time).
  final DateTime breakOutAt;

  /// Minutes still available from the **daily** break pool for this session.
  final int remainingAllowanceMinutes;

  final DateTime? shiftStart;
  final DateTime? shiftEnd;

  @override
  bool operator ==(Object other) {
    return other is BreakTimerArgs &&
        other.breakOutAt == breakOutAt &&
        other.remainingAllowanceMinutes == remainingAllowanceMinutes &&
        other.shiftStart == shiftStart &&
        other.shiftEnd == shiftEnd;
  }

  @override
  int get hashCode =>
      Object.hash(breakOutAt, remainingAllowanceMinutes, shiftStart, shiftEnd);
}

@immutable
class BreakTimerState {
  const BreakTimerState({
    required this.isExceeded,
    required this.remainingSeconds,
    required this.exceededSeconds,
  });

  final bool isExceeded;
  final int remainingSeconds;
  final int exceededSeconds;

  String get remainingLabel {
    final duration = Duration(seconds: remainingSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get exceededLabel {
    final duration = Duration(seconds: exceededSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Ticks once per second while watched so the employee break card stays live.
final breakTimerProvider = StreamProvider.autoDispose
    .family<BreakTimerState, BreakTimerArgs>((ref, args) async* {
      while (true) {
        final now = DateTime.now();
        final elapsedSec = openBreakElapsedSecondsClamped(
          args.breakOutAt,
          now,
          args.shiftStart,
          args.shiftEnd,
        );
        final budgetSec =
            (args.remainingAllowanceMinutes < 0 ? 0 : args.remainingAllowanceMinutes) *
            60;

        if (elapsedSec <= budgetSec) {
          yield BreakTimerState(
            isExceeded: false,
            remainingSeconds: budgetSec - elapsedSec,
            exceededSeconds: 0,
          );
        } else {
          yield BreakTimerState(
            isExceeded: true,
            remainingSeconds: 0,
            exceededSeconds: elapsedSec - budgetSec,
          );
        }

        await Future<void>.delayed(const Duration(seconds: 1));
      }
    });
