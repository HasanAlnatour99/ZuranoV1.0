class FirestorePaths {
  const FirestorePaths._();

  static const users = 'users';
  static const salons = 'salons';

  /// Guest display nickname registry (doc id = lowercase nickname key).
  static const guestProfiles = 'guestProfiles';

  /// Cross-salon guest booking index (doc id = public booking code, e.g. ZR-AB12CD).
  static const guestBookings = 'guestBookings';

  static String guestProfile(String nicknameKey) =>
      '$guestProfiles/$nicknameKey';

  static String guestBooking(String bookingCode) =>
      '$guestBookings/$bookingCode';

  /// Public salon browse index (customer discovery). Doc id = salonId.
  static const publicSalons = 'publicSalons';

  /// Customer-safe team mirror under each public salon doc (`publicSalons/{salonId}/team/{employeeId}`).
  static const publicSalonTeam = 'team';
  static const employees = 'employees';
  static const shiftTemplates = 'shiftTemplates';
  static const weeklyScheduleTemplates = 'weeklyScheduleTemplates';
  static const weeklyScheduleAssignments = 'assignments';
  static const employeeSchedules = 'employeeSchedules';
  static const services = 'services';
  static const sales = 'sales';
  static const attendance = 'attendance';
  static const attendanceEvents = 'events';
  static const settings = 'settings';
  static const attendanceSettingsDocId = 'attendance';
  static const salesSettingsDocId = 'sales';
  static const customerBookingSettingsDocId = 'customerBooking';
  static const attendanceRequests = 'attendanceRequests';
  static const attendanceCorrections = 'attendance_corrections';

  /// Employee Today v2: day aggregate + punch audit trail.
  static const attendanceDays = 'attendanceDays';
  static const attendanceDayPunches = 'punches';
  static const attendanceDayBreaks = 'breaks';

  /// Pending/approved correction flow (camelCase collection id).
  static const attendanceCorrectionRequests = 'attendanceCorrectionRequests';
  static const attendancePolicyReadableDocId = 'attendancePolicyReadable';
  static const auditLogs = 'audit_logs';
  static const violations = 'violations';
  static const payroll = 'payroll';
  static const payrollElements = 'payroll_elements';
  static const employeeElementEntries = 'employee_element_entries';
  static const payrollRuns = 'payroll_runs';
  static const payrollRunResults = 'results';
  static const expenses = 'expenses';
  static const bookings = 'bookings';
  static const reviews = 'reviews';
  static const barberMetrics = 'barberMetrics';
  /// Monthly per-employee performance summaries (`{yyyyMM}_{employeeId}`).
  static const performance = 'performance';
  static const insights = 'insights';

  /// Owner/admin cached text snippets (e.g. team sales digest). Distinct from [insights].
  static const aiInsights = 'aiInsights';
  static const customers = 'customers';
  static String customer(String customerId) => '$customers/$customerId';

  /// Curated discovery lists for the customer home hub (`items` under a segment doc).
  /// Example: `customerDiscovery/categories/items/{categoryId}`.
  static const customerDiscovery = 'customerDiscovery';
  static const customerDiscoveryCategoriesDoc = 'categories';
  static const customerDiscoveryTrendingServicesDoc = 'trendingServices';
  static const customerDiscoveryBannersDoc = 'banners';
  static const customerDiscoveryItems = 'items';

  static String user(String uid) => '$users/$uid';

  static const userDevices = 'devices';
  static const userNotifications = 'notifications';
  static const notificationSettings = 'notificationSettings';
  static const salonNotificationsCollection = 'notifications';

  static String userDevicesPath(String uid) => '${user(uid)}/$userDevices';

  static String userDevice(String uid, String deviceId) =>
      '${userDevicesPath(uid)}/$deviceId';

  static String userNotificationsPath(String uid) =>
      '${user(uid)}/$userNotifications';

  static String salon(String salonId) => '$salons/$salonId';

  static String publicSalon(String salonId) => '$publicSalons/$salonId';

  static String publicSalonTeamCollection(String salonId) =>
      '${publicSalon(salonId)}/$publicSalonTeam';

  static String publicSalonTeamMember(String salonId, String employeeId) =>
      '${publicSalonTeamCollection(salonId)}/$employeeId';

  /// Customer-safe service mirror (`publicSalons/{salonId}/services/{serviceId}`).
  static String publicSalonServicesCollection(String salonId) =>
      '${publicSalon(salonId)}/$services';

  static String publicSalonService(String salonId, String serviceId) =>
      '${publicSalonServicesCollection(salonId)}/$serviceId';

  static String salonEmployees(String salonId) =>
      '${salon(salonId)}/$employees';

  static String salonShiftTemplates(String salonId) =>
      '${salon(salonId)}/$shiftTemplates';

  static String salonShiftTemplate(String salonId, String shiftTemplateId) =>
      '${salonShiftTemplates(salonId)}/$shiftTemplateId';

  static String salonWeeklyScheduleTemplates(String salonId) =>
      '${salon(salonId)}/$weeklyScheduleTemplates';

  static String salonWeeklyScheduleTemplate(
    String salonId,
    String weekTemplateId,
  ) => '${salonWeeklyScheduleTemplates(salonId)}/$weekTemplateId';

  static String salonWeeklyScheduleAssignments(
    String salonId,
    String weekTemplateId,
  ) =>
      '${salonWeeklyScheduleTemplate(salonId, weekTemplateId)}/$weeklyScheduleAssignments';

  static String salonWeeklyScheduleAssignment(
    String salonId,
    String weekTemplateId,
    String assignmentId,
  ) =>
      '${salonWeeklyScheduleAssignments(salonId, weekTemplateId)}/$assignmentId';

  static String salonEmployeeSchedules(String salonId) =>
      '${salon(salonId)}/$employeeSchedules';

  static String salonEmployeeSchedule(String salonId, String scheduleId) =>
      '${salonEmployeeSchedules(salonId)}/$scheduleId';

  static String salonEmployee(String salonId, String employeeId) =>
      '${salonEmployees(salonId)}/$employeeId';

  /// Per-employee salon service roster (`assignedServices/{serviceId}`).
  static const assignedServicesCollection = 'assignedServices';

  static String salonEmployeeAssignedServices(
    String salonId,
    String employeeId,
  ) => '${salonEmployee(salonId, employeeId)}/$assignedServicesCollection';

  static String salonEmployeeAssignedService(
    String salonId,
    String employeeId,
    String serviceId,
  ) => '${salonEmployeeAssignedServices(salonId, employeeId)}/$serviceId';

  static String salonServices(String salonId) => '${salon(salonId)}/$services';

  static String salonService(String salonId, String serviceId) =>
      '${salonServices(salonId)}/$serviceId';

  static String salonReviews(String salonId) => '${salon(salonId)}/$reviews';

  static String salonReview(String salonId, String reviewId) =>
      '${salonReviews(salonId)}/$reviewId';

  static String salonSales(String salonId) => '${salon(salonId)}/$sales';

  static String salonSale(String salonId, String saleId) =>
      '${salonSales(salonId)}/$saleId';

  static String salonAttendance(String salonId) =>
      '${salon(salonId)}/$attendance';

  static String salonAttendanceRecord(String salonId, String attendanceId) =>
      '${salonAttendance(salonId)}/$attendanceId';

  /// `salons/{salonId}/attendance/{attendanceId}/events` (collection path).
  static String salonAttendanceEventsCollection(
    String salonId,
    String attendanceId,
  ) => '${salonAttendanceRecord(salonId, attendanceId)}/$attendanceEvents';

  static String salonAttendanceEventDoc(
    String salonId,
    String attendanceId,
    String eventId,
  ) => '${salonAttendanceEventsCollection(salonId, attendanceId)}/$eventId';

  static String salonSettingsCollection(String salonId) =>
      '${salon(salonId)}/$settings';

  static String salonAttendanceSettingsDoc(String salonId) =>
      '${salonSettingsCollection(salonId)}/$attendanceSettingsDocId';

  static String salonSalesSettingsDoc(String salonId) =>
      '${salonSettingsCollection(salonId)}/$salesSettingsDocId';

  static String salonCustomerBookingSettingsDoc(String salonId) =>
      '${salonSettingsCollection(salonId)}/$customerBookingSettingsDocId';

  static String salonAttendancePolicyReadableDoc(String salonId) =>
      '${salonSettingsCollection(salonId)}/$attendancePolicyReadableDocId';

  /// `salons/{salonId}/attendanceDays`
  static String salonAttendanceDays(String salonId) =>
      '${salon(salonId)}/$attendanceDays';

  static String salonAttendanceDay(String salonId, String attendanceDayId) =>
      '${salonAttendanceDays(salonId)}/$attendanceDayId';

  static String salonAttendanceDayPunchesCollection(
    String salonId,
    String attendanceDayId,
  ) => '${salonAttendanceDay(salonId, attendanceDayId)}/$attendanceDayPunches';

  static String salonAttendanceDayPunch(
    String salonId,
    String attendanceDayId,
    String punchId,
  ) =>
      '${salonAttendanceDayPunchesCollection(salonId, attendanceDayId)}/$punchId';

  /// `salons/{salonId}/attendanceDays/{attendanceDayId}/breaks`
  static String salonAttendanceDayBreaksCollection(
    String salonId,
    String attendanceDayId,
  ) => '${salonAttendanceDay(salonId, attendanceDayId)}/$attendanceDayBreaks';

  static String salonAttendanceDayBreak(
    String salonId,
    String attendanceDayId,
    String breakId,
  ) =>
      '${salonAttendanceDayBreaksCollection(salonId, attendanceDayId)}/$breakId';

  static String salonAttendanceCorrectionRequests(String salonId) =>
      '${salon(salonId)}/$attendanceCorrectionRequests';

  static String salonAttendanceCorrectionRequest(
    String salonId,
    String requestId,
  ) => '${salonAttendanceCorrectionRequests(salonId)}/$requestId';

  static String salonAttendanceRequests(String salonId) =>
      '${salon(salonId)}/$attendanceRequests';

  static String salonAttendanceRequest(String salonId, String requestId) =>
      '${salonAttendanceRequests(salonId)}/$requestId';

  static String salonAttendanceCorrections(String salonId) =>
      '${salon(salonId)}/$attendanceCorrections';

  static String salonAuditLogs(String salonId) =>
      '${salon(salonId)}/$auditLogs';

  static String salonViolations(String salonId) =>
      '${salon(salonId)}/$violations';

  static String salonViolation(String salonId, String violationId) =>
      '${salonViolations(salonId)}/$violationId';

  static String salonPayroll(String salonId) => '${salon(salonId)}/$payroll';

  static String salonPayrollRecord(String salonId, String payrollId) =>
      '${salonPayroll(salonId)}/$payrollId';

  static String salonPayrollElements(String salonId) =>
      '${salon(salonId)}/$payrollElements';

  static String salonPayrollElement(String salonId, String elementId) =>
      '${salonPayrollElements(salonId)}/$elementId';

  static String salonEmployeeElementEntries(String salonId) =>
      '${salon(salonId)}/$employeeElementEntries';

  static String salonEmployeeElementEntry(String salonId, String entryId) =>
      '${salonEmployeeElementEntries(salonId)}/$entryId';

  static String salonPayrollRuns(String salonId) =>
      '${salon(salonId)}/$payrollRuns';

  static String salonPayrollRun(String salonId, String runId) =>
      '${salonPayrollRuns(salonId)}/$runId';

  static String salonPayrollRunResults(String salonId, String runId) =>
      '${salonPayrollRun(salonId, runId)}/$payrollRunResults';

  static String salonPayrollRunResult(
    String salonId,
    String runId,
    String resultId,
  ) => '${salonPayrollRunResults(salonId, runId)}/$resultId';

  static String salonExpenses(String salonId) => '${salon(salonId)}/$expenses';

  static String salonExpense(String salonId, String expenseId) =>
      '${salonExpenses(salonId)}/$expenseId';

  static String salonBookings(String salonId) => '${salon(salonId)}/$bookings';

  static String salonBooking(String salonId, String bookingId) =>
      '${salonBookings(salonId)}/$bookingId';

  static String salonBarberMetrics(String salonId) =>
      '${salon(salonId)}/$barberMetrics';

  static String salonBarberMetric(String salonId, String employeeId) =>
      '${salonBarberMetrics(salonId)}/$employeeId';

  static String salonPerformance(String salonId) =>
      '${salon(salonId)}/$performance';

  static String salonPerformanceRecord(String salonId, String performanceId) =>
      '${salonPerformance(salonId)}/$performanceId';

  static String salonInsights(String salonId) => '${salon(salonId)}/$insights';

  static String salonAiInsights(String salonId) =>
      '${salon(salonId)}/$aiInsights';

  static String salonNotifications(String salonId) =>
      '${salon(salonId)}/$salonNotificationsCollection';

  static String salonNotification(String salonId, String notificationId) =>
      '${salonNotifications(salonId)}/$notificationId';

  static String salonNotificationSettings(String salonId) =>
      '${salon(salonId)}/$notificationSettings';

  static String salonNotificationSetting(String salonId, String userId) =>
      '${salonNotificationSettings(salonId)}/$userId';

  static String salonCustomers(String salonId) =>
      '${salon(salonId)}/$customers';

  static String salonCustomer(String salonId, String customerId) =>
      '${salonCustomers(salonId)}/$customerId';

  /// Monthly payslips (`{employeeId}_{yyyyMM}`) with `lines` + `aiAnalysis` subcollections.
  static const payslips = 'payslips';
  static const payslipLines = 'lines';
  static const payslipAiAnalysis = 'aiAnalysis';
  static const payrollSettings = 'payroll_settings';
  static const payrollSettingsMainDocId = 'main';
  static const payrollAdjustments = 'payroll_adjustments';
  static const payrollAdjustmentsV2 = 'payrollAdjustments';
  /// Owner/admin payroll attendance rollups (`salons/{salonId}/payrollPeriods/{yyyyMM}`).
  static const payrollPeriods = 'payrollPeriods';
  static const employeeSummaries = 'employeeSummaries';
  /// Adjustment audit entries written via Cloud Functions only.
  static const attendanceAdjustments = 'attendanceAdjustments';
  static const violationRules = 'violation_rules';

  static String salonPayslips(String salonId) => '${salon(salonId)}/$payslips';

  static String salonPayslip(String salonId, String payslipId) =>
      '${salonPayslips(salonId)}/$payslipId';

  static String salonPayslipLines(String salonId, String payslipId) =>
      '${salonPayslip(salonId, payslipId)}/$payslipLines';

  static String salonPayslipAiAnalysis(String salonId, String payslipId) =>
      '${salonPayslip(salonId, payslipId)}/$payslipAiAnalysis';

  static String salonPayrollSettingsDoc(String salonId) =>
      '${salon(salonId)}/$payrollSettings/$payrollSettingsMainDocId';

  static String salonPayrollAdjustments(String salonId) =>
      '${salon(salonId)}/$payrollAdjustments';

  static String salonPayrollAdjustmentsV2(String salonId) =>
      '${salon(salonId)}/$payrollAdjustmentsV2';

  static String salonViolationRules(String salonId) =>
      '${salon(salonId)}/$violationRules';

  static String salonAttendanceAdjustments(String salonId) =>
      '${salon(salonId)}/$attendanceAdjustments';

  static String salonPayrollPeriods(String salonId) =>
      '${salon(salonId)}/$payrollPeriods';

  static String salonPayrollPeriod(String salonId, String periodYm) =>
      '${salonPayrollPeriods(salonId)}/$periodYm';

  static String salonPayrollPeriodEmployeeSummaries(
    String salonId,
    String periodYm,
  ) => '${salonPayrollPeriod(salonId, periodYm)}/$employeeSummaries';

  static String salonPayrollPeriodEmployeeSummary(
    String salonId,
    String periodYm,
    String employeeId,
  ) => '${salonPayrollPeriodEmployeeSummaries(salonId, periodYm)}/$employeeId';
}
