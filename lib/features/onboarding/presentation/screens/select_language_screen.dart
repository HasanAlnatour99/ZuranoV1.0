import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../auth/presentation/widgets/auth_shell.dart';
import '../widgets/language_option_card.dart';

class SelectLanguageScreen extends ConsumerStatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  ConsumerState<SelectLanguageScreen> createState() =>
      _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends ConsumerState<SelectLanguageScreen> {
  Locale? _selected;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingPrefsProvider);
    final code = onboarding.selectedLanguageCode?.trim();
    if (code == 'en' || code == 'ar') {
      _selected = Locale.fromSubtags(languageCode: code!);
    } else {
      _selected = null;
    }
  }

  Future<void> _onContinue() async {
    if (_selected == null) {
      return;
    }
    await ref
        .read(onboardingPrefsProvider.notifier)
        .completeLanguageSelection(_selected!);
    if (mounted) {
      context.go(AppRoutes.onboardingCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AuthShell(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40.h),
                      Center(
                        child:
                            Image.asset(
                                  'assets/images/branding/zurano_lang.png',
                                  width: 240.w,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                )
                                .animate()
                                .fade(
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .scaleXY(
                                  begin: 0.92,
                                  end: 1,
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                      ),
                      SizedBox(height: 32.h),
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.preAuthLanguageTitle,
                                textAlign: TextAlign.start,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                l10n.preAuthLanguageSubtitle,
                                textAlign: TextAlign.start,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fade(duration: 480.ms, curve: Curves.easeOutCubic)
                          .slideY(
                            begin: 0.3,
                            duration: 480.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      SizedBox(height: 32.h),
                      LanguageOptionCard(
                        title: l10n.preAuthLanguageEnglish,
                        subtitle: l10n.preAuthLanguageEnglishHint,
                        selected: _selected?.languageCode == 'en',
                        onTap: () =>
                            setState(() => _selected = const Locale('en')),
                      ).animate().fade(
                        delay: 80.ms,
                        duration: 420.ms,
                        curve: Curves.easeOutCubic,
                      ),
                      SizedBox(height: 12.h),
                      LanguageOptionCard(
                        title: l10n.preAuthLanguageArabic,
                        subtitle: l10n.preAuthLanguageArabicHint,
                        selected: _selected?.languageCode == 'ar',
                        onTap: () =>
                            setState(() => _selected = const Locale('ar')),
                      ).animate().fade(
                        delay: 140.ms,
                        duration: 420.ms,
                        curve: Curves.easeOutCubic,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                child:
                    _OnboardingLocaleContinueCta(
                      label: l10n.preAuthContinue,
                      onPressed: _selected == null ? null : _onContinue,
                    ).animate().fade(
                      delay: 400.ms,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width primary CTA with brand gradient. Used only for locale continue;
/// does not run navigation on its own.
class _OnboardingLocaleContinueCta extends StatelessWidget {
  const _OnboardingLocaleContinueCta({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? AppPremiumGradients.accent : null,
            color: enabled ? null : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppBrandColorsPremium.primary.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 56.h,
              width: double.infinity,
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: enabled
                        ? AppBrandColorsPremium.onPrimary
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
