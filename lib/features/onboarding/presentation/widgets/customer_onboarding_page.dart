import 'package:flutter/material.dart';

import '../models/onboarding_page_data.dart';
import 'onboarding_image_card.dart';

/// Single onboarding slide: image card, title, subtitle (scroll-safe).
class CustomerOnboardingPage extends StatelessWidget {
  const CustomerOnboardingPage({
    super.key,
    required this.data,
    required this.imageHeight,
    required this.isCompact,
  });

  final OnboardingPageData data;
  final double imageHeight;
  final bool isCompact;

  static const _titleColor = Color(0xFF111111);
  static const _subtitleColor = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    final titleSize = isCompact ? 28.0 : 34.0;
    final subtitleSize = isCompact ? 16.0 : 18.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OnboardingImageCard(
                  imagePath: data.imagePath,
                  height: imageHeight,
                  showBackground: data.showImageCardBackground,
                ),
                const SizedBox(height: 28),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: _titleColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      height: 1.45,
                      color: _subtitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
