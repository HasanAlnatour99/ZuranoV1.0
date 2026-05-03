import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/customer_home_providers.dart';
import '../theme/zurano_customer_colors.dart';

class CustomerSearchBar extends ConsumerStatefulWidget {
  const CustomerSearchBar({super.key});

  @override
  ConsumerState<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends ConsumerState<CustomerSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(customerSearchTextProvider),
    );
    _controller.addListener(() {
      ref.read(customerSearchTextProvider.notifier).state = _controller.text
          .trimLeft();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ZuranoCustomerColors.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 22,
            color: ZuranoCustomerColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              cursorColor: ZuranoCustomerColors.primary,
              decoration: InputDecoration(
                hintText: l10n.zuranoDiscoverSearchHint,
                hintStyle: TextStyle(
                  color: ZuranoCustomerColors.textMuted.withValues(alpha: 0.9),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 15,
                color: ZuranoCustomerColors.textStrong,
              ),
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFE4DDED)),
          const SizedBox(width: 6),
          ZuranoFiltersButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.zuranoDiscoverFiltersComingSoon)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ZuranoFiltersButton extends StatelessWidget {
  const ZuranoFiltersButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: ZuranoCustomerColors.primary.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.zuranoDiscoverFiltersLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ZuranoCustomerColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
