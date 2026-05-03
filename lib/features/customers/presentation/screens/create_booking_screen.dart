import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/ui/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../owner/presentation/widgets/add_barber/add_barber_header.dart';
import '../../../employees/data/models/employee.dart';
import '../../../services/data/models/service.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../data/models/customer.dart';
import '../../logic/create_booking_controller.dart';
import '../../logic/customer_providers.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({
    super.key,
    this.initialCustomerId,
    this.initialServiceId,
    this.initialBarberId,
    this.initialDurationMinutes,
  });

  final String? initialCustomerId;
  final String? initialServiceId;
  final String? initialBarberId;
  final int? initialDurationMinutes;

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  Customer? _selectedCustomer;
  String? _selectedServiceId;
  String? _selectedBarberId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.initialServiceId;
    _selectedBarberId = widget.initialBarberId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final services =
        ref.watch(servicesStreamProvider).asData?.value ??
        const <SalonService>[];
    final barbers =
        (ref.watch(employeesStreamProvider).asData?.value ?? const <Employee>[])
            .where((e) => e.isActive)
            .toList();
    final query = _searchController.text.trim();
    final user = ref.watch(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final customerResults = ref.watch(
      customerSearchProvider((salonId: salonId, query: query)),
    );
    final canCreateCustomers =
        user != null && (user.role == 'owner' || user.role == 'admin');

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: AddBarberHeader(
              title: l10n.customerBookAppointment,
              subtitle: l10n.createBookingValidationIncomplete,
              compact: true,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.createBookingSearchCustomerLabel,
                    suffixIcon: canCreateCustomers
                        ? TextButton(
                            onPressed: () => context.push('/customers/new'),
                            child: Text(l10n.createBookingAddNewCustomer),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                customerResults.when(
                  data: (customers) => Column(
                    children: customers.take(5).map((customer) {
                      final selected = _selectedCustomer?.id == customer.id;
                      return ListTile(
                        selected: selected,
                        title: Text(customer.fullName),
                        subtitle: Text(customer.phoneNumber),
                        trailing: selected
                            ? const Icon(AppIcons.check_circle)
                            : null,
                        onTap: () =>
                            setState(() => _selectedCustomer = customer),
                      );
                    }).toList(),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  initialValue: _selectedServiceId,
                  decoration: InputDecoration(
                    labelText: l10n.customerSelectService,
                  ),
                  items: services
                      .map(
                        (service) => DropdownMenuItem(
                          value: service.id,
                          child: Text(service.serviceName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedServiceId = value),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBarberId,
                  decoration: InputDecoration(
                    labelText: l10n.customerSelectBarber,
                  ),
                  items: barbers
                      .map(
                        (barber) => DropdownMenuItem(
                          value: barber.id,
                          child: TeamMemberNameText(barber.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedBarberId = value),
                ),
                const SizedBox(height: AppSpacing.medium),
                ListTile(
                  title: Text(
                    l10n.createBookingDateWithValue(
                      DateFormat.yMMMd(localeName).format(_selectedDate),
                    ),
                  ),
                  trailing: const Icon(AppIcons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                ListTile(
                  title: Text(
                    l10n.createBookingTimeWithValue(
                      _selectedTime?.format(context) ??
                          l10n.createBookingPickTime,
                    ),
                  ),
                  trailing: const Icon(AppIcons.schedule_outlined),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.addCustomerFieldNotes,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton(
                  onPressed: _saving ? null : () => _submit(services),
                  child: _saving
                      ? const CircularProgressIndicator()
                      : Text(l10n.createBookingSaveCta),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(List<SalonService> services) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCustomer == null ||
        _selectedServiceId == null ||
        _selectedBarberId == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createBookingValidationIncomplete)),
      );
      return;
    }
    final service = services.firstWhere((s) => s.id == _selectedServiceId);
    final barbers =
        ref.read(employeesStreamProvider).asData?.value ?? const <Employee>[];
    final barber = barbers.firstWhere((e) => e.id == _selectedBarberId);
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final end = start.add(Duration(minutes: service.durationMinutes));

    setState(() => _saving = true);
    try {
      await ref
          .read(createBookingControllerProvider)
          .createBooking(
            CreateBookingInput(
              customer: _selectedCustomer!,
              barberId: barber.id,
              barberName: barber.name,
              serviceIds: [service.id],
              serviceNames: [service.serviceName],
              totalPrice: service.price,
              totalDurationMinutes: service.durationMinutes,
              startAt: start.toUtc(),
              endAt: end.toUtc(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createBookingSuccessSnackbar)),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
