import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../shared/ui/zurano_responsive.dart';
import '../../data/models/customer_salon_model.dart';
import '../theme/zurano_customer_colors.dart';

class RecommendedSalonCard extends StatefulWidget {
  const RecommendedSalonCard({
    super.key,
    required this.salon,
    required this.onOpen,
    this.onToggleFavorite,
  });

  final CustomerSalonModel salon;
  final VoidCallback onOpen;
  final VoidCallback? onToggleFavorite;

  @override
  State<RecommendedSalonCard> createState() => _RecommendedSalonCardState();
}

class _RecommendedSalonCardState extends State<RecommendedSalonCard> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.salon;
    final cover = s.coverImageUrl.trim();
    final cardW = ZuranoResponsive.s(context, 186);
    final cardH = ZuranoResponsive.v(context, 204);
    final imageH = ZuranoResponsive.v(context, 100);

    return SizedBox(
      width: cardW,
      height: cardH,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onOpen,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ZuranoCustomerColors.borderHairline),
            boxShadow: [
              BoxShadow(
                color: ZuranoCustomerColors.primary.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    SizedBox(
                      height: imageH,
                      child: cover.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: cover,
                              height: imageH,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorWidget: (_, error, stackTrace) =>
                                  _coverFallback(context, imageH),
                              placeholder: (_, progress) => Container(
                                color: ZuranoCustomerColors.lavenderSoft,
                              ),
                            )
                          : _coverFallback(context, imageH),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.52),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    s.ratingAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Material(
                        shape: const CircleBorder(),
                        color: Colors.white.withValues(alpha: 0.9),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap:
                              widget.onToggleFavorite ??
                              () {
                                setState(() => _favorite = !_favorite);
                              },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: 18,
                              color: ZuranoCustomerColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: ZuranoResponsive.font(context, 13.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: ZuranoCustomerColors.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              s.locationLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: ZuranoCustomerColors.textMuted,
                                    fontSize: ZuranoResponsive.font(
                                      context,
                                      11.5,
                                    ),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: s.tags.take(3).map((t) {
                          return Chip(
                            label: Text(
                              t,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: ZuranoResponsive.font(
                                      context,
                                      10,
                                    ),
                                  ),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            backgroundColor: ZuranoCustomerColors.lavenderSoft,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverFallback(BuildContext context, double height) {
    return Container(
      color: ZuranoCustomerColors.lavenderSoft,
      height: height,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        color: ZuranoCustomerColors.primary,
        size: ZuranoResponsive.s(context, 32),
      ),
    );
  }
}
