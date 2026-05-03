import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/connectivity/connectivity_service.dart';
import '../core/logging/app_logger.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/attendance/data/attendance_repository.dart';
import '../features/attendance_admin/data/repositories/attendance_requests_admin_repository.dart';
import '../features/employee_dashboard/data/repositories/attendance_request_repository.dart';
import '../features/employee_dashboard/data/repositories/employee_attendance_repository.dart';
import '../features/employee_dashboard/data/repositories/employee_dashboard_repository.dart';
import '../features/team/data/team_deck_firestore_repository.dart';
import '../features/team/data/team_member_cards_repository.dart';
import '../features/team_member_attendance/data/repositories/team_member_attendance_repository.dart';
import '../features/bookings/data/barber_metrics_repository.dart';
import '../features/bookings/data/booking_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/logic/complete_profile_after_social_login_use_case.dart';
import '../features/customers/data/customer_repository.dart';
import '../features/employees/data/employee_repository.dart';
import '../features/employees/data/staff_invite_remote_data_source.dart';
import '../features/employees/data/staff_provisioning_repository.dart';
import '../features/expenses/data/expense_repository.dart';
import '../features/insights/data/insights_repository.dart';
import '../features/payroll/data/employee_element_entry_repository.dart';
import '../features/payroll/data/payroll_calculation_service.dart';
import '../features/payroll/data/payroll_element_repository.dart';
import '../features/payroll/data/payroll_run_repository.dart';
import '../features/payroll/data/payroll_repository.dart';
import '../features/payroll/data/repositories/payslip_repository.dart';
import '../features/payroll/data/payroll_service.dart';
import '../features/payroll/logic/payroll_run_usecase.dart';
import '../features/payroll/logic/quickpay_usecase.dart';
import '../features/sales/data/repositories/add_sale_repository.dart';
import '../features/sales/data/sales_repository.dart';
import '../features/sales/data/salon_sales_settings_repository.dart';
import '../features/salon/data/salon_repository.dart';
import '../features/services/data/service_image_storage.dart';
import '../features/services/data/service_repository.dart';
import '../features/notifications/data/notification_repository.dart';
import '../features/users/data/user_repository.dart';
import '../features/violations/data/violation_repository.dart';
import 'firebase_providers.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  return LoggerAppLogger();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).watchIsOnline();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(firestore: ref.read(firestoreProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    userRepository: ref.read(userRepositoryProvider),
  );
});

final completeProfileAfterSocialLoginUseCaseProvider =
    Provider<CompleteProfileAfterSocialLoginUseCase>((ref) {
      return CompleteProfileAfterSocialLoginUseCase(
        auth: ref.read(firebaseAuthProvider),
        userRepository: ref.read(userRepositoryProvider),
      );
    });

final salonRepositoryProvider = Provider<SalonRepository>((ref) {
  return SalonRepository(firestore: ref.read(firestoreProvider));
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(
    firestore: ref.read(firestoreProvider),
    storage: ref.read(firebaseStorageProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    logger: ref.read(appLoggerProvider),
  );
});

final staffProvisioningRepositoryProvider =
    Provider<StaffProvisioningRepository>((ref) {
      return StaffProvisioningRepository(remote: StaffInviteRemoteDataSource());
    });

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(firestore: ref.read(firestoreProvider));
});

