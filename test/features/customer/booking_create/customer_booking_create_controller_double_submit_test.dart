import 'package:barber_shop_app/features/customer/application/customer_booking_create_providers.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_create_result.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_draft.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_settings.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_service_public_model.dart';
import 'package:barber_shop_app/features/customer/data/repositories/customer_booking_create_repository.dart';
import 'package:barber_shop_app/features/customer/application/customer_booking_create_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCreateRepo implements CustomerBookingCreateRepository {
  int calls = 0;

  @override
  Future<CustomerBookingCreateResult> createBookingFromDraft({
    required String salonId,
    required CustomerBookingDraft draft,
    required CustomerBookingSettings bookingSettings,
    required String customerUiLanguageCode,
    bool anonymousGuestRequiresNickname = false,
  }) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return CustomerBookingCreateResult(
      bookingId: 'b1',
      salonId: salonId,
      customerId: 'c1',
      bookingCode: 'ZR-123456',
      status: 'confirmed',
      startAt: DateTime.now(),
      endAt: DateTime.now().add(const Duration(minutes: 30)),
    );
  }
}

void main() {
  test('double submit only triggers one create call', () async {
    final repo = _FakeCreateRepo();
    final container = ProviderContainer(
      overrides: [
        customerBookingCreateServiceProvider.overrideWithValue(
          CustomerBookingCreateService(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      customerBookingCreateControllerProvider.notifier,
    );

    // Ensure the AsyncNotifier is initialized (not in build loading state).
    await container.read(customerBookingCreateControllerProvider.future);

    const svc = CustomerServicePublicModel(
      id: 's1',
      salonId: 'salon-1',
      name: 'Haircut',
      displayName: 'Haircut',
      category: 'hair',
      categoryLabel: 'Hair',
      price: 10,
      durationMinutes: 30,
      isActive: true,
      isCustomerVisible: true,
      sortOrder: 1,
    );

    final startAt = DateTime.now().add(const Duration(days: 1));
    final endAt = startAt.add(const Duration(minutes: 30));

    final draft = const CustomerBookingDraft(
      salonId: 'salon-1',
      selectedServices: [svc],
      selectedEmployeeId: 'emp-1',
      selectedEmployeeName: 'Barber',
      anyAvailableEmployee: false,
      selectedStartAt: null,
      selectedEndAt: null,
      customerName: 'Hasan',
      customerPhoneNormalized: '+97470001043',
      durationMinutes: 30,
    ).copyWith(
      selectedStartAt: startAt,
      selectedEndAt: endAt,
    );

    final settings = const CustomerBookingSettings();

    final f1 = controller.create(
      salonId: 'salon-1',
      draft: draft,
      bookingSettings: settings,
      customerUiLanguageCode: 'en',
    );
    final f2 = controller.create(
      salonId: 'salon-1',
      draft: draft,
      bookingSettings: settings,
      customerUiLanguageCode: 'en',
    );

    await Future.wait([f1, f2]);
    expect(repo.calls, 1);
  });
}

