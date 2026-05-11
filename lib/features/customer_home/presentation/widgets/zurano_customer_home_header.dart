import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../controllers/customer_location_providers.dart';
import '../theme/zurano_customer_home_design_tokens.dart';

/// Soft lavender hero: location pill, bell, headline + subtitle.
class ZuranoCustomerHomeHeader extends ConsumerWidget {
  const ZuranoCustomerHomeHeader({super.key});

  static String? _cityLine(AppLocalizations l10n, Placemark pm) {
    String? pick(Iterable<String?> candidates) {
      for (final raw in candidates) {
        final t = raw?.trim();
        if (t != null && t.isNotEmpty) {
          return t;
        }
      }
      return null;
    }

    final city = pick([
      pm.locality,
      pm.subAdministrativeArea,
      pm.administrativeArea,
    ]);
    final country = pm.country?.trim();
    if (city != null && country != null && country.isNotEmpty) {
      return l10n.zuranoHomeLocationCityCountry(city, country);
    }
    if (city != null && city.isNotEmpty) {
      return city;
    }
    if (country != null && country.isNotEmpty) {
      return country;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    final positionAsync = ref.watch(customerCurrentPositionProvider);
    final placeAsync = ref.watch(customerHomeResolvedPlaceProvider);

    final String locationLabel = positionAsync.when(
      loading: () => l10n.zuranoHomeLocationLoading,
      error: (_, _) => l10n.zuranoHomeLocationUnavailable,
      data: (pos) {
        if (pos == null) {
          return l10n.zuranoHomeLocationUnavailable;
        }
        return placeAsync.when(
          loading: () => l10n.zuranoHomeLocationLoading,
          error: (_, _) => l10n.zuranoHomeLocationNearYou,
          data: (pm) {
            if (pm == null) {
              return l10n.zuranoHomeLocationNearYou;
            }
            return _cityLine(l10n, pm) ?? l10n.zuranoHomeLocationNearYou;
          },
        );
      },
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF5EEFF),
            ZuranoCustomerHomeColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, top + 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        ref.invalidate(customerCurrentPositionProvider);
                        ref.invalidate(customerHomeResolvedPlaceProvider);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: ZuranoCustomerHomeColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                locationLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ZuranoCustomerHomeColors.darkText,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: ZuranoCustomerHomeColors.mutedText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                  child: IconButton(
                    tooltip: l10n.customerNotificationsTooltip,
                    onPressed: () => context.push(AppRoutes.notifications),
                    icon: Builder(
                      builder: (context) {
                        final n = ref.watch(unreadNotificationCountProvider);
                        return AppNotificationBadge(
                          count: n,
                          child: Icon(
                            Icons.notifications_outlined,
                            color: ZuranoCustomerHomeColors.darkText,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Builder(
              builder: (context) {
                final narrow =
                    MediaQuery.sizeOf(context).width < 340;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: narrow ? 22 : 24,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: ZuranoCustomerHomeColors.darkText,
                        ),
                        children: [
                          TextSpan(text: '${l10n.zuranoHomeHeroFindYour}\n'),
                          TextSpan(
                            text: l10n.zuranoHomeHeroPerfectStyle,
                            style: const TextStyle(
                              color: ZuranoCustomerHomeColors.primary,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 6,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 17,
                                color: ZuranoCustomerHomeColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.zuranoHomeHeroSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: ZuranoCustomerHomeColors.mutedText,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
