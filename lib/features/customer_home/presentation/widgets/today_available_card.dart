import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/public_specialist_model.dart';
import '../theme/zurano_customer_colors.dart';

class TodayAvailableCard extends StatelessWidget {
  const TodayAvailableCard({
    super.key,
    required this.specialist,
    required this.fallbackBadge,
  });

  final PublicSpecialistModel specialist;
  final String fallbackBadge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badge = specialist.nextAvailableSlotText?.trim();
    final badgeText = (badge != null && badge.isNotEmpty) ? badge : fallbackBadge;
    final photo = specialist.photoUrl?.trim();
    final hasPhoto = photo != null && photo.isNotEmpty;

    return SizedBox(
      width: 250,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: hasPhoto
                        ? AppNetworkImage(imageUrl: photo, fit: BoxFit.cover)
                        : ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_rounded,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        specialist.displayName.isNotEmpty
                            ? specialist.displayName
                            : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ZuranoCustomerColors.textStrong,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialist.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ZuranoCustomerColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ZuranoCustomerColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

