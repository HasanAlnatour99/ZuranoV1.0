import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/session_provider.dart';
import '../controllers/customer_location_providers.dart';
import '../theme/zurano_customer_colors.dart';

class CustomerHomeHeader extends ConsumerWidget {
  const CustomerHomeHeader({super.key});

  String _timeGreeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) {
      return l10n.customerDiscoveryGoodMorning;
    }
    if (h < 17) {
      return l10n.customerDiscoveryGoodAfternoon;
    }
    return l10n.customerDiscoveryGoodEvening;
  }

  String _displayName(WidgetRef ref, AppLocalizations l10n) {
    final profile = ref.watch(sessionUserProvider).asData?.value;
    final raw = profile?.name.trim() ?? '';
    if (raw.isNotEmpty) {
      return raw;
    }
    return l10n.zuranoDiscoverGuestName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadNotificationCountProvider);
    final name = _displayName(ref, l10n);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final headlineSize = screenWidth < 370 ? 26.0 : 28.0;
    final greetingSize = screenWidth < 370 ? 14.0 : 15.0;

    final baseHeadlineStyle = GoogleFonts.playfairDisplay(
      fontSize: headlineSize,
      height: 0.95,
      letterSpacing: -0.9,
      fontWeight: FontWeight.w900,
      color: ZuranoCustomerColors.textStrong,
    );

    final highlightStyle = GoogleFonts.playfairDisplay(
      fontSize: headlineSize,
      height: 0.95,
      letterSpacing: -0.9,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      color: ZuranoCustomerColors.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: greetingSize,
                      color: ZuranoCustomerColors.textMuted,
                    ),
                    children: [
                      TextSpan(text: '${_timeGreeting(l10n)}, '),
                      TextSpan(
                        text: l10n.customerDiscoveryNameWave(name),
                        style: GoogleFonts.playfairDisplay(
                          textStyle: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontSize: greetingSize + 1,
                                color: ZuranoCustomerColors.textStrong,
                                fontWeight: FontWeight.w600,
                                height: 1.05,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ZuranoNotificationBell(
                hasUnread: unread > 0,
                onPressed: () {
                  final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
                  if (uid != null && uid.isNotEmpty) {
                    context.go(AppRoutes.notifications);
                  } else {
                    context.go(AppRoutes.customerAuth);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                textScaler: const TextScaler.linear(1),
                text: TextSpan(
                  style: baseHeadlineStyle,
                  children: [
                    TextSpan(text: '${l10n.zuranoHomeHeadlineLine1}\n'),
                    TextSpan(text: l10n.zuranoHomeHeadlineLine2Prefix),
                    TextSpan(
                      text: l10n.zuranoHomeHeadlineHighlight,
                      style: highlightStyle,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: _CustomerHomeLocationPill(),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CustomerHomeLocationPill extends ConsumerWidget {
  const _CustomerHomeLocationPill();

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
    final positionAsync = ref.watch(customerCurrentPositionProvider);
    final placeAsync = ref.watch(customerHomeResolvedPlaceProvider);

    final String label = positionAsync.when(
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
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: ZuranoCustomerColors.lavenderSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 17,
            color: ZuranoCustomerColors.primary,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: ZuranoCustomerColors.textStrong,
              ),
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 17,
            color: ZuranoCustomerColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class ZuranoNotificationBell extends StatelessWidget {
  const ZuranoNotificationBell({
    super.key,
    required this.onPressed,
    required this.hasUnread,
  });

  final VoidCallback onPressed;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZuranoCustomerColors.lavenderSoft,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          width: 48,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: ZuranoCustomerColors.primary,
                size: 23,
              ),
              if (hasUnread)
                const Positioned(
                  right: 8,
                  top: 10,
                  child: SizedBox(
                    height: 7,
                    width: 7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
