import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../../data/models/customer_salon_preview_model.dart';
import '../controllers/customer_home_providers.dart';
import '../theme/zurano_customer_colors.dart';

class PremiumRecommendedSalonCard extends ConsumerWidget {
  const PremiumRecommendedSalonCard({
    super.key,
    required this.salon,
    required this.onOpen,
  });

  final CustomerSalonPreviewModel salon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = salon.coverImageUrl.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 7,
                    child: cover.isNotEmpty
                        ? Image.network(
                            cover,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                color: ZuranoCustomerColors.lavenderSoft,
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ZuranoCustomerColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF3F4F6),
                              alignment: Alignment.center,
                              child: const Icon(Icons.storefront_outlined),
                            ),
                          )
                        : Container(
                            color: ZuranoCustomerColors.lavenderSoft,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.storefront_outlined,
                              color: ZuranoCustomerColors.primary,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _RatingBadge(rating: salon.ratingAvg),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _FavoriteSalonButton(salonId: salon.salonId),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: salon.logoUrl.trim().isNotEmpty
                          ? NetworkImage(salon.logoUrl)
                          : null,
                      backgroundColor: ZuranoCustomerColors.textStrong,
                      child: salon.logoUrl.trim().isEmpty
                          ? const Icon(Icons.storefront, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salon.salonName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 17,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  salon.locationLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (salon.tags.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 6,
                          runSpacing: 6,
                          children: salon.tags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1E8FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
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
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteSalonButton extends ConsumerWidget {
  const _FavoriteSalonButton({required this.salonId});

  final String salonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoriteSalonIdsProvider);
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;

    final isFavorite = favAsync.maybeWhen(
      data: (ids) => ids.contains(salonId),
      orElse: () => false,
    );

    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: uid == null || uid.isEmpty
            ? null
            : () async {
                final repo = ref.read(customerHomeRepositoryProvider);
                await repo.toggleFavorite(
                  uid: uid,
                  salonId: salonId,
                  currentlyFavorite: isFavorite,
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            color: ZuranoCustomerColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
