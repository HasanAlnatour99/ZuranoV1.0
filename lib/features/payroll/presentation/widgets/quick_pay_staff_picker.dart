import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/employees/data/models/employee.dart';
import '../../../../l10n/app_localizations.dart';

String quickPayEmployeeRoleLabel(AppLocalizations l10n, String role) {
  final r = role.trim().toLowerCase();
  if (r == UserRoles.owner) return l10n.roleOwner;
  if (r == UserRoles.admin) return l10n.roleAdmin;
  if (r == UserRoles.barber) return l10n.roleBarber;
  if (r.isEmpty) return '';
  return role;
}

/// Premium staff row (Finance dashboard surfaces) for Quick Pay.
class QuickPayStaffSelectorTile extends StatelessWidget {
  const QuickPayStaffSelectorTile({
    super.key,
    required this.l10n,
    required this.employees,
    required this.selectedId,
    required this.onTap,
    this.enabled = true,
  });

  final AppLocalizations l10n;
  final List<Employee> employees;
  final String? selectedId;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Employee? selected;
    if (selectedId != null) {
      for (final e in employees) {
        if (e.id == selectedId) {
          selected = e;
          break;
        }
      }
    }
    final name = selected?.name ?? l10n.payrollQuickPayStaffPickerLabel;
    final roleLine = selected == null
        ? ''
        : quickPayEmployeeRoleLabel(l10n, selected.role);

    return Material(
      color: ZuranoPremiumUiColors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ZuranoPremiumUiColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  final url = selected?.avatarUrl?.trim();
                  final hasPhoto = url != null && url.isNotEmpty;
                  return Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ZuranoPremiumUiColors.softPurple,
                      borderRadius: BorderRadius.circular(18),
                      image: hasPhoto
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(url),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hasPhoto
                        ? null
                        : const Icon(
                            Icons.person_rounded,
                            color: ZuranoPremiumUiColors.primaryPurple,
                          ),
                  );
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.payrollQuickPayStaffPickerLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ZuranoPremiumUiColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: ZuranoPremiumUiColors.textPrimary,
                      ),
                    ),
                    if (roleLine.isNotEmpty)
                      Text(
                        roleLine,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (enabled)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: ZuranoPremiumUiColors.softPurple.withValues(
                      alpha: 0.54,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: ZuranoPremiumUiColors.deepPurple,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showQuickPayStaffPickerSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required List<Employee> employees,
  required String? selectedId,
  required ValueChanged<String> onEmployeeSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: ZuranoPremiumUiColors.background,
    builder: (ctx) => _QuickPayStaffSheetBody(
      l10n: l10n,
      employees: employees,
      selectedId: selectedId,
      onEmployeeSelected: (id) {
        Navigator.of(ctx).pop();
        onEmployeeSelected(id);
      },
    ),
  );
}

class _QuickPayStaffSheetBody extends StatefulWidget {
  const _QuickPayStaffSheetBody({
    required this.l10n,
    required this.employees,
    required this.selectedId,
    required this.onEmployeeSelected,
  });

  final AppLocalizations l10n;
  final List<Employee> employees;
  final String? selectedId;
  final ValueChanged<String> onEmployeeSelected;

  @override
  State<_QuickPayStaffSheetBody> createState() =>
      _QuickPayStaffSheetBodyState();
}

class _QuickPayStaffSheetBodyState extends State<_QuickPayStaffSheetBody> {
  late final TextEditingController _search;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search = TextEditingController()..addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() => _query = _search.text.trim().toLowerCase());
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query;
    final filtered = q.isEmpty
        ? widget.employees
        : widget.employees
              .where(
                (e) => e.name.toLowerCase().contains(q) || e.email
                    .toLowerCase()
                    .contains(q),
              )
              .toList(growable: false);

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.l10n.payrollQuickPayStaffSheetTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.employees.length > 6) ...[
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: widget.l10n.payrollQuickPaySearchHint,
                filled: true,
                fillColor: ZuranoPremiumUiColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: ZuranoPremiumUiColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: ZuranoPremiumUiColors.border,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.employees.isEmpty
                            ? widget.l10n.payrollQuickPayStaffEmpty
                            : widget.l10n.payrollQuickPaySearchEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ZuranoPremiumUiColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final e = filtered[index];
                      final selected = e.id == widget.selectedId;
                      final roleLine = quickPayEmployeeRoleLabel(
                        widget.l10n,
                        e.role,
                      );
                      return Material(
                        color: ZuranoPremiumUiColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => widget.onEmployeeSelected(e.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? ZuranoPremiumUiColors.primaryPurple
                                    : ZuranoPremiumUiColors.border,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color:
                                              ZuranoPremiumUiColors.textPrimary,
                                        ),
                                      ),
                                      if (roleLine.isNotEmpty)
                                        Text(
                                          roleLine,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ZuranoPremiumUiColors
                                                .textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: ZuranoPremiumUiColors
                                        .primaryPurple,
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
    );
  }
}

