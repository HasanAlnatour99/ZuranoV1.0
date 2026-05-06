import '../../../../l10n/app_localizations.dart';
import '../domain/salon_map_item.dart';

String customerMapDistanceLabel(
  AppLocalizations l10n,
  SalonMapItem salon,
) {
  final meters = salon.distanceMeters;
  if (meters == null) return '';
  if (meters < 1000) {
    return l10n.customerMapDistanceMeters(meters.round().toString());
  }
  return l10n.customerMapDistanceKm(
    (meters / 1000).toStringAsFixed(1),
  );
}
