import 'package:flutter/material.dart';

import '../../core/phone/zurano_phone_country.dart';
import '../../core/phone/zurano_phone_country_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'zurano_country_code_picker_sheet.dart';

class ZuranoPhoneField extends StatelessWidget {
  const ZuranoPhoneField({
    super.key,
    required this.controller,
    required this.country,
    required this.repository,
    required this.label,
    this.errorText,
    this.onCountryChanged,
    this.onChanged,
    this.countryPickerTitle,
    this.countryPickerSearchHint,
    this.textInputAction,
  });

  final TextEditingController controller;
  final ZuranoPhoneCountry country;
  final ZuranoPhoneCountryRepository repository;
  final String label;
  final String? errorText;
  final ValueChanged<ZuranoPhoneCountry>? onCountryChanged;
  final ValueChanged<String>? onChanged;
  final String? countryPickerTitle;
  final String? countryPickerSearchHint;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColorsLight.textSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CountryButton(
              country: country,
              onTap: onCountryChanged == null
                  ? null
                  : () async {
                      final picked = await ZuranoCountryCodePickerSheet.show(
                        context,
                        repository: repository,
                        selected: country,
                        title: countryPickerTitle,
                        searchHint: countryPickerSearchHint,
                      );
                      if (picked != null) {
                        onCountryChanged?.call(picked);
                      }
                    },
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: textInputAction ?? TextInputAction.next,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: '—',
                  filled: true,
                  fillColor: scheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    borderSide: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    borderSide: BorderSide(
                      color: scheme.primary,
                      width: 1.4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    borderSide: BorderSide(color: scheme.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    borderSide: BorderSide(color: scheme.error, width: 1.4),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null && errorText!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onTap});

  final ZuranoPhoneCountry country;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                country.dialCode,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColorsLight.textPrimary,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColorsLight.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

