import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.errorText,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  /// Forwarded to [TextField.onSubmitted] (e.g. focus moves on keyboard “next”).
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final decoration = InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon == null
          ? null
          : ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: suffixIcon,
            ),
      errorText: errorText,
      errorMaxLines: 3,
    ).applyDefaults(theme.inputDecorationTheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted:
              onSubmitted ??
              (textInputAction == TextInputAction.done
                  ? (_) => FocusManager.instance.primaryFocus?.unfocus()
                  : null),
          enabled: enabled,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
          cursorColor: theme.colorScheme.primary,
          decoration: decoration,
        ),
        if (helperText != null &&
            (errorText == null || errorText!.isEmpty)) ...[
          const SizedBox(height: AppSpacing.small),
          Text(
            helperText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
