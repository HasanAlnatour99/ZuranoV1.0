import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/signup_premium_tokens.dart';

/// Light-theme [TextFormField] for signup (filled surface, premium radius).
class AuthSignupTextField extends StatelessWidget {
  const AuthSignupTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.autofillHints,
    this.inputFormatters,
    this.autocorrect = true,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: SignupPremiumColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted:
              onFieldSubmitted ??
              (textInputAction == TextInputAction.done
                  ? (_) => FocusManager.instance.primaryFocus?.unfocus()
                  : null),
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          autocorrect: autocorrect,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: SignupPremiumColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: SignupPremiumColors.purpleDeep,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: SignupPremiumColors.inputFill,
            hintText: hintText,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: SignupPremiumColors.textSecondary.withValues(alpha: 0.85),
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                SignupPremiumLayout.fieldRadius,
              ),
              borderSide: const BorderSide(color: SignupPremiumColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                SignupPremiumLayout.fieldRadius,
              ),
              borderSide: const BorderSide(color: SignupPremiumColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                SignupPremiumLayout.fieldRadius,
              ),
              borderSide: const BorderSide(
                color: SignupPremiumColors.purpleDeep,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                SignupPremiumLayout.fieldRadius,
              ),
              borderSide: const BorderSide(color: SignupPremiumColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                SignupPremiumLayout.fieldRadius,
              ),
              borderSide: const BorderSide(color: SignupPremiumColors.error),
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: SignupPremiumColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
