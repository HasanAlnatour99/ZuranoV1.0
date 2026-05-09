import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/customer.dart';

class CreateCustomerInput {
  const CreateCustomerInput({
    required this.fullName,
    this.phoneNumber,
    this.gender,
    this.birthDate,
    this.notes,
    this.preferredBarberId,
    this.preferredBarberName,
    this.tags = const <String>[],
    this.address,
    this.source,
  });

  final String fullName;
  final String? phoneNumber;
  final String? gender;
  final DateTime? birthDate;
  final String? notes;
  final String? preferredBarberId;
  final String? preferredBarberName;
  final List<String> tags;
  final String? address;
  final String? source;
}

class CreateCustomerController {
  CreateCustomerController(this._ref);

  final Ref _ref;

  Future<String> createCustomer(CreateCustomerInput input) async {
    final user = _ref.read(sessionUserProvider).asData?.value;
    final createdBy = user?.uid ?? '';
    if (createdBy.isEmpty) {
      throw StateError('You must be signed in to create a customer.');
    }
    final fullName = input.fullName.trim();
    if (fullName.isEmpty) {
      throw StateError('Customer full name is required.');
    }
    final salonId = user?.salonId?.trim() ?? '';
    if (salonId.isEmpty) {
      throw StateError(
        'Your profile is missing a salon. Cannot create customer.',
      );
    }
    final repo = _ref.read(customerRepositoryProvider);
    try {
      final customerId = await repo.createCustomer(
        salonId: salonId,
        customer: Customer(
          id: '',
          salonId: salonId,
          authUid: null,
          fullName: fullName,
          fullNameLower: normalizeCustomerName(fullName),
          phone: input.phoneNumber?.trim().isEmpty == true
              ? ''
              : input.phoneNumber?.trim() ?? '',
          searchKeywords: buildCustomerSearchKeywords(
            fullName: fullName,
            phoneNumber: input.phoneNumber,
          ),
          preferredBarberId: input.preferredBarberId,
          preferredBarberName: input.preferredBarberName,
          email: null,
          notes: input.notes,
          gender: input.gender,
          birthDate: input.birthDate,
          source: input.source,
          tags: input.tags,
          address: (input.address?.trim().isNotEmpty == true)
              ? <String, dynamic>{'line1': input.address!.trim()}
              : null,
          isVip: false,
          category: 'new',
          createdBy: createdBy,
        ),
      );
      return customerId;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final createCustomerControllerProvider = Provider<CreateCustomerController>((
  ref,
) {
  return CreateCustomerController(ref);
});