final serviceImageStorageProvider = Provider<ServiceImageStorage>((ref) {
  return ServiceImageStorage(storage: ref.read(firebaseStorageProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(
    firestore: ref.read(firestoreProvider),
    storage: ref.read(firebaseStorageProvider),
  );
});

final addSaleRepositoryProvider = Provider<AddSaleRepository>((ref) {
  return AddSaleRepository(
    ref.read(firestoreProvider),
    ref.read(salesRepositoryProvider),
  );
});

final salonSalesSettingsRepositoryProvider =
    Provider<SalonSalesSettingsRepository>((ref) {
      return SalonSalesSettingsRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(firestore: ref.read(firestoreProvider));
});

final teamDeckFirestoreRepositoryProvider =
    Provider<TeamDeckFirestoreRepository>((ref) {
  return TeamDeckFirestoreRepository(
    ref.read(firestoreProvider),
    ref.read(attendanceRepositoryProvider),
  );
});

final teamMemberAttendanceRepositoryProvider =
    Provider<TeamMemberAttendanceRepository>((ref) {
      return TeamMemberAttendanceRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

final violationRepositoryProvider = Provider<ViolationRepository>((ref) {
  return ViolationRepository(firestore: ref.read(firestoreProvider));
});

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepository(firestore: ref.read(firestoreProvider));
});

final payslipRepositoryProvider = Provider<PayslipRepository>((ref) {
  return PayslipRepository(firestore: ref.read(firestoreProvider));
});

final payrollElementRepositoryProvider = Provider<PayrollElementRepository>((
  ref,
) {
  return PayrollElementRepository(
    firestore: ref.read(firestoreProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    logger: ref.read(appLoggerProvider),
  );
});

final employeeElementEntryRepositoryProvider =
    Provider<EmployeeElementEntryRepository>((ref) {
      return EmployeeElementEntryRepository(
        firestore: ref.read(firestoreProvider),
        connectivityService: ref.read(connectivityServiceProvider),
        logger: ref.read(appLoggerProvider),
      );
    });

final payrollRunRepositoryProvider = Provider<PayrollRunRepository>((ref) {
  return PayrollRunRepository(
    firestore: ref.read(firestoreProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    logger: ref.read(appLoggerProvider),
  );
});

final payrollServiceProvider = Provider<PayrollService>((ref) {
  return PayrollService(
    payrollRepository: ref.read(payrollRepositoryProvider),
    salesRepository: ref.read(salesRepositoryProvider),
    employeeRepository: ref.read(employeeRepositoryProvider),
    violationRepository: ref.read(violationRepositoryProvider),
    firestore: ref.read(firestoreProvider),
  );
});

final payrollCalculationServiceProvider = Provider<PayrollCalculationService>((
  ref,
) {
  return PayrollCalculationService(
    payrollElementRepository: ref.read(payrollElementRepositoryProvider),
    employeeElementEntryRepository: ref.read(
      employeeElementEntryRepositoryProvider,
    ),
    employeeRepository: ref.read(employeeRepositoryProvider),
    salesRepository: ref.read(salesRepositoryProvider),
    attendanceRepository: ref.read(attendanceRepositoryProvider),
    violationRepository: ref.read(violationRepositoryProvider),
    salonRepository: ref.read(salonRepositoryProvider),
    payrollRunRepository: ref.read(payrollRunRepositoryProvider),
  );
});

final payrollRunUseCaseProvider = Provider<PayrollRunUseCase>((ref) {
  return PayrollRunUseCase(
    payrollCalculationService: ref.read(payrollCalculationServiceProvider),
    payrollRunRepository: ref.read(payrollRunRepositoryProvider),
    payrollElementRepository: ref.read(payrollElementRepositoryProvider),
    violationRepository: ref.read(violationRepositoryProvider),
    payslipRepository: ref.read(payslipRepositoryProvider),
    salonRepository: ref.read(salonRepositoryProvider),
    employeeRepository: ref.read(employeeRepositoryProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    logger: ref.read(appLoggerProvider),
  );
});

final quickPayUseCaseProvider = Provider<QuickPayUseCase>((ref) {
  return QuickPayUseCase(
    payrollCalculationService: ref.read(payrollCalculationServiceProvider),
    payrollRunUseCase: ref.read(payrollRunUseCaseProvider),
    payrollElementRepository: ref.read(payrollElementRepositoryProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    logger: ref.read(appLoggerProvider),
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(firestore: ref.read(firestoreProvider));
});

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return InsightsRepository(firestore: ref.read(firestoreProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(firestore: ref.read(firestoreProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(firestore: ref.read(firestoreProvider));
});

final barberMetricsRepositoryProvider = Provider<BarberMetricsRepository>((
  ref,
) {
  return BarberMetricsRepository(firestore: ref.read(firestoreProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(firestore: ref.read(firestoreProvider));
});

final employeeAttendanceRepositoryProvider =
    Provider<EmployeeAttendanceRepository>((ref) {
      return EmployeeAttendanceRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

final employeeDashboardRepositoryProvider =
    Provider<EmployeeDashboardRepository>((ref) {
      return EmployeeDashboardRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

final attendanceRequestRepositoryProvider =
    Provider<AttendanceRequestRepository>((ref) {
      return AttendanceRequestRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

final attendanceRequestsAdminRepositoryProvider =
    Provider<AttendanceRequestsAdminRepository>((ref) {
      return AttendanceRequestsAdminRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

final teamMemberCardsRepositoryProvider =
    Provider<TeamMemberCardsRepository>((ref) {
      return TeamMemberCardsRepository(ref.read(firestoreProvider));
    });
