import 'package:flutter/material.dart';

import '../../core/phone/zurano_phone_country.dart';
import '../../core/phone/zurano_phone_country_repository.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/zurano_tokens.dart';

class ZuranoCountryCodePickerSheet extends StatefulWidget {
  const ZuranoCountryCodePickerSheet({
    super.key,
    required this.repository,
    required this.selected,
    this.title,
    this.searchHint,
  });

  final ZuranoPhoneCountryRepository repository;
  final ZuranoPhoneCountry selected;
  final String? title;
  final String? searchHint;

  static Future<ZuranoPhoneCountry?> show(
    BuildContext context, {
    required ZuranoPhoneCountryRepository repository,
    required ZuranoPhoneCountry selected,
    String? title,
    String? searchHint,
  }) {
    return showModalBottomSheet<ZuranoPhoneCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ZuranoCountryCodePickerSheet(
        repository: repository,
        selected: selected,
        title: title,
        searchHint: searchHint,
      ),
    );
  }

  @override
  State<ZuranoCountryCodePickerSheet> createState() =>
      _ZuranoCountryCodePickerSheetState();
}

class _ZuranoCountryCodePickerSheetState
    extends State<ZuranoCountryCodePickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final title = widget.title ?? '';
    final hint = widget.searchHint ?? '';

    final items = widget.repository.search(_query, limit: 120);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ZuranoTokens.textDark,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.small),
                    itemBuilder: (context, index) {
                      final c = items[index];
                      final selected = c.isoCode == widget.selected.isoCode;
                      final name = widget.repository.displayNameForLocale(
                        c,
                        locale,
                      );
                      return Material(
                        color: selected
                            ? ZuranoTokens.lightPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          onTap: () => Navigator.of(context).pop(c),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium,
                              vertical: AppSpacing.medium,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  c.flagEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: AppSpacing.medium),
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: ZuranoTokens.textDark,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.medium),
                                Text(
                                  c.dialCode,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: ZuranoTokens.textGray,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

