import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../application/booking_lookup_controller.dart';
import '../../data/models/customer_booking_lookup_model.dart';
import '../widgets/customer_booking_lookup_card.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/customer_text_field.dart';

final recentGuestBookingsOnDeviceProvider =
    StreamProvider.autoDispose<List<_RecentGuestBookingRow>>((ref) {
  final isAnonymous = ref.watch(firebaseAuthProvider).currentUser?.isAnonymous ==
      true;
  if (!isAnonymous) {
    return Stream.value(const <_RecentGuestBookingRow>[]);
  }

  final guestIdentity = ref.watch(guestIdentityRepositoryProvider);
  final firestore = ref.watch(firestoreProvider);
  return Stream.fromFuture(guestIdentity.getGuestProfileId()).asyncExpand((
    guestProfileId,
  ) {
    final id = guestProfileId?.trim() ?? '';
    if (id.isEmpty) {
      return Stream.value(const <_RecentGuestBookingRow>[]);
    }

    final q = firestore
        .collectionGroup('bookings')
        .where('guestProfileId', isEqualTo: id)
        .orderBy('startAt', descending: true)
        .limit(5);

    return q.snapshots().map((snap) {
      return snap.docs
          .map((d) => _RecentGuestBookingRow.fromFirestore(d.data(), d.id))
          .toList(growable: false);
    });
  });
});

class FindBookingScreen extends ConsumerStatefulWidget {
  const FindBookingScreen({super.key});

  @override
  ConsumerState<FindBookingScreen> createState() => _FindBookingScreenState();
}

class _FindBookingScreenState extends ConsumerState<FindBookingScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _bookingCodeController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _bookingCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bookingCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lookupState = ref.watch(bookingLookupControllerProvider);
    final invalidPhone = lookupState.error is BookingLookupException &&
        (lookupState.error! as BookingLookupException).error ==
            BookingLookupError.invalidPhone;
    final missingFields = lookupState.error is BookingLookupException &&
        (lookupState.error! as BookingLookupException).error ==
            BookingLookupError.missingPhoneOrCode;

    final signedInUid =
        (ref.watch(sessionUserProvider).asData?.value?.uid ?? '').trim();

    return CustomerGradientScaffold(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerAccountBookingsForFindProvider);
            ref.invalidate(recentGuestBookingsOnDeviceProvider);
          },
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.small,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                sliver: SliverToBoxAdapter(
                  child: _Header(
                    title: l10n.customerBookingLookupTitle,
                    subtitle: l10n.customerBookingLookupSubtitle,
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                sliver: SliverToBoxAdapter(
                  child: _SearchCard(
                    phoneController: _phoneController,
                    bookingCodeController: _bookingCodeController,
                    phoneLabel: l10n.customerBookingLookupPhoneNumber,
                    bookingCodeLabel: l10n.customerBookingLookupBookingCode,
                    bookingCodeHint: l10n.customerBookingLookupBookingCodeHint,
                    searchLabel: l10n.customerBookingLookupSearch,
                    phoneErrorText: invalidPhone
                        ? l10n.customerBookingLookupInvalidPhone
                        : null,
                    bookingCodeErrorText: missingFields
                        ? l10n.customerBookingLookupBothRequired
                        : null,
                    loading: lookupState.isLoading,
                    onChanged: () {
                      if (lookupState.hasError) {
                        ref
                            .read(bookingLookupControllerProvider.notifier)
                            .clear();
                      }
                    },
                    onSearch: () => ref
                        .read(bookingLookupControllerProvider.notifier)
                        .search(
                          phoneInput: _phoneController.text,
                          bookingCodeInput: _bookingCodeController.text,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.medium,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                sliver: SliverToBoxAdapter(
                  child: _InfoCard(message: l10n.customerBookingLookupPhoneHint),
                ),
              ),
              ..._recentGuestBookingsSlivers(context, ref, l10n),
              if (signedInUid.isNotEmpty)
                ..._signedInAccountBookingSlivers(context, ref, l10n),
              _ResultArea(state: lookupState),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _recentGuestBookingsSlivers(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  final isAnonymous =
      ref.watch(firebaseAuthProvider).currentUser?.isAnonymous == true;
  if (!isAnonymous) {
    return const <Widget>[];
  }

  final theme = Theme.of(context);
  final async = ref.watch(recentGuestBookingsOnDeviceProvider);
  return async.when(
    loading: () => [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          AppSpacing.small,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.guestRecentBookingsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ZuranoTokens.textDark,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverList.list(
          children: const [
            AppSkeletonBlock(height: 102),
            SizedBox(height: AppSpacing.medium),
            AppSkeletonBlock(height: 102),
          ],
        ),
      ),
    ],
    error: (_, _) => [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          AppSpacing.small,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.guestRecentBookingsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ZuranoTokens.textDark,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverToBoxAdapter(
          child: _StateCard(message: l10n.customerBookingLookupGenericError),
        ),
      ),
    ],
    data: (rows) {
      final titleSliver = SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          AppSpacing.small,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.guestRecentBookingsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ZuranoTokens.textDark,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
      );

      if (rows.isEmpty) {
        return [
          titleSliver,
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            sliver: SliverToBoxAdapter(
              child: _StateCard(message: l10n.guestRecentBookingsEmpty),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.medium,
              AppSpacing.large,
              AppSpacing.medium,
            ),
            sliver: SliverToBoxAdapter(
              child: _InfoCard(message: l10n.guestRecentBookingsHelper),
            ),
          ),
        ];
      }

      return [
        titleSliver,
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          sliver: SliverList.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) =>
                _GuestRecentBookingCard(row: rows[index]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.medium,
          ),
          sliver: SliverToBoxAdapter(
            child: _InfoCard(message: l10n.guestRecentBookingsHelper),
          ),
        ),
      ];
    },
  );
}

