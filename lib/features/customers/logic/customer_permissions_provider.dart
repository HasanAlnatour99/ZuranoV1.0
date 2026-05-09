import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/session_provider.dart';

class CustomerPermissions {
  const CustomerPermissions({
    required this.canViewCustomer,
    required this.canCreateCustomer,
    required this.canEditCustomer,
    required this.canArchiveCustomer,
    required this.canManageVipDiscount,
    required this.canAddSaleForCustomer,
    required this.canBookAppointment,
  });

  final bool canViewCustomer;
  final bool canCreateCustomer;
  final bool canEditCustomer;
  final bool canArchiveCustomer;
  final bool canManageVipDiscount;
  final bool canAddSaleForCustomer;
  final bool canBookAppointment;
}

final customerPermissionsProvider = Provider<CustomerPermissions>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final role = user?.role.trim() ?? '';
  final hasSalon = (user?.salonId?.trim().isNotEmpty ?? false);

  final isOwnerAdmin = role == 'owner' || role == 'admin';
  final isStaff = isOwnerAdmin || role == 'barber' || role == 'employee';

  return CustomerPermissions(
    canViewCustomer: hasSalon && isStaff,
    canCreateCustomer: hasSalon && isOwnerAdmin,
    canEditCustomer: hasSalon && isOwnerAdmin,
    canArchiveCustomer: hasSalon && isOwnerAdmin,
    canManageVipDiscount: hasSalon && isOwnerAdmin,
    canAddSaleForCustomer: hasSalon && isStaff,
    canBookAppointment: hasSalon && isOwnerAdmin, // for now
  );
});

