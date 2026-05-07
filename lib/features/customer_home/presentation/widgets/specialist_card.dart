import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/public_specialist_model.dart';
import '../theme/zurano_customer_colors.dart';

class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.specialist,
    required this.viewLabel,
  });

  final PublicSpecialistModel specialist;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photo = specialist.photoUrl?.trim();
    final hasPhoto = photo != null && photo.isNotEmpty;

    return SizedBox(
      width: 270,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 72,
                    height: 96,
                    child: hasPhoto
                        ? AppNetworkImage(imageUrl: photo, fit: BoxFit.cover)
                        : ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_rounded,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                              size: 40,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        specialist.roleTitle.isNotEmpty ? specialist.roleTitle : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        specialist.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            specialist.ratingAvg > 0
                                ? specialist.ratingAvg.toStringAsFixed(1)
                                : '0.0',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: ZuranoCustomerColors.textStrong,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${specialist.ratingCount})',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColorsLight.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: ZuranoCustomerColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              viewLabel,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ZuranoCustomerColors.primary,
                                  ),
                            ),
                          ),
                        ],
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

