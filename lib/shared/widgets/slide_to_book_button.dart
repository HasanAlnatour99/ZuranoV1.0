import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideToBookButton extends StatefulWidget {
  const SlideToBookButton({
    super.key,
    required this.onCompleted,
    this.text = '',
    this.loadingText = '',
    this.enabled = true,
    this.height = 72,
    this.thumbSize = 64,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.completeThreshold = 0.85,
  });

  final Future<void> Function() onCompleted;
  final String text;
  final String loadingText;
  final bool enabled;
  final double height;
  final double thumbSize;
  final EdgeInsets margin;
  final double completeThreshold;

  @override
  State<SlideToBookButton> createState() => _SlideToBookButtonState();
}

class _SlideToBookButtonState extends State<SlideToBookButton>
    with TickerProviderStateMixin {
  late final AnimationController _resetController;
  late final AnimationController _shineController;
  late final AnimationController _pulseController;

  double _dragX = 0;
  double _resetStartX = 0;
  bool _isLoading = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        final curved = Curves.easeOutCubic.transform(_resetController.value);
        setState(() {
          _dragX = lerpDouble(_resetStartX, 0, curved) ?? 0;
        });
      });

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _resetController.dispose();
    _shineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _complete(double maxDrag) async {
    if (_completed || _isLoading || !widget.enabled) return;

    setState(() {
      _completed = true;
      _isLoading = true;
      _dragX = maxDrag;
    });

    HapticFeedback.mediumImpact();

    try {
      await widget.onCompleted();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _completed = false;
          _dragX = 0;
        });
      }
    }
  }

  void _reset() {
    _resetStartX = _dragX;
    _resetController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - widget.margin.horizontal;
        final maxDrag = totalWidth - widget.thumbSize - 8;
        final progress = maxDrag <= 0 ? 0.0 : (_dragX / maxDrag).clamp(0.0, 1.0);

        return Padding(
          padding: widget.margin,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: widget.enabled ? 1 : 0.45,
            child: SizedBox(
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _SliderBackground(
                    progress: progress,
                    shineController: _shineController,
                    enabled: widget.enabled,
                  ),
                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 160),
                        opacity: 1 - (progress * 0.55),
                        child: Text(
                          _isLoading ? widget.loadingText : widget.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ) ??
                              TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: isRtl ? null : 7 + _dragX,
                    end: isRtl ? 7 + _dragX : null,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: widget.enabled && !_isLoading
                          ? (details) {
                              final delta = isRtl
                                  ? -details.delta.dx
                                  : details.delta.dx;

                              setState(() {
                                _dragX = (_dragX + delta).clamp(0, maxDrag);
                              });
                            }
                          : null,
                      onHorizontalDragEnd: widget.enabled && !_isLoading
                          ? (_) {
                              if (progress >= widget.completeThreshold) {
                                _complete(maxDrag);
                              } else {
                                HapticFeedback.selectionClick();
                                _reset();
                              }
                            }
                          : null,
                      child: ScaleTransition(
                        scale: _pulseController,
                        child: Container(
                          width: widget.thumbSize,
                          height: widget.thumbSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.onPrimary,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.28),
                                blurRadius: 26,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.event_available_rounded,
                                  color: colorScheme.primary,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (!_isLoading)
                    PositionedDirectional(
                      start: isRtl ? null : widget.thumbSize + 34,
                      end: isRtl ? widget.thumbSize + 34 : null,
                      child: IgnorePointer(
                        child: _AnimatedChevrons(
                          controller: _shineController,
                          isRtl: isRtl,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderBackground extends StatelessWidget {
  const _SliderBackground({
    required this.progress,
    required this.shineController,
    required this.enabled,
  });

  final double progress;
  final AnimationController shineController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: shineController,
      builder: (context, _) {
        final shineX = -1.2 + (shineController.value * 2.4);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                scheme.primary,
                scheme.primaryContainer,
                scheme.secondaryContainer,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: enabled ? 0.28 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: scheme.onPrimary.withValues(alpha: 0.24),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(shineX * 260, 0),
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.onPrimary.withValues(alpha: 0),
                            scheme.onPrimary.withValues(alpha: 0.16),
                            scheme.onPrimary.withValues(alpha: 0),
                          ],
                        ),
                      ),
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

class _AnimatedChevrons extends StatelessWidget {
  const _AnimatedChevrons({
    required this.controller,
    required this.isRtl,
  });

  final AnimationController controller;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final opacity1 = (controller.value < 0.33) ? 1.0 : 0.35;
        final opacity2 =
            (controller.value >= 0.33 && controller.value < 0.66) ? 1.0 : 0.35;
        final opacity3 = (controller.value >= 0.66) ? 1.0 : 0.35;

        final icon = isRtl
            ? Icons.keyboard_double_arrow_left_rounded
            : Icons.keyboard_double_arrow_right_rounded;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: scheme.onPrimary.withValues(alpha: opacity1), size: 22),
            Transform.translate(
              offset: const Offset(-8, 0),
              child: Icon(
                icon,
                color: scheme.onPrimary.withValues(alpha: opacity2),
                size: 22,
              ),
            ),
            Transform.translate(
              offset: const Offset(-16, 0),
              child: Icon(
                icon,
                color: scheme.onPrimary.withValues(alpha: opacity3),
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}

