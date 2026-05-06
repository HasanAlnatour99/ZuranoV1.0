import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customer_home/presentation/controllers/customer_location_providers.dart';
import '../data/customer_map_repository.dart';
import '../domain/salon_map_item.dart';
import 'widgets/map_permission_banner.dart';
import 'widgets/map_search_header.dart';
import 'widgets/salon_map_bottom_card.dart';

class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  static const LatLng _doha = LatLng(25.2854, 51.5310);

  GoogleMapController? _mapController;
  SalonMapItem? _selectedSalon;

  Set<Marker> _buildMarkers(
    AppLocalizations l10n,
    List<SalonMapItem> salons,
    LatLng? userPosition,
  ) {
    final markers = <Marker>{};

    if (userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer_location'),
          position: userPosition,
          infoWindow: InfoWindow(title: l10n.customerMapMarkerYouAreHere),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    for (final salon in salons) {
      markers.add(
        Marker(
          markerId: MarkerId('salon_${salon.id}'),
          position: salon.position,
          infoWindow: InfoWindow(
            title: salon.name,
            snippet: salon.locationLabel,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          onTap: () {
            setState(() => _selectedSalon = salon);
          },
        ),
      );
    }

    return markers;
  }

  List<SalonMapItem> _applyDistanceIfAvailable(
    List<SalonMapItem> salons,
    LatLng? userPosition,
  ) {
    final user = userPosition;

    if (user == null) return salons;

    return ref.read(customerMapRepositoryProvider).withDistance(
          salons: salons,
          userLat: user.latitude,
          userLng: user.longitude,
        );
  }

  Future<void> _fitSalonsOnMap(
    List<SalonMapItem> salons,
    LatLng? userPosition,
  ) async {
    if (_mapController == null || salons.isEmpty) return;

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

  void _openSalonDetails(String salonId) {
    context.push(AppRoutes.customerSalon(salonId));
  }

  void _bookSalon(String salonId) {
    context.push(AppRoutes.customerSalonBook(salonId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(customerMapSalonsProvider);
    final positionAsync = ref.watch(customerCurrentPositionProvider);

    ref.listen(customerCurrentPositionProvider, (prev, next) {
      next.maybeWhen(
        data: (pos) {
          if (pos == null || !mounted) return;
          final latLng = LatLng(pos.latitude, pos.longitude);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
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
        error: (_, _) => _MapErrorView(message: l10n.customerMapCouldNotLoadSalons),
        data: (rawSalons) {
          final salons = _applyDistanceIfAvailable(rawSalons, userPosition);
          final markers = _buildMarkers(l10n, salons, userPosition);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _doha,
                  zoom: 12,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                markers: markers,
                onMapCreated: (controller) async {
                  _mapController = controller;

                  if (userPosition != null) {
                    await controller.animateCamera(
                      CameraUpdate.newLatLngZoom(userPosition, 14),
                    );
                  } else if (salons.isNotEmpty) {
                    await _fitSalonsOnMap(salons, userPosition);
                  }
                },
                onTap: (_) {
                  setState(() => _selectedSalon = null);
                },
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 16,
                    end: 16,
                    top: 12,
                  ),
                  child: MapSearchHeader(
                    title: l10n.zuranoNearbyTitle,
                    subtitle: salons.isEmpty
                        ? l10n.customerMapNoSalonsOnMap
                        : l10n.customerMapSalonsOnMapCount(salons.length.toString()),
                    onBack: () => context.pop(),
                  ),
                ),
              ),

              if (locationDenied)
                PositionedDirectional(
                  top: 118,
                  start: 16,
                  end: 16,
                  child: MapPermissionBanner(
                    message: l10n.customerMapPermissionBanner,
                  ),
                ),

              if (locationLoading)
                PositionedDirectional(
                  top: 118,
                  start: 16,
                  end: 16,
                  child: _SmallMapStatus(
                    message: l10n.customerMapFindingLocation,
                  ),
                ),

              PositionedDirectional(
                end: 16,
                bottom: _selectedSalon == null ? 112 : 250,
                child: FloatingActionButton.small(
                  heroTag: 'customer_map_location',
                  backgroundColor: AppBrandColors.primary,
                  foregroundColor: AppBrandColors.onPrimary,
                  onPressed: () {
                    ref.invalidate(customerCurrentPositionProvider);
                  },
                  child: const Icon(Icons.my_location_rounded),
                ),
              ),

              PositionedDirectional(
                end: 16,
                bottom: _selectedSalon == null ? 58 : 196,
                child: FloatingActionButton.small(
                  heroTag: 'customer_map_fit',
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: AppBrandColors.primary,
                  onPressed: () => _fitSalonsOnMap(salons, userPosition),
                  child: const Icon(Icons.center_focus_strong_rounded),
                ),
              ),

              if (salons.isEmpty)
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 32,
                  child: _SmallMapStatus(
                    message: l10n.customerMapNoSalonsOnMap,
                  ),
                ),

              if (_selectedSalon != null)
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 24,
                  child: SalonMapBottomCard(
                    salon: _selectedSalon!,
                    onViewDetails: () =>
                        _openSalonDetails(_selectedSalon!.id),
                    onBookNow: () => _bookSalon(_selectedSalon!.id),
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