List<Widget> _signedInAccountBookingSlivers(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final async = ref.watch(customerAccountBookingsForFindProvider);
  return async.when(
    loading: () => [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          AppSpacing.small,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.customerBookingLookupYourBookingsSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColorsLight.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverList.list(
          children: const [
            AppSkeletonBlock(height: 132),
            SizedBox(height: AppSpacing.medium),
            AppSkeletonBlock(height: 132),
          ],
        ),
      ),
    ],
    error: (Object error, StackTrace stackTrace) => [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          AppSpacing.small,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.customerBookingLookupYourBookingsSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColorsLight.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverToBoxAdapter(
          child: _StateCard(message: l10n.customerBookingLookupGenericError),
        ),
      ),
    ],
    data: (CustomerAccountBookingsPreview preview) {
      final list = preview.items;
      final titleSliver = SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          AppSpacing.small,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.customerBookingLookupYourBookingsSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ZuranoTokens.textDark,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
      );
      if (list.isEmpty) {
        return [
          titleSliver,
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            sliver: SliverToBoxAdapter(
              child: _StateCard(
                message: l10n.customerBookingLookupSignedInEmpty,
              ),
            ),
          ),
        ];
      }
      return [
        titleSliver,
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          sliver: SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              return CustomerBookingLookupCard(booking: list[index]);
            },
          ),
        ),
        if (preview.showViewAll)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.medium,
              AppSpacing.large,
              AppSpacing.small,
            ),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZuranoTokens.primary,
                    side: const BorderSide(color: ZuranoTokens.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ZuranoTokens.radiusButton),
                    ),
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.customerMyBookings),
                  child: Text(l10n.customerBookingLookupViewAll),
                ),
              ),
            ),
          ),
      ];
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColorsLight.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.phoneController,
    required this.bookingCodeController,
    required this.phoneLabel,
    required this.bookingCodeLabel,
    required this.bookingCodeHint,
    required this.searchLabel,
    required this.loading,
    required this.onChanged,
    required this.onSearch,
    this.phoneErrorText,
    this.bookingCodeErrorText,
  });

  final TextEditingController phoneController;
  final TextEditingController bookingCodeController;
  final String phoneLabel;
  final String bookingCodeLabel;
  final String bookingCodeHint;
  final String searchLabel;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onSearch;
  final String? phoneErrorText;
  final String? bookingCodeErrorText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.primary.withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              CustomerTextField(
                controller: phoneController,
                label: phoneLabel,
                errorText: phoneErrorText,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: AppSpacing.medium),
              CustomerTextField(
                controller: bookingCodeController,
                label: bookingCodeLabel,
                hint: bookingCodeHint,
                errorText: bookingCodeErrorText,
                textInputAction: TextInputAction.search,
                inputFormatters: [UpperCaseTextFormatter()],
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: CustomerPrimaryButtonStyle.filled(context),
                  onPressed: loading ? null : onSearch,
                  child: loading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(searchLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZuranoTokens.lightPurple,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: ZuranoTokens.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: ZuranoTokens.primary,
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ZuranoTokens.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultArea extends StatelessWidget {
  const _ResultArea({required this.state});

  final AsyncValue<List<CustomerBookingLookupModel>?> state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverList.list(
          children: const [
            AppSkeletonBlock(height: 132),
            SizedBox(height: AppSpacing.medium),
            AppSkeletonBlock(height: 132),
          ],
        ),
      );
    }

    if (state.hasError) {
      final isValidation = state.error is BookingLookupException;
      if (isValidation) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverToBoxAdapter(
          child: _StateCard(message: l10n.customerBookingLookupGenericError),
        ),
      );
    }

    final items = state.value;
    if (items == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (items.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverToBoxAdapter(
          child: _StateCard(message: l10n.customerBookingLookupNotFound),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.medium),
        itemBuilder: (context, index) {
          return CustomerBookingLookupCard(booking: items[index]);
        },
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColorsLight.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _RecentGuestBookingRow {
  const _RecentGuestBookingRow({
    required this.salonId,
    required this.bookingId,
    required this.bookingCode,
    required this.startAt,
    required this.status,
  });

  final String salonId;
  final String bookingId;
  final String bookingCode;
  final DateTime startAt;
  final String status;

  factory _RecentGuestBookingRow.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    final sid = (json['salonId'] as String?)?.trim() ?? '';
    final storedId = (json['id'] as String?)?.trim() ?? '';
    final bid = storedId.isNotEmpty ? storedId : documentId;
    final code = (json['bookingCode'] as String?)?.trim() ?? '';
    final rawStartAt = json['startAt'];
    final startAt = rawStartAt is Timestamp
        ? rawStartAt.toDate()
        : rawStartAt is DateTime
            ? rawStartAt
            : DateTime.fromMillisecondsSinceEpoch(0);
    final st = (json['status'] as String?)?.trim() ?? '';
    return _RecentGuestBookingRow(
      salonId: sid,
      bookingId: bid,
      bookingCode: code,
      startAt: startAt,
      status: st,
    );
  }
}

class _GuestRecentBookingCard extends ConsumerWidget {
  const _GuestRecentBookingCard({required this.row});

  final _RecentGuestBookingRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final dateFmt = DateFormat.yMMMd(locale.toString());
    final timeFmt = DateFormat.jm(locale.toString());

    final publicSalonRef = ref
        .watch(firestoreProvider)
        .doc('publicSalons/${row.salonId}');

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        onTap: () {
          if (row.salonId.isEmpty || row.bookingId.isEmpty) {
            return;
          }
          context.pushNamed(
            AppRouteNames.customerBookingDetails,
            pathParameters: {'salonId': row.salonId, 'bookingId': row.bookingId},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xlarge),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppBrandColors.primary.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: publicSalonRef.get().then((snap) {
                        final raw = snap.data()?['name'];
                        final name = raw is String ? raw.trim() : '';
                        return name.isEmpty ? row.salonId : name;
                      }),
                      builder: (context, snap) {
                        final salonName =
                            (snap.data ?? row.salonId).trim().isEmpty
                                ? l10n.customerBookingReviewSalon
                                : (snap.data ?? row.salonId);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salonName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColorsLight.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              row.bookingCode.isEmpty
                                  ? row.bookingId
                                  : row.bookingCode,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppBrandColors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _CompactStatusPill(status: row.status),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: AppBrandColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      '${dateFmt.format(row.startAt.toLocal())} · ${timeFmt.format(row.startAt.toLocal())}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColorsLight.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStatusPill extends StatelessWidget {
  const _CompactStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.trim();
    final scheme = Theme.of(context).colorScheme;
    final label = s.isEmpty ? '—' : s;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: ZuranoTokens.textGray,
            ),
      ),
    );
  }
}
