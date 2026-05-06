import 'package:flutter/material.dart';

import '../../features/onboarding/domain/value_objects/country_option.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import 'app_country_picker_field.dart';
import 'app_text_field.dart';
import 'national_phone_input_formatter.dart';

/// National number field with a country selector that supplies dial code + ISO.
class AppPhoneWithCountryField extends StatelessWidget {
  const AppPhoneWithCountryField({
    required this.label,
    required this.countryLabel,
    required this.countrySelected,
    required this.onCountryChanged,
    required this.nationalController,
    this.countryErrorText,
    this.nationalErrorText,
    this.enabled = true,
    this.nationalHintText,
    this.nationalTextInputAction = TextInputAction.done,
    super.key,
  });

  final String label;
  final String countryLabel;
  final CountryOption? countrySelected;
  final ValueChanged<CountryOption?> onCountryChanged;
  final TextEditingController nationalController;
  final String? countryErrorText;
  final String? nationalErrorText;
  final bool enabled;
  final String? nationalHintText;
  final TextInputAction nationalTextInputAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.medium),
        AppCountryPickerField(
          label: countryLabel,
          selected: countrySelected,
          onChanged: onCountryChanged,
          errorText: countryErrorText,
          enabled: enabled,
        ),
        const SizedBox(height: AppSpacing.medium),
        AppTextField(
          label: countrySelected == null
              ? l10n.fieldLabelPhone
              : '${l10n.fieldLabelPhone} (${countrySelected!.dialCode})',
          hintText: nationalHintText ?? l10n.onboardingMobileNationalHint,
          controller: nationalController,
          keyboardType: TextInputType.phone,
          textInputAction: nationalTextInputAction,
          errorText: nationalErrorText,
          enabled: enabled,
          inputFormatters: [NationalPhoneInputFormatter()],
        ),
      ],
    );
  }
}
