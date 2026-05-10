import 'package:flutter/material.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/customer_home_ui_models.dart';
import '../theme/zurano_customer_home_design_tokens.dart';

class ZuranoSpecialistCard extends StatelessWidget {
  const ZuranoSpecialistCard({
    super.key,
    required this.specialist,
    required this.onTap,
  });

  final RecommendedSpecialistUi specialist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photo = specialist.imageUrl.trim();

    return SizedBox(
      width: 260,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ClipOval(
                          child: photo.isNotEmpty
                              ? AppNetworkImage(
                                  imageUrl: photo,
                                  fit: BoxFit.cover,
                                )
                              : ColoredBox(
                                  color: ZuranoCustomerHomeColors.lavender,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: ZuranoCustomerHomeColors.primary
                                        .withValues(alpha: 0.6),
                                    size: 32,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ZuranoCustomerHomeColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  specialist.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        specialist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ZuranoCustomerHomeColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        specialist.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ZuranoCustomerHomeColors.mutedText,
                        ),
                      ),
                      if (specialist.yearsExperience != null &&
                          specialist.yearsExperience! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.zuranoSpecialistYearsExperience(
                            specialist.yearsExperience!,
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ZuranoCustomerHomeColors.primary,
                          ),
                        ),
                      ],
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
