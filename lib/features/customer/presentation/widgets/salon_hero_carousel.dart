import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Full-bleed salon hero: swipe between photos or auto-advance every [interval].
///
/// [imageUrls] should be deduplicated; cover image first if provided separately.
class SalonHeroCarousel extends StatefulWidget {
  const SalonHeroCarousel({
    super.key,
    required this.imageUrls,
    this.autoAdvanceInterval = const Duration(seconds: 5),
  });

  final List<String> imageUrls;
  final Duration autoAdvanceInterval;

  @override
  State<SalonHeroCarousel> createState() => _SalonHeroCarouselState();
}

class _SalonHeroCarouselState extends State<SalonHeroCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scheduleAutoAdvance();
  }

  @override
  void didUpdateWidget(SalonHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length ||
        !_sameUrls(oldWidget.imageUrls, widget.imageUrls)) {
      _timer?.cancel();
      _pageIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _scheduleAutoAdvance();
    }
  }

  bool _sameUrls(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  void _scheduleAutoAdvance() {
    _timer?.cancel();
    if (widget.imageUrls.length <= 1) {
      return;
    }
    _timer = Timer.periodic(widget.autoAdvanceInterval, (_) => _advanceOne());
  }

  void _advanceOne() {
    if (!mounted || !_pageController.hasClients) {
      return;
    }
    final n = widget.imageUrls.length;
    if (n <= 1) {
      return;
    }
    final next = (_pageIndex + 1) % n;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _pageIndex = index);
    _scheduleAutoAdvance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return const _HeroFallback();
    }
    if (urls.length == 1) {
      return _HeroNetworkImage(url: urls.first);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: urls.length,
          itemBuilder: (context, index) {
            return _HeroNetworkImage(url: urls[index]);
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(urls.length, (i) {
              final selected = i == _pageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: selected ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _HeroNetworkImage extends StatelessWidget {
  const _HeroNetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final u = url.trim();
    if (u.isEmpty) {
      return const _HeroFallback();
    }

    // Decode at roughly screen resolution — large Firebase Storage JPEGs are slow
    // to fetch *and* expensive to rasterize at full pixel size.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final wPx = (MediaQuery.sizeOf(context).width * dpr).round();
    final hPx = (520 * dpr).round();

    return CachedNetworkImage(
      imageUrl: u,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: wPx,
      memCacheHeight: hPx,
      fadeInDuration: const Duration(milliseconds: 240),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (context, _) => const _HeroLoadingPlaceholder(),
      errorWidget: (context, url, error) => const _HeroFallback(),
    );
  }
}

/// Visible while bytes download — avoids an empty hero that feels “stuck”.
class _HeroLoadingPlaceholder extends StatelessWidget {
  const _HeroLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9E4FF),
      highlightColor: const Color(0xFFF8F6FF),
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B2FF7), Color(0xFF9B51E0), Color(0xFFB794F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 72,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
