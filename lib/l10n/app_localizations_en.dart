// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zurano';

  @override
  String get splashTitle => 'Barber Shop';

  @override
  String get splashTagline => 'Crafted cuts. Calm bookings.';

  @override
  String get genericError => 'Something went wrong.';

  @override
  String get loadingPlaceholder => '…';

  @override
  String get customerDiscoverTitle => 'Discover';

  @override
  String get customerHomeMenuTooltip => 'More options';

  @override
  String get customerHomeEmptyTitle => 'No salons to show';

  @override
  String get customerHomeResetFilters => 'Reset search';

  @override
  String get customerSignOut => 'Sign out';

  @override
  String get signOutSubtitle =>
      'You\'ll need to sign in again to use your account.';

  @override
  String get customerSearchHint => 'Search salons, areas…';

  @override
  String customerGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get customerGuestName => 'there';

  @override
  String get customerNoSalons => 'No salons match your search.';

  @override
  String get customerSalonDetails => 'Salon';

  @override
  String get customerBook => 'Book appointment';

  @override
  String get customerServicesPreview => 'Popular services';

  @override
  String get customerNoServicesListed => 'No services listed yet.';

  @override
  String customerServiceMeta(int minutes, String price) {
    return '$minutes min · $price';
  }

  @override
  String get customerSalonNotFound => 'This salon is no longer available.';

  @override
  String get customerBookAppointment => 'Book appointment';

  @override
  String get customerSelectDate => 'Date';

  @override
  String get customerSelectService => 'Service';

  @override
  String get customerSelectBarber => 'Team member';

  @override
  String get customerSelectTime => 'Time';

  @override
  String get customerNotes => 'Notes (optional)';

  @override
  String get customerConfirmBooking => 'Confirm booking';

  @override
  String get customerBookingSubmitted => 'You are booked';

  @override
  String get customerBackHome => 'Back to home';

  @override
  String get bookingConfirmationTitle => 'Confirmation';

  @override
  String get bookingWhen => 'When';

  @override
  String get bookingBarber => 'Team member';

  @override
  String get bookingService => 'Service';

  @override
  String get bookingSalon => 'Salon';

  @override
  String get bookingReference => 'Reference';

  @override
  String get bookingNotFound => 'Booking not found.';

  @override
  String get customerNoBarbers => 'No team members available yet.';

  @override
  String get customerNoSlots =>
      'No open slots for this day. Try another date or team member.';

  @override
  String get customerBookingIncomplete =>
      'Choose a service, team member, and time.';

  @override
  String get customerBookingSignInRequired =>
      'Sign in to complete your booking.';

  @override
  String get customerBookingSlotTaken =>
      'That time was just taken. Choose another slot.';

  @override
  String get customerBookingSlotInvalid =>
      'That time is not available. Pick a different slot.';

  @override
  String customerBookingNotesTooLong(int maxChars) {
    return 'Notes cannot exceed $maxChars characters.';
  }

  @override
  String get customerBookingScreenHint =>
      'Pick a date, service, team member, and time. Smart picks below can fill team member and slot for you.';

  @override
  String get customerBookingSummaryTitle => 'Your visit';

  @override
  String get ownerTabOverview => 'Overview';

  @override
  String get ownerTabTeam => 'Team';

  @override
  String get ownerTabServices => 'Services';

  @override
  String get ownerTabBookings => 'Bookings';

  @override
  String get ownerTabMoney => 'Money';

  @override
  String get ownerWorkspaceWide => 'Today\'s workspace';

  @override
  String get ownerWorkspaceNarrow => 'Today\'s overview';

  @override
  String get ownerLoadError =>
      'Could not load your workspace. Please sign in again.';

  @override
  String ownerSalonChip(String id) {
    return 'Salon · $id';
  }

  @override
  String get ownerSalonSetupTitle => 'Add your salon details';

  @override
  String get ownerSalonSetupMessage =>
      'Choose your salon name and city to start managing bookings and your team.';

  @override
  String get ownerSalonSetupCta => 'Set up salon';

  @override
  String get ownerSales7 => 'Last 7 days';

  @override
  String get ownerSales30 => 'Last 30 days';

  @override
  String get ownerSalesAll => 'All';

  @override
  String get ownerOverviewTitle => 'Today at a glance';

  @override
  String get ownerOverviewSubtitle => 'Live totals from your salon.';

  @override
  String get ownerOverviewQuickService => 'Add service';

  @override
  String get ownerOverviewQuickBooking => 'Add booking';

  @override
  String get ownerOverviewQuickBarber => 'Add Team Member';

  @override
  String get ownerOverviewEmptyRevenueToday => 'No sales recorded today.';

  @override
  String get ownerOverviewEmptyBookingsToday =>
      'No bookings scheduled for today.';

  @override
  String get ownerOverviewEmptyTopBarberMonth =>
      'No team member sales yet this month.';

  @override
  String get ownerOverviewEmptyTopServiceMonth =>
      'No service usage yet this month.';

  @override
  String get ownerOverviewLoadingMetrics => 'Loading your metrics…';

  @override
  String get ownerOverviewTotalRevenueLabel => 'Total revenue';

  @override
  String get ownerOverviewTotalRevenuePeriod => 'This month';

  @override
  String get ownerOverviewTotalRevenueEmpty =>
      'No completed sales yet this month.';

  @override
  String get ownerOverviewServicesPanelCaption => 'Prices & durations';

  @override
  String ownerServicesCategoryBanner(String category) {
    return '$category — prices & durations';
  }

  @override
  String get ownerServicesCategoryAll => 'All services';

  @override
  String get ownerOverviewTeamColumnMember => 'Member';

  @override
  String get ownerOverviewTeamColumnRole => 'Role';

  @override
  String get ownerOverviewTeamColumnEmail => 'Email';

  @override
  String ownerOverviewServiceUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uses',
      one: '1 use',
    );
    return '$_temp0';
  }

  @override
  String get ownerStatTodayBookings => 'Today’s bookings';

  @override
  String get ownerStatRevenue => 'Revenue (window)';

  @override
  String get ownerStatUpcoming => 'Upcoming';

  @override
  String get ownerNoBookingsStat => '0';

  @override
  String get ownerBookingsListTitle => 'Bookings';

  @override
  String get ownerBookingCancel => 'Cancel';

  @override
  String get ownerBookingCancelled => 'Booking cancelled';

  @override
  String get ownerFilterStatus => 'Status';

  @override
  String get ownerFilterAll => 'All';

  @override
  String get ownerTeamTitle => 'Team';

  @override
  String get ownerTeamSubtitle => 'Manage team members and admins.';

  @override
  String get ownerTeamCardRoleLabel => 'Role';

  @override
  String get ownerTeamCardStatusLabel => 'Status';

  @override
  String get ownerTeamCardStatusActive => 'Active';

  @override
  String get ownerTeamCardStatusInactive => 'Inactive';

  @override
  String get ownerTeamCardManage => 'Manage';

  @override
  String get ownerAddMember => 'Add member';

  @override
  String get ownerEmployeeName => 'Name';

  @override
  String get ownerEmployeeEmail => 'Email';

  @override
  String get ownerEmployeeRole => 'Role';

  @override
  String get ownerEmployeePhone => 'Phone';

  @override
  String get ownerSave => 'Save';

  @override
  String get ownerEditMember => 'Edit member';

  @override
  String get ownerDeactivate => 'Deactivate';

  @override
  String get ownerActivate => 'Activate';

  @override
  String get ownerServicesTitle => 'Services';

  @override
  String get ownerServicesSubtitle => 'Manage what customers can book and buy';

  @override
  String get ownerServicesSearchPlaceholder => 'Search services';

  @override
  String get ownerServicesStatTotal => 'Total';

  @override
  String get ownerServicesStatActive => 'Active';

  @override
  String get ownerServicesStatInactive => 'Inactive';

  @override
  String get ownerServicesChipAll => 'All';

  @override
  String get ownerServicesChipHair => 'Hair';

  @override
  String get ownerServicesChipBeard => 'Beard';

  @override
  String get ownerServicesChipFacial => 'Facial';

  @override
  String get ownerServicesChipPackages => 'Packages';

  @override
  String get ownerServicesChipColoring => 'Coloring';

  @override
  String get ownerServiceCategoryHair => 'Hair';

  @override
  String get ownerServiceCategoryBarberBeard => 'Barber / Beard';

  @override
  String get ownerServiceCategoryNails => 'Nails';

  @override
  String get ownerServiceCategoryHairRemovalWaxing => 'Hair Removal / Waxing';

  @override
  String get ownerServiceCategoryOther => 'Other';

  @override
  String get ownerServiceCategoryBrowsLashes => 'Brows & Lashes';

  @override
  String get ownerServiceCategoryFacialSkincare => 'Facial / Skincare';

  @override
  String get ownerServiceCategoryMakeup => 'Makeup';

  @override
  String get ownerServiceCategoryMassageSpa => 'Massage / Spa';

  @override
  String get ownerServiceCategoryPackages => 'Packages';

  @override
  String get ownerServiceCategoryColoring => 'Coloring';

  @override
  String get ownerServiceCategoryTexturedHair => 'Textured Hair';

  @override
  String get ownerServiceCategoryBridal => 'Bridal';

  @override
  String get ownerServiceCategoryTanning => 'Tanning';

  @override
  String get ownerServiceCategoryMedSpa => 'Med Spa';

  @override
  String get ownerServiceCategoryMenGrooming => 'Men Grooming';

  @override
  String get ownerServiceCategoryHaircutStyling => 'Haircut & Styling';

  @override
  String get ownerServiceCategoryHairTreatments => 'Hair Treatments';

  @override
  String get ownerServiceCategoryScalpTreatments => 'Scalp Treatments';

  @override
  String get ownerServiceCategoryKeratinSmoothing => 'Keratin / Smoothing';

  @override
  String get ownerServiceCategoryHairExtensions => 'Hair Extensions';

  @override
  String get ownerServiceCategoryKidsServices => 'Kids Services';

  @override
  String get ownerServiceCategoryManicurePedicure => 'Manicure / Pedicure';

  @override
  String get ownerServiceCategoryNailArt => 'Nail Art';

  @override
  String get ownerServiceCategoryThreading => 'Threading';

  @override
  String get ownerServiceCategoryLashExtensions => 'Lash Extensions';

  @override
  String get ownerServiceCategoryBodyTreatments => 'Body Treatments';

  @override
  String get ownerServiceCategoryMakeupPermanent => 'Permanent Makeup';

  @override
  String get ownerServiceCustomCategoryLabel => 'Category name';

  @override
  String get ownerServiceValidationCategoryRequired => 'Choose a category.';

  @override
  String get ownerServiceValidationCustomCategoryRequired =>
      'Enter a category name.';

  @override
  String get ownerServiceValidationDuplicateCustomCategory =>
      'You already use this custom category name.';

  @override
  String get ownerServiceCategoriesMore => 'More';

  @override
  String get ownerServiceCategoriesMoreTitle => 'More categories';

  @override
  String get ownerServiceCategoryAllOther => 'All in Other';

  @override
  String get ownerServicesEmptyTitle => 'No services yet';

  @override
  String get ownerServicesEmptyDescription =>
      'Add your first service to let customers discover and book your offerings.';

  @override
  String get ownerServicesNoMatches =>
      'No services match your search or filters.';

  @override
  String get ownerServicesFabTooltip => 'Add service';

  @override
  String get ownerServiceSaveCta => 'Save Service';

  @override
  String get ownerServiceSavedSuccess => 'Service saved.';

  @override
  String get ownerServiceDeletedSuccess => 'Service removed.';

  @override
  String get ownerServiceValidationDurationInvalid =>
      'Enter a duration greater than zero.';

  @override
  String get ownerServiceValidationPriceInvalid =>
      'Enter a price greater than zero.';

  @override
  String get ownerServiceValidationArabicNameRequired =>
      'Enter the Arabic service name.';

  @override
  String get ownerServiceDeleteConfirmTitle => 'Delete service?';

  @override
  String get ownerServiceDeleteConfirmBody =>
      'This removes the service from your catalog. This cannot be undone.';

  @override
  String get ownerServiceActionCancel => 'Cancel';

  @override
  String get ownerServiceActionDelete => 'Delete';

  @override
  String get ownerServiceActionEdit => 'Edit';

  @override
  String get ownerServiceStatusActive => 'Active';

  @override
  String get ownerServiceStatusInactive => 'Inactive';

  @override
  String ownerServiceTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Used $count times',
      one: 'Used $count time',
    );
    return '$_temp0';
  }

  @override
  String ownerServiceTotalRevenue(String amount) {
    return 'Revenue $amount';
  }

  @override
  String get ownerServiceAnalyticsPlaceholder =>
      'Usage & revenue will appear as you sell.';

  @override
  String get ownerServiceFormImageUrlHint => 'Image URL (optional)';

  @override
  String get ownerServicePhotoSectionLabel => 'Service photo';

  @override
  String get ownerServiceUploadPhotoAction => 'Upload photo';

  @override
  String get ownerServicePhotoChooseGallery => 'Photo library';

  @override
  String get ownerServicePhotoChooseCamera => 'Take photo';

  @override
  String get ownerServicePhotoRemove => 'Remove photo';

  @override
  String get ownerServicePhotoUploading => 'Uploading…';

  @override
  String get ownerServicePhotoTooLarge => 'Choose an image under 5 MB.';

  @override
  String get ownerServicePhotoUploadError =>
      'Couldn’t upload the image. Try again.';

  @override
  String get ownerServiceFormDescriptionHint => 'Description (optional)';

  @override
  String get ownerServiceCategoryPickerLabel => 'Category';

  @override
  String get ownerServiceCategoryIconPreviewHint =>
      'This icon appears in booking, sales, and customer apps.';

  @override
  String get ownerServiceCategoryNone => 'None';

  @override
  String get ownerAddService => 'Add service';

  @override
  String get ownerEditService => 'Edit service';

  @override
  String get ownerServiceName => 'Service name (English)';

  @override
  String get ownerServiceNameArabic => 'Service name (Arabic)';

  @override
  String get ownerAddServiceSheetSubtitle =>
      'Create a bookable service for your customers';

  @override
  String get ownerServiceSectionDetailsTitle => 'Service details';

  @override
  String get ownerServiceSectionDetailsSubtitle =>
      'Basic information about your service';

  @override
  String get ownerServiceSectionDurationTitle => 'Duration & pricing';

  @override
  String get ownerServiceSectionDurationSubtitle =>
      'Set how long it takes and how much it costs';

  @override
  String get ownerServiceSectionPhotoSubtitle =>
      'Add a photo to showcase your service';

  @override
  String get ownerServiceSectionDescriptionSubtitle =>
      'Add more details about this service';

  @override
  String get ownerServiceActiveSubtitle => 'Show this service to customers';

  @override
  String get ownerServiceNamePlaceholder => 'e.g. Classic Haircut';

  @override
  String get ownerServiceNameArabicPlaceholder => 'e.g. قصة شعر كلاسيكية';

  @override
  String get ownerServiceDescriptionPlaceholderLong =>
      'Describe your service, what\'s included, benefits, etc.';

  @override
  String get ownerServicePhotoFormatsHint => 'PNG, JPG up to 5MB';

  @override
  String get ownerServicePhotoSizeHint => 'Recommended size: 1200x800px';

  @override
  String get ownerServiceSuffixMin => 'min';

  @override
  String get ownerServiceDuration => 'Duration (minutes)';

  @override
  String get ownerServicePrice => 'Price';

  @override
  String get ownerDeleteService => 'Delete';

  @override
  String get ownerMoneyTitle => 'Money';

  @override
  String get ownerMoneySubtitle => 'Sales, payroll, and expenses.';

  @override
  String get ownerKpiNone => '—';

  @override
  String get ownerKpiTodayRevenue => 'Today\'s revenue';

  @override
  String get ownerKpiMonthRevenue => 'Monthly revenue';

  @override
  String get ownerKpiBookingsToday => 'Bookings today';

  @override
  String get ownerKpiEmployees => 'Active employees';

  @override
  String get ownerKpiTopBarber => 'Top barber (month)';

  @override
  String get ownerKpiTopService => 'Top service (month)';

  @override
  String get ownerKpiCompletedToday => 'Completed today';

  @override
  String get ownerKpiCancelledToday => 'Cancelled today';

  @override
  String get ownerKpiRescheduledToday => 'Rescheduled today';

  @override
  String get ownerKpiCompletionRateMonth => 'Completion rate (month)';

  @override
  String get ownerKpiCancellationRateMonth => 'Cancellation rate (month)';

  @override
  String get ownerKpiTopBarberCompletionsMonth =>
      'Top barber · completions (month)';

  @override
  String get ownerMoneyRecognitionOperational => 'Operational';

  @override
  String get ownerMoneyRecognitionCash => 'Cash';

  @override
  String get ownerMoneySalesMonth => 'Sales (this month)';

  @override
  String get ownerMoneyPayrollSection => 'Payroll';

  @override
  String get ownerMoneyExpensesSection => 'Expenses';

  @override
  String get ownerMoneyEmptyPayroll => 'No payroll runs yet.';

  @override
  String get ownerMoneyEmptyExpenses => 'No expenses recorded yet.';

  @override
  String get ownerMoneyPayrollEmptyTitle => 'No payroll';

  @override
  String get ownerMoneyExpensesEmptyTitle => 'No expenses';

  @override
  String get ownerDashboardTitle => 'Workspace';

  @override
  String get ownerAiAssistantTooltip => 'Open dashboard assistant';

  @override
  String get aiAssistantTitle => 'Dashboard assistant';

  @override
  String get aiAssistantInputLabel => 'Ask the assistant';

  @override
  String get aiAssistantInputHint =>
      'Ask for today revenue, monthly revenue, or top barbers.';

  @override
  String get aiAssistantSend => 'Generate view';

  @override
  String get aiAssistantWelcomeTitle => 'Ask for an owner snapshot';

  @override
  String get aiAssistantWelcomeMessage =>
      'Use natural prompts to generate a focused revenue and team summary for your salon.';

  @override
  String get aiAssistantLoadingTitle => 'Building your dashboard view';

  @override
  String get aiAssistantLoadingMessage =>
      'The assistant is calling approved tools and preparing a compact surface.';

  @override
  String get aiAssistantErrorTitle => 'Assistant unavailable';

  @override
  String get aiAssistantErrorMessage =>
      'The assistant could not build a surface right now. Try again in a moment.';

  @override
  String get aiAssistantRetry => 'Try again';

  @override
  String get aiAssistantSalonRequiredTitle => 'Salon required';

  @override
  String get aiAssistantSalonRequiredMessage =>
      'This assistant needs a valid salon before it can load owner insights.';

  @override
  String get aiAssistantSuggestionTodayRevenue => 'show today revenue';

  @override
  String get aiAssistantSuggestionMonthRevenue => 'show this month revenue';

  @override
  String get aiAssistantSuggestionTopBarbers => 'show top barbers this month';

  @override
  String get smartWorkspaceTitle => 'Smart workspace';

  @override
  String get smartWorkspaceLoadingTitle => 'Preparing your workspace';

  @override
  String get smartWorkspaceLoadingMessage =>
      'Loading the right payroll, analytics, or attendance assistant view.';

  @override
  String get smartWorkspaceErrorTitle => 'Smart workspace unavailable';

  @override
  String get smartWorkspaceErrorMessage =>
      'The workspace could not load right now. Try again in a moment.';

  @override
  String get smartWorkspaceRetryAction => 'Try again';

  @override
  String get smartWorkspaceSalonRequiredTitle => 'Salon required';

  @override
  String get smartWorkspaceSalonRequiredMessage =>
      'This workspace needs a valid salon before it can load assistant tools.';

  @override
  String get smartWorkspaceWelcomeTitle => 'Ask for a guided workspace';

  @override
  String get smartWorkspaceWelcomeMessage =>
      'Use this assistant for payroll setup, payroll explanations, analytics summaries, and attendance corrections while keeping the business logic deterministic.';

  @override
  String get smartWorkspaceInputLabel => 'Ask smart workspace';

  @override
  String get smartWorkspaceInputHint =>
      'Try: set up payroll for Ahmed, explain Sara\'s payroll, or show payroll and expense summary for this month.';

  @override
  String get smartWorkspaceSendAction => 'Open workspace';

  @override
  String get smartWorkspaceUnknownTitle => 'Choose a guided assistant flow';

  @override
  String get smartWorkspaceUnknownSummary =>
      'The assistant only supports approved workspace flows.';

  @override
  String get smartWorkspaceUnknownMessage =>
      'Ask for payroll setup, payroll explanation, analytics, or attendance correction to continue.';

  @override
  String get smartWorkspaceSuggestionPayrollSetup =>
      'set up payroll for this month';

  @override
  String get smartWorkspaceSuggestionPayrollExplain =>
      'explain this month\'s payroll for Ahmed';

  @override
  String get smartWorkspaceSuggestionAnalytics =>
      'show payroll, revenue, and expenses this month';

  @override
  String get smartWorkspaceSuggestionAttendance =>
      'fix attendance for today\'s late barber';

  @override
  String get smartWorkspacePayrollSetupTitle => 'Payroll setup assistant';

  @override
  String get smartWorkspacePayrollSetupSummary =>
      'Review who is ready for payroll and jump into the right setup screen.';

  @override
  String get smartWorkspacePayrollSetupMissingEmployees =>
      'Missing basic salary setup';

  @override
  String smartWorkspacePayrollSetupActiveElements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active payroll elements available',
      one: '1 active payroll element available',
    );
    return '$_temp0';
  }

  @override
  String smartWorkspacePayrollSetupEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active payroll entries',
      one: '1 active payroll entry',
      zero: 'No active payroll entries',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspacePayrollSetupPickEmployeeTitle =>
      'Pick a team member';

  @override
  String get smartWorkspacePayrollSetupPickEmployeeMessage =>
      'Choose an employee to review their payroll entries and salary setup.';

  @override
  String get smartWorkspaceEmployeePickerLabel => 'Team member';

  @override
  String get smartWorkspacePeriodSelectorLabel => 'Payroll period';

  @override
  String get smartWorkspacePeriodPlaceholder => 'Choose a month';

  @override
  String get smartWorkspaceDateRangePickerLabel => 'Date range';

  @override
  String get smartWorkspaceDateRangePlaceholder => 'Choose a date range';

  @override
  String get smartWorkspaceOpenEmployeeSetup => 'Open employee setup';

  @override
  String get smartWorkspaceOpenPayrollRunReview => 'Open payroll run review';

  @override
  String get smartWorkspaceAddElementTitle => 'Add payroll element';

  @override
  String get smartWorkspaceAddElementSummary =>
      'Confirm the proposed payroll element before saving it to your catalog.';

  @override
  String get smartWorkspaceAddElementNeedsDetailsTitle =>
      'Need more payroll element details';

  @override
  String get smartWorkspaceAddElementNeedsDetailsMessage =>
      'Include a name and amount, for example: add a recurring transport allowance for 150.';

  @override
  String get smartWorkspaceElementClassificationTitle => 'Classification';

  @override
  String get smartWorkspaceClassificationEarning => 'Earning';

  @override
  String get smartWorkspaceClassificationDeduction => 'Deduction';

  @override
  String get smartWorkspaceClassificationInformation => 'Information';

  @override
  String get smartWorkspaceElementRecurrenceTitle => 'Recurrence';

  @override
  String get smartWorkspaceRecurrenceRecurring => 'Recurring';

  @override
  String get smartWorkspaceRecurrenceNonRecurring => 'One-time';

  @override
  String get smartWorkspaceElementCalculationTitle => 'Calculation method';

  @override
  String get smartWorkspaceCalculationFixed => 'Fixed amount';

  @override
  String get smartWorkspaceCalculationPercentage => 'Percentage';

  @override
  String get smartWorkspaceCalculationDerived => 'Derived';

  @override
  String get smartWorkspaceConfirmationTitle => 'Confirmation';

  @override
  String get smartWorkspaceAddElementConfirmMessage =>
      'This will save a new payroll element through the existing payroll repository.';

  @override
  String get smartWorkspaceFieldName => 'Name';

  @override
  String get smartWorkspaceFieldAmount => 'Amount';

  @override
  String get smartWorkspaceFieldClassification => 'Classification';

  @override
  String get smartWorkspaceFieldDate => 'Date';

  @override
  String get smartWorkspaceFieldStatus => 'Status';

  @override
  String get smartWorkspaceFieldCheckIn => 'Check-in';

  @override
  String get smartWorkspaceFieldCheckOut => 'Check-out';

  @override
  String get smartWorkspaceSaveElementAction => 'Save payroll element';

  @override
  String get smartWorkspacePayrollExplanationTitle => 'Payroll explanation';

  @override
  String get smartWorkspacePayrollExplanationSummary =>
      'Break down earnings and deductions using the existing payroll calculation service.';

  @override
  String get smartWorkspaceNetPayTitle => 'Net pay';

  @override
  String get smartWorkspacePayrollPreviewStatus =>
      'Preview based on current payroll rules';

  @override
  String get smartWorkspaceEarningsBreakdownTitle => 'Earnings breakdown';

  @override
  String get smartWorkspaceDeductionsBreakdownTitle => 'Deductions breakdown';

  @override
  String get smartWorkspaceOpenQuickPayAction => 'Open quick pay';

  @override
  String get smartWorkspaceAnalyticsTitle => 'Dynamic analytics assistant';

  @override
  String get smartWorkspaceRevenueTitle => 'Revenue';

  @override
  String smartWorkspaceTransactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed transactions',
      one: '1 completed transaction',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspaceExpensesTitle => 'Expenses';

  @override
  String get smartWorkspacePayrollTitle => 'Payroll';

  @override
  String smartWorkspaceDraftPayrollRuns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count draft payroll runs',
      one: '1 draft payroll run',
      zero: 'No draft payroll runs',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspaceNetResultTitle => 'Net result';

  @override
  String get smartWorkspaceChartTitle => 'Recent monthly trend';

  @override
  String get smartWorkspaceChartSubtitle =>
      'Revenue bars are shown with the same period context used by the assistant.';

  @override
  String get smartWorkspaceOpenSalesAction => 'Open sales';

  @override
  String get smartWorkspaceOpenExpensesAction => 'Open expenses';

  @override
  String get smartWorkspaceOpenPayrollAction => 'Open payroll';

  @override
  String get smartWorkspaceAttendanceCorrectionTitle =>
      'Attendance correction assistant';

  @override
  String get smartWorkspaceAttendanceCorrectionSummary =>
      'Review correction-ready records and confirm approved updates through the existing attendance repository.';

  @override
  String get smartWorkspaceAttendancePendingTitle =>
      'Pending attendance requests';

  @override
  String smartWorkspaceAttendanceCorrectionsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records need correction',
      one: '1 record needs correction',
      zero: 'No records need correction',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspaceAttendanceNoRecordTitle =>
      'No correction-ready record found';

  @override
  String get smartWorkspaceAttendanceNoRecordMessage =>
      'Adjust the employee or date range to find the attendance request you want to review.';

  @override
  String smartWorkspaceAttendanceRecordSummary(String status) {
    return 'Attendance status: $status';
  }

  @override
  String get smartWorkspaceAttendanceConfirmMessage =>
      'Review the correction details before applying the approved update.';

  @override
  String get smartWorkspaceAttendancePromptForDetails =>
      'Add a status or time change in your prompt to prepare a correction.';

  @override
  String get smartWorkspaceApplyAttendanceAction => 'Apply correction';

  @override
  String get smartWorkspaceOpenAttendanceReviewAction =>
      'Open attendance review';

  @override
  String get ownerTooltipCycleTheme =>
      'Cycle appearance (system / light / dark)';

  @override
  String get ownerTooltipCycleThemeShort => 'Cycle appearance';

  @override
  String get ownerTooltipLanguage => 'Switch language (English / العربية)';

  @override
  String get ownerTooltipLanguageShort => 'Language';

  @override
  String get ownerTooltipSignOut => 'Sign out';

  @override
  String get customerCategoryAll => 'All';

  @override
  String get customerMyBookings => 'My bookings';

  @override
  String get customerMyBookingsSubtitle => 'Upcoming and past visits';

  @override
  String get customerMyBookingsEmpty =>
      'You have no bookings yet. Discover a salon and book an appointment.';

  @override
  String get bookingNotes => 'Notes';

  @override
  String get bookingDuration => 'Duration';

  @override
  String bookingDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get bookingStatus => 'Status';

  @override
  String get bookingStatusPending => 'Pending';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingStatusNoShow => 'No show';

  @override
  String get bookingStatusRescheduled => 'Rescheduled';

  @override
  String get barberSummaryTitle => 'Today';

  @override
  String barberSummaryAppointments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appointments',
      one: '1 appointment',
      zero: 'No appointments',
    );
    return '$_temp0';
  }

  @override
  String get barberNextAppointment => 'Next';

  @override
  String get barberNextNone => 'No more today';

  @override
  String get barberEarningsMonth => 'This month';

  @override
  String get barberQuickSale => 'Quick sale';

  @override
  String get barberAttendanceCardTitle => 'Attendance';

  @override
  String get barberAttendanceIn => 'Checked in';

  @override
  String get barberAttendanceOut => 'Checked out';

  @override
  String get barberAttendanceNone => 'Not checked in yet';

  @override
  String get customerSectionBarbers => 'Team';

  @override
  String get customerBarberCardCta => 'Book +';

  @override
  String get customerBarberVerifiedTooltip => 'Salon-verified stylist';

  @override
  String get customerNoBarbersDetail => 'No barbers listed for this salon yet.';

  @override
  String get barberTabToday => 'Today';

  @override
  String get barberTabSale => 'Sale';

  @override
  String get barberTabAttendance => 'Attendance';

  @override
  String get barberTodayTitle => 'Today’s schedule';

  @override
  String get barberTodaySubtitle => 'Your assigned appointments.';

  @override
  String get barberNoEmployee =>
      'Your profile is missing a team link. Contact the owner.';

  @override
  String get barberRecordSaleTitle => 'Record sale';

  @override
  String get barberSaleService => 'Service';

  @override
  String get barberSalePayment => 'Payment';

  @override
  String get barberSaleSubmit => 'Save sale';

  @override
  String get barberSaleSuccess => 'Sale recorded';

  @override
  String get barberAttendanceTitle => 'Attendance';

  @override
  String get barberAttendanceSubtitle => 'Today’s punches.';

  @override
  String get barberCheckIn => 'Check in';

  @override
  String get barberCheckOut => 'Check out';

  @override
  String get barberNoAttendance => 'No attendance records today.';

  @override
  String get ownerMoneyPeriodToday => 'Today';

  @override
  String get ownerMoneyPeriodMonth => 'This month';

  @override
  String get ownerMoneyPeriodCustomSoon => 'Custom (soon)';

  @override
  String get ownerMoneyTotalSales => 'Sales total';

  @override
  String get ownerMoneyTotalPayroll => 'Payroll total';

  @override
  String get ownerMoneyTotalExpenses => 'Expenses total';

  @override
  String get ownerMoneyNetResult => 'Net result';

  @override
  String get ownerBookingsLoadMore => 'Load more';

  @override
  String get ownerBookingsLoadingMore => 'Loading…';

  @override
  String get ownerBookingDetailsTitle => 'Booking details';

  @override
  String get ownerBookingSaveNotes => 'Save notes';

  @override
  String get ownerBookingNotesSaved => 'Notes saved';

  @override
  String get ownerBookingNewTitle => 'New booking';

  @override
  String get ownerBookingCustomerUid => 'Customer user ID';

  @override
  String get ownerBookingCustomerUidHint =>
      'Paste the customer’s Firebase Auth UID (from their profile).';

  @override
  String get ownerBookingCustomerUidInvalid => 'Customer user ID is required.';

  @override
  String get ownerBookingCustomerNameOptional => 'Customer name (optional)';

  @override
  String get ownerBookingCreate => 'Create booking';

  @override
  String get ownerBookingCreated => 'Booking created';

  @override
  String get ownerBookingRescheduled => 'Booking rescheduled';

  @override
  String get ownerHrSettingsTitle => 'HR & violations';

  @override
  String get ownerHrSettingsSubtitle =>
      'Manage staff penalties, attendance rules and review requests.';

  @override
  String get ownerSettingsHrTileTitle => 'HR & violations';

  @override
  String get ownerSettingsHrTileSubtitle =>
      'Penalty rules, attendance policies and review queue';

  @override
  String get salonAttendanceZoneTitle => 'Attendance zone';

  @override
  String get salonAttendanceZoneSubtitle =>
      'Control where your team can punch in and out.';

  @override
  String get salonAttendanceZoneMapSectionTitle => 'Map';

  @override
  String get salonAttendanceZoneMapTapHint =>
      'Tap the map to move the zone center.';

  @override
  String get salonAttendanceZoneMapWebHint =>
      'Use the mobile app to pick the zone on the map.';

  @override
  String get salonAttendanceZoneMapCenterMarker => 'Zone center';

  @override
  String salonAttendanceZoneCoordinates(String lat, String lng) {
    return 'Lat $lat, Lng $lng';
  }

  @override
  String salonAttendanceZonePunchRadiusMeters(int meters) {
    return 'Allowed punch radius: $meters meters';
  }

  @override
  String salonAttendanceZoneMetersShort(int meters) {
    return '$meters m';
  }

  @override
  String get salonAttendanceZoneEnable => 'Enable attendance';

  @override
  String get salonAttendanceZoneRequireInPunchIn =>
      'Require inside zone for punch in';

  @override
  String get salonAttendanceZoneRequireInPunchOut =>
      'Require inside zone for punch out';

  @override
  String get salonAttendanceZoneAllowBreaks => 'Allow breaks';

  @override
  String get salonAttendanceZoneAllowCorrections =>
      'Allow attendance correction requests';

  @override
  String get salonAttendanceZoneSave => 'Save';

  @override
  String get salonAttendanceZoneSaved => 'Attendance settings saved';

  @override
  String get salonAttendanceZoneSaveFailed => 'Save failed';

  @override
  String get ownerAttendanceSettingsTitle => 'Attendance settings';

  @override
  String get ownerAttendanceSettingsSubtitle =>
      'Manage zone, punches, breaks, corrections and HR rules';

  @override
  String get ownerAttendanceSettingsStatusActive => 'Active';

  @override
  String get ownerAttendanceSettingsStatusLocationMissing => 'Location missing';

  @override
  String get ownerAttendanceSectionZone => 'Attendance zone';

  @override
  String get ownerAttendanceSectionPunchRules => 'Punch rules';

  @override
  String get ownerAttendanceSectionGrace => 'Grace and working time';

  @override
  String get ownerAttendanceSectionCorrection => 'Correction requests';

  @override
  String get ownerAttendanceSectionViolations => 'HR violation rules';

  @override
  String get ownerAttendanceZoneMapPickAction => 'Pick salon location';

  @override
  String get ownerAttendanceZoneCoordinatesEmpty =>
      'Tap the map to set the salon location.';

  @override
  String get ownerAttendanceZoneRadiusLabel => 'Allowed radius';

  @override
  String get ownerAttendanceZoneLocationRequired =>
      'Location required to punch';

  @override
  String get ownerAttendanceZoneLocationRequiredHint =>
      'Employees must be inside the zone to punch in or out.';

  @override
  String get ownerAttendanceRulesAttendanceRequired => 'Attendance required';

  @override
  String get ownerAttendanceRulesAttendanceRequiredHint =>
      'Employees must record their day before working.';

  @override
  String get ownerAttendanceRulesPunchInRequired => 'Punch in required';

  @override
  String get ownerAttendanceRulesPunchOutRequired => 'Punch out required';

  @override
  String get ownerAttendanceRulesBreaksEnabled => 'Breaks enabled';

  @override
  String get ownerAttendanceRulesMaxPunchesLabel => 'Max punches per day';

  @override
  String get ownerAttendanceRulesMaxBreaksLabel => 'Max breaks per day';

  @override
  String get ownerAttendanceGraceLateLabel => 'Late grace (minutes)';

  @override
  String get ownerAttendanceGraceEarlyExitLabel => 'Early exit grace (minutes)';

  @override
  String get ownerAttendanceGraceMinShiftLabel => 'Minimum shift (minutes)';

  @override
  String get ownerAttendanceGraceMaxShiftLabel => 'Maximum shift (minutes)';

  @override
  String get ownerAttendanceCorrectionEnabled => 'Enable correction requests';

  @override
  String get ownerAttendanceCorrectionRequireReason =>
      'Require correction reason';

  @override
  String get ownerAttendanceCorrectionRequireApproval =>
      'Require owner/admin approval';

  @override
  String get ownerAttendanceCorrectionMaxPerMonth =>
      'Max correction requests per month';

  @override
  String get ownerAttendanceViolationsAuto => 'Auto-create violations';

  @override
  String get ownerAttendanceViolationsAutoHint =>
      'Generate payroll violations automatically when limits are exceeded.';

  @override
  String get ownerAttendanceViolationsMissingCheckoutPercent =>
      'Missing checkout deduction (%)';

  @override
  String get ownerAttendanceViolationsAbsencePercent => 'Absence deduction (%)';

  @override
  String get ownerAttendanceViolationsLatePercent => 'Late deduction (%)';

  @override
  String get ownerAttendanceViolationsEarlyExitPercent =>
      'Early exit deduction (%)';

  @override
  String get ownerAttendanceViolationsLateAllowance =>
      'Allowed late count per month';

  @override
  String get ownerAttendanceViolationsEarlyExitAllowance =>
      'Allowed early exit count per month';

  @override
  String get ownerAttendanceViolationsMissingCheckoutAllowance =>
      'Allowed missing checkout count per month';

  @override
  String get ownerAttendanceSettingsSave => 'Save changes';

  @override
  String get ownerAttendanceSettingsSaved => 'Attendance settings updated';

  @override
  String get ownerAttendanceSettingsSaveFailed =>
      'Could not save attendance settings';

  @override
  String get ownerAttendanceSettingsValidationLocationMissing =>
      'Pick a salon location before saving.';

  @override
  String get ownerAttendanceSettingsValidationRadius =>
      'Radius must be between 10 and 500 meters.';

  @override
  String get ownerAttendanceSettingsValidationMaxPunches =>
      'Max punches must be between 2 and 10.';

  @override
  String get ownerAttendanceSettingsValidationMaxBreaks =>
      'Max breaks must be between 0 and 5.';

  @override
  String get ownerAttendanceSettingsValidationGraceLate =>
      'Late grace must be between 0 and 120 minutes.';

  @override
  String get ownerAttendanceSettingsValidationGraceEarly =>
      'Early exit grace must be between 0 and 120 minutes.';

  @override
  String get ownerAttendanceSettingsValidationMinShift =>
      'Minimum shift must be greater than 0.';

  @override
  String get ownerAttendanceSettingsValidationMaxShift =>
      'Maximum shift must be greater than minimum shift.';

  @override
  String get ownerAttendanceSettingsValidationDeduction =>
      'Deduction percentages must be between 0 and 100.';

  @override
  String get ownerAttendanceSettingsValidationAllowance =>
      'Allowed counts must be 0 or more.';

  @override
  String get ownerMoneySalesSection => 'Sales';

  @override
  String get ownerMoneySalesEmptyTitle => 'No sales';

  @override
  String get ownerMoneyEmptySales => 'No sales in this period yet.';

  @override
  String get ownerAddSaleTitle => 'Add sale';

  @override
  String get ownerAddSaleSubtitle =>
      'Record a walk-in or counter sale quickly.';

  @override
  String get ownerAddSaleServiceField => 'Service';

  @override
  String get ownerAddSaleBarberField => 'Service provider';

  @override
  String get ownerAddSalePriceLabel => 'Price';

  @override
  String get ownerAddSalePriceHint => 'Choose a service to see the price.';

  @override
  String get ownerAddSaleCustomerHint => 'Customer name (optional)';

  @override
  String get ownerAddSaleSave => 'Save sale';

  @override
  String get ownerAddSaleSuccess => 'Sale saved';

  @override
  String get ownerAddSaleValidation =>
      'Pick at least one service, a service provider, and a payment method.';

  @override
  String get ownerAddSaleOpen => 'Add sale';

  @override
  String get ownerAddSaleNoStaff => 'Add team members before recording sales.';

  @override
  String get ownerServiceCategory => 'Category (optional)';

  @override
  String get ownerServiceActiveLabel => 'Service is active';

  @override
  String get ownerServiceInactiveBadge => 'Inactive';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get adminConsoleTitle => 'Admin console';

  @override
  String get adminWorkspaceSubtitle =>
      'Manage staff, policies, and operations for your salon.';

  @override
  String adminSalonIdLine(String salonId) {
    return 'Salon ID: $salonId';
  }

  @override
  String get adminSalonNotLinked => 'No salon linked';

  @override
  String get roleBarber => 'Team member';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodDigitalWallet => 'Digital wallet';

  @override
  String get paymentMethodOther => 'Other';

  @override
  String get payrollStatusDraft => 'Draft';

  @override
  String get payrollStatusPendingApproval => 'Pending approval';

  @override
  String get payrollStatusApproved => 'Approved';

  @override
  String get payrollStatusPaid => 'Paid';

  @override
  String get payrollStatusVoided => 'Voided';

  @override
  String get customerBookingsUpcoming => 'Upcoming';

  @override
  String get customerBookingsPast => 'Past';

  @override
  String get customerBookingsUpcomingEmpty => 'No upcoming visits.';

  @override
  String get customerBookingsPastEmpty => 'No past visits yet.';

  @override
  String get customerBookingCancel => 'Cancel';

  @override
  String get customerBookingReschedule => 'Reschedule';

  @override
  String get customerBookingCancelledToast => 'Booking cancelled';

  @override
  String get customerBookingRescheduledToast => 'Booking updated';

  @override
  String get customerBookingActionUnavailable =>
      'This action is not available for this booking.';

  @override
  String get customerRescheduleTitle => 'Reschedule booking';

  @override
  String get customerRescheduleSubmit => 'Save new time';

  @override
  String get customerMyBookingsLoading => 'Loading your bookings…';

  @override
  String get listLoadMore => 'Load more';

  @override
  String get bookingOpMarkArrived => 'Customer arrived';

  @override
  String get bookingOpStartService => 'Start service';

  @override
  String get bookingOpComplete => 'Complete';

  @override
  String get bookingOpNoShowCustomer => 'No-show (customer)';

  @override
  String get bookingOpNoShowBarber => 'No-show (barber)';

  @override
  String get ownerViolationsTitle => 'Violations & penalties';

  @override
  String get ownerViolationsSubtitle =>
      'Approve deductions before payroll applies them.';

  @override
  String get ownerViolationsEmpty => 'No pending violations.';

  @override
  String get ownerViolationBooking => 'Booking';

  @override
  String get ownerViolationAmount => 'Amount';

  @override
  String get ownerViolationApprove => 'Approve';

  @override
  String get ownerViolationReject => 'Reject';

  @override
  String get ownerViolationReviewSaved => 'Violation updated';

  @override
  String get ownerPenaltySettingsTitle => 'Penalty rules';

  @override
  String get ownerPenaltySettingsSaved => 'Penalty settings saved';

  @override
  String get ownerPenaltyLateEnabled => 'Staff late penalties';

  @override
  String get ownerPenaltyGraceMinutes => 'Grace (minutes)';

  @override
  String get ownerPenaltyCalcFlat => 'Flat amount';

  @override
  String get ownerPenaltyCalcPercent => 'Percent of gross';

  @override
  String get ownerPenaltyCalcPerMinute => 'Per minute after grace';

  @override
  String get ownerPenaltyLateValue => 'Late penalty value';

  @override
  String get ownerPenaltyNoShowEnabled => 'Staff no-show penalties';

  @override
  String get ownerPenaltyNoShowValue => 'No-show penalty value';

  @override
  String get ownerViolationsMetricPending => 'Pending reviews';

  @override
  String get ownerViolationsMetricRulesOn => 'Active rules';

  @override
  String get ownerPenaltyAppliesWhenLabel => 'Penalty applies when';

  @override
  String get ownerPenaltyLateWhenBody =>
      'Staff member checks in late after grace';

  @override
  String get ownerPenaltyNoShowWhenBody =>
      'Staff member misses the appointment';

  @override
  String get ownerPenaltyMetricCalculation => 'Calculation';

  @override
  String get ownerKpiNoShowToday => 'No-shows today';

  @override
  String get ownerKpiNoShowRateMonth => 'No-show rate (month)';

  @override
  String get ownerKpiPenaltyMonth => 'Penalties (month)';

  @override
  String get ownerKpiTopPenalizedBarber => 'Top penalized (month)';

  @override
  String get payrollDeductionViolations => 'Deductions';

  @override
  String get payrollStatusRolledBack => 'Rolled back';

  @override
  String get payrollBadgeRecurring => 'Recurring';

  @override
  String get payrollBadgeNonRecurring => 'One-time';

  @override
  String payrollLineQuantity(String value) {
    return 'Qty $value';
  }

  @override
  String payrollLineRate(String value) {
    return 'Rate $value';
  }

  @override
  String get payrollGenericError =>
      'Payroll data could not be loaded right now.';

  @override
  String get payrollEmployeeAlreadyPaidForPeriod =>
      'This team member already has a paid payroll for this period.';

  @override
  String get payrollAllStaffAlreadyPaidForPeriod =>
      'Everyone on your list already has a paid payroll for this period.';

  @override
  String get payrollSummaryEarnings => 'Earnings';

  @override
  String get payrollSummaryDeductions => 'Deductions';

  @override
  String get payrollSummaryNetPay => 'Net pay';

  @override
  String get payrollSectionEarnings => 'Earnings lines';

  @override
  String get payrollSectionDeductions => 'Deduction lines';

  @override
  String get payrollSectionInformation => 'Information lines';

  @override
  String get payrollSectionEmpty => 'No lines for this section.';

  @override
  String get payrollDashboardTitle => 'Payroll';

  @override
  String payrollDashboardSubtitle(String monthLabel) {
    return '$monthLabel payroll engine overview.';
  }

  @override
  String get ownerPayrollFinanceBreadcrumb => 'Finance · Payroll';

  @override
  String get ownerPayrollRunReviewBreadcrumb =>
      'Finance · Payroll · Run review';

  @override
  String get payrollRunReviewEngineHint =>
      'Includes commissions from sales, attendance, violations, and your payroll elements.';

  @override
  String get payrollRunReviewConfigureSectionTitle => 'Period & team';

  @override
  String get payrollRunReviewCadenceLabel => 'Payroll period type';

  @override
  String get payrollRunReviewCadenceMonthly => 'Monthly';

  @override
  String get payrollRunReviewCadenceWeekly => 'Weekly';

  @override
  String get payrollRunWeeklyPaidDaysHint =>
      'Pay is calculated only for the calendar days you select (inclusive).';

  @override
  String get payrollRunWeeklyStartLabel => 'Start date';

  @override
  String get payrollRunWeeklyEndLabel => 'End date';

  @override
  String get payrollRunWeeklyRangeInvalid =>
      'Choose a valid weekly range (1–31 days, end on or after start).';

  @override
  String get payrollRunNoMatchingStaffForCadence =>
      'No team members use this payroll period. Assign monthly or weekly under Team → payroll period, or switch the period type above.';

  @override
  String get payrollRunReviewViewPayslip => 'View payslip';

  @override
  String get payrollRollbackConfirmTitle => 'Rollback this payroll run?';

  @override
  String get payrollRollbackConfirmMessage =>
      'This reverses payslip snapshots and linked adjustments for this run. If the run is paid, payslips are removed from staff apps—confirm this matches your bank and accounting records. Continue?';

  @override
  String get payrollRollbackConfirmAction => 'Rollback';

  @override
  String get payrollRunReviewStatusPaidHint =>
      'Paid run. Use rollback below only if you must reverse payouts—payslips disappear from staff apps and linked violations reopen where applicable.';

  @override
  String get payrollRunReviewStatusRolledBackHint =>
      'This run was rolled back. You can recalculate when ready.';

  @override
  String get payrollRunReviewKpiHeadcountTrend => 'In this run';

  @override
  String get payrollRunReviewWorkflowTitle => 'Next steps';

  @override
  String get payrollRunReviewWorkflowSubtitle =>
      'Approve when ready, then mark paid after you pay out.';

  @override
  String get payrollRunReviewTeamPreviewTitle => 'Team breakdown';

  @override
  String get payrollDashboardKpiTrendLabel => 'This month';

  @override
  String get payrollDashboardKpiThisWeek => 'This week';

  @override
  String get payrollDashboardKpiRunsLabel => 'Payroll runs';

  @override
  String get payrollDashboardKpiRunsHint => 'Runs in this month';

  @override
  String get payrollDashboardKpiRunsHintWeek => 'Runs in this ISO week';

  @override
  String payrollDashboardSubtitleWeek(String weekLabel) {
    return '$weekLabel payroll engine overview.';
  }

  @override
  String payrollIsoWeekShortLabel(int weekYear, String weekNumberPadded) {
    return '$weekYear-W$weekNumberPadded';
  }

  @override
  String get payrollWeekPickerHelp => 'Pick any day in the payroll week';

  @override
  String get payrollStatusBreakdownSubtitleWeek =>
      'Counts for the selected ISO week.';

  @override
  String get payrollRecentRunsSectionSubtitleWeek =>
      'Finalized runs in the selected ISO week.';

  @override
  String get settingsPayrollCadenceTitle => 'Payroll period';

  @override
  String get settingsPayrollCadenceSubtitle =>
      'Default calendar for payroll runs, QuickPay, and the payroll hub.';

  @override
  String get settingsPayrollCadenceSave => 'Save';

  @override
  String get settingsPayrollCadenceSaved => 'Payroll period updated';

  @override
  String get settingsPayrollCadenceMonthly => 'Monthly';

  @override
  String get settingsPayrollCadenceWeekly => 'Weekly (ISO weeks)';

  @override
  String get teamPayrollPeriodLabel => 'Payroll period';

  @override
  String get teamPayrollPeriodHint =>
      'Defaults to your salon payroll period. Change only if this person should use the other cadence.';

  @override
  String get teamPayrollPeriodInherit => 'Same as salon default';

  @override
  String teamPayrollPeriodInheritDetail(String periodLabel) {
    return 'Same as salon · $periodLabel';
  }

  @override
  String get teamPayrollPeriodMonthly => 'Monthly';

  @override
  String get teamPayrollPeriodWeekly => 'Weekly (ISO weeks)';

  @override
  String get payrollRecentRunsSectionSubtitle =>
      'Finalized runs in the selected month.';

  @override
  String get payrollStatusBreakdownSubtitle => 'Counts for the selected month.';

  @override
  String get payrollQuickPayTitle => 'QuickPay';

  @override
  String get payrollQuickPayScreenSubtitle =>
      'Choose who to pay and which month. Calculate, then save as draft, approve, or mark paid—the same workflow as your payroll runs.';

  @override
  String get payrollQuickPayShortcutSubtitle =>
      'Pick staff and month, calculate, then pay for this period.';

  @override
  String get payrollQuickPaySetupCardTitle => 'Period and staff';

  @override
  String get payrollQuickPayStaffSheetTitle => 'Choose staff';

  @override
  String get payrollQuickPayStaffPickerLabel => 'Staff member';

  @override
  String get payrollQuickPayStaffEmpty => 'No eligible staff for payroll.';

  @override
  String get payrollQuickPayStatementCardTitle => 'Pay statement';

  @override
  String get payrollQuickPayRunStatusLabel => 'Run status';

  @override
  String get payrollQuickPaySearchHint => 'Search by name';

  @override
  String get payrollQuickPaySearchEmpty => 'No matching staff.';

  @override
  String get payrollRunReviewTitle => 'Payroll run review';

  @override
  String get payrollRunShortcutSubtitle =>
      'Review a monthly payroll run for multiple employees.';

  @override
  String get payrollStatusBreakdownTitle => 'Status breakdown';

  @override
  String get payrollRecentRunsTitle => 'Recent payroll runs';

  @override
  String get payrollRecentRunsEmpty =>
      'Recent payroll activity will appear here.';

  @override
  String payrollRunGroupLabel(int count) {
    return '$count employees';
  }

  @override
  String get payrollMissingSetupTitle => 'Missing payroll setup';

  @override
  String get payrollMissingSetupEmpty =>
      'All active employees have a recurring payroll setup.';

  @override
  String get payrollDashboardSetupCardTitle => 'Payroll setup';

  @override
  String get payrollSetupEveryoneReadyHeading => 'Team is ready';

  @override
  String get payrollSetupNeedsAttentionSubtitle =>
      'Add at least one recurring \"basic salary\" payroll entry for each teammate below (opens their payroll setup).';

  @override
  String get payrollSetupWhereToConfigureTitle => 'Where to configure';

  @override
  String get payrollSetupShortcutCatalogTitle => 'Payroll catalog';

  @override
  String get payrollSetupShortcutCatalogSubtitle =>
      'Seed defaults, earning and deduction rules';

  @override
  String get payrollSetupShortcutTeamTitle => 'Team';

  @override
  String get payrollSetupShortcutTeamSubtitle =>
      'Open a barber profile → Payroll to add salary entries';

  @override
  String get payrollActionSetUp => 'Set up';

  @override
  String get payrollElementsTitle => 'Payroll elements';

  @override
  String get payrollElementsSeedDefaults => 'Seed defaults';

  @override
  String get payrollElementsAdd => 'Add element';

  @override
  String get payrollElementsEmptyTitle => 'No payroll elements yet';

  @override
  String get payrollElementsEmptySubtitle =>
      'Seed the default earning, deduction, and information elements to start building payroll.';

  @override
  String get payrollElementsSystemTag => 'System';

  @override
  String get payrollFieldCode => 'Code';

  @override
  String get payrollFieldName => 'Name';

  @override
  String get payrollFieldClassification => 'Classification';

  @override
  String get payrollFieldRecurrence => 'Recurrence';

  @override
  String get payrollFieldCalculationMethod => 'Calculation method';

  @override
  String get payrollFieldDefaultAmount => 'Default amount';

  @override
  String get payrollFieldVisibleOnPayslip => 'Visible on payslip';

  @override
  String get payrollFieldAffectsNetPay => 'Affects net pay';

  @override
  String get payrollFieldElement => 'Element';

  @override
  String get payrollFieldAmount => 'Amount';

  @override
  String get payrollFieldPercentageOptional => 'Percentage (optional)';

  @override
  String get payrollFieldNote => 'Note';

  @override
  String get payrollFieldEmployee => 'Employee';

  @override
  String get payrollFieldPayrollPeriod => 'Payroll period';

  @override
  String get payrollClassificationEarning => 'Earning';

  @override
  String get payrollClassificationDeduction => 'Deduction';

  @override
  String get payrollClassificationInformation => 'Information';

  @override
  String get payrollCalculationFixed => 'Fixed';

  @override
  String get payrollCalculationPercentage => 'Percentage';

  @override
  String get payrollCalculationDerived => 'Derived';

  @override
  String get payrollActionSave => 'Save';

  @override
  String get payrollActionCalculate => 'Calculate';

  @override
  String get payrollActionSaveDraft => 'Save draft';

  @override
  String get payrollActionApprove => 'Approve';

  @override
  String get payrollActionPay => 'Pay';

  @override
  String get payrollActionRollback => 'Rollback';

  @override
  String get payrollReversalTitle => 'Reverse payroll';

  @override
  String get payrollReversalShortcutSubtitle =>
      'Pick a run, then reverse the whole run or one team member.';

  @override
  String get payrollReversalScreenTitle => 'Reverse a payroll run';

  @override
  String get payrollReversalScreenSubtitle =>
      'Choose a draft, approved, or paid run. Paid runs remove payslips from staff apps—confirm carefully.';

  @override
  String get payrollReversalScopeWholeRun => 'Whole run';

  @override
  String get payrollReversalScopeOneMember => 'One team member';

  @override
  String get payrollReversalSelectRunHint => 'Select a payroll run';

  @override
  String get payrollReversalSelectMemberHint => 'Select a team member';

  @override
  String get payrollReversalNoRunsMessage =>
      'No reversible payroll runs right now.';

  @override
  String get payrollReversalPartialUnavailableHint =>
      'This run only includes one person—use whole run to reverse it.';

  @override
  String get payrollReversalConfirmTitle => 'Reverse payroll?';

  @override
  String get payrollReversalConfirmWholeRunMessage =>
      'This will roll back the entire run, restore linked violations where applicable, and remove payslips for this period.';

  @override
  String payrollReversalConfirmOneMemberMessage(String employeeName) {
    return 'This will remove $employeeName from this run, roll back their linked violations where applicable, and delete their payslip for this period.';
  }

  @override
  String get payrollReversalSuccess => 'Payroll reversal completed.';

  @override
  String get payrollEmployeeSetupTitle => 'Employee payroll setup';

  @override
  String get payrollEmployeeAddEntry => 'Add entry';

  @override
  String get payrollEmployeeSetupSubtitle =>
      'Manage recurring and one-time payroll entries for this employee.';

  @override
  String get payrollEmployeeEntriesEmptyTitle => 'No payroll entries yet';

  @override
  String get payrollEmployeeEntriesEmptySubtitle =>
      'Add recurring salary items and one-time adjustments for this employee.';

  @override
  String get payrollQuickPayValidation =>
      'Select an employee and payroll period first.';

  @override
  String get payrollQuickPayStatementEmptyTitle => 'No quick pay statement yet';

  @override
  String get payrollQuickPayStatementEmptySubtitle =>
      'Choose an employee and period to calculate earnings and deductions.';

  @override
  String get payrollPayslipTitle => 'Payslip';

  @override
  String get payrollPayslipEmptyTitle => 'No payslip lines found';

  @override
  String get payrollPayslipEmptySubtitle =>
      'This payroll run does not have visible lines for the selected employee.';

  @override
  String get payrollRunEmployeesLabel => 'Employees';

  @override
  String get payrollRunAllEmployees => 'All active employees';

  @override
  String get payrollRunAllMatchingStaff => 'All matching staff';

  @override
  String get payrollRunValidation =>
      'Choose a payroll period before calculating.';

  @override
  String get payrollRunReviewHistoryTitle => 'Payroll history';

  @override
  String get payrollRunReviewHistorySubtitle =>
      'Approved and paid payroll runs (drafts are hidden). Tap an approved run to pay or roll back.';

  @override
  String get payrollRunReviewHistoryEmpty =>
      'No payroll transactions yet. Calculate a run above to get started.';

  @override
  String get payrollHistoryApprovedSheetTitle => 'Approved — not paid yet';

  @override
  String get payrollHistoryApprovedSheetBody =>
      'Mark as paid after you transfer funds, or roll back to undo this approval.';

  @override
  String get payrollHistoryMarkedPaidSnack => 'Marked as paid.';

  @override
  String get payrollHistoryRollbackSnack => 'Payroll run rolled back.';

  @override
  String payrollRunEmployeeSummary(int lineCount, String netPay) {
    return '$lineCount lines · net $netPay';
  }

  @override
  String get violationTypeBarberLate => 'Late';

  @override
  String get violationTypeBarberNoShow => 'Barber no-show';

  @override
  String get customerRecommendationsTitle => 'Suggestions';

  @override
  String get customerRecommendationBest => 'Best choice';

  @override
  String get customerRecommendationFastest => 'Fastest available';

  @override
  String get customerRecommendationPreferred => 'Your barber';

  @override
  String get customerRecommendationAlternatives => 'Alternatives';

  @override
  String customerRecommendationUseSlot(String time, String barber) {
    return 'Use $time · $barber';
  }

  @override
  String get recommendationReasonExperiencedWithService =>
      'Experienced with this service';

  @override
  String get recommendationReasonNoServiceHistoryFallback =>
      'Limited recent history for this service';

  @override
  String get recommendationReasonStrongTrackRecord =>
      'Strong completion record';

  @override
  String get recommendationReasonSoonestTime => 'Soonest open time';

  @override
  String get recommendationReasonPreferredBarber => 'Your preferred barber';

  @override
  String get recommendationReasonBalancedSchedule => 'Balanced upcoming load';

  @override
  String get recommendationReasonMoreAvailabilityToday => 'Earlier slot today';

  @override
  String get notificationsCenterTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationsPreferencesTitle => 'Notification settings';

  @override
  String get notificationsPreferencesTooltip => 'Notification settings';

  @override
  String get notificationsPrefPushMaster => 'Push notifications';

  @override
  String get notificationsPrefBookingReminders => 'Booking reminders';

  @override
  String get notificationsPrefBookingChanges => 'Booking updates';

  @override
  String get notificationsPrefPayroll => 'Payroll alerts';

  @override
  String get notificationsPrefViolations => 'Violations and no-shows';

  @override
  String get notificationsPrefMarketing => 'Tips and offers';

  @override
  String get notificationsPrefMarketingHint =>
      'Occasional updates from your salon or the app.';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterUnread => 'Unread';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptySubtitle =>
      'Updates about bookings, attendance, payroll, and team activity will appear here.';

  @override
  String get notificationsFirestoreIndexBuildingSubtitle =>
      'Your inbox will load shortly — Firestore is finishing the notification index. Pull to refresh or try again in a minute.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsSettingBookingUpdates => 'Booking updates';

  @override
  String get notificationsSettingAttendanceUpdates => 'Attendance updates';

  @override
  String get notificationsSettingPayrollUpdates => 'Payroll updates';

  @override
  String get notificationsSettingApprovals => 'Approval requests';

  @override
  String get notificationsSettingSystemAlerts => 'System alerts';

  @override
  String get notificationsInboxTooltip => 'Notifications';

  @override
  String get customerNotificationsTooltip => 'Notifications';

  @override
  String get customerDiscoveryGoodMorning => 'Good morning';

  @override
  String get customerDiscoveryGoodAfternoon => 'Good afternoon';

  @override
  String get customerDiscoveryGoodEvening => 'Good evening';

  @override
  String customerDiscoveryNameWave(String name) {
    return '$name 👋';
  }

  @override
  String customerPromoSalonEyebrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salons live',
      one: '1 salon live',
      zero: 'No salons to show yet',
    );
    return '$_temp0';
  }

  @override
  String customerPromoServicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active services to browse',
      one: '1 active service to browse',
      zero: 'Services appear as soon as salons publish them.',
    );
    return '$_temp0';
  }

  @override
  String get customerPromoCta => 'Browse salons';

  @override
  String get customerSectionQuickServices => 'Services from salons';

  @override
  String get customerSectionNearbySalons => 'Salons for you';

  @override
  String get customerSeeAll => 'See all';

  @override
  String get customerSalonDiscoveryTitle => 'Find your salon';

  @override
  String get customerSalonDiscoverySubtitle => 'Book your next appointment';

  @override
  String get customerSalonDiscoverySearchHint => 'Search salon, service, area…';

  @override
  String get customerSalonDiscoveryNearYou => 'Near you';

  @override
  String get customerSalonDiscoveryEmpty =>
      'No salons match yet. Try adjusting filters or search.';

  @override
  String get customerSalonDiscoveryRetry => 'Retry';

  @override
  String get customerSalonDiscoveryErrorPermission =>
      'Salon list is unavailable. Check Firestore rules and indexes.';

  @override
  String get customerSalonDiscoveryBookingsSignIn =>
      'Sign in to view your bookings.';

  @override
  String get customerSalonDiscoveryNavDiscover => 'Discover';

  @override
  String get customerSalonDiscoveryNavBookings => 'Bookings';

  @override
  String get customerSalonDiscoveryNavAccount => 'Account';

  @override
  String get customerSalonBookmarkTooltip => 'Save salon';

  @override
  String customerSalonStartingFrom(String price) {
    return 'From $price';
  }

  @override
  String get customerSalonOpenNowBadge => 'Open now';

  @override
  String get customerSalonClosedBadge => 'Closed';

  @override
  String get customerSalonFilterNearby => 'Nearby';

  @override
  String get customerSalonFilterOpenNow => 'Open now';

  @override
  String get customerSalonFilterTopRated => 'Top rated';

  @override
  String get customerSalonFilterOffers => 'Offers';

  @override
  String get customerSalonFilterLadies => 'Ladies';

  @override
  String get customerSalonFilterMen => 'Men';

  @override
  String get customerSalonFilterUnisex => 'Unisex';

  @override
  String get customerProfileTabServices => 'Services';

  @override
  String get customerProfileTabTeam => 'Team';

  @override
  String get customerProfileTabReviews => 'Reviews';

  @override
  String get customerProfileTabAbout => 'About';

  @override
  String get customerProfileBookAppointment => 'Book appointment';

  @override
  String get customerProfileActionCall => 'Call';

  @override
  String get customerProfileActionWhatsApp => 'WhatsApp';

  @override
  String get customerProfileActionMap => 'Map';

  @override
  String get customerProfileActionShare => 'Share';

  @override
  String get customerProfileEmptyServices => 'No services available yet.';

  @override
  String get customerProfileEmptyTeam => 'No specialists available yet.';

  @override
  String get customerProfileEmptyReviews => 'No reviews yet.';

  @override
  String get customerProfileSalonNotFound => 'This salon is not available.';

  @override
  String get customerProfileWorkingHoursPlaceholder =>
      'Opening hours will appear here soon.';

  @override
  String get customerProfileMapPreviewPlaceholder => 'Map preview';

  @override
  String get customerProfileAboutArea => 'Area';

  @override
  String get customerProfileAboutPhone => 'Phone';

  @override
  String get customerProfileAboutGender => 'Gender';

  @override
  String customerProfileGenderValue(String gender) {
    return '$gender';
  }

  @override
  String customerProfileMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get customerServiceSelectionTitle => 'Choose your services';

  @override
  String get customerServiceSelectionSubtitle => 'Select one or more services';

  @override
  String get customerServiceSelectionStepLabel => 'Step 1 of 5';

  @override
  String get customerServiceSelectionProgressTitle => 'Services';

  @override
  String get customerServiceSelectionEmpty => 'No services available yet.';

  @override
  String customerServiceSelectionSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String customerServiceSelectionSummary(int minutes, String total) {
    return 'Duration: $minutes min · Total: $total';
  }

  @override
  String get customerServiceSelectionContinue => 'Continue';

  @override
  String get customerServiceSelectionClear => 'Clear';

  @override
  String get customerServiceSelectionRequiredSnack =>
      'Select at least one service to continue.';

  @override
  String customerServiceSelectionComingNext(String salonId) {
    return 'Service selection is coming next.\n\nSalon id:\n$salonId';
  }

  @override
  String customerTeamSelectionComingNext(String salonId) {
    return 'Team selection is coming next.\n\nSalon id:\n$salonId';
  }

  @override
  String get customerTeamSelectionTitle => 'Choose your specialist';

  @override
  String get customerTeamSelectionSubtitle =>
      'Select a team member or any available';

  @override
  String get customerTeamSelectionStepLabel => 'Step 2 of 5';

  @override
  String get customerTeamSelectionProgressTitle => 'Specialist';

  @override
  String get customerTeamSelectionAnyTitle => 'Any Available Specialist';

  @override
  String get customerTeamSelectionAnySubtitle =>
      'We will assign the best available specialist for your selected time.';

  @override
  String get customerTeamSelectionEmpty => 'No specialists available yet.';

  @override
  String get customerTeamSelectionRequiredSnack =>
      'Choose a specialist to continue.';

  @override
  String get customerTeamSelectionServicesRequiredSnack =>
      'Choose at least one service first.';

  @override
  String get customerTeamSelectionNoStaffHint =>
      'Add bookable team members to continue.';

  @override
  String customerTeamSelectionRating(String rating, int count) {
    return 'Rating $rating ($count)';
  }

  @override
  String customerDateTimeSelectionComingNext(String salonId) {
    return 'Date & time selection is coming next.\n\nSalon id:\n$salonId';
  }

  @override
  String get customerDateTimeTitle => 'Choose date & time';

  @override
  String get customerDateTimeSubtitle => 'Select an available appointment slot';

  @override
  String get customerDateTimeStepLabel => 'Step 3 of 5';

  @override
  String get customerDateTimeProgressTitle => 'Date & Time';

  @override
  String get customerDateTimeToday => 'Today';

  @override
  String get customerDateTimeTomorrow => 'Tomorrow';

  @override
  String get customerDateTimeMorning => 'Morning';

  @override
  String get customerDateTimeAfternoon => 'Afternoon';

  @override
  String get customerDateTimeEvening => 'Evening';

  @override
  String get customerDateTimeEmpty => 'No available slots';

  @override
  String get customerDateTimeChooseAnotherDate => 'Please choose another date';

  @override
  String get customerDateTimeRequiredSnack =>
      'Select an available time to continue.';

  @override
  String customerDateTimeSummaryTitle(int count, String specialist) {
    return '$count services · $specialist';
  }

  @override
  String customerDateTimeSummarySubtitle(int minutes, String total) {
    return 'Duration: $minutes min · Total: $total';
  }

  @override
  String customerDetailsComingNext(String salonId) {
    return 'Customer details coming next.\n\nSalon id:\n$salonId';
  }

  @override
  String get customerDetailsTitle => 'Customer details';

  @override
  String get customerDetailsSubtitle =>
      'Add contact details for your appointment';

  @override
  String get customerDetailsStepLabel => 'Step 4 of 5';

  @override
  String get customerDetailsProgressTitle => 'Details';

  @override
  String get customerDetailsFullName => 'Full name';

  @override
  String get customerDetailsPhoneNumber => 'Phone number';

  @override
  String get customerDetailsGender => 'Gender';

  @override
  String get customerDetailsGenderMale => 'Male';

  @override
  String get customerDetailsGenderFemale => 'Female';

  @override
  String get customerDetailsGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get customerDetailsNotes => 'Notes';

  @override
  String get customerDetailsNotesHint => 'Any notes for the salon?';

  @override
  String get customerDetailsPhoneInfo =>
      'We will use your phone number only to confirm and find your booking.';

  @override
  String get customerDetailsRequiredField => 'Required field';

  @override
  String get customerDetailsInvalidPhone => 'Enter a valid phone number';

  @override
  String get customerDetailsNameTooShort =>
      'Name must be at least 2 characters';

  @override
  String get customerDetailsNotesTooLong =>
      'Notes cannot exceed 300 characters';

  @override
  String customerDetailsSummaryTitle(int count, String specialist) {
    return '$count services · $specialist';
  }

  @override
  String customerDetailsSummarySubtitle(String dateTime, String total) {
    return '$dateTime · $total';
  }

  @override
  String customerBookingReviewComingNext(String salonId) {
    return 'Booking review coming next.\n\nSalon id:\n$salonId';
  }

  @override
  String get customerBookingReviewTitle => 'Review booking';

  @override
  String get customerBookingReviewSubtitle =>
      'Check your appointment details before confirming';

  @override
  String get customerBookingReviewStepLabel => 'Step 5 of 5';

  @override
  String get customerBookingReviewProgressTitle => 'Review';

  @override
  String get customerBookingReviewSalon => 'Salon';

  @override
  String get customerBookingReviewServices => 'Services';

  @override
  String get customerBookingReviewSpecialist => 'Specialist';

  @override
  String get customerBookingReviewDateTime => 'Date & Time';

  @override
  String get customerBookingReviewCustomer => 'Customer';

  @override
  String get customerBookingReviewPaymentSummary => 'Payment summary';

  @override
  String get customerBookingReviewSubtotal => 'Subtotal';

  @override
  String get customerBookingReviewDiscount => 'Discount';

  @override
  String get customerBookingReviewTotal => 'Total';

  @override
  String get customerBookingReviewConfirm => 'Confirm Booking';

  @override
  String get customerBookingReviewSlotUnavailable =>
      'This time slot is no longer available. Please choose another time.';

  @override
  String get customerBookingReviewChooseSpecialistAgain =>
      'Please choose a specialist again.';

  @override
  String get customerBookingReviewGenericError =>
      'Something went wrong. Please try again.';

  @override
  String customerBookingSuccessPlaceholder(String bookingCode) {
    return 'Booking confirmed\n\nBooking code:\n$bookingCode';
  }

  @override
  String get customerBookingSuccessTitle => 'Booking confirmed';

  @override
  String get customerBookingSuccessSubtitle =>
      'Your appointment has been saved successfully.';

  @override
  String get customerBookingSuccessCode => 'Booking code';

  @override
  String get customerBookingSuccessStatus => 'Status';

  @override
  String get customerBookingSuccessDate => 'Date';

  @override
  String get customerBookingSuccessTime => 'Time';

  @override
  String get customerBookingSuccessStatusFallback => 'Saved';

  @override
  String get customerBookingSuccessFallback => 'Available in booking details';

  @override
  String get customerBookingSuccessSaveCodeInfo =>
      'Save your booking code. You can use it later to find your appointment.';

  @override
  String get customerBookingSuccessViewBooking => 'View booking';

  @override
  String get customerBookingSuccessBookAnother => 'Book another appointment';

  @override
  String get customerBookingSuccessBackToSalon => 'Back to salon';

  @override
  String get customerBookingSuccessCodeCopied => 'Booking code copied.';

  @override
  String get customerBookingLookupTitle => 'Find your booking';

  @override
  String get customerBookingLookupSubtitle =>
      'Enter your phone number to view your appointment';

  @override
  String get customerBookingLookupPhoneNumber => 'Phone number';

  @override
  String get customerBookingLookupBookingCode => 'Booking code';

  @override
  String get customerBookingLookupBookingCodeOptional =>
      'Booking code optional';

  @override
  String get customerBookingLookupSearch => 'Search';

  @override
  String get customerBookingLookupPhoneHint =>
      'Use the same phone number you used when booking.';

  @override
  String get customerBookingLookupNoBookings => 'No bookings found';

  @override
  String get customerBookingLookupViewDetails => 'View details';

  @override
  String get customerBookingStatusPending => 'Pending';

  @override
  String get customerBookingStatusConfirmed => 'Confirmed';

  @override
  String get customerBookingStatusCheckedIn => 'Checked in';

  @override
  String get customerBookingStatusCompleted => 'Completed';

  @override
  String get customerBookingStatusCancelled => 'Cancelled';

  @override
  String get customerBookingStatusNoShow => 'No show';

  @override
  String get customerBookingLookupInvalidPhone => 'Enter a valid phone number';

  @override
  String get customerBookingLookupGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get customerBookingLookupAnySpecialist => 'Any available specialist';

  @override
  String get customerBookingDetailsTitle => 'Booking details';

  @override
  String get customerBookingDetailsSubtitle =>
      'View your appointment information';

  @override
  String get customerBookingDetailsCopied => 'Copied';

  @override
  String customerBookingDetailsDurationPrice(int minutes, String price) {
    return '$minutes min · $price';
  }

  @override
  String get customerBookingDetailsTimelineTitle => 'Timeline';

  @override
  String get customerBookingDetailsTimelineCreated => 'Created';

  @override
  String get customerBookingDetailsTimelineUpcoming => 'Upcoming';

  @override
  String get customerBookingDetailsTimelineConfirmed => 'Confirmed';

  @override
  String get customerBookingDetailsPendingConfirmation =>
      'Pending confirmation';

  @override
  String get customerBookingDetailsSpecialist => 'Specialist';

  @override
  String get customerBookingDetailsCall => 'Call';

  @override
  String get customerBookingDetailsWhatsApp => 'WhatsApp';

  @override
  String get customerBookingDetailsWhatsAppMessage =>
      'Hello — I have a question about my booking.';

  @override
  String get customerBookingDetailsPhoneUnavailable =>
      'Phone number is not available';

  @override
  String get customerBookingDetailsReschedule => 'Reschedule';

  @override
  String get customerBookingDetailsCancelBooking => 'Cancel booking';

  @override
  String get customerBookingDetailsLeaveFeedback => 'Leave feedback';

  @override
  String get customerBookingDetailsBookAgain => 'Book again';

  @override
  String get customerBookingDetailsComingSoon => 'Coming soon';

  @override
  String get customerBookingDetailsActionsTitle => 'What\'s next?';

  @override
  String get customerBookingDetailsArea => 'Area';

  @override
  String get customerCancelBookingTitle => 'Cancel booking';

  @override
  String get customerCancelBookingConfirmMessage =>
      'Are you sure you want to cancel this booking?';

  @override
  String get customerCancelBookingReasonLabel => 'Reason';

  @override
  String get customerCancelBookingReasonHint => 'Reason optional';

  @override
  String get customerCancelBookingKeep => 'Keep booking';

  @override
  String get customerCancelBookingConfirm => 'Confirm cancellation';

  @override
  String get customerCancelBookingSuccess => 'Booking cancelled successfully';

  @override
  String get customerCancelBookingCannotCancelOnline =>
      'This booking cannot be cancelled online.';

  @override
  String get customerCancelBookingTooCloseToStart =>
      'This booking is too close to the appointment time to cancel online. Please contact the salon.';

  @override
  String get customerCancelBookingReasonTooLong =>
      'Reason cannot exceed 200 characters';

  @override
  String get customerRescheduleSubtitle => 'Choose a new appointment time';

  @override
  String get customerRescheduleCurrentAppointment => 'Current appointment';

  @override
  String get customerRescheduleNewAppointment => 'New appointment';

  @override
  String get customerRescheduleConfirmTime => 'Confirm new time';

  @override
  String get customerRescheduleSuccess => 'Booking rescheduled successfully';

  @override
  String get customerRescheduleCannotOnline =>
      'This booking cannot be rescheduled online.';

  @override
  String get customerRescheduleTooCloseToStart =>
      'This booking is too close to the appointment time to reschedule online. Please contact the salon.';

  @override
  String get customerRescheduleNoSlots => 'No available slots';

  @override
  String get customerRescheduleChooseAnotherDate =>
      'Please choose another date';

  @override
  String get customerRescheduleStepLabel => 'Reschedule';

  @override
  String get customerRescheduleProgressTitle => 'New time';

  @override
  String get customerFeedbackTitle => 'Leave feedback';

  @override
  String get customerFeedbackSubtitle => 'Tell us about your appointment';

  @override
  String get customerFeedbackCommentHint => 'Share your experience';

  @override
  String get customerFeedbackCommentLabel => 'Comment';

  @override
  String get customerFeedbackRatingSection => 'Your rating';

  @override
  String get customerFeedbackWouldComeAgain => 'Would you come again?';

  @override
  String get customerFeedbackYes => 'Yes';

  @override
  String get customerFeedbackNo => 'No';

  @override
  String get customerFeedbackSubmit => 'Submit feedback';

  @override
  String get customerFeedbackThankYouTitle => 'Thank you for your feedback';

  @override
  String get customerFeedbackThankYouSubtitle =>
      'We appreciate you taking the time.';

  @override
  String get customerFeedbackAlreadySubmittedTitle =>
      'Feedback already submitted';

  @override
  String get customerFeedbackAlreadySubmittedSubtitle =>
      'You can view this booking anytime from booking lookup.';

  @override
  String get customerFeedbackSubmittedBadge => 'Feedback submitted';

  @override
  String get customerFeedbackBackToDetails => 'Back to booking details';

  @override
  String get customerFeedbackRatingPoor => 'Poor';

  @override
  String get customerFeedbackRatingFair => 'Fair';

  @override
  String get customerFeedbackRatingGood => 'Good';

  @override
  String get customerFeedbackRatingVeryGood => 'Very good';

  @override
  String get customerFeedbackRatingExcellent => 'Excellent';

  @override
  String get customerFeedbackRatingRequired => 'Rating is required';

  @override
  String get customerFeedbackCommentTooLong =>
      'Comment cannot exceed 500 characters';

  @override
  String get customerFeedbackOnlyCompleted =>
      'Feedback can only be submitted for completed bookings.';

  @override
  String get customerFeedbackGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get customerSalonBadgeOpen => 'Open';

  @override
  String get customerStatBookings => 'Bookings';

  @override
  String get customerStatSalonsVisited => 'Salons visited';

  @override
  String get customerStatUpcoming => 'Upcoming';

  @override
  String get customerProfileEdit => 'Edit';

  @override
  String get customerSettingsTileNotificationsSubtitle =>
      'Booking alerts & reminders';

  @override
  String get customerSettingsTileBookingsSubtitle => 'Upcoming and past visits';

  @override
  String customerAppFooterVersion(String appName, String version) {
    return '$appName v$version';
  }

  @override
  String get customerProfileTitle => 'Profile';

  @override
  String get ownerInsightsTitle => 'Smart insights';

  @override
  String get ownerInsightsSubtitle =>
      'Weekly highlights from sales and bookings (updates every Monday).';

  @override
  String get ownerInsightsEmpty =>
      'Insights will appear after the weekly summary runs.';

  @override
  String get ownerInsightsError => 'Could not load insights.';

  @override
  String get ownerRetentionTitle => 'Customer retention';

  @override
  String get ownerRetentionSubtitle =>
      'Based on completed visits and no-shows (salon timezone when set).';

  @override
  String get ownerRetentionEmpty =>
      'Retention metrics will appear after the weekly job runs.';

  @override
  String ownerRetentionMonthLabel(int year, String month) {
    return '$year-$month';
  }

  @override
  String ownerRetentionTimeZoneUsed(String tz) {
    return 'Timezone: $tz';
  }

  @override
  String get ownerRetentionRepeatCustomers => 'Repeat customers this month';

  @override
  String get ownerRetentionFirstTimeCustomers =>
      'First-time customers this month';

  @override
  String get ownerRetentionDistinctThisMonth =>
      'Customers with a completed visit (MTD)';

  @override
  String get ownerRetentionReturningThisMonth =>
      'Returning customers (had a prior visit)';

  @override
  String get ownerRetentionRate => 'Retention rate';

  @override
  String get ownerRetentionInactive30Days =>
      'Customers with no visit in 30 days';

  @override
  String get ownerRetentionNoShowTrend => 'No-show trend (local weeks)';

  @override
  String get ownerRetentionNoShowLastLocalWeek => 'Last completed local week';

  @override
  String get ownerRetentionNoShowPreviousLocalWeek => 'Previous local week';

  @override
  String get ownerRetentionNoShowDelta => 'Change vs previous week';

  @override
  String get ownerRetentionDeltaFlat => 'No change';

  @override
  String ownerRetentionDeltaUp(int n) {
    return '+$n';
  }

  @override
  String ownerRetentionDeltaDown(int n) {
    return '−$n';
  }

  @override
  String get onboardingLanguageTitle => 'Language';

  @override
  String get onboardingLanguageSubtitle =>
      'Choose your preferred language for the app.';

  @override
  String get onboardingLanguageEnglish => 'English';

  @override
  String get onboardingLanguageArabic => 'Arabic';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingCountryTitle => 'Country / region';

  @override
  String get onboardingCountrySubtitle =>
      'Used for formats and future regional options.';

  @override
  String get preAuthLanguageTitle => 'Choose your language';

  @override
  String get preAuthLanguageSubtitle =>
      'Select the language you want to use in the app';

  @override
  String get preAuthLanguageEnglish => 'English';

  @override
  String get preAuthLanguageArabic => 'Arabic';

  @override
  String get preAuthContinue => 'Continue';

  @override
  String get preAuthCountryTitle => 'Choose your country';

  @override
  String get preAuthCountrySubtitle =>
      'This helps us tailor the app experience';

  @override
  String get preAuthRoleTitle => 'How would you like to use the app?';

  @override
  String get preAuthRoleSubtitle => 'Choose the experience that fits you best';

  @override
  String get preAuthRoleCustomerTitle => 'User';

  @override
  String get preAuthRoleCustomerSubtitle =>
      'Customers sign in with email. Salon staff sign in with username.';

  @override
  String get preAuthRoleOwnerTitle => 'Salon Owner';

  @override
  String get preAuthRoleOwnerSubtitle =>
      'Manage your salon, team, bookings, and business';

  @override
  String get startupEntryTitle => 'Welcome';

  @override
  String get startupEntrySubtitle => 'Choose how you want to get started';

  @override
  String get startupBookOrAccessTitle => 'Book or Access Services';

  @override
  String get startupBookOrAccessSubtitle =>
      'Find salons, book visits, or continue with your team access';

  @override
  String get startupManageSalonTitle => 'Manage My Salon';

  @override
  String get startupManageSalonSubtitle =>
      'Owners sign in to run the business, team, and revenue';

  @override
  String get startupContinueAsUserTitle => 'Continue as User';

  @override
  String get startupContinueAsUserSubtitle =>
      'Book visits, explore salons, or sign in as staff';

  @override
  String get startupOwnSalonTitle => 'I Own a Salon';

  @override
  String get startupOwnSalonSubtitle =>
      'Manage your business, team, bookings, and revenue';

  @override
  String get userSelectionContinueTitle => 'Choose how you want to continue';

  @override
  String get userSelectionContinueSubtitle => 'Pick the path that matches you';

  @override
  String get userSelectionTitle => 'How will you use the app?';

  @override
  String get userSelectionSubtitle =>
      'Customers and salon staff use different sign-in methods';

  @override
  String get userSelectionCustomerTitle => 'Continue as Customer';

  @override
  String get userSelectionCustomerSubtitle =>
      'Browse salons and book appointments with email';

  @override
  String get userSelectionStaffTitle => 'Continue as Staff';

  @override
  String get userSelectionStaffSubtitle =>
      'Use the username your salon shared with you';

  @override
  String get customerProfileSetupTitle => 'Your profile';

  @override
  String get customerProfileSetupSubtitle =>
      'A quick step before you create your account';

  @override
  String get customerProfileSetupContinue => 'Continue';

  @override
  String get customerProfileSetupNameLabel => 'Full name';

  @override
  String get customerProfileSetupNameError => 'Enter your name';

  @override
  String get customerProfileSetupPhoneLabel => 'Phone (optional)';

  @override
  String get staffLoginHeadline => 'Staff sign in';

  @override
  String get staffLoginSubtitle =>
      'Sign in with the email and password your salon owner created for you, or your staff username.';

  @override
  String get staffLoginNoSignupHint =>
      'Team accounts are created by your salon. Contact the owner if you need access.';

  @override
  String get preAuthSlideSalonTitle => 'Discover Salons Near You';

  @override
  String get preAuthSlideSalonSubtitle =>
      'Find top-rated salons and beauty experts near you — anytime, anywhere.';

  @override
  String get preAuthSlideBarberTitle => 'Book in Seconds';

  @override
  String get preAuthSlideBarberSubtitle =>
      'Choose your barber, pick a time, and confirm instantly.';

  @override
  String get preAuthSlideBookingTitle => 'Stay in Control';

  @override
  String get preAuthSlideBookingSubtitle =>
      'Manage bookings, save favorites, and enjoy a seamless experience.';

  @override
  String get preAuthNext => 'Next';

  @override
  String get preAuthGetStarted => 'Get Started';

  @override
  String get preAuthSkip => 'Skip';

  @override
  String get authGateTitle => 'Welcome';

  @override
  String get authGateSubtitle =>
      'Sign in, create a customer account to book visits, or register a new salon.';

  @override
  String get authGateSignIn => 'Sign in';

  @override
  String get authGateCreateAccount => 'Create customer account';

  @override
  String get authGateCreateAccountSubtitle =>
      'For booking appointments only. Salon owners use “Create salon” below.';

  @override
  String get authGateRegionSettings => 'Language & region settings';

  @override
  String get appSettingsTitle => 'App settings';

  @override
  String get appSettingsIntroBody =>
      'Customize preferences and manage settings for your salon workflow.';

  @override
  String get appSettingsLanguageSubtitle => 'Choose your preferred language';

  @override
  String get appSettingsCountrySubtitle => 'Set your current operating region';

  @override
  String get appSettingsChangeAnytimeBanner => 'You can change these anytime.';

  @override
  String get appSettingsMoreActionSubtitle =>
      'App information, privacy and other options';

  @override
  String get signOutDialogTitle => 'Sign out?';

  @override
  String get hrViolationsSummaryAwaitingApproval => 'Awaiting approval';

  @override
  String get hrViolationsSummaryActiveRulesSubtitle => 'Penalty rules enabled';

  @override
  String get hrViolationsSummaryStaffFlaggedTitle => 'Staff flagged';

  @override
  String get hrViolationsEnabledChip => 'Enabled';

  @override
  String get hrViolationsDisabledChip => 'Disabled';

  @override
  String get hrViolationsLateRuleTitle => 'Late arrival rule';

  @override
  String get hrViolationsNoShowRuleTitle => 'No-show rule';

  @override
  String get hrViolationsGraceTimeLabel => 'Grace time';

  @override
  String get hrViolationsPendingEmptyTitle => 'No pending violation requests';

  @override
  String get hrViolationsPendingEmptyBody =>
      'You\'re all caught up. Any violation requests will appear here.';

  @override
  String get hrViolationsAddRule => 'Add rule';

  @override
  String get hrViolationsAddRuleComingSoon =>
      'More rule types are coming soon.';

  @override
  String get hrViolationsToggleConfirmTitle => 'Update penalty rule?';

  @override
  String get hrViolationsToggleConfirmBody =>
      'This affects payroll and deductions for your team.';

  @override
  String get hrViolationsToggleConfirmAction => 'Update';

  @override
  String get hrViolationsSummaryLoadError => 'Unable to load HR summary.';

  @override
  String get appSettingsLanguageSection => 'Language';

  @override
  String get appSettingsCountrySection => 'Country / region';

  @override
  String get appSettingsCountryLabel => 'Country';

  @override
  String get appSettingsCountryHint => 'You can change these anytime here.';

  @override
  String get appSettingsAppearanceSection => 'Appearance';

  @override
  String get appSettingsThemeLight => 'Light';

  @override
  String get appSettingsThemeDark => 'Dark';

  @override
  String get appSettingsThemeSystem => 'System default';

  @override
  String get appSettingsMoreSectionTitle => 'More';

  @override
  String get appSettingsMoreSectionBody =>
      'Notification preferences and other options will expand here over time.';

  @override
  String get validationEmailRequired =>
      'We need your email so we can sign you in securely.';

  @override
  String get validationEmailInvalid =>
      'Use a valid email format, like name@salon.com.';

  @override
  String get validationPasswordRequired =>
      'Choose a password to protect your account.';

  @override
  String get validationPasswordShort => 'Use at least 8 characters.';

  @override
  String get validationPasswordMinSixChars => 'Use at least 6 characters.';

  @override
  String get authSignupTitleCreateAccount => 'Create Account';

  @override
  String get authSignupSubtitleGetStarted => 'Sign up to get started';

  @override
  String get authSignupPrimaryCta => 'Sign Up';

  @override
  String get authSignupPasswordHintMinSix => 'At least 6 characters';

  @override
  String get registerHintPhone => 'Your mobile number';

  @override
  String get registerHintCity => 'Doha';

  @override
  String get validationPhoneRequired =>
      'Add a phone number your team and clients can reach.';

  @override
  String get validationPhoneShort =>
      'That number looks too short—include the full local or mobile number.';

  @override
  String get validationPhoneOptionalInvalid =>
      'Enter a valid phone number or leave this field empty.';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName is required.';
  }

  @override
  String get validationConfirmPasswordEmpty =>
      'Re-enter your password so we know it was typed correctly.';

  @override
  String get validationConfirmPasswordMismatch =>
      'Those passwords do not match. Try again.';

  @override
  String get validationUserLoginIdentifierRequired =>
      'Enter your email or username.';

  @override
  String get validationStaffUsernameRequired => 'Username is required.';

  @override
  String get validationStaffUsernameInvalid =>
      'Use 4–20 characters: lowercase letters, numbers, underscore, or dot only.';

  @override
  String get fieldLabelName => 'Name';

  @override
  String get fieldLabelFullName => 'Full name';

  @override
  String get fieldLabelEmail => 'Email';

  @override
  String get fieldLabelEmailOrUsername => 'Email or username';

  @override
  String get fieldLabelPassword => 'Password';

  @override
  String get fieldLabelConfirmPassword => 'Confirm password';

  @override
  String get fieldLabelSalonName => 'Salon name';

  @override
  String get fieldLabelPhone => 'Phone';

  @override
  String get fieldLabelAddress => 'Address';

  @override
  String get authCommonBack => 'Back';

  @override
  String get authCommonSettings => 'Settings';

  @override
  String get authGateCreateSalon => 'Create salon';

  @override
  String get authGateCreateSalonSubtitle =>
      'Register as a salon owner, then set up your workspace. If you already have an account, sign in.';

  @override
  String get loginEyebrow => 'Sign in';

  @override
  String get loginTitle => 'Welcome back.';

  @override
  String get loginDescription =>
      'Book appointments as a customer or run your business as a salon owner. Team accounts sign in here too.';

  @override
  String get loginSectionEmailPassword => 'Email & password';

  @override
  String get loginSectionSubtitle =>
      'Owners and customers use the same login. Your dashboard depends on your role.';

  @override
  String get loginHintIdentifier => 'you@example.com or salon.username';

  @override
  String get loginSignInButton => 'Sign in';

  @override
  String get loginFooterCreateAccount => 'New here? Create an account';

  @override
  String get loginTeamHint =>
      'Barber and admin accounts are created by your salon owner. Sign in with the username they gave you.';

  @override
  String get registerEyebrow => 'Create account';

  @override
  String get registerTitle => 'Join the platform.';

  @override
  String get registerDescription =>
      'After you register, you will choose customer or salon owner. Barber and admin accounts are created by the salon owner—use sign in instead.';

  @override
  String get registerCustomerTitle => 'Create your customer account.';

  @override
  String get registerCustomerDescription =>
      'Book visits, see your history, and manage your profile. Barber and admin accounts are created by the salon owner—use sign in instead.';

  @override
  String get registerSalonOwnerTitle => 'Register as a salon owner.';

  @override
  String get registerSalonOwnerDescription =>
      'Next, you will add your salon details. If you already have an account, go back and sign in.';

  @override
  String get registerSalonOwnerStepLabel => 'Account — step 1 of 2';

  @override
  String get registerStepLabel => 'Account — step 1 of 3';

  @override
  String get registerSectionYourDetails => 'Your details';

  @override
  String get registerSectionProfileHint =>
      'We store your profile in Firestore under your Firebase Auth account.';

  @override
  String get registerContinueButton => 'Continue';

  @override
  String get registerFooterSignIn => 'Already have an account? Sign in';

  @override
  String get registerOwnerIntentBanner =>
      'Next, choose “Salon owner” to create your salon.';

  @override
  String get registerHintFullName => 'Alex Rivera';

  @override
  String get registerHintEmail => 'you@example.com';

  @override
  String get registerHintPassword => 'Minimum 8 characters';

  @override
  String get registerHintConfirmPassword => 'Repeat your password';

  @override
  String get createSalonEyebrow => 'Salon setup';

  @override
  String get createSalonTitle => 'Create the salon your team will work inside.';

  @override
  String get createSalonDescription =>
      'Add the core business details now. This salon record becomes the foundation for staff, attendance, payroll, and bookings later.';

  @override
  String get createSalonStepLabel => 'Salon setup — step 2 of 2';

  @override
  String get createSalonFooterDifferentAccount => 'Use a different account';

  @override
  String get createSalonSectionTitle => 'Salon details';

  @override
  String get createSalonSectionSubtitle =>
      'Finish your salon profile to open the owner dashboard and invite your team.';

  @override
  String get createSalonOwnerFallback => 'Owner account';

  @override
  String get createSalonButton => 'Create salon';

  @override
  String get createSalonPhoneTip =>
      'Spaces, dashes, and parentheses are fine—we normalize the number when you save.';

  @override
  String get createSalonHintSalonName => 'Golden Chair Barber Studio';

  @override
  String get createSalonHintPhone => '+962 7X XXX XXXX';

  @override
  String get createSalonHintAddress => 'Amman, Abdoun, Main Street 12';

  @override
  String get roleEyebrow => 'Choose path';

  @override
  String get roleTitle => 'How will you use the app?';

  @override
  String get roleDescription =>
      'Customers book and manage visits. Owners set up their salon workspace. Barber and admin accounts are issued by the salon owner.';

  @override
  String get roleStepLabel => 'Role — step 2 of 2';

  @override
  String get roleSectionPrompt => 'I am…';

  @override
  String get roleCustomerTitle => 'A customer';

  @override
  String get roleCustomerSubtitle =>
      'Book services, see history, manage your profile.';

  @override
  String get roleOwnerTitle => 'A salon owner';

  @override
  String get roleOwnerSubtitle =>
      'Create your salon, invite staff, run operations.';

  @override
  String get roleSignOut => 'Sign out';

  @override
  String get socialAuthOr => 'OR';

  @override
  String get socialAuthContinueTitle => 'Continue with';

  @override
  String get socialAuthGoogle => 'Google';

  @override
  String get socialAuthApple => 'Apple';

  @override
  String get socialAuthFacebook => 'Facebook';

  @override
  String get passwordStrengthHintWeak =>
      'Add length and mix letters or numbers.';

  @override
  String get passwordStrengthHintOk => 'Good start—consider a longer phrase.';

  @override
  String get passwordStrengthHintStrong => 'Strong for this app’s minimum.';

  @override
  String get passwordStrengthHintExcellent => 'Excellent—hard to guess.';

  @override
  String passwordStrengthSemanticLabel(String level) {
    return 'Password strength: $level';
  }

  @override
  String get accessibilityShowPassword => 'Show password';

  @override
  String get accessibilityHidePassword => 'Hide password';

  @override
  String get loginHintEmail => 'you@example.com';

  @override
  String get loginHintPassword => 'Your password';

  @override
  String get validationCountryRequired =>
      'Choose your country so we can format your phone number correctly.';

  @override
  String get validationBusinessTypeRequired =>
      'Select what kind of salon you run.';

  @override
  String get fieldLabelCountry => 'Country';

  @override
  String get fieldLabelCity => 'City';

  @override
  String get fieldLabelStreet => 'Street';

  @override
  String get fieldLabelBuildingUnit => 'Building / unit number';

  @override
  String get fieldLabelPostalCode => 'Postal code (optional)';

  @override
  String get fieldLabelSalonPhoneOptional => 'Salon phone (optional)';

  @override
  String get fieldLabelBusinessType => 'Business type';

  @override
  String get businessTypeBarber => 'Barber shop';

  @override
  String get businessTypeWomenSalon => 'Women’s salon';

  @override
  String get businessTypeUnisex => 'Unisex';

  @override
  String get onboardingSearchCountryHint => 'Search country or code';

  @override
  String get onboardingCountryPopularSection => 'Popular countries';

  @override
  String get onboardingCountryAllSection => 'All countries';

  @override
  String get customerSignupEyebrow => 'Customer';

  @override
  String get customerSignupTitle => 'Create your customer account';

  @override
  String get customerSignupDescription =>
      'We’ll save your profile securely so you can book and manage visits.';

  @override
  String get customerSignupAddressHint =>
      'Helps salons recognize you and send booking updates.';

  @override
  String get customerSignupSubmit => 'Create account';

  @override
  String get salonOwnerSignupEyebrow => 'Salon owner';

  @override
  String get salonOwnerSignupTitle => 'Owner account — step 1 of 2';

  @override
  String get salonOwnerSignupDescription =>
      'Next you’ll add your salon’s location and business type.';

  @override
  String get salonOwnerSignupSubmit => 'Continue to salon details';

  @override
  String get onboardingMobileNationalHint =>
      'Local number without country code';

  @override
  String get createSalonBusinessTypeSection => 'Business type';

  @override
  String get createSalonLocationSection => 'Location';

  @override
  String get createSalonContactSection => 'Contact (optional)';

  @override
  String get createSalonProfileSyncTimeout =>
      'Your salon was saved but we could not confirm your profile yet. Check your connection, then pull to refresh or sign out and back in.';

  @override
  String get accountProfileBootstrapEyebrow => 'Account recovery';

  @override
  String get accountProfileBootstrapTitleMissing =>
      'Finish setting up your profile';

  @override
  String get accountProfileBootstrapDescriptionMissing =>
      'We could not load your saved profile. Choose how you use the app to create your user record, or sign in with a different account if this one is new.';

  @override
  String get accountProfileBootstrapTitleStaff => 'Team profile incomplete';

  @override
  String get accountProfileBootstrapDescriptionStaff =>
      'Your account is missing salon linkage (salon or staff ID). This usually means the profile was not finished or data was removed. Sign out and ask your salon owner to re-send your team invite, or use a different account.';

  @override
  String get accountProfileBootstrapContinueCustomer =>
      'I book appointments as a customer';

  @override
  String get accountProfileBootstrapContinueOwner => 'I run a salon (owner)';

  @override
  String get accountProfileBootstrapCreateProfile => 'Create my profile';

  @override
  String get accountProfileBootstrapChoosePath => 'Choose one to continue:';

  @override
  String get accountProfileBootstrapFooterDifferentAccount =>
      'Use a different account';

  @override
  String get accountProfileBootstrapErrorNoAuthUser =>
      'No signed-in user. Please sign in again.';

  @override
  String get accountProfileBootstrapErrorGeneric =>
      'Could not save your profile. Try again.';

  @override
  String get ownerStaffInviteSuccessTitle => 'Team member added';

  @override
  String ownerStaffInviteSuccessBody(
    String name,
    String email,
    String password,
  ) {
    return '$name can sign in with this email and a temporary password. Ask them to change their password after logging in.\n\nEmail:\n$email\n\nTemporary password:\n$password';
  }

  @override
  String get ownerStaffInviteOk => 'Done';

  @override
  String get staffInviteErrorEmailTaken =>
      'This username is already taken or the account already exists';

  @override
  String get staffInviteErrorPermission =>
      'Only owners and admins can create staff accounts';

  @override
  String get staffInviteErrorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get staffInviteErrorInvalidArgs =>
      'Some information looks invalid. Check the form and try again.';

  @override
  String get staffInviteErrorGeneric =>
      'Unable to create barber account. Please try again.';

  @override
  String ownerHeaderGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get ownerOverviewGreetingMorning => 'Good morning';

  @override
  String get ownerOverviewGreetingAfternoon => 'Good afternoon';

  @override
  String get ownerOverviewGreetingEvening => 'Good evening';

  @override
  String get ownerOverviewHeroSearchHint =>
      'Search team, revenue, and requests';

  @override
  String get ownerOverviewRevenueMonthLabel => 'Revenue this month';

  @override
  String get ownerOverviewRevenueMonthHintEmpty => 'No sales recorded yet.';

  @override
  String get ownerOverviewRevenueMonthSubtitle =>
      'Revenue trend for the current month';

  @override
  String get ownerOverviewRevenueMonthEmpty => 'No revenue yet this month';

  @override
  String ownerOverviewRevenueMonthTotal(String amount) {
    return 'Month total: $amount';
  }

  @override
  String get ownerOverviewRevenuePeriodDay => 'Day';

  @override
  String get ownerOverviewRevenuePeriodMonth => 'Month';

  @override
  String get ownerOverviewRevenuePeriodWeek => 'Week';

  @override
  String get ownerOverviewRevenueTodayByHourTitle => 'Revenue today';

  @override
  String get ownerOverviewRevenueTodayByHourSubtitle =>
      'By hour (your local time)';

  @override
  String get ownerOverviewRevenueTodayByHourEmpty => 'No revenue yet today';

  @override
  String ownerOverviewRevenueTodayByHourTotal(String amount) {
    return 'Today total: $amount';
  }

  @override
  String get ownerOverviewRevenueThisWeekTitle => 'Revenue this week';

  @override
  String get ownerOverviewRevenueThisWeekSubtitle =>
      'Revenue trend for the current week';

  @override
  String get ownerOverviewRevenueThisWeekEmpty => 'No revenue yet this week';

  @override
  String ownerOverviewRevenueThisWeekTotal(String amount) {
    return 'Week total: $amount';
  }

  @override
  String get ownerOverviewTeamPerformanceTitle => 'Team performance';

  @override
  String get ownerOverviewTeamPerformanceSubtitle =>
      'Top barbers by today’s revenue';

  @override
  String get ownerOverviewTeamPerformanceEmpty =>
      'No services recorded yet today';

  @override
  String get ownerOverviewTeamPerformanceError =>
      'Could not load team performance';

  @override
  String get ownerOverviewTeamPerformanceFallbackName => 'Team member';

  @override
  String ownerOverviewTeamPerformanceServicesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services today',
      one: '1 service today',
      zero: '0 services today',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewKpiPendingRequests => 'Pending requests';

  @override
  String get ownerOverviewKpiPendingApprovals => 'Pending approvals';

  @override
  String get ownerOverviewDashboardTagline =>
      'Track revenue, team, and bookings in one place.';

  @override
  String get ownerOverviewTodayInsightTitle => 'Today’s insight';

  @override
  String get ownerOverviewTodayInsightNoActivity =>
      'No activity yet today. Start by adding a sale or booking.';

  @override
  String ownerOverviewTodayInsightRevenue(String amount) {
    return 'You’re doing well today. Revenue is $amount.';
  }

  @override
  String ownerOverviewTodayInsightBookings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count bookings today. Keep the calendar moving.',
      one: 'You have 1 booking today. Turn it into a smooth visit.',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewTodayInsightPendingRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests need review.',
      one: '1 request needs review.',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewTodayInsightPendingApprovals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attendance requests need your review.',
      one: '1 attendance request needs your review.',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewRecentServicesTitle => 'Recent services';

  @override
  String get ownerOverviewRecentServicesEmpty => 'No active services yet.';

  @override
  String get ownerOverviewPerformanceNoData => 'No data yet';

  @override
  String ownerOverviewBestServiceSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Best service this week · $count sales',
      one: 'Best service this week · 1 sale',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewBestBarberSubtitle(String amount) {
    return 'Best team member today · $amount';
  }

  @override
  String get ownerOverviewRecentActivityTitle => 'Recent activity';

  @override
  String get ownerOverviewRecentActivityEmpty => 'No recent activity yet';

  @override
  String ownerOverviewLatestSaleSubtitle(String service, String amount) {
    return 'Last sale: $service · $amount';
  }

  @override
  String get ownerOverviewLatestSaleFallbackService => 'Sale';

  @override
  String get ownerOverviewViewTeam => 'View team';

  @override
  String get ownerOverviewSmartCardServiceTitle => 'Add your first service';

  @override
  String get ownerOverviewSmartCardServiceSubtitle =>
      'Customers need a menu to book.';

  @override
  String get ownerOverviewSmartCardBarberTitle => 'Add your first barber';

  @override
  String get ownerOverviewSmartCardBarberSubtitle =>
      'Staff appear on the floor and in payroll.';

  @override
  String get ownerOverviewSmartCardBookingTitle => 'Create your first booking';

  @override
  String get ownerOverviewSmartCardBookingSubtitle =>
      'Fill the calendar and track revenue.';

  @override
  String ownerOverviewRevenueTodayLine(String amount) {
    return 'Today: $amount';
  }

  @override
  String ownerOverviewRevenueDeltaUp(String percent) {
    return '$percent vs last month';
  }

  @override
  String ownerOverviewRevenueDeltaDown(String percent) {
    return '$percent vs last month';
  }

  @override
  String get ownerOverviewStatRevenueToday => 'Revenue today';

  @override
  String get ownerOverviewStatBookingsToday => 'Bookings today';

  @override
  String get ownerOverviewStatServicesToday => 'Services today';

  @override
  String get ownerOverviewStatCompletedToday => 'Completed today';

  @override
  String get ownerOverviewStatCheckedIn => 'Checked in';

  @override
  String get ownerOverviewStatWorkingNow => 'Working now';

  @override
  String get ownerOverviewQuickActionsTitle => 'Quick actions';

  @override
  String get ownerOverviewQuickAddSale => 'Add sale';

  @override
  String get ownerOverviewQuickAddExpense => 'Add expense';

  @override
  String get ownerOverviewNeedsAttentionTitle => 'Needs review';

  @override
  String get ownerOverviewNeedsAttentionNone =>
      'All clear. Nothing urgent right now.';

  @override
  String get ownerOverviewFabLabel => 'Quick add';

  @override
  String get ownerOverviewRunPayroll => 'Run payroll';

  @override
  String get ownerOverviewSmartSuggestionsTitle => 'Smart suggestions';

  @override
  String get ownerOverviewSmartSuggestionsSubtitle =>
      'Start with the essentials so bookings and payouts stay accurate.';

  @override
  String get ownerOverviewSmartAddBarber => 'Add Team Member';

  @override
  String get ownerOverviewSmartAddService => 'Add service';

  @override
  String get ownerOverviewSmartCreateBooking => 'Create booking';

  @override
  String get ownerOverviewStatDeltaSameAsYesterday => 'Same as yesterday';

  @override
  String ownerOverviewStatDeltaVsYesterday(String amount) {
    return '$amount vs yesterday';
  }

  @override
  String get ownerOverviewKpiBadgeLive => 'Live';

  @override
  String get ownerOverviewKpiBadgeQuiet => 'Quiet';

  @override
  String get ownerOverviewKpiBadgeBusy => 'Busy';

  @override
  String get ownerOverviewKpiBadgeDone => 'Done';

  @override
  String get ownerOverviewKpiBadgeNone => 'None';

  @override
  String get ownerOverviewKpiBadgeOnFloor => 'On floor';

  @override
  String ownerOverviewRevenueLastMonthTotal(String amount) {
    return 'Last month: $amount';
  }

  @override
  String get ownerOverviewRevenueNoPriorMonthCompare =>
      'No completed sales last month to compare';

  @override
  String get ownerOverviewRevenueDeltaFlatVsLastMonth => 'Flat vs last month';

  @override
  String ownerOverviewAttentionPendingBookings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookings awaiting confirmation',
      one: '1 booking awaiting confirmation',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewAttentionPendingApprovals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attendance requests to review',
      one: '1 attendance request to review',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewAttentionPayrollPending =>
      'Payroll hasn\'t been run for this month yet.';

  @override
  String get ownerOverviewAttentionNoServices =>
      'Add at least one service so customers can book.';

  @override
  String get ownerOverviewReview => 'Review';

  @override
  String get ownerOverviewSeeAll => 'See all';

  @override
  String get ownerOverviewTeamCardTitle => 'Team';

  @override
  String ownerOverviewTeamCardSubtitle(int active, int checkedIn) {
    return '$active active · $checkedIn checked in today';
  }

  @override
  String ownerOverviewTeamCardTopBarber(String name) {
    return 'Top team member today: $name';
  }

  @override
  String ownerOverviewTeamCardInactive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inactive members',
      one: '1 inactive member',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewServicesCardTitle => 'Services';

  @override
  String ownerOverviewServicesCardSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active services',
      one: '1 active service',
      zero: 'No active services yet',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewServicesAveragePrice(String amount) {
    return 'Average price: $amount';
  }

  @override
  String ownerOverviewServicesTopToday(String name) {
    return 'Top today: $name';
  }

  @override
  String ownerOverviewServicesTopMonth(String name) {
    return 'Most booked this month: $name';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String ownerOverviewAttentionInactiveEmployees(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inactive team members to review',
      one: '1 inactive team member to review',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewInsightsTitle => 'Insights';

  @override
  String ownerOverviewInsightRevenueUp(String percent) {
    return 'Revenue is up $percent vs last month.';
  }

  @override
  String ownerOverviewInsightRevenueDown(String percent) {
    return 'Revenue is down $percent vs last month.';
  }

  @override
  String get ownerOverviewInsightRevenueFlat =>
      'Revenue is flat vs last month.';

  @override
  String get ownerOverviewInsightRevenueFresh =>
      'New revenue this month — nothing to compare yet.';

  @override
  String ownerOverviewInsightTopBarberContribution(
    String name,
    String percent,
  ) {
    return '$name generated $percent of today\'s revenue.';
  }

  @override
  String get ownerOverviewInsightTopBarberEmpty =>
      'No team member activity yet today.';

  @override
  String ownerOverviewInsightPopularService(String name) {
    return '$name is the most popular service this month.';
  }

  @override
  String get ownerOverviewAddExpenseTitle => 'Add expense';

  @override
  String get ownerOverviewAddExpenseSubtitle =>
      'Record a salon expense in seconds.';

  @override
  String get ownerOverviewAddExpenseTitleField => 'Title';

  @override
  String get ownerOverviewAddExpenseCategoryField => 'Category';

  @override
  String get ownerOverviewAddExpenseAmountField => 'Amount';

  @override
  String get ownerOverviewAddExpenseVendorField => 'Vendor (optional)';

  @override
  String get ownerOverviewAddExpenseNotesField => 'Notes (optional)';

  @override
  String get ownerOverviewAddExpenseSubmit => 'Save expense';

  @override
  String get ownerOverviewAddExpenseDateField => 'Date';

  @override
  String get ownerOverviewAddExpenseSuggestedCategories =>
      'Suggested categories';

  @override
  String get ownerOverviewAddExpenseValidationError =>
      'Please fill title, category, and a positive amount.';

  @override
  String get ownerOverviewExpenseCreated => 'Expense recorded';

  @override
  String ownerOverviewSummaryEarnedFromSales(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed sales',
      one: '1 completed sale',
    );
    return 'Today you earned $amount from $_temp0.';
  }

  @override
  String ownerOverviewSummaryEarnedOnly(String amount) {
    return 'Today you earned $amount.';
  }

  @override
  String get ownerOverviewSummaryNoSalesToday =>
      'No completed sales yet today.';

  @override
  String ownerOverviewSummaryPendingSegment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookings pending',
      one: '1 booking pending',
      zero: 'No bookings pending',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewSummaryBarbersCheckedInSegment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count team members checked in',
      one: '1 team member checked in',
      zero: 'No team members checked in',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewSummaryPayrollPendingSegment => 'Payroll pending';

  @override
  String get ownerOverviewEmptyBookingsTodayTitle => 'No bookings today.';

  @override
  String get ownerOverviewEmptyCompletedTodayTitle =>
      'No services completed yet today.';

  @override
  String get ownerOverviewEmptyCheckedInTitle => 'No one has checked in yet.';

  @override
  String get ownerOverviewTeamMarkAttendance => 'Mark attendance';

  @override
  String ownerOverviewTeamActiveBarbersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active team members',
      one: '1 active team member',
      zero: 'No team members yet',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewTeamCheckedInShort(int count) {
    return '$count checked in';
  }

  @override
  String get ownerOverviewTeamEmptyTitle => 'No team members added yet.';

  @override
  String get ownerOverviewTeamEmptyBody =>
      'Add your first team member to start tracking attendance and sales.';

  @override
  String get ownerOverviewTeamStatusCheckedIn => 'Checked in';

  @override
  String get ownerOverviewTeamStatusNotCheckedIn => 'Not checked in';

  @override
  String get ownerOverviewTeamStatusOnService => 'On service';

  @override
  String get ownerOverviewTeamStatusLate => 'Late';

  @override
  String ownerOverviewInsightTopServiceWeek(String name) {
    return '$name is the top service this week.';
  }

  @override
  String ownerOverviewInsightBookingsUp(String percent) {
    return 'Bookings are up $percent compared with yesterday.';
  }

  @override
  String ownerOverviewInsightBookingsDown(String percent) {
    return 'Bookings are down $percent compared with yesterday.';
  }

  @override
  String get ownerOverviewInsightNoBookingsToday =>
      'No bookings today — quieter than yesterday.';

  @override
  String get ownerOverviewInsightsGrowing =>
      'Insights will appear as your salon activity grows.';

  @override
  String ownerOverviewAttentionBarbersNotCheckedIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count team members have not checked in',
      one: '1 team member has not checked in',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewFabSheetTitle => 'Quick actions';

  @override
  String get ownerOverviewFabBookAppointment => 'Book appointment';

  @override
  String get attendanceReviewTitle => 'Attendance requests';

  @override
  String get attendanceReviewEmptyTitle => 'No pending attendance requests';

  @override
  String get attendanceReviewEmptyMessage => 'Everything is up to date.';

  @override
  String get attendanceReviewErrorTitle => 'Could not load requests';

  @override
  String get attendanceReviewStatusPending => 'Pending';

  @override
  String get attendanceReviewApprove => 'Approve';

  @override
  String get attendanceReviewReject => 'Reject';

  @override
  String get attendanceReviewRejectDialogTitle => 'Add a rejection note';

  @override
  String get attendanceReviewRejectDialogHint =>
      'Optional — helps the employee understand.';

  @override
  String get attendanceReviewRejectConfirm => 'Reject';

  @override
  String attendanceReviewCheckInAt(String time) {
    return 'Checked in at $time';
  }

  @override
  String attendanceReviewCheckOutAt(String time) {
    return 'Checked out at $time';
  }

  @override
  String attendanceReviewSubmittedAt(String time) {
    return 'Submitted at $time';
  }

  @override
  String get attendanceReviewUnknownEmployee => 'Unknown team member';

  @override
  String get attendanceReviewTypePresent => 'Attendance correction';

  @override
  String get attendanceReviewTypeAbsent => 'Absence request';

  @override
  String get attendanceReviewTypeLeave => 'Leave request';

  @override
  String get attendanceReviewTypeGeneric => 'Attendance request';

  @override
  String get attendanceReviewApprovedSnackbar => 'Attendance approved';

  @override
  String get attendanceReviewRejectedSnackbar => 'Attendance rejected';

  @override
  String attendanceReviewErrorSnackbar(String message) {
    return 'Could not update: $message';
  }

  @override
  String get teamManagementTitle => 'Team';

  @override
  String get teamManagementSubtitle => 'Manage your team members and admins';

  @override
  String get teamSummaryTotalBarbers => 'Total team members';

  @override
  String get teamSummaryCheckedInToday => 'Checked in today';

  @override
  String get teamSummarySalesToday => 'Sales today';

  @override
  String get teamSummaryCommissionToday => 'Commission today';

  @override
  String get teamSummaryTotalMembers => 'Total Members';

  @override
  String get teamSummaryTotalMembersHelper => 'Team roster';

  @override
  String get teamSummaryWorkingNow => 'Working Now';

  @override
  String teamSummaryWorkingNowHelper(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'of $count members',
      one: 'of 1 member',
      zero: 'No members yet',
    );
    return '$_temp0';
  }

  @override
  String get teamSummaryAbsentToday => 'Absent Today';

  @override
  String get teamSummaryAbsentTodayHelper => 'Needs follow-up';

  @override
  String get teamSummaryRevenueToday => 'Revenue Today';

  @override
  String get teamSummaryRevenueTodayHelper => 'Live sales';

  @override
  String get teamAnalyticsAction => 'Team analytics';

  @override
  String get teamAnalyticsComingSoon =>
      'Team analytics will be available soon.';

  @override
  String get teamAnalyticsActiveInactiveLabel => 'Active / Inactive';

  @override
  String get teamAnalyticsTopPerformerLabel => 'Top performer';

  @override
  String get teamGuideDescription =>
      'Team members help you run attendance, services, sales, commissions, and payroll in one place.';

  @override
  String get teamFilterAll => 'All';

  @override
  String get teamFilterActive => 'Active';

  @override
  String get teamFilterCheckedIn => 'Checked in';

  @override
  String get teamFilterWorking => 'Working';

  @override
  String get teamFilterInactive => 'Inactive';

  @override
  String get teamFilterTopSellers => 'Top sellers';

  @override
  String get teamFilterTopPerformers => 'Top Performers';

  @override
  String get teamFilterTopServices => 'Top Services';

  @override
  String get teamFilterTopPerformance => 'Top Performance';

  @override
  String get teamFilterOldest => 'Old';

  @override
  String get teamFilterNewest => 'New';

  @override
  String get teamFilterNeedsAttention => 'Needs attention';

  @override
  String get teamAddBarberAction => 'Add Team Member';

  @override
  String get teamHeroSearchHint => 'Search members by name or phone';

  @override
  String get teamSearchHint => 'Search by name or phone';

  @override
  String get teamMemberWhatsAppNoPhone =>
      'No phone number on file for this team member';

  @override
  String get teamFilterAction => 'Filter team';

  @override
  String get teamSortAction => 'Sort team';

  @override
  String get teamSortSheetTitle => 'Sort by';

  @override
  String get teamSortNameAsc => 'Name A–Z';

  @override
  String get teamSortNameDesc => 'Name Z–A';

  @override
  String get teamSortRole => 'Role';

  @override
  String get teamSortJoinedNewest => 'Newest hire first';

  @override
  String get teamSortJoinedOldest => 'Oldest hire first';

  @override
  String get teamSortSalesToday => 'Today\'s sales';

  @override
  String get teamSortSalesMonth => 'This month\'s sales';

  @override
  String get teamEmptyTitle => 'No team members yet';

  @override
  String get teamEmptySubtitle =>
      'Add your first team member to start tracking attendance, sales, and payroll.';

  @override
  String get teamEmptyBuildTitle => 'Build your team';

  @override
  String get teamEmptyBuildSubtitle =>
      'Add your first team member or admin to start tracking attendance, sales, commissions, and payroll.';

  @override
  String get teamEmptyNoMatchTitle => 'No matching team member';

  @override
  String teamEmptyNoMatchSubtitle(String query) {
    return 'We couldn\'t find anyone matching \"$query\". Try another name, phone, employee number, or role.';
  }

  @override
  String teamEmptyNoFilterResultTitle(String filter) {
    return 'No $filter team members found';
  }

  @override
  String teamEmptyNoFilterResultSubtitle(String filter) {
    return 'No team members are currently in $filter. Clear filters or choose a different status.';
  }

  @override
  String get teamEmptyPrimaryClearSearch => 'Clear Search';

  @override
  String get teamEmptyPrimaryAddMember => 'Add Team Member';

  @override
  String get teamEmptySecondaryAddMember => 'Add Team Member';

  @override
  String get teamEmptySecondaryLearnHow => 'Learn how team works';

  @override
  String get teamLoadErrorTitle => 'Could not load team';

  @override
  String get teamStatusActive => 'Active';

  @override
  String get teamStatusCheckedIn => 'Checked in';

  @override
  String get teamStatusLate => 'Late';

  @override
  String get teamStatusInactive => 'Inactive';

  @override
  String get teamMemberMoreActions => 'More actions';

  @override
  String get teamMemberViewProfileAction => 'View profile';

  @override
  String get teamMemberEditAction => 'Edit member';

  @override
  String get teamMemberAttendanceAction => 'Attendance';

  @override
  String get teamMemberPayrollAction => 'Payroll';

  @override
  String get teamMemberDeactivateAction => 'Deactivate';

  @override
  String get teamMemberActivateAction => 'Activate';

  @override
  String get teamMemberResetPasswordPlaceholder => 'Reset password later';

  @override
  String get teamMemberSalesToday => 'Sales today';

  @override
  String get teamMemberServicesToday => 'Services today';

  @override
  String get teamMemberServicesShort => 'Services';

  @override
  String get teamMemberRevenueToday => 'Revenue';

  @override
  String get teamMemberPerformance => 'Performance';

  @override
  String teamMemberPerformancePercent(int percent) {
    return '$percent%';
  }

  @override
  String get teamMemberCommissionToday => 'Commission today';

  @override
  String get employeeDashboardFirestorePermissionBanner =>
      'Unable to load your attendance. Please ask your admin to deploy the latest permissions.';

  @override
  String get employeeDashboardAttendanceNotStartedYet => 'Not started yet';

  @override
  String get teamMemberNoAttendanceToday => 'No attendance yet today';

  @override
  String get teamMemberNotCheckedIn => 'Not checked in';

  @override
  String get teamMemberInactiveStatus => 'Inactive';

  @override
  String get teamCardAttendanceNotRequired => 'Attendance not required';

  @override
  String get teamCardAttendanceOnBreak => 'On break';

  @override
  String get teamCardAccountFrozen => 'Frozen';

  @override
  String teamMemberLateAt(String time) {
    return 'Late · $time';
  }

  @override
  String teamMemberCheckedOutAt(String time) {
    return 'Checked out at $time';
  }

  @override
  String teamMemberCheckedInAt(String time) {
    return 'Checked in at $time';
  }

  @override
  String get teamMemberAddSaleAction => 'Add sale';

  @override
  String get teamMemberMarkAttendanceAction => 'Mark attendance';

  @override
  String get teamMemberViewDetailsAction => 'View details';

  @override
  String get teamFieldFullName => 'Full name';

  @override
  String get teamFieldEmail => 'Email';

  @override
  String get teamFieldUsername => 'Username';

  @override
  String get teamFieldPhone => 'Phone';

  @override
  String get teamFieldHiringDate => 'Hiring date';

  @override
  String get teamFieldHiringDateHint =>
      'Monthly base salary in payroll is prorated by calendar days from this date.';

  @override
  String get teamFieldRole => 'Role';

  @override
  String get teamRoleRequired => 'Choose a role.';

  @override
  String get teamCommissionValueRequired => 'Enter a commission value.';

  @override
  String get teamCommissionValueInvalid => 'Enter a valid commission value.';

  @override
  String get teamCommissionValueNegative => 'Commission cannot be negative.';

  @override
  String get teamSaveErrorGeneric => 'Could not save team member details.';

  @override
  String teamAddBarberSuccess(String name) {
    return '$name was added to the team.';
  }

  @override
  String teamEditBarberSuccess(String name) {
    return '$name was updated.';
  }

  @override
  String get teamAddBarberSheetTitle => 'Add Team Member';

  @override
  String get teamEditBarberSheetTitle => 'Edit team member';

  @override
  String get teamAddBarberSheetSubtitle =>
      'Set the basics now and keep the profile ready for attendance, sales, payroll, and future booking.';

  @override
  String get teamPhotoPickerTitle => 'Profile Photo';

  @override
  String get teamPhotoActionTake => 'Take photo';

  @override
  String get teamPhotoActionGallery => 'Choose from gallery';

  @override
  String get teamPhotoActionRemove => 'Remove photo';

  @override
  String get teamPhotoActionCancel => 'Cancel';

  @override
  String get teamRolePickerTitle => 'Choose role';

  @override
  String get teamRolePickerSubtitle =>
      'Select what this team member can access in the salon.';

  @override
  String get teamRolePickerBarberTitle => 'Team member';

  @override
  String get teamRolePickerBarberSubtitle =>
      'Can record services, view own attendance, sales, and payslips.';

  @override
  String get teamRolePickerBarberBadge => 'Service staff';

  @override
  String get teamRolePickerAdminTitle => 'Admin';

  @override
  String get teamRolePickerAdminSubtitle =>
      'Can manage daily operations based on permissions set by the owner.';

  @override
  String get teamRolePickerAdminBadge => 'Management';

  @override
  String get teamCommissionPickerTitle => 'Commission type';

  @override
  String get teamCommissionPickerSubtitle =>
      'Choose how this team member earns commission.';

  @override
  String get teamCommissionPickerPercentageTitle => 'Percentage only';

  @override
  String get teamCommissionPickerPercentageSubtitle =>
      'Commission is calculated as a percentage of sales.';

  @override
  String get teamCommissionPickerFixedTitle => 'Fixed amount only';

  @override
  String get teamCommissionPickerFixedSubtitle =>
      'Team member earns a fixed amount per service or period.';

  @override
  String get teamCommissionPickerMixedTitle => 'Percentage + fixed amount';

  @override
  String get teamCommissionPickerMixedSubtitle =>
      'Combine percentage commission with a fixed amount.';

  @override
  String get addBarberSheetHeroSubtitle =>
      'Create a new team member account and set up their basic details.';

  @override
  String get addBarberSectionLoginPassword => 'Login & password';

  @override
  String get addBarberSectionCommissionWork => 'Commission & work settings';

  @override
  String get addBarberProfilePhotoTitle => 'Profile photo';

  @override
  String get addBarberProfilePhotoCaption => 'Add a clear team member photo';

  @override
  String get addBarberProfilePhotoButton => 'Add photo';

  @override
  String get addBarberProfilePhotoAfterCreateSnack =>
      'You can add a profile photo after the account is created from the team member profile.';

  @override
  String get addBarberMainTitle => 'Team member account details';

  @override
  String get addBarberMainSubtitle =>
      'Create a login for the team member and set a temporary starting password';

  @override
  String get addBarberSectionPersonalDetails => 'Personal details';

  @override
  String get addBarberSectionAccountAccess => 'Account access';

  @override
  String get addBarberFieldFullName => 'Full name';

  @override
  String get addBarberFieldEmailAddress => 'Email address';

  @override
  String get addBarberFieldUsername => 'Username';

  @override
  String get addBarberFieldPhoneNumber => 'Phone number';

  @override
  String get addBarberFieldRole => 'Role';

  @override
  String get addBarberFieldPassword => 'Password';

  @override
  String get addBarberFieldConfirmPassword => 'Confirm password';

  @override
  String get addBarberPlaceholderFullName => 'Enter full name';

  @override
  String get addBarberPlaceholderEmail => 'Enter email address';

  @override
  String get addBarberHelperEmailLogin =>
      'This email is used to sign in with their password. They can also use their username on the User login screen.';

  @override
  String get addBarberPlaceholderUsername => 'e.g. jane.doe';

  @override
  String get addBarberPlaceholderPhone => 'Enter phone number';

  @override
  String get addBarberPlaceholderPassword => 'Enter password';

  @override
  String get addBarberPlaceholderConfirmPassword => 'Re-enter password';

  @override
  String get addBarberHelperPasswordShared =>
      'Password will be shared with the team member by the salon owner';

  @override
  String get addBarberHelperMustChangePassword =>
      'Team member will be asked to change the password on first login';

  @override
  String get addBarberPasswordRulesHint =>
      'Use at least 8 characters, including upper and lower case letters and a number';

  @override
  String get addBarberValidationFullNameRequired => 'Full name is required';

  @override
  String get addBarberValidationEmailRequired => 'Email address is required';

  @override
  String get addBarberValidationEmailInvalid => 'Enter a valid email address';

  @override
  String get addBarberValidationEmailInternalNotAllowed =>
      'Use the team member\'s own email address, not an internal staff address.';

  @override
  String get addBarberValidationPasswordRequired => 'Password is required';

  @override
  String get addBarberValidationConfirmPasswordRequired =>
      'Confirm password is required';

  @override
  String get addBarberValidationPasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get addBarberValidationPasswordComplexity =>
      'Password must include uppercase, lowercase, and a number';

  @override
  String get addBarberValidationPasswordsMismatch => 'Passwords do not match';

  @override
  String get addBarberButtonCreate => 'Create Team Member';

  @override
  String get addBarberButtonCreating => 'Creating team member...';

  @override
  String get addBarberSuccessMessage =>
      'Team member has been created successfully';

  @override
  String get addBarberSuccessSubtext =>
      'Ask them to sign in on the User screen with this email or their username and the password you set, then change it on first login if required';

  @override
  String get addBarberRequirePasswordChangeOnFirstLogin =>
      'Require password change on first login';

  @override
  String get addBarberChecklistMinLength => 'At least 8 characters';

  @override
  String get addBarberChecklistUppercase => 'Contains uppercase letter';

  @override
  String get addBarberChecklistLowercase => 'Contains lowercase letter';

  @override
  String get addBarberChecklistDigit => 'Contains a number';

  @override
  String get addBarberChecklistPasswordsMatch => 'Passwords match';

  @override
  String get teamFieldCommissionType => 'Commission type';

  @override
  String get teamCommissionTypePercentage => 'Percentage only';

  @override
  String get teamCommissionTypeFixed => 'Fixed amount only';

  @override
  String get teamCommissionTypePercentagePlusFixed =>
      'Percentage + fixed amount';

  @override
  String get teamFieldCommissionPercentagePercent => 'Commission rate (%)';

  @override
  String teamFieldCommissionFixedAmount(String currencyCode) {
    return 'Fixed amount ($currencyCode)';
  }

  @override
  String get teamCommissionPercentInputHint => 'Enter a rate like 2, 10, or 25';

  @override
  String get teamCommissionHelperPercentage =>
      'The rate applies to total sales and services.';

  @override
  String get teamCommissionHelperFixed =>
      'A fixed amount is added to the team member\'s commission.';

  @override
  String get teamCommissionHelperPercentagePlusFixed =>
      'Combines a sales-based rate with a fixed amount.';

  @override
  String get teamCommissionPreviewLabel => 'Estimated commission';

  @override
  String get teamCommissionPreviewDisclaimer =>
      'This value is for preview only';

  @override
  String get teamCommissionPreviewSampleNote =>
      'Illustrative example only — not saved payroll';

  @override
  String teamCommissionPreviewEquationPercent(
    String sales,
    String percent,
    String result,
  ) {
    return '$sales × $percent = $result';
  }

  @override
  String teamCommissionPreviewEquationFixed(String result) {
    return '$result';
  }

  @override
  String teamCommissionPreviewEquationMixed(
    String fixed,
    String sales,
    String percent,
    String result,
  ) {
    return '$fixed + ($sales × $percent) = $result';
  }

  @override
  String get teamCommissionPercentRequired =>
      'Enter a commission rate greater than 0.';

  @override
  String get teamCommissionPercentInvalidRange =>
      'Rate must be between 0 and 100.';

  @override
  String get teamCommissionFixedInvalid =>
      'Enter a valid fixed amount (0 or more).';

  @override
  String get teamCommissionCombinedInvalid =>
      'Enter a valid rate and/or fixed amount.';

  @override
  String teamCommissionSummaryFixed(String amount, String currencyCode) {
    return '$amount $currencyCode';
  }

  @override
  String teamCommissionSummaryMixed(
    String percent,
    String amount,
    String currencyCode,
  ) {
    return '$percent% + $amount $currencyCode';
  }

  @override
  String get teamFieldCommissionValue => 'Commission value';

  @override
  String get teamCommissionValueHelper =>
      'Percentage value used for sales and payroll calculations.';

  @override
  String get teamFieldAttendanceRequired => 'Attendance required';

  @override
  String get teamFieldAttendanceRequiredHint =>
      'Attendance tracking can be adjusted manually when needed.';

  @override
  String get teamFieldBookable => 'Bookable later';

  @override
  String get teamFieldBookableHint =>
      'Prepare this profile for a future customer booking flow.';

  @override
  String get teamFieldActiveStatus => 'Active status';

  @override
  String get teamFieldActiveStatusHint =>
      'Inactive team members stay hidden from operational actions.';

  @override
  String get teamSaveBarberAction => 'Save team member';

  @override
  String get teamSaveChangesAction => 'Save changes';

  @override
  String get teamResetPasswordPlaceholderNotice =>
      'Password reset will be added in a later update.';

  @override
  String teamMemberDeactivated(String name) {
    return '$name was deactivated.';
  }

  @override
  String teamMemberActivated(String name) {
    return '$name was activated.';
  }

  @override
  String get teamAttendanceMarkedSuccess => 'Attendance marked.';

  @override
  String get teamAttendanceCheckoutSuccess => 'Check-out recorded.';

  @override
  String get teamAttendanceAlreadyCompleted =>
      'Today\'s attendance is already complete.';

  @override
  String get teamAttendanceMarkError => 'Could not update attendance.';

  @override
  String get teamMemberAttendanceAdminNoRecordTitle => 'No attendance today';

  @override
  String teamMemberAttendanceAdminNoRecordSubtitle(String name) {
    return '$name has not checked in yet.';
  }

  @override
  String get teamMemberAttendanceAdminCheckedInTitle => 'Currently checked in';

  @override
  String get teamMemberAttendanceAdminCheckedInSubtitle =>
      'Check-in recorded; check-out is still pending.';

  @override
  String get teamMemberAttendanceAdminCompletedTitle => 'Attendance completed';

  @override
  String get teamMemberAttendanceAdminCompletedSubtitle =>
      'Check-in and check-out are recorded for today.';

  @override
  String get teamMemberAttendanceStatusNone => 'No record';

  @override
  String get teamMemberAttendanceCheckInLabel => 'Punch in';

  @override
  String get teamMemberAttendanceCheckOutLabel => 'Punch out';

  @override
  String get teamMemberAttendanceAddManual => 'Add attendance manually';

  @override
  String get teamMemberAttendanceEditManual => 'Edit attendance record';

  @override
  String get teamMemberAttendanceSummaryWeek => 'Attendance this week';

  @override
  String get teamMemberAttendanceSummaryLateMonth => 'Late count';

  @override
  String get teamMemberAttendanceSummaryLateMonthHint => 'This month';

  @override
  String get teamMemberAttendanceSummaryMissingCheckout => 'Missing punch-outs';

  @override
  String get teamMemberAttendanceSummaryMissingCheckoutHint => 'times';

  @override
  String get teamMemberAttendanceSummaryPendingRequests => 'Pending requests';

  @override
  String get teamMemberAttendanceSummaryPendingRequestsHint => 'corrections';

  @override
  String get teamMemberAttendanceNoShiftAssigned =>
      'No shift assigned. Open Weekly Shifts to set one.';

  @override
  String get teamMemberAttendanceSummaryDaysUnit => 'days';

  @override
  String get teamMemberAttendanceCorrectionsTitle =>
      'Attendance correction requests';

  @override
  String get teamMemberAttendanceCorrectionEmptyTitle =>
      'No correction requests';

  @override
  String get teamMemberAttendanceCorrectionEmptySubtitle =>
      'This team member’s requests will appear here.';

  @override
  String get teamMemberAttendanceApprove => 'Approve';

  @override
  String get teamMemberAttendanceReject => 'Reject';

  @override
  String get teamMemberAttendanceRequestTypeMissingCheckIn =>
      'Missing check-in';

  @override
  String get teamMemberAttendanceRequestTypeMissingCheckout =>
      'Missing check-out';

  @override
  String get teamMemberAttendanceRequestTypeWrongCheckIn =>
      'Wrong check-in time';

  @override
  String get teamMemberAttendanceRequestTypeWrongCheckOut =>
      'Wrong check-out time';

  @override
  String get teamMemberAttendanceRequestTypeAbsence => 'Absence correction';

  @override
  String get teamMemberAttendanceRequestTypeGeneric => 'Attendance correction';

  @override
  String get teamMemberAttendanceStatusPending => 'Pending';

  @override
  String get teamMemberAttendanceStatusApproved => 'Approved';

  @override
  String get teamMemberAttendanceStatusRejected => 'Rejected';

  @override
  String get teamMemberAttendanceNoReason => 'No reason provided';

  @override
  String get teamMemberAttendanceHistoryTitle => 'Recent attendance';

  @override
  String get teamMemberAttendanceFullHistoryTitle => 'All attendance';

  @override
  String get teamMemberAttendanceHistoryFilterTitle => 'Date range';

  @override
  String get teamMemberAttendanceHistoryFilterFrom => 'From';

  @override
  String get teamMemberAttendanceHistoryFilterTo => 'To';

  @override
  String get teamMemberAttendanceHistoryFilterApply => 'Apply';

  @override
  String get teamMemberAttendanceHistoryFilterClear => 'Clear';

  @override
  String get teamMemberAttendanceHistoryFilterSelectDate => 'Select date';

  @override
  String get teamMemberAttendanceHistoryFilterNeedBothDates =>
      'Select both start and end dates.';

  @override
  String get teamMemberAttendanceHistoryFilterEmptyRange =>
      'No attendance in this range.';

  @override
  String get teamMemberAttendanceViewAll => 'View all';

  @override
  String get teamMemberAttendanceHistoryEmpty => 'No attendance records yet';

  @override
  String get teamMemberAttendanceRecordStatusCheckedIn => 'Checked in';

  @override
  String get teamMemberAttendanceRecordStatusPresent => 'Completed';

  @override
  String get teamMemberAttendanceRecordStatusLate => 'Late';

  @override
  String get teamMemberAttendanceRecordStatusIncomplete => 'Incomplete';

  @override
  String get teamMemberAttendanceRecordStatusManual => 'Manual';

  @override
  String get teamMemberAttendanceRecordStatusAbsent => 'Absent';

  @override
  String get teamMemberAttendanceRecordStatusOnBreak => 'On break';

  @override
  String get teamMemberAttendanceManualSaved => 'Attendance record saved.';

  @override
  String get teamMemberAttendanceCorrectionApproved =>
      'Correction request approved.';

  @override
  String get teamMemberAttendanceCorrectionRejected =>
      'Correction request rejected.';

  @override
  String get teamMemberAttendanceManualSheetTitle => 'Manual attendance';

  @override
  String get teamMemberAttendanceSave => 'Save';

  @override
  String get teamMemberAttendanceDateLabel => 'Date';

  @override
  String get teamMemberAttendanceStatusFieldLabel => 'Status';

  @override
  String get teamMemberAttendanceLateMinutes => 'Late minutes';

  @override
  String get teamMemberAttendanceEarlyExitMinutes => 'Early exit minutes';

  @override
  String get teamMemberAttendanceMissingCheckoutSwitch => 'Missing check-out';

  @override
  String get teamMemberAttendanceNotes => 'Notes';

  @override
  String get teamMemberAttendanceReviewApproveTitle => 'Approve correction';

  @override
  String get teamMemberAttendanceReviewRejectTitle => 'Reject correction';

  @override
  String get teamMemberAttendanceReviewNoteLabel => 'Review note';

  @override
  String get teamMemberAttendanceReviewConfirmApprove => 'Approve';

  @override
  String get teamMemberAttendanceReviewConfirmReject => 'Reject';

  @override
  String get attendanceAdjustmentSheetTitle => 'Adjust attendance';

  @override
  String get attendanceAdjustmentSheetSubtitle =>
      'Changes are saved on the server and recorded in the audit log. Payroll summaries may update for this month.';

  @override
  String get attendanceAdjustmentShiftOffDay => 'Off day';

  @override
  String get attendanceAdjustmentDateLabel => 'Date';

  @override
  String get attendanceAdjustmentShiftLabel => 'Shift';

  @override
  String get attendanceAdjustmentStatusLabel => 'Status';

  @override
  String get attendanceAdjustmentStatusPresent => 'Present';

  @override
  String get attendanceAdjustmentStatusLateChips => 'Late';

  @override
  String get attendanceAdjustmentStatusAbsentChip => 'Absent';

  @override
  String get attendanceAdjustmentStatusDayOff => 'Day off';

  @override
  String get attendanceAdjustmentNotSet => 'Not set';

  @override
  String get attendanceAdjustmentLateMinLabel => 'Late (min)';

  @override
  String get attendanceAdjustmentEarlyExitLabel => 'Early exit (min)';

  @override
  String get attendanceAdjustmentMissingCheckoutLabelShort => 'Missing out';

  @override
  String attendanceAdjustmentMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String attendanceAdjustmentYesWithMinutes(int minutes) {
    return 'Yes (+$minutes pen.)';
  }

  @override
  String get attendanceAdjustmentNoAbbr => 'No';

  @override
  String get attendanceAdjustmentErrorReasonRequired =>
      'Please select a reason for this adjustment.';

  @override
  String get attendanceAdjustmentSaveSuccess => 'Correction saved.';

  @override
  String attendanceAdjustmentCloudError(String code) {
    return 'Could not save: $code';
  }

  @override
  String get attendanceAdjustmentSaveFailed =>
      'Could not save attendance. Try again.';

  @override
  String get attendanceAdjustmentTimesLabel => 'Punch times';

  @override
  String get attendanceAdjustmentBreakOutLabel => 'Break start';

  @override
  String get attendanceAdjustmentBreakInLabel => 'Break end';

  @override
  String get attendanceAdjustmentMissingCheckoutWarning =>
      'Punch-out is missing. Minutes may include the missing check-out penalty from salon settings.';

  @override
  String get attendanceAdjustmentReasonLabel => 'Reason';

  @override
  String get attendanceAdjustmentReasonPlaceholder => 'Select a reason';

  @override
  String get attendanceAdjustmentReasonForgot => 'Forgot punch';

  @override
  String get attendanceAdjustmentReasonGps => 'GPS / device issue';

  @override
  String get attendanceAdjustmentReasonSchedule => 'Schedule correction';

  @override
  String get attendanceAdjustmentReasonPayroll => 'Payroll sync';

  @override
  String get attendanceAdjustmentReasonOther => 'Other';

  @override
  String get attendanceAdjustmentManagerNoteLabel => 'Internal note (optional)';

  @override
  String get attendanceAdjustmentAuditFootnote =>
      'This action creates an adjustment record and updates monthly payroll summaries when applicable.';

  @override
  String get attendanceAdjustmentSaveCta => 'Save correction';

  @override
  String get attendanceAdjustmentFirestoreDocLabel => 'Firestore path · ';

  @override
  String get attendanceAdjustmentSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get attendanceAdjustmentPermissionDeniedSave =>
      'You don\'t have permission to save this correction.';

  @override
  String get attendanceAdjustmentServerUnavailableSave =>
      'Could not reach the server. Please try again.';

  @override
  String get attendanceAdjustmentSaveFailedMapped =>
      'Could not save the correction. Please try again.';

  @override
  String get attendanceAdjustmentLoadContextFailed =>
      'Could not load this screen. Please try again.';

  @override
  String get teamDetailsLoadErrorTitle => 'Could not load team member details';

  @override
  String get teamDetailsTabOverview => 'Overview';

  @override
  String get teamDetailsTabSales => 'Sales';

  @override
  String get teamDetailsTabAttendance => 'Attendance';

  @override
  String get teamDetailsTabPayroll => 'Payroll';

  @override
  String get teamDetailsTabServices => 'Services';

  @override
  String get teamDetailsTabBookingPrep => 'Booking Prep';

  @override
  String get teamDetailsStatusLabel => 'Status';

  @override
  String get teamDetailsJoinDate => 'Hiring date';

  @override
  String get teamDetailsCommissionRate => 'Commission %';

  @override
  String get teamDetailsBookableLater => 'Bookable later';

  @override
  String get teamProfileStatusFrozen => 'Frozen';

  @override
  String get teamProfileJoinDateMissing => 'Hiring date not available';

  @override
  String get teamProfileSectionContact => 'Contact';

  @override
  String get teamProfileSectionWorkSettings => 'Work settings';

  @override
  String get teamProfileTodaySalesLabel => 'Today sales';

  @override
  String get teamProfileServicesLabel => 'Services';

  @override
  String get teamProfileAttendanceLabel => 'Attendance';

  @override
  String get teamProfileActionCall => 'Call';

  @override
  String get teamProfileActionAddBooking => 'Add booking';

  @override
  String get teamProfilePhoneMissingSnack => 'Phone number is not available';

  @override
  String get teamProfileDialerErrorSnack => 'Could not open phone dialer';

  @override
  String get teamProfileWhatsAppUnavailableSnack =>
      'WhatsApp is not available on this device';

  @override
  String get teamProfileBookingUnavailableSnack =>
      'This team member is not available for booking';

  @override
  String get teamProfileAttendanceNotRequiredSummary => 'Not required';

  @override
  String get teamProfilePermissionDenied =>
      'You do not have permission to view this team member.';

  @override
  String get teamProfileLoadGenericError =>
      'Something went wrong while loading this team member.';

  @override
  String get teamProfileNotFound => 'Team member was not found.';

  @override
  String get teamValueNotAvailable => 'Not available';

  @override
  String get teamValueYes => 'Yes';

  @override
  String get teamValueNo => 'No';

  @override
  String get teamValueEnabled => 'Enabled';

  @override
  String get teamValueDisabled => 'Disabled';

  @override
  String get teamCardTeamMemberSubtitle => 'Team member';

  @override
  String get teamCardNameMissing => 'Unnamed';

  @override
  String get teamMemberPerformanceUnrated => 'Unrated';

  @override
  String teamCardEmployeeId(String id) {
    return 'ID · $id';
  }

  @override
  String get teamCardChipLabelStatus => 'Status';

  @override
  String get teamCardChipLabelAttendToday => 'Attend today';

  @override
  String get teamCardAttendWorking => 'Working';

  @override
  String get teamCardAttendCompleted => 'Completed';

  @override
  String get teamCardAttendAbsent => 'Absent';

  @override
  String get teamCardAttendTodayOff => 'Today off';

  @override
  String get teamCardAttendNoCheckIn => 'No check-in';

  @override
  String get teamCardSwipeBrowseHint => 'Swipe to browse team';

  @override
  String teamDeckFooterMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count team members',
      one: '1 team member',
    );
    return '$_temp0';
  }

  @override
  String teamCommissionPercentValue(String value) {
    return '$value%';
  }

  @override
  String get teamNoSalesTodayTitle => 'No sales recorded today';

  @override
  String get teamNoSalesTodaySubtitle =>
      'Record the first sale for this team member.';

  @override
  String get teamSalesRecentSalesTitle => 'Recent sales';

  @override
  String get teamSalesTopServicesTitle => 'Top sold services';

  @override
  String get teamTopServicesEmpty => 'No service performance yet.';

  @override
  String teamSalesTopServiceCount(int count) {
    return '$count sold';
  }

  @override
  String get teamSalesAverageTicketTitle => 'Average ticket value';

  @override
  String get teamPlaceholderLaterReady => 'Later-ready placeholder';

  @override
  String get teamSalesRevenueToday => 'Revenue today';

  @override
  String get teamSalesRevenueWeek => 'Revenue this week';

  @override
  String get teamSalesRevenueMonth => 'Revenue this month';

  @override
  String get teamSalesServicesToday => 'Services today';

  @override
  String get teamSalesServicesMonth => 'Services this month';

  @override
  String teamSalesCommissionLabel(String value) {
    return 'Commission $value';
  }

  @override
  String get teamMemberSalesHistoryTitle => 'Sales history';

  @override
  String get teamMemberSalesFilterThisMonth => 'This month';

  @override
  String get teamMemberSalesFilterToday => 'Today';

  @override
  String get teamMemberSalesFilterThisWeek => 'This week';

  @override
  String get teamMemberSalesFilterCustom => 'Custom';

  @override
  String teamMemberSalesShowing(String filter) {
    return 'Showing: $filter';
  }

  @override
  String teamMemberSalesHistoryTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get teamMemberSalesLoadError =>
      'Unable to load sales. Please try again.';

  @override
  String get teamMemberSalesPermissionDenied =>
      'You do not have permission to view these sales.';

  @override
  String get teamMemberSalesEmptyHistoryTitle => 'No sales in this period';

  @override
  String get teamMemberSalesEmptyHistorySubtitle =>
      'Try another date range or record a new sale.';

  @override
  String get teamMemberSalesWalkInCustomer => 'Walk-in customer';

  @override
  String get teamMemberSalesServiceSummaryFallback => 'Services';

  @override
  String get teamMemberSalesSmartSummaryTitle => 'Smart summary';

  @override
  String get teamMemberSalesNotAvailableShort => '—';

  @override
  String get teamMemberSalesReceiptTapToEnlarge =>
      'Receipt photo, tap to enlarge';

  @override
  String get teamMemberSalesReceiptViewerTitle => 'Receipt';

  @override
  String get teamNoAttendanceTodayTitle => 'No attendance yet today';

  @override
  String get teamNoAttendanceTodaySubtitle =>
      'Mark attendance to start the day.';

  @override
  String get teamAttendanceTodayStatusTitle => 'Today\'s attendance';

  @override
  String get teamAttendanceCheckedInLabel => 'Check-in time';

  @override
  String get teamAttendanceCheckedOutLabel => 'Check-out time';

  @override
  String get teamAttendanceStatusLabel => 'Attendance status';

  @override
  String get teamAttendanceWeeklySummary => 'Weekly attendance';

  @override
  String get teamAttendanceLateCount => 'Late count';

  @override
  String get teamAttendanceMissingCheckoutCount => 'Missing checkout';

  @override
  String get teamAttendanceCorrectionRequestsTitle =>
      'Attendance correction requests';

  @override
  String get teamPayrollCommissionPercentage => 'Commission percentage';

  @override
  String get teamPayrollCommissionToday => 'Commission today';

  @override
  String get teamPayrollCommissionMonth => 'Commission this month';

  @override
  String get teamPayrollBonusesTotal => 'Bonuses total';

  @override
  String get teamPayrollDeductionsTotal => 'Deductions total';

  @override
  String get teamPayrollEstimatedPayout => 'Estimated payout';

  @override
  String get teamPayrollHistoryEmptyTitle => 'No payroll history yet';

  @override
  String get teamPayrollHistoryEmptySubtitle =>
      'Monthly payroll history will appear here as records are generated.';

  @override
  String get teamPayrollHistoryTitle => 'Payroll history';

  @override
  String get teamServicesEditAssignmentsAction => 'Edit service assignment';

  @override
  String get teamServicesEmptyTitle => 'No services assigned yet';

  @override
  String get teamServicesEmptySubtitle =>
      'Assign services to prepare this team member for operations and future booking.';

  @override
  String get teamServicesAssignedTitle => 'Assigned services';

  @override
  String get teamServicesServiceActive => 'Active';

  @override
  String get teamServicesServiceInactive => 'Inactive';

  @override
  String get teamServicesEditAssignmentCardSubtitle =>
      'Manage the services this barber can perform.';

  @override
  String get teamServicesAssignedSectionSubtitle =>
      'Services this barber is currently offering.';

  @override
  String get teamServicesAssignServicesAction => 'Assign services';

  @override
  String get teamServicesAssignmentSelectAll => 'Select all';

  @override
  String get teamServicesAssignmentClearSelection => 'Clear selection';

  @override
  String get teamServicesRetryAction => 'Try again';

  @override
  String get teamServicesLoadErrorTitle => 'Could not load assignments';

  @override
  String get teamServicesUnnamedService => 'Unnamed service';

  @override
  String get teamBookingPrepPublicDisplayName => 'Public display name';

  @override
  String get teamBookingPrepPublicBio => 'Public bio';

  @override
  String get teamBookingPrepWorkingHoursProfile => 'Working hours profile';

  @override
  String get teamBookingPrepSlotDuration => 'Booking slot duration';

  @override
  String get teamBookingPrepDisplayOrder => 'Display order';

  @override
  String get teamBookingPrepProfileImage => 'Profile image';

  @override
  String get teamBookingPrepVisibleServicesTitle =>
      'Visible services for customers';

  @override
  String get teamBookingPrepVisibleServicesEmpty =>
      'No customer-visible services yet.';

  @override
  String get moneyDashboardTitle => 'Money';

  @override
  String get moneyDashboardSubtitle =>
      'Monthly finance signals, trends, and operational insights.';

  @override
  String get moneyDashboardErrorTitle => 'Could not load money dashboard';

  @override
  String get moneyDashboardErrorMessage => 'Try again in a moment.';

  @override
  String get moneyDashboardRetry => 'Retry';

  @override
  String get moneyDashboardTrendTitle => 'Sales vs expenses';

  @override
  String get moneyDashboardTrendSubtitleDaily =>
      'Track how revenue and costs moved day by day in the selected month.';

  @override
  String get moneyDashboardTrendSubtitleWeekly =>
      'Track how revenue and costs moved by week in the selected month.';

  @override
  String get moneyDashboardTrendSubtitleMonthly =>
      'Track how revenue and costs moved across recent months.';

  @override
  String get moneyDashboardTrendSubtitleYearly =>
      'Track how revenue and costs moved across recent calendar years.';

  @override
  String get moneyDashboardSalesLegend => 'Sales';

  @override
  String get moneyDashboardExpensesLegend => 'Expenses';

  @override
  String get moneyDashboardInsightsTitle => 'Insights';

  @override
  String get moneyDashboardInsightsEmpty =>
      'More insights will appear as sales, payroll, and expenses build up.';

  @override
  String get moneyDashboardSalesNavSubtitle =>
      'Open the transaction engine and record sales.';

  @override
  String get moneyDashboardExpensesNavSubtitle =>
      'Review costs, categories, and recent expenses.';

  @override
  String get moneyDashboardSummaryHeadline => 'Financial snapshot';

  @override
  String get moneyDashboardSalesTotal => 'Sales total';

  @override
  String get moneyDashboardExpensesTotal => 'Expenses total';

  @override
  String get moneyDashboardPayrollTotal => 'Payroll total';

  @override
  String get moneyDashboardNetProfit => 'Net profit';

  @override
  String moneyDashboardInsightTopBarber(Object name, Object amount) {
    return '$name leads this month with $amount in sales.';
  }

  @override
  String moneyDashboardInsightTopService(Object service, Object amount) {
    return '$service is the top earning service at $amount.';
  }

  @override
  String moneyDashboardInsightExpenseCategory(Object category, Object share) {
    return '$category accounts for the largest expense share at $share.';
  }

  @override
  String get moneyDashboardUncategorized => 'Uncategorized';

  @override
  String get moneyDashboardNetLossWarning =>
      'Net profit is negative for this month (completed sales minus expenses and payroll in this period). Trim discretionary spending, revisit pricing, and check payroll runs when they apply.';

  @override
  String moneyDashboardTrendPeakSalesSummary(Object day, Object amount) {
    return 'Peak sales day $day · $amount';
  }

  @override
  String moneyDashboardInsightActionTopBarber(Object name, Object amount) {
    return 'Double down on $name ($amount sales) — protect their chair time, clone what works in consultations, and rebalance quieter books.';
  }

  @override
  String moneyDashboardInsightActionTopService(Object service, Object amount) {
    return 'Feature $service in bundles and upsells — it earned $amount this month.';
  }

  @override
  String moneyDashboardInsightActionExpenseCategory(
    Object category,
    Object share,
  ) {
    return 'Spend clusters in $category ($share) — audit vendors, subscriptions, and category rules before they compound.';
  }

  @override
  String get moneyDashboardSearchHint => 'Search team, revenue, and requests';

  @override
  String get moneyDashboardChartGranularityDaily => 'Daily';

  @override
  String get moneyDashboardChartGranularityWeekly => 'Weekly';

  @override
  String get moneyDashboardChartGranularityMonthly => 'Monthly';

  @override
  String get moneyDashboardChartGranularityYearly => 'Yearly';

  @override
  String get moneyDashboardChartGranularityPickerTitle => 'Chart period';

  @override
  String get moneyDashboardKpiTrendNoData => '—';

  @override
  String get moneyDashboardKpiTrendNew => 'New';

  @override
  String moneyDashboardKpiTrendUpVsMonth(Object percent, Object month) {
    return '↗ $percent% vs $month';
  }

  @override
  String moneyDashboardKpiTrendDownVsMonth(Object percent, Object month) {
    return '↘ $percent% vs $month';
  }

  @override
  String moneyDashboardKpiTrendFlatVsMonth(Object percent, Object month) {
    return '→ $percent% vs $month';
  }

  @override
  String get moneyDashboardQuickPayrollSubtitle =>
      'Review monthly payroll runs and payslips.';

  @override
  String get moneyDashboardQuickSalesBody =>
      'Record transactions and monitor service revenue.';

  @override
  String get moneyDashboardQuickExpensesBody =>
      'Track costs, categories, and recent spending.';

  @override
  String get salesScreenTitle => 'Sales';

  @override
  String get salesScreenSubtitle => 'Track revenue, services and performance.';

  @override
  String get salesScreenAddSale => 'Add sale';

  @override
  String get salesScreenErrorTitle => 'Could not load sales';

  @override
  String get salesScreenErrorMessage =>
      'The transaction feed is unavailable right now.';

  @override
  String get salesScreenSummaryTitle => 'Smart summary';

  @override
  String get salesScreenTransactionCount => 'Transactions';

  @override
  String get salesScreenAverageTicket => 'Average ticket';

  @override
  String get salesScreenTopBarber => 'Top team member';

  @override
  String get salesScreenTopService => 'Top service';

  @override
  String get salesScreenValuePending => '—';

  @override
  String salesScreenCustomRange(Object start, Object end) {
    return 'Custom range: $start - $end';
  }

  @override
  String get salesScreenBarberFilter => 'Team member';

  @override
  String get salesScreenAllBarbers => 'All team members';

  @override
  String get salesScreenEmptyTitle => 'No sales yet';

  @override
  String get salesScreenEmptyMessage =>
      'Record the first sale to start tracking revenue here.';

  @override
  String salesScreenDayTotal(Object amount) {
    return 'Day total $amount';
  }

  @override
  String get salesScreenUnknownService => 'Service';

  @override
  String get salesScreenAllPayments => 'All payments';

  @override
  String get salesScreenFiltersButton => 'Filters';

  @override
  String get salesScreenFiltersSheetTitle => 'Refine sales';

  @override
  String get salesScreenTopServicesTitle => 'Top services by revenue';

  @override
  String get salesScreenBarberRankingTitle => 'Team performance';

  @override
  String get salesScreenTopServicesEmpty =>
      'Service mix will show once sales include line items.';

  @override
  String salesScreenPaymentSingleMethod(Object method) {
    return 'All sales used $method. Consider promoting card or wallet to reduce cash handling.';
  }

  @override
  String get salesDetailsTitle => 'Sale details';

  @override
  String get salesDetailsNotFoundTitle => 'Sale not found';

  @override
  String get salesDetailsNotFoundMessage =>
      'This sale is no longer available for your salon.';

  @override
  String get salesDetailsOverviewTitle => 'Overview';

  @override
  String get salesDetailsLineItemsTitle => 'Line items';

  @override
  String get salesDetailsCustomerLabel => 'Customer';

  @override
  String get salesDetailsRecordedByLabel => 'Recorded by';

  @override
  String get salesDetailsStatusLabel => 'Status';

  @override
  String get salesDetailsPaymentLabel => 'Payment';

  @override
  String get salesDetailsSoldAtLabel => 'Sold at';

  @override
  String get salesDetailsSubtotalLabel => 'Subtotal';

  @override
  String get salesDetailsTaxLabel => 'Tax';

  @override
  String get salesDetailsDiscountLabel => 'Discount';

  @override
  String get salesDetailsCommissionLabel => 'Commission';

  @override
  String get salesStatusCompleted => 'Completed';

  @override
  String get salesStatusPending => 'Pending';

  @override
  String get salesStatusRefunded => 'Refunded';

  @override
  String get salesStatusVoided => 'Voided';

  @override
  String get salesDateToday => 'Today';

  @override
  String get salesDateThisWeek => 'This week';

  @override
  String get salesDateThisMonth => 'This month';

  @override
  String get salesDateCustom => 'Custom';

  @override
  String get salesHeroTotalSalesLabel => 'Total sales';

  @override
  String get salesChartSalesVsExpenses => 'Sales vs Expenses';

  @override
  String get salesChartLegendSales => 'Sales';

  @override
  String get salesChartLegendExpenses => 'Expenses';

  @override
  String get salesInsightTopServicesSubtitle => 'By revenue';

  @override
  String get salesInsightBarberSubtitle => 'By revenue';

  @override
  String get salesInsightPaymentMixTitle => 'Payment method mix';

  @override
  String get salesInsightPaymentSubtitle => 'By method';

  @override
  String get salesInsightHelperTopServices =>
      'Record sales to see your top performing services.';

  @override
  String get salesInsightHelperBarber =>
      'Record sales to see your team members\' performance.';

  @override
  String get salesInsightHelperPayment =>
      'Record sales to see your payment mix.';

  @override
  String get salesInsightActionAddServices => 'Add services';

  @override
  String get salesInsightActionAddSales => 'Add sales';

  @override
  String get salesRecentCardTitle => 'Recent sales';

  @override
  String get salesRecentEmptyTitle => 'No sales yet';

  @override
  String get salesRecentEmptyBody =>
      'Start adding sales to see your recent transactions here.';

  @override
  String get paymentMethodMixed => 'Mixed';

  @override
  String get addSaleSelectServicesTitle => 'Select services';

  @override
  String get addSaleManageServices => 'Manage services';

  @override
  String get addSaleSearchServicesHint => 'Search services';

  @override
  String addSaleSelectedServicesTitle(int count) {
    return 'Selected services ($count)';
  }

  @override
  String get addSaleAddAnotherService => 'Add another service';

  @override
  String get addSaleAllServicesSectionTitle => 'All services';

  @override
  String get addSaleSelectedServiceLineSubtitle => 'In this sale';

  @override
  String get addSaleClearSearchTooltip => 'Clear search';

  @override
  String get addSaleBarberLabel => 'Service provider';

  @override
  String get addSaleWalkInCustomer => 'Walk-in customer';

  @override
  String get addSaleAddNameLink => 'Add name';

  @override
  String get addSaleOrderSummaryTitle => 'Order summary';

  @override
  String get addSaleSubtotal => 'Subtotal';

  @override
  String get addSaleDiscountLink => 'Add discount';

  @override
  String get addSaleDiscountTitle => 'Discount';

  @override
  String get addSaleDiscountHint => 'Amount to subtract from subtotal';

  @override
  String get addSaleTotal => 'Total';

  @override
  String get addSaleRecordSale => 'Record sale';

  @override
  String get addSaleDiscountInvalid => 'Discount cannot exceed the subtotal.';

  @override
  String get expensesScreenTitle => 'Expenses';

  @override
  String get expensesScreenSubtitle =>
      'Track and manage your salon\'s spending in one place.';

  @override
  String get expensesScreenSalonMissing => 'Salon profile not found.';

  @override
  String get expensesScreenRetry => 'Retry';

  @override
  String get expensesScreenTotalExpensesLabel => 'Total expenses';

  @override
  String get expensesScreenTransactionsLabel => 'Transactions';

  @override
  String expensesScreenTransactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get expensesScreenViewAll => 'View all';

  @override
  String get expensesScreenNoCategoriesTitle => 'No categories yet';

  @override
  String get expensesScreenNoCategoriesMessage =>
      'Add your first expense to see category insights.';

  @override
  String get expensesScreenRecentTitle => 'Recent expenses';

  @override
  String get expensesScreenReportComingSoon => 'Reports are coming soon.';

  @override
  String get expensesScreenRecordedByLabel => 'Recorded by';

  @override
  String get expensesScreenAllCreators => 'Everyone';

  @override
  String get expensesScreenClearFilters => 'Clear filters';

  @override
  String get expensesScreenApplyFilters => 'Apply';

  @override
  String get expensesScreenAddExpense => 'Add expense';

  @override
  String get expensesScreenErrorTitle => 'Could not load expenses';

  @override
  String get expensesScreenErrorMessage =>
      'The expense feed is unavailable right now.';

  @override
  String get expensesScreenSummaryTitle => 'Smart summary';

  @override
  String get expensesScreenCount => 'Expenses';

  @override
  String get expensesScreenTopCategory => 'Top category';

  @override
  String get expensesScreenValuePending => 'Not enough data';

  @override
  String get expensesScreenAllCategories => 'All categories';

  @override
  String get expensesScreenBreakdownTitle => 'Category breakdown';

  @override
  String get expensesScreenBreakdownEmpty =>
      'Breakdown will appear after you log expenses.';

  @override
  String get expensesScreenEmptyTitle => 'No expenses yet';

  @override
  String get expensesScreenEmptyMessage =>
      'Add the first expense to start tracking costs here.';

  @override
  String expensesScreenDayTotal(Object amount) {
    return 'Day total $amount';
  }

  @override
  String get expensesScreenUnknownExpense => 'Expense';

  @override
  String get expensesScreenFiltersButton => 'Filters';

  @override
  String get expensesScreenFiltersSheetTitle => 'Refine expenses';

  @override
  String get expensesScreenAverageExpense => 'Avg / expense';

  @override
  String get expensesScreenHighestExpense => 'Largest';

  @override
  String get expensesScreenTrend => 'Trend';

  @override
  String expensesScreenTrendVsPrior(Object percent) {
    return '$percent vs prior window';
  }

  @override
  String get expenseScreenLinkedBarber => 'Related team member';

  @override
  String get addSalePaymentMethodField => 'Payment method';

  @override
  String get employeeAddSaleFab => 'Add Sale';

  @override
  String get employeeSectionPermissionDenied =>
      'You do not have permission to view this section.';

  @override
  String get employeeTodayWorkspaceSubtitle => 'Your workspace today';

  @override
  String get employeeTodayAttendanceTitle => 'Today attendance';

  @override
  String get employeeTodayAttendanceTagline => 'Stay on time, stay awesome.';

  @override
  String get employeeTodayStatusNotCheckedIn => 'Not checked in';

  @override
  String get employeeTodayStatusCheckedIn => 'Checked in';

  @override
  String get employeeTodayStatusOnBreak => 'On break';

  @override
  String get employeeTodayStatusBackFromBreak => 'Back from break';

  @override
  String get employeeTodayStatusCheckedOut => 'Checked out';

  @override
  String get employeeTodayStatusInvalidSequence => 'Invalid punch sequence';

  @override
  String get employeeTodayZoneInside => 'Inside salon zone';

  @override
  String get employeeTodayZoneOutside => 'Outside salon zone';

  @override
  String get employeeTodaySalonLabel => 'Salon';

  @override
  String get employeeTodayAddressOnFile => 'Address on file';

  @override
  String employeeTodayDistanceMeters(int meters) {
    return 'About $meters m from center';
  }

  @override
  String get employeeTodayAttendanceRequestTitle => 'Attendance request';

  @override
  String get employeeTodayAttendanceRequestSubtitle =>
      'Forgot a punch? Submit a request for admin approval.';

  @override
  String get employeeTodayRequestCorrection => 'Request correction';

  @override
  String employeeTodayPendingCount(int count) {
    return 'Pending: $count';
  }

  @override
  String get employeeTodayNoActivity => 'No activity yet today.';

  @override
  String get employeeTodayPrivacyNote =>
      'You can only view your own attendance, sales, and requests.';

  @override
  String get employeeTodayViewPolicy => 'View policy';

  @override
  String get employeeTodaySalonLocationMissing =>
      'Salon attendance location is not configured. Please contact the owner.';

  @override
  String get employeeTodayPunchIn => 'Punch in';

  @override
  String get employeeTodayPunchOut => 'Punch out';

  @override
  String get employeeTodayBreakOut => 'Leave for break';

  @override
  String get employeeTodayBreakIn => 'Return from break';

  @override
  String employeeTodayBreakCountdownRemaining(String time) {
    return 'Remaining break time: $time';
  }

  @override
  String employeeTodayBreakCountdownExceeded(String time) {
    return 'Break exceeded by $time';
  }

  @override
  String get employeeTodayBreakOutsideShift =>
      'You can only start a break during your scheduled shift hours.';

  @override
  String get employeeTodayCompletedForToday => 'Completed for today';

  @override
  String employeeTodayHoursLabel(Object hours) {
    return '$hours h';
  }

  @override
  String employeeTodaySalesAmount(Object amount) {
    return '$amount sales';
  }

  @override
  String employeeTodayServicesCount(int count) {
    return '$count services';
  }

  @override
  String get employeeTodayTeamMemberFallback => 'Team member';

  @override
  String employeeTodayPunchRecorded(Object action) {
    return '$action recorded';
  }

  @override
  String get employeeTodayOfflinePunch =>
      'You need an internet connection to punch.';

  @override
  String get employeeTodayPunchUnavailableAttendanceDisabled =>
      'Attendance is turned off for this salon.';

  @override
  String get employeeTodayPunchUnavailableMoveToZone =>
      'Move inside the salon zone to punch in or out.';

  @override
  String get employeeTodayPunchUnavailableShiftComplete =>
      'You have reached today\'s punch limit. If something looks wrong, submit a correction request.';

  @override
  String get employeeTodayPunchUnavailableGeneric =>
      'No punch actions are available right now.';

  @override
  String get employeeTodayPrimaryPunchInSubtitle => 'Start your work session';

  @override
  String get employeeTodayPrimaryPunchOutSubtitle => 'End your current session';

  @override
  String get employeeTodayPrimaryBreakOutSubtitle => 'Start a break';

  @override
  String get employeeTodayPrimaryBreakInSubtitle => 'Resume your shift';

  @override
  String get employeeTodayNoAction => 'No action';

  @override
  String get employeeTodayActionUnavailable => 'Action is unavailable';

  @override
  String get employeeTodayPunchUnavailableMissingPunch =>
      'Please request a correction for the missing punch.';

  @override
  String get employeeTodayAttendanceLoadErrorTitle => 'Attendance unavailable';

  @override
  String get employeeTodayAttendanceStatusLabel => 'Status';

  @override
  String get employeeTodayLastPunchLabel => 'Last punch';

  @override
  String get employeeTodayLocationContextLabel => 'Location';

  @override
  String get employeeTodayShiftLabel => 'Shift';

  @override
  String get employeeTodayGpsVerified => 'GPS Verified';

  @override
  String get employeeTodayGpsLocating => 'Locating GPS';

  @override
  String get employeeTodayPunchNotAllowedNow => 'This punch is not allowed now';

  @override
  String get employeeQuickActionsTitle => 'Quick actions';

  @override
  String get employeeQuickActionAddSaleSubtitle =>
      'Record a service or payment';

  @override
  String get employeeQuickActionRequestCorrectionTitle => 'Request correction';

  @override
  String get employeeQuickActionRequestCorrectionSubtitle =>
      'Fix a missing or wrong punch';

  @override
  String get employeeQuickActionViewPolicySubtitle =>
      'Attendance rules and violations';

  @override
  String get employeeQuickActionPayrollTitle => 'Payroll';

  @override
  String get employeeQuickActionPayrollSubtitle =>
      'Payslips and payroll history';

  @override
  String get employeeTodaySectionLoadFailed =>
      'We couldn\'t load this section.';

  @override
  String get employeeTodayTryAgain => 'Try again';

  @override
  String get employeeTodayNoActivityTitle => 'No punches yet';

  @override
  String get employeeTodayNoActivityBody =>
      'Your timeline will fill in as you punch in and out.';

  @override
  String get employeeTodaySemanticNotifications => 'Notifications';

  @override
  String get employeeTodaySemanticSettings => 'Settings';

  @override
  String get employeeActivityTimelineTitle => 'Today activity';

  @override
  String get employeeActivityTimelineLive => 'Live';

  @override
  String get employeeActivityTimelineEmpty => 'No punches yet today.';

  @override
  String get employeeSalesTitle => 'My Sales';

  @override
  String get employeeSalesSubtitle => 'Track your revenue and commission';

  @override
  String get employeeSalesNotAllowedAdd =>
      'You are not allowed to add sales. Please contact the salon owner.';

  @override
  String get employeeSaleRecordedSuccess => 'Sale recorded successfully.';

  @override
  String get employeeSalesEmptyPeriod =>
      'No sales recorded for this period yet.';

  @override
  String get employeeSalesEmptyCta =>
      'Tap Add Sale to record your first sale today.';

  @override
  String get employeeSalesRecentTitle => 'Recent sales';

  @override
  String get employeeSalesViewReceipts => 'View receipts';

  @override
  String get employeeSalesViewReceiptsHint =>
      'Receipt review for owners is coming soon.';

  @override
  String get employeeSalesTotalLabel => 'Total Sales';

  @override
  String get employeeSalesHeroNoSales =>
      'No sales recorded for this period yet.';

  @override
  String get employeeSalesKpiTotal => 'Total Sales';

  @override
  String get employeeSalesKpiServices => 'Services';

  @override
  String get employeeSalesKpiCommission => 'Est. Commission';

  @override
  String get employeeSalesKpiAvgService => 'Avg. Service';

  @override
  String get employeeSalesCommissionRate => 'Commission rate';

  @override
  String get employeeSalesCommissionHint => 'Your commission percentage';

  @override
  String get employeeSalesEstimatedCommission => 'Estimated commission';

  @override
  String employeeSalesFromSales(Object amount) {
    return 'From $amount sales';
  }

  @override
  String get employeeSalesCustomersLabel => 'Customers';

  @override
  String employeeSalesServicesCustomersRow(Object services, Object customers) {
    return '$services services · $customers customers';
  }

  @override
  String employeeSalesShowingLatest(int count) {
    return 'Showing latest $count sales';
  }

  @override
  String get addSaleReceiptSectionTitle => 'Receipt photo';

  @override
  String get addSaleReceiptSectionBody =>
      'Take a photo of the card receipt, cash receipt, or payment proof.';

  @override
  String get addSaleReceiptTakePhoto => 'Take photo';

  @override
  String get addSaleReceiptRetake => 'Retake photo';

  @override
  String get addSaleReceiptRemove => 'Remove';

  @override
  String get addSaleReceiptRequiredCard =>
      'Receipt photo is required for card payments.';

  @override
  String get addSaleReceiptRequiredMixed =>
      'Receipt photo is required because this sale includes card payment.';

  @override
  String get addSaleOptionalCashPhotoHint =>
      'Optional: take a photo of cash received or a handwritten receipt.';

  @override
  String get addSaleCashCardSplitTitle => 'Cash & card amounts';

  @override
  String get addSaleCashAmountHint => 'Cash';

  @override
  String get addSaleCardAmountHint => 'Card';

  @override
  String get addSalePaymentSplitInvalid =>
      'Cash plus card must equal the total sale amount.';

  @override
  String get ownerAddSaleAutoPrice => 'Auto-filled price';

  @override
  String get addSaleModeBookingCode => 'Booking code';

  @override
  String get addSaleModeManual => 'Manual sale';

  @override
  String get addSaleDualSubtitle =>
      'Add from a guest booking code or record a manual sale.';

  @override
  String get addSaleBookingCodeFieldLabel => 'Booking code';

  @override
  String get addSaleBookingCodeHint => 'Enter booking code';

  @override
  String get addSaleBookingCodeExample => 'Example: ZR-AB12CD';

  @override
  String get addSaleRetrieveBooking => 'Retrieve booking';

  @override
  String get addSaleCreateFromBooking => 'Create sale';

  @override
  String get addSaleBookingFound => 'Booking found';

  @override
  String get addSaleBookingSectionPayment => 'Payment';

  @override
  String get addSaleBookingSectionAppointment => 'Appointment';

  @override
  String get addSaleBookingSectionServices => 'Services';

  @override
  String get addSaleBookingSubtotal => 'Subtotal';

  @override
  String get addSaleBookingDiscount => 'Discount';

  @override
  String get addSaleBookingTotal => 'Total';

  @override
  String get addSaleBookingStatus => 'Booking status';

  @override
  String get addSalePaymentStatusPending => 'Pending';

  @override
  String get addSalePaymentStatusPaid => 'Paid';

  @override
  String get addSalePaymentStatusFailed => 'Failed';

  @override
  String get addSalePaymentStatusRefunded => 'Refunded';

  @override
  String get addSalePaymentMethodUnspecified => 'Unspecified';

  @override
  String get addSaleBookingErrorEmptyCode => 'Please enter a booking code.';

  @override
  String get addSaleBookingErrorNotFound => 'Booking code not found.';

  @override
  String get addSaleBookingErrorWrongSalon =>
      'This booking does not belong to this salon.';

  @override
  String get addSaleBookingErrorCancelled => 'This booking is cancelled.';

  @override
  String get addSaleBookingErrorSaleExists =>
      'A sale was already created for this booking.';

  @override
  String get addSaleBookingErrorNoServices => 'This booking has no services.';

  @override
  String get addSaleBookingErrorZeroTotal => 'Total must be greater than zero.';

  @override
  String get addSaleBookingErrorBarberMismatch =>
      'Booking barber does not match.';

  @override
  String get addSaleBookingErrorNotYourBooking =>
      'You can only use bookings assigned to you.';

  @override
  String get addSaleBookingErrorNoPreview => 'Retrieve the booking first.';

  @override
  String get addSaleBookingErrorNoSession => 'Sign in again to continue.';

  @override
  String get addSaleBookingErrorBarberMissing =>
      'Assigned barber was not found.';

  @override
  String get addSaleBookingErrorUnknown => 'Something went wrong. Try again.';

  @override
  String get addSaleBookingSaleCreated => 'Sale created';

  @override
  String get addSaleBookingSalon => 'Salon';

  @override
  String get addSaleBookingCodeLabel => 'Booking code';

  @override
  String get addSaleBookingCustomer => 'Customer';

  @override
  String get addSaleBookingBarber => 'Barber';

  @override
  String get addSalePaymentMethodWallet => 'Wallet';

  @override
  String get addSaleBookingErrorManualNameRequired =>
      'Customer name is required.';

  @override
  String get authV2WelcomeTitle => 'Operations, simplified.';

  @override
  String get authV2WelcomeSubtitle =>
      'Run bookings, team, payroll, and money in one premium workspace.';

  @override
  String get authV2WelcomeContinue => 'Continue';

  @override
  String get authV2FieldLanguage => 'Language';

  @override
  String get authV2FieldCountry => 'Country';

  @override
  String get authV2RoleTitle => 'How do you want to use Zurano?';

  @override
  String get authV2RoleOwnerTitle => 'Create a salon';

  @override
  String get authV2RoleOwnerSubtitle =>
      'Register your business, team, and operations.';

  @override
  String get authV2RoleCustomerTitle => 'Continue as User';

  @override
  String get authV2RoleCustomerSubtitle =>
      'Discover salons and book appointments.';

  @override
  String get authV2OwnerLoginHeadline => 'Welcome back';

  @override
  String get authV2OwnerLoginSubtitle => 'Sign in to manage your salon.';

  @override
  String get authV2UserLoginHeadline => 'Welcome back';

  @override
  String get authV2UserLoginSubtitle => 'Sign in to continue.';

  @override
  String get authV2UserLoginIdentifierHelper =>
      'Employees sign in with username. Customers sign in with email.';

  @override
  String get userLoginForgotPasswordNeedEmail =>
      'Password reset works with email. Add “@” if you are signing in with email.';

  @override
  String get authLoginErrorIncorrect =>
      'Incorrect email, username, or password.';

  @override
  String get authLoginErrorDisabled => 'This account has been disabled.';

  @override
  String get authLoginErrorInvalidEmail => 'Enter a valid email address.';

  @override
  String get authLoginErrorTooManyRequests =>
      'Too many attempts. Wait and try again, or reset your password.';

  @override
  String get authLoginErrorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get authLoginErrorStaffUseUsername =>
      'Salon staff sign in with the email or username from the salon owner. Customers use their own email here.';

  @override
  String get authLoginErrorGeneric => 'Could not sign in. Please try again.';

  @override
  String get authStaffLoginUserDocMissing =>
      'User profile not found. Contact your salon owner.';

  @override
  String get authStaffLoginUserInactive =>
      'This account is paused. Contact your salon owner.';

  @override
  String get authStaffLoginEmployeeDocMissing =>
      'Your staff profile is not linked to the salon. Contact your salon owner.';

  @override
  String get authStaffLoginEmployeeInactive =>
      'Your access has been turned off by the salon owner.';

  @override
  String get authStaffLoginWrongPortal =>
      'This entrance is for salon team only. Customers and owners should use the matching sign-in option.';

  @override
  String get changeTemporaryPasswordFieldCurrent => 'Current password';

  @override
  String get changeTemporaryPasswordFieldNew => 'New password';

  @override
  String get changeTemporaryPasswordFieldConfirm => 'Confirm new password';

  @override
  String get changeTemporaryPasswordTitle => 'Create a new password';

  @override
  String get changeTemporaryPasswordSubtitle =>
      'Your salon owner set a temporary password. Choose a new one to continue.';

  @override
  String get changeTemporaryPasswordSignOut => 'Sign out';

  @override
  String get changeTemporaryPasswordSubmit => 'Update password';

  @override
  String get changeTemporaryPasswordSuccessSnack =>
      'Password changed successfully';

  @override
  String get changeTemporaryPasswordErrorCurrentRequired =>
      'Enter your current password.';

  @override
  String get changeTemporaryPasswordErrorNewMinLength =>
      'New password must be at least 8 characters.';

  @override
  String get changeTemporaryPasswordErrorNewRequiresLetterAndNumber =>
      'New password must include at least one letter and one number.';

  @override
  String get changeTemporaryPasswordErrorConfirmMismatch =>
      'New passwords do not match.';

  @override
  String get changeTemporaryPasswordErrorWrongPassword =>
      'Current password is incorrect.';

  @override
  String get changeTemporaryPasswordErrorWeakPassword =>
      'Password is too weak. Try a longer mix of letters and numbers.';

  @override
  String get changeTemporaryPasswordErrorRequiresRecentLogin =>
      'Please sign out and sign in again, then retry.';

  @override
  String get changeTemporaryPasswordErrorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get changeTemporaryPasswordErrorGeneric =>
      'Could not update password. Please try again.';

  @override
  String get changeTemporaryPasswordFirestorePartialFailure =>
      'Password changed, but account status could not be updated. Please contact the salon owner.';

  @override
  String get authLoginErrorStaffNotFound =>
      'No staff account found for this username. Check spelling or ask your salon owner.';

  @override
  String get authLoginErrorPermission =>
      'You do not have permission to complete this action.';

  @override
  String get authV2LoginHeadline => 'Sign in';

  @override
  String get authV2LoginSubtitle =>
      'Use your work email to access your workspace.';

  @override
  String get authV2SignupHeadline => 'Create account';

  @override
  String get authV2SignupSubtitle => 'Quick setup — you can add details later.';

  @override
  String get authV2ForgotPassword => 'Forgot password?';

  @override
  String get authV2ForgotPasswordTitle => 'Reset Password';

  @override
  String get authV2ForgotPasswordDescription =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get authV2ForgotPasswordSent =>
      'Check your email for reset instructions.';

  @override
  String get authV2SendResetLink => 'Send link';

  @override
  String get authV2OrDivider => 'OR';

  @override
  String get guestAuthOrDivider => 'or';

  @override
  String get guestAuthContinueAsGuest => 'Continue as guest';

  @override
  String get guestAuthGuestSubtitle =>
      'No account needed. Discover salons and book in seconds.';

  @override
  String guestAuthSignInFailed(String details) {
    return 'Unable to continue as guest: $details';
  }

  @override
  String get guestAuthSessionTimeout =>
      'Your profile is taking too long to load. Check your connection and try again.';

  @override
  String get guestNicknameScreenTitle => 'How should we call you?';

  @override
  String get guestNicknameScreenSubtitle =>
      'Pick a nickname for the salon team. We’ll make it unique.';

  @override
  String get guestNicknameFieldLabel => 'Nickname';

  @override
  String get guestNicknameSuggestedLabel => 'Your display name';

  @override
  String get guestNicknameContinue => 'Continue';

  @override
  String get guestNicknameErrorTooShort => 'Enter at least 2 characters.';

  @override
  String get guestNicknameErrorInvalid => 'Use letters and numbers only.';

  @override
  String get guestNicknameErrorReserveFailed =>
      'Could not reserve that name. Try again.';

  @override
  String get customerBookingReviewMissingGuestNickname =>
      'Please set your guest nickname first.';

  @override
  String get authV2ContinueGoogle => 'Continue with Google';

  @override
  String get authV2ContinueApple => 'Continue with Apple';

  @override
  String get authV2ContinueFacebook => 'Continue with Facebook';

  @override
  String get authV2SignUpLink => 'Create an account';

  @override
  String get authV2SignInLink => 'Sign in';

  @override
  String get authV2LoginSignupPrompt => 'New to Zurano?';

  @override
  String get authV2SignupSigninPrompt => 'Already have an account?';

  @override
  String get authV2PasswordHintRules => 'At least 8 characters';

  @override
  String get authV2CreateSalonTitle => 'Add your salon details';

  @override
  String get authV2CreateSalonSubtitle =>
      'Choose your salon name and city to start managing bookings and your team.';

  @override
  String get authV2CurrencyLabel => 'Currency';

  @override
  String get authV2OptionalAddressLabel => 'Address (optional)';

  @override
  String get authV2CreateSalonCta => 'Create salon';

  @override
  String get createSalonCountryRequired =>
      'Finish country selection in onboarding before creating your salon.';

  @override
  String get createSalonCitiesLoading => 'Loading cities for your country…';

  @override
  String get createSalonNoCitiesForCountry =>
      'No city list is available for this country. Enter your city manually.';

  @override
  String get createSalonEnterCityManually => 'Enter city manually';

  @override
  String get createSalonPickFromList => 'Pick from list';

  @override
  String get createSalonSelectCityHint => 'Tap to search and select a city';

  @override
  String get bentoDashboardScreenTitle => 'Operations hub';

  @override
  String get firstTimeRoleEyebrow => 'Welcome';

  @override
  String get firstTimeRoleTitle => 'How will you use Zurano?';

  @override
  String get firstTimeRoleDescription =>
      'Choose your role to finish setting up your profile.';

  @override
  String get firstTimeRoleUserTitle => 'User';

  @override
  String get firstTimeRoleUserSubtitle =>
      'Book services, explore salons, and manage appointments.';

  @override
  String get firstTimeRoleOwnerTitle => 'Salon Owner';

  @override
  String get firstTimeRoleOwnerSubtitle =>
      'Create your salon, manage staff, bookings, payroll, and operations.';

  @override
  String get firstTimeRoleContinue => 'Continue';

  @override
  String get firstTimeRoleDifferentAccount => 'Use a different account';

  @override
  String get firstTimeRoleError =>
      'We couldn’t finish setting up your profile. Please try again.';

  @override
  String get ownerTabCustomers => 'Customers';

  @override
  String get ownerTabFinance => 'Finance';

  @override
  String get ownerDashboardSettingsTooltip => 'Settings';

  @override
  String get ownerServicesWaitingForSalon =>
      'Waiting for salon on your profile…';

  @override
  String get onboardingSalonCreatedTitle => 'Salon created';

  @override
  String get onboardingSalonCreatedSubtitle => 'Opening your dashboard…';

  @override
  String get splashBootstrapErrorMessage =>
      'Startup failed due to a network or Firestore issue. Please retry.';

  @override
  String get splashRetryStartup => 'Retry startup';

  @override
  String get customersScreenTitle => 'Customers';

  @override
  String customersHeroGreeting(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String customersSalonOnlyBannerTitle(String salonName) {
    return '$salonName customers only';
  }

  @override
  String get customersSalonOnlyBannerSubtitle =>
      'Salon-owned list for visits, bookings, and spending.';

  @override
  String get customersGlobalSearchHint => 'Search team, revenue, and requests';

  @override
  String customersCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers',
      one: '1 customer',
      zero: '0 customers',
    );
    return '$_temp0';
  }

  @override
  String get customersGoldenInfoTitle => 'Golden customers';

  @override
  String get customersGoldenInfoSubtitle =>
      'Track visits, bookings, and spending.';

  @override
  String get customersGoldenInfoDismissSemantics => 'Dismiss tip';

  @override
  String get customersInsightsThisMonth => 'This month';

  @override
  String get customersInsightsNewThisMonth => 'New customers';

  @override
  String get customersInsightsReturningThisMonth => 'Returning';

  @override
  String get customersInsightsTotalCustomers => 'Total active';

  @override
  String get customersInsightsTotalSpent => 'Total spending';

  @override
  String get customersInsightsLoadError => 'Could not load insights.';

  @override
  String customersLastServiceLine(String serviceName) {
    return 'Last service: $serviceName';
  }

  @override
  String get customersActionCall => 'Call customer';

  @override
  String get customersActionMessage => 'Message on WhatsApp';

  @override
  String get customersActionViewProfile => 'View profile';

  @override
  String get customersActionCouldNotOpen => 'Could not open the link.';

  @override
  String get customersListFooterTitle => 'Build your customer list';

  @override
  String get customersListFooterSubtitle =>
      'Add walk-in customers, link bookings, and track loyalty automatically.';

  @override
  String get customersFilterEmptyTitle => 'No matches';

  @override
  String get customersFilterEmptySubtitle =>
      'Try another search or chip, or clear filters.';

  @override
  String get customersClearFilters => 'Clear filters';

  @override
  String get customersSearchEmptyTitle => 'No search results';

  @override
  String get customersSearchEmptySubtitle =>
      'Try a different name or phone, or clear the search.';

  @override
  String get customersClearSearch => 'Clear search';

  @override
  String get customersAddCustomerFab => 'Add customer';

  @override
  String get customersPermissionErrorTitle =>
      'You do not have access to these customers.';

  @override
  String get customersPermissionErrorSubtitle =>
      'Please check salon membership or permissions.';

  @override
  String get customersGenericLoadError =>
      'We couldn’t load customers. Please try again.';

  @override
  String get customersCategoryNewBadge => 'New';

  @override
  String get customersCategoryRegularBadge => 'Regular';

  @override
  String get customersStatusActive => 'Active';

  @override
  String get customersStatusInactive => 'Inactive';

  @override
  String customersLastVisitShort(String date) {
    return 'Last visit: $date';
  }

  @override
  String customersVisitsShort(int count) {
    return 'Visits: $count';
  }

  @override
  String customersSpentShort(String amount) {
    return 'Spent: $amount';
  }

  @override
  String get customersSearchHint => 'Search name or phone';

  @override
  String get customersTagAll => 'All';

  @override
  String get customersTagNew => 'New';

  @override
  String get customersTagRegular => 'Regular';

  @override
  String get customersTagVip => 'VIP';

  @override
  String get customersTagInactive => 'Inactive';

  @override
  String get customersEmptyTitle => 'No customers yet';

  @override
  String get customersEmptyMessageCanCreate =>
      'Add your first customer to start tracking visits and spending.';

  @override
  String get customersEmptyMessageNoAccess =>
      'No customers are available for your account.';

  @override
  String get customersAddFirstCta => 'Add first customer';

  @override
  String get customersLastVisitNever => 'No visit yet';

  @override
  String get customersPreferredBarberNone => 'No preferred team member';

  @override
  String customersPreferredBarberLine(String phone, String barber) {
    return '$phone · $barber';
  }

  @override
  String customersPreferredBarberLabel(String name) {
    return 'Preferred team member: $name';
  }

  @override
  String customersLastVisitLine(String date, String relative) {
    return 'Last visit: $date ($relative)';
  }

  @override
  String customersVisitsPointsLine(int visits, int points) {
    return 'Visits: $visits · Points: $points';
  }

  @override
  String customersTotalSpentLine(String amount) {
    return 'Total spent: $amount';
  }

  @override
  String get customersVipBadge => 'VIP';

  @override
  String get customersTimeNever => 'never';

  @override
  String get customersTimeJustNow => 'just now';

  @override
  String customersTimeMinutesAgo(int n) {
    return '${n}m ago';
  }

  @override
  String customersTimeHoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String customersTimeDaysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String customersTimeMonthsAgo(int n) {
    return '${n}mo ago';
  }

  @override
  String customersTimeYearsAgo(int n) {
    return '${n}y ago';
  }

  @override
  String get customerNotFound => 'Customer not found';

  @override
  String get customerNotFoundSubtitle =>
      'This customer may have been deleted or you do not have permission to view it.';

  @override
  String get customerBackToCustomers => 'Back to customers';

  @override
  String get customerDetailsCall => 'Call';

  @override
  String get customerDetailsWhatsApp => 'WhatsApp';

  @override
  String get customerDetailsEdit => 'Edit';

  @override
  String get customerDetailsBook => 'Book';

  @override
  String get customerDetailsAddService => 'Add sale';

  @override
  String get customerDetailsUpcomingSection => 'Upcoming appointments';

  @override
  String get customerDetailsHistorySection => 'Visit history';

  @override
  String get customerDetailsBookSameServiceAgain => 'Book same service again';

  @override
  String customerDetailsSpendingSummary(String amount) {
    return 'Spending summary: $amount';
  }

  @override
  String customerDetailsNotesWithValue(String notes) {
    return 'Notes: $notes';
  }

  @override
  String get customerDetailsNotesEmpty => 'No notes';

  @override
  String get customerDetailsServiceFallback => 'Service';

  @override
  String get customerInsightsTitle => 'Customer insights';

  @override
  String get customerProfileVipSubtitle => 'VIP customer · enabled by owner';

  @override
  String get customerInsightNoVisits => 'No previous visits yet';

  @override
  String customerInsightLastVisitDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
      zero: 'today',
    );
    return 'Last visit $_temp0';
  }

  @override
  String customerInsightTotalVisitsLine(int count) {
    return 'Total visits: $count';
  }

  @override
  String customerInsightTotalSpentLine(String amount) {
    return 'Total spend: $amount';
  }

  @override
  String get customerSuggestedActionVip =>
      'High-value customer — consider a tailored offer';

  @override
  String get customerSuggestedActionNew =>
      'New customer — follow up with a welcome offer';

  @override
  String get customerSuggestedActionRegular =>
      'Regular customer — keep the relationship warm';

  @override
  String get customerSuggestedActionInactive =>
      'Inactive — consider a win-back offer';

  @override
  String get customerTypeSectionTitle => 'Customer type';

  @override
  String get customerTypeChipsHint =>
      'Types help you tailor offers. VIP is set by the owner.';

  @override
  String get customerTypeVip => 'VIP';

  @override
  String get customerTypeNew => 'New';

  @override
  String get customerTypeRegular => 'Regular';

  @override
  String get customerTypeInactive => 'Inactive';

  @override
  String get customerDiscountBoxTitle => 'Customer discount';

  @override
  String get customerDiscountBoxSubtitle =>
      'Applied automatically when recording a sale';

  @override
  String get customerDiscountEditSheetTitle => 'Edit discount';

  @override
  String get customerDiscountPercentLabel => 'Discount %';

  @override
  String get customerDiscountInvalid => 'Enter a value between 0 and 100';

  @override
  String get customerSalesSectionTitle => 'Transaction history';

  @override
  String customerSalesTotalSpentSummary(String amount) {
    return 'Total spent: $amount';
  }

  @override
  String customerSalesLastVisitSummary(String date) {
    return 'Last visit: $date';
  }

  @override
  String get customerSalesEmptyTitle => 'No transactions yet';

  @override
  String get customerSalesEmptySubtitle =>
      'Sales for this customer will appear here.';

  @override
  String get customerUpcomingSectionTitle => 'Upcoming appointments';

  @override
  String get customerUpcomingEmptyTitle => 'No upcoming appointments';

  @override
  String get customerNotesSectionTitle => 'Notes';

  @override
  String get createBookingSearchCustomerLabel => 'Search customer';

  @override
  String get createBookingAddNewCustomer => 'Add new';

  @override
  String createBookingDateWithValue(String date) {
    return 'Date: $date';
  }

  @override
  String createBookingTimeWithValue(String time) {
    return 'Time: $time';
  }

  @override
  String get createBookingPickTime => 'Pick time';

  @override
  String get createBookingValidationIncomplete =>
      'Please complete customer, service, team member, date and time.';

  @override
  String get createBookingSuccessSnackbar => 'Booking created successfully';

  @override
  String get createBookingSaveCta => 'Save booking';

  @override
  String get addCustomerTitle => 'Add new customer';

  @override
  String get addCustomerSaveCustomer => 'Save customer';

  @override
  String get addCustomerSaveAndBook => 'Save and book';

  @override
  String get addCustomerFieldFullName => 'Full name';

  @override
  String get addCustomerFullNameRequired => 'Full name is required';

  @override
  String get addCustomerFieldPhone => 'Phone number';

  @override
  String get addCustomerFieldSource => 'Source (walk-in, Instagram, referral…)';

  @override
  String get addCustomerFieldNotes => 'Notes';

  @override
  String get addCustomerSavedWithPhone => 'Customer saved successfully.';

  @override
  String get addCustomerSavedNoPhone =>
      'Customer saved. No phone number added.';

  @override
  String get accountProfileRecoveryInlineError =>
      'Account created, but profile setup did not finish. Tap “Create profile” to recover your account.';

  @override
  String get profileFieldFullName => 'Full name';

  @override
  String get profileFieldMobile => 'Mobile';

  @override
  String get profileFieldCity => 'City';

  @override
  String get authHintEmailExample => 'name@example.com';

  @override
  String get customerBookingMoreDays => 'More days';

  @override
  String barberAttendanceInOutLine(String checkIn, String checkOut) {
    return 'In: $checkIn · Out: $checkOut';
  }

  @override
  String get barberAttendanceStatusPresent => 'Present';

  @override
  String get barberAttendanceStatusAbsent => 'Absent';

  @override
  String get barberAttendanceStatusLate => 'Late';

  @override
  String get barberAttendanceStatusLeave => 'Leave';

  @override
  String get preAuthLanguageEnglishHint => 'English interface';

  @override
  String get preAuthLanguageArabicHint => 'Arabic interface';

  @override
  String get semanticIllustrationSalonOwnerSignup =>
      'Salon owner signup illustration';

  @override
  String get semanticIllustrationCustomerSignup =>
      'Customer signup illustration';

  @override
  String get semanticIllustrationEmptyServices => 'Empty services illustration';

  @override
  String get semanticIllustrationWelcomeOnboarding =>
      'Welcome onboarding illustration';

  @override
  String get employeePayrollTitle => 'Payroll';

  @override
  String get employeePayrollSubtitle => 'Your salary and payslip';

  @override
  String get employeePayrollSelectMonth => 'Select month';

  @override
  String get employeePayrollNetPay => 'Net pay';

  @override
  String get employeePayrollEarnings => 'Earnings';

  @override
  String get employeePayrollDeductions => 'Deductions';

  @override
  String get employeePayrollNetSalary => 'Net salary';

  @override
  String get employeePayrollStatusPaid => 'Paid';

  @override
  String get employeePayrollStatusApproved => 'Approved';

  @override
  String get employeePayrollServicesStat => 'Services';

  @override
  String get employeePayrollThisMonth => 'This month';

  @override
  String get employeePayrollCommissionStat => 'Commission';

  @override
  String get employeePayrollOnServices => 'On services';

  @override
  String get employeePayrollAttendanceStat => 'Attendance';

  @override
  String get employeePayrollDaysPresent => 'Days present';

  @override
  String get employeePayrollViewFullPayslip => 'View full payslip';

  @override
  String get employeePayrollDownloadPdf => 'Download PDF';

  @override
  String get employeePayrollRecentTitle => 'Recent payslips';

  @override
  String get employeePayrollViewAll => 'View all';

  @override
  String get employeePayrollEmptyTitle =>
      'Payslip is not generated yet for this month';

  @override
  String get employeePayrollEmptyBody =>
      'Your payslip will appear here once the salon owner generates payroll for this period.';

  @override
  String get employeeWorkspaceNotLinkedTitle => 'Employee profile not linked';

  @override
  String get employeeWorkspaceNotLinkedBody =>
      'Your account is not linked to an employee profile yet. Ask your salon owner to complete staff provisioning.';

  @override
  String get employeeStaffWorkspaceUnavailableTitle =>
      'Staff workspace unavailable';

  @override
  String get employeeStaffWorkspaceUnavailableBody =>
      'Your user account or staff profile is inactive, or your employee record could not be loaded. Ask your salon owner if this should be restored.';

  @override
  String get employeeMapLocationPermissionRequired =>
      'Location permission is required to show your position on the map.';

  @override
  String get employeeMapUnavailableBody =>
      'Map could not be loaded. You can still punch using GPS when enabled.';

  @override
  String get employeePayrollErrorTitle => 'Could not load payroll';

  @override
  String get employeePayrollSalaryNotesTitle => 'Salary notes';

  @override
  String get employeePayrollNoWorkspace => 'No workspace';

  @override
  String get employeePayrollHistoryTitle => 'Payslip history';

  @override
  String get employeePayrollDetailsTitle => 'Payslip';

  @override
  String get employeePayrollPdfShareSubject => 'Payslip';

  @override
  String get employeePayrollTotalEarnings => 'Total earnings';

  @override
  String get employeePayrollTotalDeductions => 'Total deductions';

  @override
  String employeePayrollPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String get employeeTodayLocationUnknown => 'Location unknown';

  @override
  String get employeeTodayNoAddressSet => 'No address set';

  @override
  String get employeeAttendanceZoneNotConfiguredAdmin =>
      'Attendance zone is not configured yet. Please contact your salon admin.';

  @override
  String get employeeAttendanceNotRequiredOrDisabled =>
      'Attendance is not required or disabled.';

  @override
  String get employeeTodayCheckedOutForToday =>
      'You are checked out for today.';

  @override
  String get employeeTodayCorrectionRequestsDisabled =>
      'Correction requests are disabled for your salon.';

  @override
  String get employeeTodayAwaitingApproval => 'Awaiting approval';

  @override
  String get employeeTodayNoOpenRequests => 'No open requests';

  @override
  String get employeeAttendanceSalonLocationTitle => 'Salon location';

  @override
  String get employeeAttendanceLocating => 'Locating…';

  @override
  String employeeAttendanceGpsAccuracy(String accuracy) {
    return 'GPS accuracy: $accuracy';
  }

  @override
  String get employeeAttendanceSalonLocationOwnerNote =>
      'Salon location is not configured. Please contact the owner.';

  @override
  String get employeeAttendanceRetryLocation => 'Retry location';

  @override
  String get employeeAttendanceWithinRange => 'Within range';

  @override
  String get employeeAttendanceOutsideRange => 'Outside range';

  @override
  String get employeeAttendanceScreenTitle => 'Attendance';

  @override
  String get employeeAttendanceScreenSubtitle =>
      'Track your work hours and stay punctual';

  @override
  String get employeeAttendanceGreetingMorning => 'Good morning,';

  @override
  String get employeeAttendanceGreetingAfternoon => 'Good afternoon,';

  @override
  String get employeeAttendanceGreetingEvening => 'Good evening,';

  @override
  String get employeeAttendanceProductiveDay => 'Have a productive day! 👋';

  @override
  String get employeePunchNextAction => 'Next action';

  @override
  String get employeePunchMissingDetectedWithCorrection =>
      'Missing punch detected. Submit a request for approval.';

  @override
  String get employeePunchDoneForToday => 'You are done for today.';

  @override
  String get employeePunchMustBeInZone =>
      'You must be within the salon zone to punch in.';

  @override
  String get employeePunchTapWhenArrive => 'Tap when you arrive at the salon.';

  @override
  String employeePunchBreakLimitMinutes(int minutes) {
    return 'Your daily break limit is $minutes minutes total.';
  }

  @override
  String get employeePunchReturnFromBreak => 'Tap when you return from break.';

  @override
  String get employeePunchEndWorkingDay => 'End your working day.';

  @override
  String get employeePunchSubmitCorrection => 'Submit correction';

  @override
  String get employeePunchMissingAskAdmin =>
      'Missing punch detected. Ask your owner or admin to enable correction requests.';

  @override
  String get employeePunchCompletedTodayTitle => 'Completed today';

  @override
  String get employeeTimelineTodayTitle => 'Today\'s timeline';

  @override
  String get employeeTimelineBreakOutTitle => 'Break out';

  @override
  String get employeeTimelineBreakInTitle => 'Break in';

  @override
  String get employeeTimelineWorkingHours => 'Working hours';

  @override
  String get employeeTimelineShiftNotSet => 'Shift times not set';

  @override
  String get employeeTodayStatusCardTitle => 'Today\'s status';

  @override
  String get employeeAttendanceWorkedLabel => 'Worked';

  @override
  String get employeeAttendanceExpectedCheckoutLabel => 'Expected checkout';

  @override
  String get employeeAttendanceStatusMissingPunch => 'Missing punch';

  @override
  String get employeeAttendanceStatusIncomplete => 'Incomplete';

  @override
  String get employeeAttendanceStatusNotCheckedInTitle => 'Not checked in';

  @override
  String get employeeRecentAttendanceTitle => 'Recent attendance';

  @override
  String get employeeAttendanceSeeAll => 'See all';

  @override
  String get employeeRecentAttendanceLoadError => 'Could not load recent days.';

  @override
  String get employeeRecentAttendanceEmpty =>
      'No attendance record yet.\nTap Punch In when you arrive at the salon.';

  @override
  String get employeeAttendanceStatusOnTime => 'On time';

  @override
  String get employeeAttendanceOverviewTitle =>
      'Attendance overview (this month)';

  @override
  String get employeeAttendanceViewCalendar => 'View calendar';

  @override
  String get employeeAttendanceOverviewFootnote =>
      'Includes days without a record before today as absent.';

  @override
  String get employeeAttendanceSummaryLoadError =>
      'Could not load attendance summary.';

  @override
  String get employeeAttendanceNoDataYet => 'No data yet.';

  @override
  String get employeeAttendanceOverviewDays => 'Days';

  @override
  String get employeeAttendanceLoadError => 'Could not load attendance.';

  @override
  String get employeeAttendanceCorrectionFlowTitle => 'Attendance correction';

  @override
  String get employeeAttendanceCorrectionSubtitle =>
      'Submit a missed punch request for approval.';

  @override
  String get employeeCorrectionSelectPunchType => 'Please select a punch type.';

  @override
  String get employeeCorrectionSelectValidDate => 'Please select a valid date.';

  @override
  String get employeeCorrectionSelectValidTime => 'Please select a valid time.';

  @override
  String get employeeCorrectionFutureNotAllowed =>
      'The request date cannot be in the future.';

  @override
  String get employeeCorrectionTooOld =>
      'This request is older than the allowed correction period.';

  @override
  String get employeeCorrectionReasonRequired => 'Please enter a reason.';

  @override
  String get employeeCorrectionReasonMinLength =>
      'Reason must be at least 10 characters.';

  @override
  String get employeeCorrectionReasonMaxLength =>
      'Reason cannot exceed 250 characters.';

  @override
  String get employeeCorrectionSubmittedSnackbar =>
      'Request submitted successfully';

  @override
  String get employeeCorrectionDetailsTitle => 'Correction details';

  @override
  String get employeeCorrectionRequestedPunchLabel => 'Requested punch';

  @override
  String get employeeCorrectionSelectPlaceholder => 'Select';

  @override
  String get employeeAttendanceReasonLabel => 'Reason';

  @override
  String get employeeCorrectionAdminReviewNote =>
      'Your request will be reviewed by an admin.';

  @override
  String get employeeCorrectionSubmitCta => 'Submit request';

  @override
  String get employeeCorrectionRecentTitle => 'Recent requests';

  @override
  String get employeePolicyTitle => 'Attendance policy';

  @override
  String get employeePolicySubtitle => 'Simple rules for your workday';

  @override
  String get employeePolicySummaryTitle => 'Policy summary';

  @override
  String employeePolicyGpsSummary(int maxBreaks) {
    return 'Your salon uses GPS attendance when enabled. Record one punch in and one punch out per day; up to $maxBreaks breaks.';
  }

  @override
  String get employeePolicyRulePunchSession =>
      'Punch In starts your work session; Punch Out ends it.';

  @override
  String get employeePolicyRuleBreakPair =>
      'Break Out / Break In must be used as a pair.';

  @override
  String get employeePolicyRuleGpsZone =>
      'GPS may be required when you punch — stay inside the salon zone.';

  @override
  String get employeePolicyUpdatedSnackbar => 'Policy updated';

  @override
  String get employeePolicyRegenerateCta => 'Regenerate policy';

  @override
  String get employeePolicyPunchRules => 'Punch rules';

  @override
  String get employeePolicyLateEarly => 'Late & early exit';

  @override
  String get employeePolicyCorrectionSection => 'Correction requests';

  @override
  String get employeePolicyDefaultTitle => 'Attendance policy';

  @override
  String get employeeTodaySubmitCorrection => 'Submit correction';

  @override
  String get employeeTodayStatusMissingPunch => 'Missing punch';

  @override
  String get employeeTodayStatusCheckedInSubtitle =>
      'You are currently on duty';

  @override
  String get employeeTodayStatusOnBreakSubtitle =>
      'Tap back when your break ends';

  @override
  String get employeeTodayStatusBackFromBreakSubtitle =>
      'You can check out later';

  @override
  String get employeeTodayStatusCheckedOutSubtitle => 'Thank you';

  @override
  String get employeeTodayStatusMissingPunchSubtitle =>
      'Please submit a correction request for the missing punch';

  @override
  String get employeeTodayStatusInvalidSequenceSubtitle =>
      'Please submit a correction request';

  @override
  String employeeTodayLastPunchAt(String time) {
    return 'Last punch: $time';
  }

  @override
  String get employeeMapOpenInMaps => 'Open in Maps';

  @override
  String get employeePolicySummaryStatic =>
      'These rules follow your salon’s attendance settings. Your owner can change them anytime.';

  @override
  String get employeePolicyDeductionsSection => 'Deductions';

  @override
  String get employeePolicyRuleWorkPunchesOneLine =>
      'Each day you record one punch in and one punch out; breaks are separate.';

  @override
  String employeePolicyRuleMaxBreakMinutesOneLine(int minutes) {
    return 'Total break time is limited to $minutes minutes per day (combined breaks).';
  }

  @override
  String get employeePolicyRuleBreakOrderOneLine =>
      'Break Out must always be followed by Break In before other punches.';

  @override
  String employeePolicyRuleGpsRequiredOneLine(int radius) {
    return 'Attendance requires your phone location. Stay within $radius m of the salon center when punching.';
  }

  @override
  String get employeePolicyRuleGpsOptionalOneLine =>
      'GPS may be used to verify punches. Stay inside the salon zone when your owner requires it.';

  @override
  String get employeePolicyRuleCorrectionForgotOneLine =>
      'If you miss a punch, submit an attendance correction request for admin approval.';

  @override
  String get employeePolicyRuleCorrectionApprovedOneLine =>
      'Approved corrections are added safely to your punch history.';

  @override
  String employeePolicyRuleLateGraceOneLine(int grace) {
    return 'Late arrival is counted only after $grace minutes grace.';
  }

  @override
  String employeePolicyRuleLateMonthlyOneLine(int count) {
    return 'You may have up to $count late arrivals per month after grace before extra review applies.';
  }

  @override
  String employeePolicyRuleEarlyGraceOneLine(int grace) {
    return 'Early exit is counted only after $grace minutes grace.';
  }

  @override
  String employeePolicyRuleEarlyMonthlyOneLine(int count) {
    return 'You may have up to $count early exits per month after grace before extra review applies.';
  }

  @override
  String get employeePolicyDeductionNone => 'None';

  @override
  String employeePolicyDeductionPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get employeePolicyDeductionMissingCheckoutTitle => 'Missing checkout';

  @override
  String get employeePolicyDeductionMissingCheckoutSubtitle =>
      'Configured deduction when checkout is missing.';

  @override
  String get employeePolicyDeductionAbsenceTitle => 'Absence';

  @override
  String get employeePolicyDeductionAbsenceSubtitle =>
      'Configured deduction for unexcused absence days.';

  @override
  String get employeeCalendarLoadError => 'Could not load calendar';

  @override
  String get employeeAttendanceDayTitle => 'Attendance day';

  @override
  String get employeeAttendanceDayNoRecord => 'No record for this day.';

  @override
  String employeeAttendanceDayStatusLine(String status) {
    return 'Status: $status';
  }

  @override
  String employeeAttendanceDayWorkedBreakLine(int worked, int breakMin) {
    return 'Worked: $worked min · Break: $breakMin min';
  }

  @override
  String get employeeAttendanceDayPunchesTitle => 'Punches';

  @override
  String get employeeHistoryTitle => 'Attendance history';

  @override
  String get employeeHistoryRequestCta => 'Request';

  @override
  String get employeeHistoryEmpty => 'No attendance days yet.';

  @override
  String get employeeAttendanceRequestAddReason => 'Please add a reason.';

  @override
  String get employeeAttendanceRequestFutureTime =>
      'Requested time cannot be in the future.';

  @override
  String get employeeAttendanceRequestDuplicatePending =>
      'You already have a pending request for this.';

  @override
  String get employeeAttendanceRequestSubmitted => 'Request submitted';

  @override
  String get employeeRequestFailed => 'Request failed';

  @override
  String get employeeAttendanceRequestScreenTitle => 'Attendance correction';

  @override
  String get employeeAttendanceRequestPunchLabel => 'Requested punch';

  @override
  String get employeeAttendanceRequestSubmitCta => 'Submit request';

  @override
  String get employeeMapPreviewMobileOnly =>
      'Map preview is available on the mobile app.';

  @override
  String get employeeMapZoneNotConfigured => 'Zone not configured';

  @override
  String get employeeMapMarkerSalonZone => 'Salon zone';

  @override
  String get employeeMapMarkerYourLocation => 'Your location';

  @override
  String get employeeTodayStatsTitle => 'My today';

  @override
  String get employeeTodayStatsSalesLabel => 'Sales';

  @override
  String get employeeTodayStatsHoursLabel => 'Hours';

  @override
  String get employeeTodayDistanceUnknown => 'Distance —';

  @override
  String get employeeBottomNavToday => 'Today';

  @override
  String get employeeBottomNavSales => 'Sales';

  @override
  String get employeeBottomNavAttendance => 'Attendance';

  @override
  String get employeeBottomNavPayroll => 'Payroll';

  @override
  String get employeeBottomNavProfile => 'Profile';

  @override
  String get employeeProfileTabOverview => 'Overview';

  @override
  String get employeeProfileTabAccountInfo => 'Account info';

  @override
  String get employeeProfilePhotoTitle => 'Profile photo';

  @override
  String get employeeProfilePhotoUpdateAction => 'Update photo';

  @override
  String get employeeProfileResetPasswordHint =>
      'Send a reset link to your account email.';

  @override
  String get employeeProfileResetPasswordAction => 'Send reset link';

  @override
  String get employeeProfileUsernameLabel => 'Username';

  @override
  String get employeeProfileRoleLabel => 'Role';

  @override
  String get employeeProfileAccountStatusLabel => 'Account status';

  @override
  String get employeeSettingsHeaderSubtitle =>
      'Manage your profile, security, and app preferences.';

  @override
  String get employeeProfileSummarySubtitle =>
      'Keep your workspace profile updated.';

  @override
  String get employeeProfileUpdateShort => 'Update';

  @override
  String get employeeNoData => 'Not set';

  @override
  String get ownerCustomerBookingTileTitle => 'Customer booking';

  @override
  String get ownerCustomerBookingTileSubtitle =>
      'Control online booking, availability, and public visibility';

  @override
  String get ownerCustomerBookingTitle => 'Customer booking';

  @override
  String get ownerCustomerBookingSubtitle =>
      'Control how customers discover your salon, book online, and see availability.';

  @override
  String get ownerCustomerBookingSectionPublic => 'Public visibility';

  @override
  String get ownerCustomerBookingSectionPublicHint => 'Listing and discovery';

  @override
  String get ownerCustomerBookingShowSalon => 'Show salon to customers';

  @override
  String get ownerCustomerBookingShowSalonHint =>
      'If off, your salon will not appear in customer discovery.';

  @override
  String get ownerCustomerBookingSectionAvailability => 'Booking availability';

  @override
  String get ownerCustomerBookingEnableBooking => 'Enable customer booking';

  @override
  String get ownerCustomerBookingAutoConfirm => 'Auto-confirm bookings';

  @override
  String get ownerCustomerBookingAnySpecialist =>
      'Allow any available specialist';

  @override
  String get ownerCustomerBookingRequireCode =>
      'Require booking code for lookup';

  @override
  String get ownerCustomerBookingShowPrices => 'Show prices to customers';

  @override
  String get ownerCustomerBookingAllowNotes => 'Allow customer notes';

  @override
  String get ownerCustomerBookingAllowFeedback => 'Allow customer feedback';

  @override
  String get ownerCustomerBookingSectionRules => 'Booking rules';

  @override
  String get ownerCustomerBookingSlotInterval => 'Slot interval';

  @override
  String get ownerCustomerBookingMaxAdvance => 'Max advance booking days';

  @override
  String get ownerCustomerBookingCancelCutoff => 'Cancellation cutoff';

  @override
  String get ownerCustomerBookingRescheduleCutoff => 'Reschedule cutoff';

  @override
  String get ownerCustomerBookingSectionContact => 'Public contact info';

  @override
  String get ownerCustomerBookingPublicArea => 'Public area';

  @override
  String get ownerCustomerBookingPublicPhone => 'Public phone';

  @override
  String get ownerCustomerBookingPublicWhatsapp => 'Public WhatsApp';

  @override
  String get ownerCustomerBookingGenderTarget => 'Gender target';

  @override
  String get ownerCustomerBookingGenderMen => 'Men';

  @override
  String get ownerCustomerBookingGenderLadies => 'Ladies';

  @override
  String get ownerCustomerBookingGenderUnisex => 'Unisex';

  @override
  String get ownerCustomerBookingWorkingHours => 'Working hours';

  @override
  String get ownerCustomerBookingCopyMonday => 'Copy Monday to Tue–Thu';

  @override
  String get ownerCustomerBookingCloseAll => 'Close all';

  @override
  String get ownerCustomerBookingOpenAll => 'Open all';

  @override
  String get ownerCustomerBookingSave => 'Save settings';

  @override
  String get ownerCustomerBookingSaved => 'Customer booking settings saved';

  @override
  String get ownerCustomerBookingValidationTimeOrder =>
      'Start time must be before end time on open days.';

  @override
  String get ownerCustomerBookingValidationWorkingDay =>
      'At least one working day is required when booking is public.';

  @override
  String get ownerCustomerBookingPublicAreaRequired =>
      'Public area is required when the salon is public and booking is on.';

  @override
  String get ownerCustomerBookingValidationSlotInterval =>
      'Choose a valid slot interval (15, 20, 30, 45, or 60 minutes).';

  @override
  String get ownerCustomerBookingValidationMaxAdvance =>
      'Max advance days must be between 1 and 90.';

  @override
  String get ownerCustomerBookingValidationCutoff =>
      'Cutoff must be between 0 and 10080 minutes.';

  @override
  String get ownerCustomerBookingValidationPhone =>
      'Enter a valid phone number or leave the field empty.';

  @override
  String get ownerCustomerBookingDayOpen => 'Open';

  @override
  String get ownerCustomerBookingDayClosed => 'Closed';

  @override
  String get ownerCustomerBookingSettingsSubtitle =>
      'Control how customers can book appointments';

  @override
  String get ownerCustomerBookingStatusEnabled => 'Enabled';

  @override
  String get ownerCustomerBookingStatusDisabled => 'Disabled';

  @override
  String get ownerCustomerBookingSameDay => 'Allow same-day booking';

  @override
  String get ownerCustomerBookingRequirePhone => 'Require customer phone';

  @override
  String get ownerCustomerBookingRequireName => 'Require customer name';

  @override
  String get ownerCustomerBookingTimeRulesTitle => 'Time rules';

  @override
  String get ownerCustomerBookingMinNotice => 'Minimum notice before booking';

  @override
  String get ownerCustomerBookingMaxDaysAhead => 'Maximum days ahead';

  @override
  String get ownerCustomerBookingSlotDuration => 'Slot duration';

  @override
  String get ownerCustomerBookingBuffer => 'Buffer between bookings';

  @override
  String get ownerCustomerBookingCancellationTitle => 'Cancellation rules';

  @override
  String get ownerCustomerBookingAllowCancel => 'Allow customer cancellation';

  @override
  String get ownerCustomerBookingCancelNotice => 'Cancellation minimum notice';

  @override
  String get ownerCustomerBookingPublicMessageTitle => 'Public booking message';

  @override
  String get ownerCustomerBookingPublicMessageHint =>
      'Shown to customers when booking is open.';

  @override
  String get ownerCustomerBookingSaveCta => 'Save';

  @override
  String get ownerCustomerBookingSaveSuccess => 'Booking settings updated';

  @override
  String get ownerCustomerBookingSaveError => 'Could not save settings';

  @override
  String get ownerCustomerBookingLoadError => 'Could not load booking settings';

  @override
  String get ownerCustomerBookingValidationMinNotice =>
      'Minimum notice cannot be negative.';

  @override
  String get ownerCustomerBookingValidationMaxDays =>
      'Maximum days ahead must be greater than 0.';

  @override
  String get ownerCustomerBookingValidationSlot =>
      'Slot duration must be greater than 0.';

  @override
  String get ownerCustomerBookingValidationBuffer =>
      'Buffer cannot be negative.';

  @override
  String get ownerCustomerBookingValidationCancelHours =>
      'Cancellation notice must be greater than 0 when cancellation is allowed.';

  @override
  String get ownerCustomerBookingValidationMessage =>
      'Message cannot exceed 250 characters.';

  @override
  String ownerCustomerBookingMinutesShort(int n) {
    return '$n min';
  }

  @override
  String ownerCustomerBookingHoursShort(int n) {
    return '$n h';
  }

  @override
  String get ownerCustomerBookingMinutesDay => '24 h';

  @override
  String get customerBookingClosedTitle => 'Online booking is closed';

  @override
  String get customerBookingClosedMessage =>
      'This salon is not accepting new online bookings right now.';

  @override
  String get addSaleSelectAtLeastOneService =>
      'Select at least one service to continue.';

  @override
  String get addSaleSelectStaffMember =>
      'Pick the staff member who delivered this service.';

  @override
  String get addSaleTotalMustBePositive => 'Total must be greater than zero.';

  @override
  String get addSaleMixedPaymentMustEqualTotal =>
      'Cash + card must equal the total.';

  @override
  String get addSaleNoActiveServicesYet => 'No active services yet';

  @override
  String get addSaleCreateServicesFirst =>
      'Create services first to record sales.';

  @override
  String get addSaleUnableToLoadServices => 'Unable to load services';

  @override
  String get ownerShiftsTileTitle => 'Shifts & Staff Schedule';

  @override
  String get ownerShiftsTileSubtitle => 'Manage templates and weekly roster';

  @override
  String get ownerShiftsTitle => 'Shifts';

  @override
  String get ownerShiftsSubtitle => 'Create and manage shift templates';

  @override
  String get ownerShiftsRetry => 'Retry';

  @override
  String get ownerShiftsLoadError => 'Could not load shift templates';

  @override
  String get ownerShiftsSummaryTotalShifts => 'Total Shifts';

  @override
  String get ownerShiftsSummaryAssignedStaff => 'Assigned Staff';

  @override
  String get ownerShiftsSummaryOffDayRules => 'Off Days Rules';

  @override
  String get ownerShiftsSummaryTemplates => 'Templates';

  @override
  String get ownerShiftsSummaryEmployees => 'Employees';

  @override
  String get ownerShiftsSummaryRuleSet => 'Rule set';

  @override
  String get ownerShiftsTemplatesSectionTitle => 'Shift Templates';

  @override
  String get ownerShiftsEmptyStateTitle => 'No shift templates yet';

  @override
  String get ownerShiftsEmptyStateSubtitle =>
      'Create your first shift template to start weekly scheduling.';

  @override
  String get ownerShiftsEmptyStateHelper =>
      'Recommended: Day Shift, Night Shift, and Off Day.';

  @override
  String get ownerShiftsDuration => 'Duration';

  @override
  String get ownerShiftsBreak => 'Break';

  @override
  String get ownerShiftsEmployees => 'Employees';

  @override
  String get ownerShiftsOvernightBadge => 'Overnight';

  @override
  String get ownerShiftsOffDay => 'Off Day';

  @override
  String get ownerShiftsOpenWeeklyRosterTitle => 'Open weekly roster';

  @override
  String get ownerShiftsOpenWeeklyRosterSubtitle =>
      'View and manage staff shifts for the week';

  @override
  String get ownerShiftsCreateTemplateCta => 'Create Shift Template';

  @override
  String get ownerShiftsDeactivateError => 'Could not deactivate this shift';

  @override
  String get ownerShiftsDeleteConfirmMessage =>
      'Are you sure you want to delete this shift template?';

  @override
  String get ownerShiftsCreateTemplatePlaceholder =>
      'Create Shift Template screen coming next';

  @override
  String get ownerShiftsEditTemplatePlaceholder =>
      'Edit Shift Template screen coming next';

  @override
  String get ownerShiftsWeeklyPlaceholder => 'Weekly Shifts screen coming next';

  @override
  String get ownerShiftsApplyPlaceholder => 'Apply Schedule screen coming next';

  @override
  String get ownerShiftCreateTitle => 'Create Shift';

  @override
  String get ownerShiftEditTitle => 'Edit Shift';

  @override
  String get ownerShiftCreateSubtitle => 'Define working hours for employees';

  @override
  String get ownerShiftEditSubtitle => 'Update working hours for employees';

  @override
  String get ownerShiftNameLabel => 'Shift name';

  @override
  String get ownerShiftNameHint => 'Day Shift';

  @override
  String get ownerShiftTypeLabel => 'Shift type';

  @override
  String get ownerShiftTypeWorking => 'Working Shift';

  @override
  String get ownerShiftTypeOff => 'Off Day';

  @override
  String get ownerShiftStartTimeLabel => 'Start time';

  @override
  String get ownerShiftEndTimeLabel => 'End time';

  @override
  String get ownerShiftBreakMinutesLabel => 'Break allowance (minutes)';

  @override
  String get ownerShiftBreakMinutesHint => '30';

  @override
  String get ownerShiftNotesLabel => 'Notes (optional)';

  @override
  String get ownerShiftNotesHint => 'Add notes for this shift...';

  @override
  String get ownerShiftColorLabel => 'Color';

  @override
  String get ownerShiftDefaultLabel => 'Default shift';

  @override
  String get ownerShiftDefaultHint =>
      'New staff will use this shift by default.';

  @override
  String get ownerShiftCancelCta => 'Cancel';

  @override
  String get ownerShiftSaveCta => 'Save Shift';

  @override
  String get ownerShiftSaveSuccess => 'Shift saved successfully';

  @override
  String get ownerShiftSaveError => 'Could not save shift';

  @override
  String get ownerShiftPreviewTitleFallback => 'Shift Preview';

  @override
  String get ownerShiftValidationNameRequired => 'Shift name is required.';

  @override
  String get ownerShiftValidationNameLength =>
      'Shift name must be 30 characters or less.';

  @override
  String get ownerShiftValidationTimeRequired =>
      'Start and end time are required for working shifts.';

  @override
  String get ownerShiftValidationDurationPositive =>
      'Shift duration must be greater than zero.';

  @override
  String get ownerShiftValidationDurationMax =>
      'Shift duration must be 16 hours or less.';

  @override
  String get ownerShiftValidationBreakMin =>
      'Break minutes cannot be negative.';

  @override
  String get ownerShiftValidationBreakMax =>
      'Break minutes must be less than shift duration.';

  @override
  String get ownerShiftValidationDefaultRequired =>
      'At least one shift template must be set as default.';

  @override
  String get ownerWeeklyShiftsTitle => 'Weekly Shifts';

  @override
  String get ownerWeeklyShiftsSubtitle => 'Manage team schedule';

  @override
  String get ownerWeeklyShiftsThisWeek => 'This Week';

  @override
  String get ownerWeeklyShiftsNextWeek => 'Next Week';

  @override
  String get ownerWeeklyShiftsApplyToMonth => 'Apply to Month';

  @override
  String get ownerWeeklyShiftsTemplatesStripTitle => 'Drag a shift onto a day';

  @override
  String get ownerWeeklyShiftsDragStripBody => 'Drag a shift\nonto a day';

  @override
  String get ownerWeeklyShiftsTipCardBody =>
      'Tap a cell to mark off, assign a different shift, or remove the current assignment.';

  @override
  String get ownerShiftsTemplatesReorder => 'Reorder';

  @override
  String get ownerWeeklyShiftsNoTemplates => 'Create shift templates first';

  @override
  String get ownerWeeklyShiftsNoEmployees => 'Add employees first';

  @override
  String get ownerWeeklyShiftsLoadError =>
      'Could not load weekly schedule data';

  @override
  String get ownerWeeklyShiftsEmptyCell => '+';

  @override
  String get ownerWeeklyShiftsEmployeesHeader => 'Employees';

  @override
  String get ownerWeeklyShiftsMarkOffAction => 'Mark Off';

  @override
  String get ownerWeeklyShiftsRemoveAssignmentAction => 'Remove assignment';

  @override
  String get ownerWeeklyShiftsAssignAction => 'Assign';

  @override
  String get ownerApplyScheduleSectionTarget => 'Apply this plan to';

  @override
  String get ownerApplyScheduleTitle => 'Apply Schedule';

  @override
  String get ownerApplyScheduleSubtitle => 'Repeat this weekly plan';

  @override
  String get ownerApplyScheduleOptionThisWeek => 'This Week Only';

  @override
  String get ownerApplyScheduleOptionRemainingMonth =>
      'Remaining Weeks of This Month';

  @override
  String get ownerApplyScheduleOptionRemainingMonthSubtitle =>
      'Apply from this week to the end of the month';

  @override
  String get ownerApplyScheduleOptionCustomRange => 'Custom Date Range';

  @override
  String get ownerApplyScheduleSelectCustomRange =>
      'Select start and end dates';

  @override
  String get ownerApplyScheduleCalendarPreview => 'Calendar Preview';

  @override
  String get ownerApplyScheduleRepeatEveryWeek => 'Repeat every week';

  @override
  String get ownerApplyScheduleSkipExistingAssignments =>
      'Skip existing assignments';

  @override
  String get ownerApplyScheduleIncludeOffDays => 'Include off days';

  @override
  String get ownerApplyScheduleInfoCard =>
      'Applying this schedule will update employee roster for selected dates.';

  @override
  String get ownerApplyScheduleCta => 'Apply Schedule';

  @override
  String get ownerApplyScheduleSuccessTitle => 'Schedule applied successfully';

  @override
  String ownerApplyScheduleSuccessBody(int writes, int skipped) {
    return 'Created/updated $writes schedules. Skipped $skipped existing schedules.';
  }

  @override
  String get ownerApplyScheduleOk => 'OK';

  @override
  String ownerApplySchedulePreviewSummary(int assignments, int offDays) {
    return 'Assignments: $assignments • Off days: $offDays';
  }

  @override
  String get zuranoDiscoverGuestName => 'Guest';

  @override
  String get zuranoHomeHeadlineLine1 => 'Where self-care';

  @override
  String get zuranoHomeHeadlineLine2Prefix => 'meets ';

  @override
  String get zuranoHomeHeadlineHighlight => 'style';

  @override
  String get zuranoHomeLocationLoading => 'Finding location…';

  @override
  String get zuranoHomeLocationUnavailable => 'Location unavailable';

  @override
  String get zuranoHomeLocationNearYou => 'Near you';

  @override
  String zuranoHomeLocationCityCountry(String city, String country) {
    return '$city, $country';
  }

  @override
  String get zuranoDiscoverSomethingWrong => 'Something went wrong';

  @override
  String get zuranoDiscoverRecommendedTitle => 'Recommended for you';

  @override
  String get zuranoDiscoverSeeAll => 'See all';

  @override
  String get zuranoDiscoverExploreAll => 'Explore all';

  @override
  String get zuranoDiscoverFiltersLabel => 'Filters';

  @override
  String get zuranoDiscoverFiltersComingSoon =>
      'Saved filters arrive in a future update.';

  @override
  String get zuranoDiscoverSearchHint => 'Search salons, services, areas...';

  @override
  String get zuranoRewardsBannerTitle => 'Glow more, pay less ✨';

  @override
  String get zuranoRewardsBannerSubtitle =>
      'Earn points on every booking and unlock exclusive rewards.';

  @override
  String get zuranoRewardsBannerCta => 'View offers';

  @override
  String get zuranoTrendingServicesTitle => 'Services trending now';

  @override
  String get zuranoNearbyTitle => 'Nearby salons';

  @override
  String get zuranoNearbyViewMap => 'View map';

  @override
  String get zuranoNearbyMapSnack => 'Map view arrives in a future update.';

  @override
  String get zuranoNearbyBookNow => 'Book now';

  @override
  String zuranoNearbyLocationLineKm(String cityCountry, String kmFormatted) {
    return '$cityCountry • $kmFormatted km';
  }

  @override
  String zuranoNearbyKilometersOnly(String kmFormatted) {
    return '$kmFormatted km';
  }

  @override
  String zuranoNearbyLocationTwoParts(String first, String second) {
    return '$first • $second';
  }

  @override
  String get zuranoBottomNavHome => 'Home';

  @override
  String get zuranoBottomNavBookings => 'Bookings';

  @override
  String get zuranoBottomNavRewards => 'Rewards';

  @override
  String get zuranoBottomNavProfile => 'Profile';

  @override
  String get zuranoDiscoverFallbackCategoryAll => 'All';

  @override
  String get zuranoDiscoverFallbackCategoryHair => 'Hair';

  @override
  String get zuranoDiscoverFallbackCategoryNails => 'Nails';

  @override
  String get zuranoDiscoverFallbackCategoryBeauty => 'Beauty';

  @override
  String get zuranoDiscoverFallbackCategoryBarbers => 'Barbers';

  @override
  String get zuranoDiscoverFallbackCategorySpa => 'Spa';

  @override
  String get zuranoDiscoverFallbackCategoryMakeup => 'Makeup';

  @override
  String get zuranoDiscoverIndexBuildingMessage =>
      'We are preparing salon data. Please try again shortly.';

  @override
  String get zuranoDiscoverSectionLoadFailed =>
      'Unable to load this section. Please try again.';

  @override
  String get zuranoDiscoverRecommendedEmpty => 'No recommended salons yet';

  @override
  String get zuranoDiscoverTrendingServicesEmpty => 'No trending services yet';

  @override
  String zuranoDiscoverNearbyEmptyInCountry(String countryName) {
    return 'No salons available in $countryName yet';
  }

  @override
  String get estimatedPayout => 'Estimated payout';

  @override
  String get commission => 'Commission';

  @override
  String get services => 'Services';

  @override
  String get addBonus => 'Add bonus';

  @override
  String get addDeduction => 'Add deduction';

  @override
  String get generatePayslip => 'Generate payslip';

  @override
  String get reverseLastPayrollMonth => 'Reverse last payroll month';

  @override
  String get fixedCommissionAmount => 'Fixed commission amount';

  @override
  String get earningsBreakdown => 'Earnings breakdown';

  @override
  String get servicesRevenue => 'Services revenue';

  @override
  String get commissionToday => 'Commission today';

  @override
  String get commissionThisMonth => 'Commission this month';

  @override
  String get bonuses => 'Bonuses';

  @override
  String get deductions => 'Deductions';

  @override
  String get payrollFormula => 'Payroll formula';

  @override
  String get payrollHistory => 'Payroll history';

  @override
  String get noPayrollRecordsYet => 'No payroll records yet';

  @override
  String get generatedPayslipsWillAppearHere =>
      'Generated payslips will appear here.';

  @override
  String get generateFirstPayslip => 'Generate first payslip';

  @override
  String get payrollLocked => 'Payroll locked';

  @override
  String get payrollPaidLockedMessage =>
      'This payroll is already paid and can no longer be edited.';

  @override
  String get payrollPayslipGeneratedLockedMessage =>
      'A payslip was generated for this month. Use Reverse last payroll month to edit or delete adjustments, then regenerate if needed.';

  @override
  String get employeeInactivePayrollMessage =>
      'This employee is inactive/frozen, so payroll actions are disabled.';

  @override
  String get addPayrollAdjustment => 'Add payroll adjustment';

  @override
  String get amount => 'Amount';

  @override
  String get elementName => 'Element name';

  @override
  String get notRecurring => 'Not recurring';

  @override
  String get recurringOneYear => 'Recurring (until removed)';

  @override
  String get deletePayrollElementTitle => 'Delete payroll element?';

  @override
  String deletePayrollElementMessage(String name) {
    return 'Remove \"$name\" from payroll elements? Recurring items will stop for future months.';
  }

  @override
  String get keepElement => 'Keep';

  @override
  String get deleteElement => 'Delete';

  @override
  String get payrollElementDeleted => 'Payroll element deleted.';

  @override
  String get payrollAdjustmentDeleteNoneMatched =>
      'Could not remove that adjustment (nothing matched in the database). Pull to refresh and try again.';

  @override
  String get reverseLastPayrollMonthTitle => 'Reverse last payroll month?';

  @override
  String get reverseLastPayrollMonthMessage =>
      'This will mark the latest payroll month as reversed. You can regenerate it if needed.';

  @override
  String get reversePayrollMonthSuccess =>
      'Last payroll month reversed successfully.';

  @override
  String get reason => 'Reason';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get save => 'Save';

  @override
  String get bonusAddedSuccessfully => 'Bonus added successfully.';

  @override
  String get deductionAddedSuccessfully => 'Deduction added successfully.';

  @override
  String get payslipGeneratedSuccessfully => 'Payslip generated successfully.';

  @override
  String get payrollLoadFailed => 'Failed to load payroll.';

  @override
  String get payrollHistoryLoadFailed => 'Failed to load payroll history.';

  @override
  String get retry => 'Retry';

  @override
  String get updatePayrollAdjustment => 'Update payroll adjustment';

  @override
  String get payrollElementUpdated => 'Payroll element updated.';

  @override
  String get update => 'Update';
}
