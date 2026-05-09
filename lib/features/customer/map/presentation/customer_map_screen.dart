import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customer_home/presentation/controllers/customer_location_providers.dart';
import '../domain/salon_map_item.dart';
import 'providers/customer_map_providers.dart';
import 'widgets/customer_map_marker_style.dart';
import 'widgets/map_filter_chips.dart';
import 'widgets/map_permission_banner.dart';
import 'widgets/map_search_header.dart';
import 'widgets/nearby_places_bottom_sheet.dart';
import 'widgets/salon_map_bottom_card.dart';
import 'widgets/search_this_area_button.dart';

class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  GoogleMapController? _mapController;
  bool _didCenterOnUser = false;

  late final ClusterManager _salonClusterManager = ClusterManager(
    clusterManagerId: const ClusterManagerId('zurano_customer_map_salons'),
    onClusterTap: _onSalonClusterTap,
  );

  void _onSalonClusterTap(Cluster cluster) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(cluster.bounds, 56),
    );
  }

  Set<Marker> _buildMarkers({
    required AppLocalizations l10n,
    required List<SalonMapItem> salons,
    required LatLng? userPosition,
    required SalonMapItem? selected,
    required bool clusterSalons,
    ClusterManagerId? salonClusterManagerId,
  }) {
    final markers = <Marker>{};

    if (userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer_location'),
          position: userPosition,
          infoWindow: InfoWindow(title: l10n.customerMapMarkerYouAreHere),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    for (final salon in salons) {
      final isSelected = selected?.id == salon.id;
      markers.add(
        Marker(
          markerId: MarkerId('salon_${salon.id}'),
          position: salon.position,
          clusterManagerId:
              clusterSalons ? salonClusterManagerId : null,
          infoWindow: InfoWindow(
            title: salon.name,
            snippet: salon.locationLabel,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            mapMarkerHueForSalon(salon, selected: isSelected),
          ),
          onTap: () {
            ref.read(selectedMapSalonProvider.notifier).state = salon;
          },
        ),
      );
    }

    return markers;
  }

  Future<void> _fitSalonsOnMap(
    List<SalonMapItem> salons,
    LatLng? userPosition,
  ) async {
    if (_mapController == null || salons.isEmpty) {
      return;
    }

    final points = <LatLng>[
      ?userPosition,
      ...salons.map((e) => e.position),
    ];

    if (points.length == 1) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 14),
      );
      return;
    }

    final minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final minLng =
        points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final maxLng =
        points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  void _updateSearchThisAreaFlag(LatLng cameraTarget) {
    final committed = ref.read(mapCommittedSearchCenterProvider);
    final moved = Geolocator.distanceBetween(
          committed.latitude,
          committed.longitude,
          cameraTarget.latitude,
          cameraTarget.longitude,
        ) >
        220;
    ref.read(mapSearchThisAreaVisibleProvider.notifier).state = moved;
  }

  void _onSearchThisArea() {
    final LatLng target = ref.read(mapCameraTargetProvider) ??
        ref.read(mapCommittedSearchCenterProvider);
    ref.read(mapCommittedSearchCenterProvider.notifier).state = target;
    ref.read(mapSearchThisAreaVisibleProvider.notifier).state = false;
    ref.read(selectedMapSalonProvider.notifier).state = null;
  }

  void _openSalonDetails(String salonId) {
    context.push(AppRoutes.customerSalon(salonId));
  }

  void _bookSalon(String salonId) {
    context.push(AppRoutes.customerSalonBook(salonId));
  }

  Future<void> _goToMyLocation() async {
    ref.invalidate(customerCurrentPositionProvider);
    final pos = await ref.read(customerCurrentPositionProvider.future);
    if (!mounted) {
      return;
    }
    if (pos == null) {
      return;
    }
    final ll = LatLng(pos.latitude, pos.longitude);
    ref.read(mapCommittedSearchCenterProvider.notifier).state = ll;
    ref.read(mapCameraTargetProvider.notifier).state = ll;
    ref.read(mapSearchThisAreaVisibleProvider.notifier).state = false;
    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(ll, 14));
  }

  void _expandSearchRadius() {
    const steps = [1.0, 3.0, 5.0, 10.0];
    final r = ref.read(mapRadiusKmProvider);
    final next = steps.firstWhere(
      (e) => e > r + 0.01,
      orElse: () => steps.last,
    );
    ref.read(mapRadiusKmProvider.notifier).state = next;
  }

  Future<void> _pickRadiusKm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final current = ref.watch(mapRadiusKmProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.customerMapSelectRadiusTitle,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    for (final km in [1.0, 3.0, 5.0, 10.0])
                      ListTile(
                        title: Text(
                          l10n.customerMapRadiusLabelKm(
                            km % 1 == 0
                                ? km.toInt().toString()
                                : km.toStringAsFixed(1),
                          ),
                        ),
                        trailing: current == km
                            ? Icon(Icons.check_rounded, color: scheme.primary)
                            : null,
                        onTap: () {
                          ref.read(mapRadiusKmProvider.notifier).state = km;
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(customerMapSalonsProvider);
    final nearby = ref.watch(nearbyPublicSalonsProvider);
    final selectedSalon = ref.watch(selectedMapSalonProvider);
    final positionAsync = ref.watch(customerCurrentPositionProvider);

    ref.listen(customerCurrentPositionProvider, (previous, next) {
      next.maybeWhen(
        data: (pos) {
          if (pos == null || !mounted || _didCenterOnUser) {
            return;
          }
          _didCenterOnUser = true;
          final latLng = LatLng(pos.latitude, pos.longitude);
          ref.read(mapCommittedSearchCenterProvider.notifier).state = latLng;
          ref.read(mapCameraTargetProvider.notifier).state = latLng;
          ref.read(mapSearchThisAreaVisibleProvider.notifier).state = false;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) {
              return;
            }
            await _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(latLng, 14),
            );
          });
        },
        orElse: () {},
      );
    });

    final userPosition = positionAsync.maybeWhen(
      data: (p) => p != null ? LatLng(p.latitude, p.longitude) : null,
      orElse: () => null,
    );
    final locationLoading = positionAsync.isLoading;
    final locationDenied = positionAsync.maybeWhen(
      data: (p) => p == null,
      error: (e, st) => true,
      orElse: () => false,
    );

    return Scaffold(
      body: salonsAsync.when(
        loading: () => const _MapLoadingView(),
        error: (_, _) =>
            _MapErrorView(message: l10n.customerMapCouldNotLoadSalons),
        data: (_) {
          final clusterSalons = nearby.length >
              CustomerMapDiscoveryEngine.kMarkerClusterThreshold;
          final markers = _buildMarkers(
            l10n: l10n,
            salons: nearby,
            userPosition: userPosition,
            selected: selectedSalon,
            clusterSalons: clusterSalons,
            salonClusterManagerId: clusterSalons
                ? _salonClusterManager.clusterManagerId
                : null,
          );

          final headerSubtitle = nearby.isEmpty
              ? l10n.customerMapNoSalonsOnMap
              : l10n.customerMapSubtitleTagline;

          return Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: kCustomerMapDohaFallback,
                  zoom: 12,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                markers: markers,
                clusterManagers:
                    clusterSalons ? {_salonClusterManager} : const <ClusterManager>{},
                onMapCreated: (controller) async {
                  _mapController = controller;
                  final initialUser = ref
                      .read(customerCurrentPositionProvider)
                      .asData
                      ?.value;
                  if (initialUser != null) {
                    final ll = LatLng(
                      initialUser.latitude,
                      initialUser.longitude,
                    );
                    await controller.animateCamera(
                      CameraUpdate.newLatLngZoom(ll, 14),
                    );
                  } else if (nearby.isNotEmpty) {
                    await _fitSalonsOnMap(nearby, userPosition);
                  } else {
                    final c = ref.read(mapCommittedSearchCenterProvider);
                    await controller.animateCamera(
                      CameraUpdate.newLatLngZoom(c, 12),
                    );
                  }
                },
                onCameraMove: (pos) {
                  ref.read(mapCameraTargetProvider.notifier).state = pos.target;
                },
                onCameraIdle: () {
                  final target = ref.read(mapCameraTargetProvider);
                  if (target != null) {
                    _updateSearchThisAreaFlag(target);
                  }
                },
                onTap: (_) {
                  ref.read(selectedMapSalonProvider.notifier).state = null;
                },
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 16,
                    end: 16,
                    top: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MapSearchHeader(
                        title: l10n.zuranoNearbyTitle,
                        subtitle: headerSubtitle,
                        onBack: () => context.pop(),
                      ),
                      const SizedBox(height: 10),
                      const MapFilterChips(),
                    ],
                  ),
                ),
              ),

              if (locationDenied)
                PositionedDirectional(
                  top: 200,
                  start: 16,
                  end: 16,
                  child: MapPermissionBanner(
                    message: l10n.customerMapPermissionBanner,
                  ),
                ),

              if (locationLoading)
                PositionedDirectional(
                  top: 200,
                  start: 16,
                  end: 16,
                  child: _SmallMapStatus(
                    message: l10n.customerMapFindingLocation,
                  ),
                ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 200,
                child: Center(
                  child: SearchThisAreaButton(
                    onPressed: _onSearchThisArea,
                  ),
                ),
              ),

              PositionedDirectional(
                end: 16,
                bottom: selectedSalon == null ? 132 : 268,
                child: FloatingActionButton.small(
                  heroTag: 'customer_map_location',
                  backgroundColor: AppBrandColors.primary,
                  foregroundColor: AppBrandColors.onPrimary,
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ),

              PositionedDirectional(
                end: 16,
                bottom: selectedSalon == null ? 76 : 212,
                child: FloatingActionButton.small(
                  heroTag: 'customer_map_radius',
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: AppBrandColors.primary,
                  onPressed: () => _pickRadiusKm(context),
                  child: const Icon(Icons.radio_button_checked_rounded),
                ),
              ),

              PositionedDirectional(
                end: 16,
                bottom: selectedSalon == null ? 20 : 156,
                child: FloatingActionButton.small(
                  heroTag: 'customer_map_fit',
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: AppBrandColors.primary,
                  onPressed: () => _fitSalonsOnMap(nearby, userPosition),
                  child: const Icon(Icons.center_focus_strong_rounded),
                ),
              ),

              Positioned.fill(
                child: NearbyPlacesBottomSheet(
                  onSelectSalon: (s) {
                    ref.read(selectedMapSalonProvider.notifier).state = s;
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(s.position, 15),
                    );
                  },
                  onBookSalon: (s) => _bookSalon(s.id),
                  onUseMyLocation: _goToMyLocation,
                  onExpandRadius: _expandSearchRadius,
                ),
              ),

              if (selectedSalon != null)
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 120,
                  child: SalonMapBottomCard(
                    salon: selectedSalon,
                    onViewDetails: () =>
                        _openSalonDetails(selectedSalon.id),
                    onBookNow: () => _bookSalon(selectedSalon.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MapLoadingView extends StatelessWidget {
  const _MapLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _MapErrorView extends StatelessWidget {
  const _MapErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallMapStatus extends StatelessWidget {
  const _SmallMapStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
