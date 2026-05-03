import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_for_country.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../services/data/models/service.dart';
import '../../../services/presentation/widgets/service_form_sheet.dart';
import '../../application/barber_services_providers.dart';
import '../widgets/services/assigned_service_card.dart';
import '../widgets/services/assigned_services_empty_state.dart';
import '../widgets/services/assigned_services_error_state.dart';
import '../widgets/services/assigned_services_header.dart';
import '../widgets/services/assigned_services_skeleton.dart';
import '../widgets/services/edit_service_assignment_card.dart';
import '../widgets/services/zurano_service_assignment_sheet.dart';

class BarberServicesTab extends ConsumerWidget {
  const BarberServicesTab({
    super.key,
    required this.salonId,
    required this.employeeId,
    required this.salonFallbackCurrencyCode,
  });

  final String salonId;
  final String employeeId;
  final String salonFallbackCurrencyCode;

  AssignedBarberServicesParams get _params => AssignedBarberServicesParams(
    salonId: salonId,
    employeeId: employeeId,
    salonFallbackCurrencyCode: resolvedSalonMoneyCurrency(
      salonCurrencyCode: salonFallbackCurrencyCode,
      salonCountryIso: null,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedAsync = ref.watch(assignedBarberServicesProvider(_params));
    final servicesAsync = ref.watch(servicesStreamProvider);

    return assignedAsync.when(
      loading: () => const AssignedServicesSkeleton(),
      error: (error, _) => AssignedServicesErrorState(
        error: error,
        onRetry: () => ref.invalidate(assignedBarberServicesProvider(_params)),
      ),
      data: (services) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              sliver: SliverList.list(
                children: [
                  EditServiceAssignmentCard(
                    onTap: servicesAsync.hasValue
                        ? () => _openAssignmentSheet(
                              context,
                              ref,
                              servicesAsync.requireValue,
                            )
                        : null,
                  ),
                  const SizedBox(height: 28),
                  AssignedServicesHeader(count: services.length),
                  const SizedBox(height: 16),
                  if (services.isEmpty)
                    AssignedServicesEmptyState(
                      onAssignService: () {
                        if (!servicesAsync.hasValue) return;
                        _openAssignmentSheet(context, ref, servicesAsync.requireValue);
                      },
                    )
                  else
                    ...services.map(
                      (service) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AssignedServiceCard(
                          service: service,
                          onTap: () =>
                              _openServiceEditor(context, ref, service.serviceId),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openServiceEditor(
    BuildContext context,
    WidgetRef ref,
    String serviceId,
  ) async {
    final repo = ref.read(serviceRepositoryProvider);
    final existing = await repo.getService(salonId, serviceId);
    if (!context.mounted) {
      return;
    }
    if (existing != null) {
      await showOwnerServiceEditorSheet(
        context,
        salonId: salonId,
        existing: existing,
      );
    }
  }

  Future<void> _openAssignmentSheet(
    BuildContext context,
    WidgetRef ref,
    List<SalonService> salonServices,
  ) async {
    final employeeRepo = ref.read(employeeRepositoryProvider);
    final emp = await employeeRepo.getEmployee(salonId, employeeId);
    if (!context.mounted) {
      return;
    }

    final selectedIds = emp?.assignedServiceIds.toSet() ?? <String>{};

    await showZuranoServiceAssignmentSheet(
      context: context,
      salonServices: salonServices,
      salonId: salonId,
      employeeId: employeeId,
      employee: emp,
      salonFallbackCurrencyCode: salonFallbackCurrencyCode,
      initialSelectedIds: selectedIds,
    );
  }
}
