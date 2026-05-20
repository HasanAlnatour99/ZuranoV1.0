import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

const _primaryPurple = Color(0xFF7B2FF7);
const _textSecondary = Color(0xFF7A728C);

class CustomerSearchBar extends StatefulWidget {
  const CustomerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: focused ? 0.16 : 0.08),
            blurRadius: focused ? 28 : 18,
            spreadRadius: focused ? -6 : -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.customersSearchHint,
          hintStyle: const TextStyle(
            color: _textSecondary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: _primaryPurple),
          suffixIcon: Icon(
            Icons.mic_none_rounded,
            color: _textSecondary.withValues(alpha: 0.72),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: _primaryPurple.withValues(alpha: 0.08),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: _primaryPurple.withValues(alpha: 0.34),
            ),
          ),
        ),
      ),
    );
  }
}
