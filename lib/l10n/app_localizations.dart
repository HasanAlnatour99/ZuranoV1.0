import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zurano'**
  String get appTitle;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Barber Shop'**
  String get splashTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Crafted cuts. Calm bookings.'**
  String get splashTagline;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericError;

  /// No description provided for @loadingPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get loadingPlaceholder;

  /// No description provided for @customerDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get customerDiscoverTitle;

  /// No description provided for @customerHomeMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get customerHomeMenuTooltip;

  /// No description provided for @customerHomeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No salons to show'**
  String get customerHomeEmptyTitle;

  /// No description provided for @customerHomeResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset search'**
  String get customerHomeResetFilters;

  /// No description provided for @customerSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get customerSignOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to use your account.'**
  String get signOutSubtitle;

  /// No description provided for @customerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search salons, areas…'**
  String get customerSearchHint;

  /// No description provided for @customerGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String customerGreeting(String name);

  /// No description provided for @customerGuestName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get customerGuestName;

  /// No description provided for @customerNoSalons.
  ///
  /// In en, this message translates to:
  /// **'No salons match your search.'**
  String get customerNoSalons;

  /// No description provided for @customerSalonDetails.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get customerSalonDetails;

  /// No description provided for @customerBook.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get customerBook;

  /// No description provided for @customerServicesPreview.
  ///
  /// In en, this message translates to:
  /// **'Popular services'**
  String get customerServicesPreview;

  /// No description provided for @customerNoServicesListed.
  ///
  /// In en, this message translates to:
  /// **'No services listed yet.'**
  String get customerNoServicesListed;

  /// No description provided for @customerServiceMeta.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {price}'**
  String customerServiceMeta(int minutes, String price);

  /// No description provided for @customerSalonNotFound.
  ///
  /// In en, this message translates to:
  /// **'This salon is no longer available.'**
  String get customerSalonNotFound;

  /// No description provided for @customerBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get customerBookAppointment;

  /// No description provided for @customerSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get customerSelectDate;

  /// No description provided for @customerSelectService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get customerSelectService;

  /// No description provided for @customerSelectBarber.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get customerSelectBarber;

  /// No description provided for @customerSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get customerSelectTime;

  /// No description provided for @customerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get customerNotes;

  /// No description provided for @customerConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get customerConfirmBooking;

  /// No description provided for @customerBookingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'You are booked'**
  String get customerBookingSubmitted;

  /// No description provided for @customerBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get customerBackHome;

  /// No description provided for @bookingConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get bookingConfirmationTitle;

  /// No description provided for @bookingWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get bookingWhen;

  /// No description provided for @bookingBarber.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get bookingBarber;

  /// No description provided for @bookingService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bookingService;

  /// No description provided for @bookingSalon.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get bookingSalon;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get bookingReference;

  /// No description provided for @bookingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Booking not found.'**
  String get bookingNotFound;

  /// No description provided for @customerNoBarbers.
  ///
  /// In en, this message translates to:
  /// **'No team members available yet.'**
  String get customerNoBarbers;

  /// No description provided for @customerNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No open slots for this day. Try another date or team member.'**
  String get customerNoSlots;

  /// No description provided for @customerBookingIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Choose a service, team member, and time.'**
  String get customerBookingIncomplete;

  /// No description provided for @customerBookingSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to complete your booking.'**
  String get customerBookingSignInRequired;

  /// No description provided for @customerBookingSlotTaken.
  ///
  /// In en, this message translates to:
  /// **'That time was just taken. Choose another slot.'**
  String get customerBookingSlotTaken;

  /// No description provided for @customerBookingSlotInvalid.
  ///
  /// In en, this message translates to:
  /// **'That time is not available. Pick a different slot.'**
  String get customerBookingSlotInvalid;

  /// No description provided for @customerBookingNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Notes cannot exceed {maxChars} characters.'**
  String customerBookingNotesTooLong(int maxChars);

  /// No description provided for @customerBookingScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a date, service, team member, and time. Smart picks below can fill team member and slot for you.'**
  String get customerBookingScreenHint;

  /// No description provided for @customerBookingSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your visit'**
  String get customerBookingSummaryTitle;

  /// No description provided for @ownerTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get ownerTabOverview;

  /// No description provided for @ownerTabTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get ownerTabTeam;

  /// No description provided for @ownerTabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get ownerTabServices;

  /// No description provided for @ownerTabBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get ownerTabBookings;

  /// No description provided for @ownerTabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get ownerTabMoney;

  /// No description provided for @ownerWorkspaceWide.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workspace'**
  String get ownerWorkspaceWide;

  /// No description provided for @ownerWorkspaceNarrow.
  ///
  /// In en, this message translates to:
  /// **'Today\'s overview'**
  String get ownerWorkspaceNarrow;

  /// No description provided for @ownerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your workspace. Please sign in again.'**
  String get ownerLoadError;

  /// No description provided for @ownerSalonChip.
  ///
  /// In en, this message translates to:
  /// **'Salon · {id}'**
  String ownerSalonChip(String id);

  /// No description provided for @ownerSalonSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your salon details'**
  String get ownerSalonSetupTitle;

  /// No description provided for @ownerSalonSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose your salon name and city to start managing bookings and your team.'**
  String get ownerSalonSetupMessage;

  /// No description provided for @ownerSalonSetupCta.
  ///
  /// In en, this message translates to:
  /// **'Set up salon'**
  String get ownerSalonSetupCta;

  /// No description provided for @ownerSales7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get ownerSales7;

  /// No description provided for @ownerSales30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get ownerSales30;

  /// No description provided for @ownerSalesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ownerSalesAll;

  /// No description provided for @ownerOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today at a glance'**
  String get ownerOverviewTitle;

  /// No description provided for @ownerOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live totals from your salon.'**
  String get ownerOverviewSubtitle;

  /// No description provided for @ownerOverviewQuickService.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get ownerOverviewQuickService;

  /// No description provided for @ownerOverviewQuickBooking.
  ///
  /// In en, this message translates to:
  /// **'Add booking'**
  String get ownerOverviewQuickBooking;

  /// No description provided for @ownerOverviewQuickBarber.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get ownerOverviewQuickBarber;

  /// No description provided for @ownerOverviewEmptyRevenueToday.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded today.'**
  String get ownerOverviewEmptyRevenueToday;

  /// No description provided for @ownerOverviewEmptyBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'No bookings scheduled for today.'**
  String get ownerOverviewEmptyBookingsToday;

  /// No description provided for @ownerOverviewEmptyTopBarberMonth.
  ///
  /// In en, this message translates to:
  /// **'No team member sales yet this month.'**
  String get ownerOverviewEmptyTopBarberMonth;

  /// No description provided for @ownerOverviewEmptyTopServiceMonth.
  ///
  /// In en, this message translates to:
  /// **'No service usage yet this month.'**
  String get ownerOverviewEmptyTopServiceMonth;

  /// No description provided for @ownerOverviewLoadingMetrics.
  ///
  /// In en, this message translates to:
  /// **'Loading your metrics…'**
  String get ownerOverviewLoadingMetrics;

  /// No description provided for @ownerOverviewTotalRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get ownerOverviewTotalRevenueLabel;

  /// No description provided for @ownerOverviewTotalRevenuePeriod.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get ownerOverviewTotalRevenuePeriod;

  /// No description provided for @ownerOverviewTotalRevenueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed sales yet this month.'**
  String get ownerOverviewTotalRevenueEmpty;

  /// No description provided for @ownerOverviewServicesPanelCaption.
  ///
  /// In en, this message translates to:
  /// **'Prices & durations'**
  String get ownerOverviewServicesPanelCaption;

  /// No description provided for @ownerServicesCategoryBanner.
  ///
  /// In en, this message translates to:
  /// **'{category} — prices & durations'**
  String ownerServicesCategoryBanner(String category);

  /// No description provided for @ownerServicesCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get ownerServicesCategoryAll;

  /// No description provided for @ownerOverviewTeamColumnMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get ownerOverviewTeamColumnMember;

  /// No description provided for @ownerOverviewTeamColumnRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get ownerOverviewTeamColumnRole;

  /// No description provided for @ownerOverviewTeamColumnEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get ownerOverviewTeamColumnEmail;

  /// No description provided for @ownerOverviewServiceUses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 use} other{{count} uses}}'**
  String ownerOverviewServiceUses(int count);

  /// No description provided for @ownerStatTodayBookings.
  ///
  /// In en, this message translates to:
  /// **'Today’s bookings'**
  String get ownerStatTodayBookings;

  /// No description provided for @ownerStatRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue (window)'**
  String get ownerStatRevenue;

  /// No description provided for @ownerStatUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get ownerStatUpcoming;

  /// No description provided for @ownerNoBookingsStat.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get ownerNoBookingsStat;

  /// No description provided for @ownerBookingsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get ownerBookingsListTitle;

  /// No description provided for @ownerBookingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ownerBookingCancel;

  /// No description provided for @ownerBookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get ownerBookingCancelled;

  /// No description provided for @ownerFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ownerFilterStatus;

  /// No description provided for @ownerFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ownerFilterAll;

  /// No description provided for @ownerTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get ownerTeamTitle;

  /// No description provided for @ownerTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage team members and admins.'**
  String get ownerTeamSubtitle;

  /// No description provided for @ownerTeamCardRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get ownerTeamCardRoleLabel;

  /// No description provided for @ownerTeamCardStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ownerTeamCardStatusLabel;

  /// No description provided for @ownerTeamCardStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ownerTeamCardStatusActive;

  /// No description provided for @ownerTeamCardStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get ownerTeamCardStatusInactive;

  /// No description provided for @ownerTeamCardManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get ownerTeamCardManage;

  /// No description provided for @ownerAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get ownerAddMember;

  /// No description provided for @ownerEmployeeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get ownerEmployeeName;

  /// No description provided for @ownerEmployeeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get ownerEmployeeEmail;

  /// No description provided for @ownerEmployeeRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get ownerEmployeeRole;

  /// No description provided for @ownerEmployeePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get ownerEmployeePhone;

  /// No description provided for @ownerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ownerSave;

  /// No description provided for @ownerEditMember.
  ///
  /// In en, this message translates to:
  /// **'Edit member'**
  String get ownerEditMember;

  /// No description provided for @ownerDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get ownerDeactivate;

  /// No description provided for @ownerActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get ownerActivate;

  /// No description provided for @ownerServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get ownerServicesTitle;

  /// No description provided for @ownerServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage what customers can book and buy'**
  String get ownerServicesSubtitle;

  /// No description provided for @ownerServicesSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get ownerServicesSearchPlaceholder;

  /// No description provided for @ownerServicesStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ownerServicesStatTotal;

  /// No description provided for @ownerServicesStatActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ownerServicesStatActive;

  /// No description provided for @ownerServicesStatInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get ownerServicesStatInactive;

  /// No description provided for @ownerServicesChipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ownerServicesChipAll;

  /// No description provided for @ownerServicesChipHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get ownerServicesChipHair;

  /// No description provided for @ownerServicesChipBeard.
  ///
  /// In en, this message translates to:
  /// **'Beard'**
  String get ownerServicesChipBeard;

  /// No description provided for @ownerServicesChipFacial.
  ///
  /// In en, this message translates to:
  /// **'Facial'**
  String get ownerServicesChipFacial;

  /// No description provided for @ownerServicesChipPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get ownerServicesChipPackages;

  /// No description provided for @ownerServicesChipColoring.
  ///
  /// In en, this message translates to:
  /// **'Coloring'**
  String get ownerServicesChipColoring;

  /// No description provided for @ownerServiceCategoryHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get ownerServiceCategoryHair;

  /// No description provided for @ownerServiceCategoryBarberBeard.
  ///
  /// In en, this message translates to:
  /// **'Barber / Beard'**
  String get ownerServiceCategoryBarberBeard;

  /// No description provided for @ownerServiceCategoryNails.
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get ownerServiceCategoryNails;

  /// No description provided for @ownerServiceCategoryHairRemovalWaxing.
  ///
  /// In en, this message translates to:
  /// **'Hair Removal / Waxing'**
  String get ownerServiceCategoryHairRemovalWaxing;

  /// No description provided for @ownerServiceCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ownerServiceCategoryOther;

  /// No description provided for @ownerServiceCategoryBrowsLashes.
  ///
  /// In en, this message translates to:
  /// **'Brows & Lashes'**
  String get ownerServiceCategoryBrowsLashes;

  /// No description provided for @ownerServiceCategoryFacialSkincare.
  ///
  /// In en, this message translates to:
  /// **'Facial / Skincare'**
  String get ownerServiceCategoryFacialSkincare;

  /// No description provided for @ownerServiceCategoryMakeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup'**
  String get ownerServiceCategoryMakeup;

  /// No description provided for @ownerServiceCategoryMassageSpa.
  ///
  /// In en, this message translates to:
  /// **'Massage / Spa'**
  String get ownerServiceCategoryMassageSpa;

  /// No description provided for @ownerServiceCategoryPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get ownerServiceCategoryPackages;

  /// No description provided for @ownerServiceCategoryColoring.
  ///
  /// In en, this message translates to:
  /// **'Coloring'**
  String get ownerServiceCategoryColoring;

  /// No description provided for @ownerServiceCategoryTexturedHair.
  ///
  /// In en, this message translates to:
  /// **'Textured Hair'**
  String get ownerServiceCategoryTexturedHair;

  /// No description provided for @ownerServiceCategoryBridal.
  ///
  /// In en, this message translates to:
  /// **'Bridal'**
  String get ownerServiceCategoryBridal;

  /// No description provided for @ownerServiceCategoryTanning.
  ///
  /// In en, this message translates to:
  /// **'Tanning'**
  String get ownerServiceCategoryTanning;

  /// No description provided for @ownerServiceCategoryMedSpa.
  ///
  /// In en, this message translates to:
  /// **'Med Spa'**
  String get ownerServiceCategoryMedSpa;

  /// No description provided for @ownerServiceCategoryMenGrooming.
  ///
  /// In en, this message translates to:
  /// **'Men Grooming'**
  String get ownerServiceCategoryMenGrooming;

  /// No description provided for @ownerServiceCategoryHaircutStyling.
  ///
  /// In en, this message translates to:
  /// **'Haircut & Styling'**
  String get ownerServiceCategoryHaircutStyling;

  /// No description provided for @ownerServiceCategoryHairTreatments.
  ///
  /// In en, this message translates to:
  /// **'Hair Treatments'**
  String get ownerServiceCategoryHairTreatments;

  /// No description provided for @ownerServiceCategoryScalpTreatments.
  ///
  /// In en, this message translates to:
  /// **'Scalp Treatments'**
  String get ownerServiceCategoryScalpTreatments;

  /// No description provided for @ownerServiceCategoryKeratinSmoothing.
  ///
  /// In en, this message translates to:
  /// **'Keratin / Smoothing'**
  String get ownerServiceCategoryKeratinSmoothing;

  /// No description provided for @ownerServiceCategoryHairExtensions.
  ///
  /// In en, this message translates to:
  /// **'Hair Extensions'**
  String get ownerServiceCategoryHairExtensions;

  /// No description provided for @ownerServiceCategoryKidsServices.
  ///
  /// In en, this message translates to:
  /// **'Kids Services'**
  String get ownerServiceCategoryKidsServices;

  /// No description provided for @ownerServiceCategoryManicurePedicure.
  ///
  /// In en, this message translates to:
  /// **'Manicure / Pedicure'**
  String get ownerServiceCategoryManicurePedicure;

  /// No description provided for @ownerServiceCategoryNailArt.
  ///
  /// In en, this message translates to:
  /// **'Nail Art'**
  String get ownerServiceCategoryNailArt;

  /// No description provided for @ownerServiceCategoryThreading.
  ///
  /// In en, this message translates to:
  /// **'Threading'**
  String get ownerServiceCategoryThreading;

  /// No description provided for @ownerServiceCategoryLashExtensions.
  ///
  /// In en, this message translates to:
  /// **'Lash Extensions'**
  String get ownerServiceCategoryLashExtensions;

  /// No description provided for @ownerServiceCategoryBodyTreatments.
  ///
  /// In en, this message translates to:
  /// **'Body Treatments'**
  String get ownerServiceCategoryBodyTreatments;

  /// No description provided for @ownerServiceCategoryMakeupPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent Makeup'**
  String get ownerServiceCategoryMakeupPermanent;

  /// No description provided for @ownerServiceCustomCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get ownerServiceCustomCategoryLabel;

  /// No description provided for @ownerServiceValidationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get ownerServiceValidationCategoryRequired;

  /// No description provided for @ownerServiceValidationCustomCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name.'**
  String get ownerServiceValidationCustomCategoryRequired;

  /// No description provided for @ownerServiceValidationDuplicateCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'You already use this custom category name.'**
  String get ownerServiceValidationDuplicateCustomCategory;

  /// No description provided for @ownerServiceCategoriesMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get ownerServiceCategoriesMore;

  /// No description provided for @ownerServiceCategoriesMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'More categories'**
  String get ownerServiceCategoriesMoreTitle;

  /// No description provided for @ownerServiceCategoryAllOther.
  ///
  /// In en, this message translates to:
  /// **'All in Other'**
  String get ownerServiceCategoryAllOther;

  /// No description provided for @ownerServicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get ownerServicesEmptyTitle;

  /// No description provided for @ownerServicesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first service to let customers discover and book your offerings.'**
  String get ownerServicesEmptyDescription;

  /// No description provided for @ownerServicesNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No services match your search or filters.'**
  String get ownerServicesNoMatches;

  /// No description provided for @ownerServicesFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get ownerServicesFabTooltip;

  /// No description provided for @ownerServiceSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save Service'**
  String get ownerServiceSaveCta;

  /// No description provided for @ownerServiceSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service saved.'**
  String get ownerServiceSavedSuccess;

  /// No description provided for @ownerServiceDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service removed.'**
  String get ownerServiceDeletedSuccess;

  /// No description provided for @ownerServiceValidationDurationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a duration greater than zero.'**
  String get ownerServiceValidationDurationInvalid;

  /// No description provided for @ownerServiceValidationPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a price greater than zero.'**
  String get ownerServiceValidationPriceInvalid;

  /// No description provided for @ownerServiceDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete service?'**
  String get ownerServiceDeleteConfirmTitle;

  /// No description provided for @ownerServiceDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the service from your catalog. This cannot be undone.'**
  String get ownerServiceDeleteConfirmBody;

  /// No description provided for @ownerServiceActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ownerServiceActionCancel;

  /// No description provided for @ownerServiceActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ownerServiceActionDelete;

  /// No description provided for @ownerServiceActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get ownerServiceActionEdit;

  /// No description provided for @ownerServiceStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ownerServiceStatusActive;

  /// No description provided for @ownerServiceStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get ownerServiceStatusInactive;

  /// No description provided for @ownerServiceTimesUsed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Used {count} time} other{Used {count} times}}'**
  String ownerServiceTimesUsed(int count);

  /// No description provided for @ownerServiceTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue {amount}'**
  String ownerServiceTotalRevenue(String amount);

  /// No description provided for @ownerServiceAnalyticsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Usage & revenue will appear as you sell.'**
  String get ownerServiceAnalyticsPlaceholder;

  /// No description provided for @ownerServiceFormImageUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Image URL (optional)'**
  String get ownerServiceFormImageUrlHint;

  /// No description provided for @ownerServicePhotoSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Service photo'**
  String get ownerServicePhotoSectionLabel;

  /// No description provided for @ownerServiceUploadPhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get ownerServiceUploadPhotoAction;

  /// No description provided for @ownerServicePhotoChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get ownerServicePhotoChooseGallery;

  /// No description provided for @ownerServicePhotoChooseCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get ownerServicePhotoChooseCamera;

  /// No description provided for @ownerServicePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get ownerServicePhotoRemove;

  /// No description provided for @ownerServicePhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get ownerServicePhotoUploading;

  /// No description provided for @ownerServicePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Choose an image under 5 MB.'**
  String get ownerServicePhotoTooLarge;

  /// No description provided for @ownerServicePhotoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t upload the image. Try again.'**
  String get ownerServicePhotoUploadError;

  /// No description provided for @ownerServiceFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get ownerServiceFormDescriptionHint;

  /// No description provided for @ownerServiceCategoryPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ownerServiceCategoryPickerLabel;

  /// No description provided for @ownerServiceCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get ownerServiceCategoryNone;

  /// No description provided for @ownerAddService.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get ownerAddService;

  /// No description provided for @ownerEditService.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get ownerEditService;

  /// No description provided for @ownerServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service name'**
  String get ownerServiceName;

  /// No description provided for @ownerAddServiceSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a bookable service for your customers'**
  String get ownerAddServiceSheetSubtitle;

  /// No description provided for @ownerServiceSectionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service details'**
  String get ownerServiceSectionDetailsTitle;

  /// No description provided for @ownerServiceSectionDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basic information about your service'**
  String get ownerServiceSectionDetailsSubtitle;

  /// No description provided for @ownerServiceSectionDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Duration & pricing'**
  String get ownerServiceSectionDurationTitle;

  /// No description provided for @ownerServiceSectionDurationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set how long it takes and how much it costs'**
  String get ownerServiceSectionDurationSubtitle;

  /// No description provided for @ownerServiceSectionPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a photo to showcase your service'**
  String get ownerServiceSectionPhotoSubtitle;

  /// No description provided for @ownerServiceSectionDescriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add more details about this service'**
  String get ownerServiceSectionDescriptionSubtitle;

  /// No description provided for @ownerServiceActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show this service to customers'**
  String get ownerServiceActiveSubtitle;

  /// No description provided for @ownerServiceNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Classic Haircut'**
  String get ownerServiceNamePlaceholder;

  /// No description provided for @ownerServiceDescriptionPlaceholderLong.
  ///
  /// In en, this message translates to:
  /// **'Describe your service, what\'s included, benefits, etc.'**
  String get ownerServiceDescriptionPlaceholderLong;

  /// No description provided for @ownerServicePhotoFormatsHint.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG up to 5MB'**
  String get ownerServicePhotoFormatsHint;

  /// No description provided for @ownerServicePhotoSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended size: 1200x800px'**
  String get ownerServicePhotoSizeHint;

  /// No description provided for @ownerServiceSuffixMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get ownerServiceSuffixMin;

  /// No description provided for @ownerServiceDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get ownerServiceDuration;

  /// No description provided for @ownerServicePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get ownerServicePrice;

  /// No description provided for @ownerDeleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ownerDeleteService;

  /// No description provided for @ownerMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get ownerMoneyTitle;

  /// No description provided for @ownerMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales, payroll, and expenses.'**
  String get ownerMoneySubtitle;

  /// No description provided for @ownerKpiNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get ownerKpiNone;

  /// No description provided for @ownerKpiTodayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue'**
  String get ownerKpiTodayRevenue;

  /// No description provided for @ownerKpiMonthRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get ownerKpiMonthRevenue;

  /// No description provided for @ownerKpiBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'Bookings today'**
  String get ownerKpiBookingsToday;

  /// No description provided for @ownerKpiEmployees.
  ///
  /// In en, this message translates to:
  /// **'Active employees'**
  String get ownerKpiEmployees;

  /// No description provided for @ownerKpiTopBarber.
  ///
  /// In en, this message translates to:
  /// **'Top barber (month)'**
  String get ownerKpiTopBarber;

  /// No description provided for @ownerKpiTopService.
  ///
  /// In en, this message translates to:
  /// **'Top service (month)'**
  String get ownerKpiTopService;

  /// No description provided for @ownerKpiCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get ownerKpiCompletedToday;

  /// No description provided for @ownerKpiCancelledToday.
  ///
  /// In en, this message translates to:
  /// **'Cancelled today'**
  String get ownerKpiCancelledToday;

  /// No description provided for @ownerKpiRescheduledToday.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled today'**
  String get ownerKpiRescheduledToday;

  /// No description provided for @ownerKpiCompletionRateMonth.
  ///
  /// In en, this message translates to:
  /// **'Completion rate (month)'**
  String get ownerKpiCompletionRateMonth;

  /// No description provided for @ownerKpiCancellationRateMonth.
  ///
  /// In en, this message translates to:
  /// **'Cancellation rate (month)'**
  String get ownerKpiCancellationRateMonth;

  /// No description provided for @ownerKpiTopBarberCompletionsMonth.
  ///
  /// In en, this message translates to:
  /// **'Top barber · completions (month)'**
  String get ownerKpiTopBarberCompletionsMonth;

  /// No description provided for @ownerMoneyRecognitionOperational.
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get ownerMoneyRecognitionOperational;

  /// No description provided for @ownerMoneyRecognitionCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get ownerMoneyRecognitionCash;

  /// No description provided for @ownerMoneySalesMonth.
  ///
  /// In en, this message translates to:
  /// **'Sales (this month)'**
  String get ownerMoneySalesMonth;

  /// No description provided for @ownerMoneyPayrollSection.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get ownerMoneyPayrollSection;

  /// No description provided for @ownerMoneyExpensesSection.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get ownerMoneyExpensesSection;

  /// No description provided for @ownerMoneyEmptyPayroll.
  ///
  /// In en, this message translates to:
  /// **'No payroll runs yet.'**
  String get ownerMoneyEmptyPayroll;

  /// No description provided for @ownerMoneyEmptyExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet.'**
  String get ownerMoneyEmptyExpenses;

  /// No description provided for @ownerMoneyPayrollEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payroll'**
  String get ownerMoneyPayrollEmptyTitle;

  /// No description provided for @ownerMoneyExpensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses'**
  String get ownerMoneyExpensesEmptyTitle;

  /// No description provided for @ownerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get ownerDashboardTitle;

  /// No description provided for @ownerAiAssistantTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard assistant'**
  String get ownerAiAssistantTooltip;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant'**
  String get aiAssistantInputLabel;

  /// No description provided for @aiAssistantInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for today revenue, monthly revenue, or top barbers.'**
  String get aiAssistantInputHint;

  /// No description provided for @aiAssistantSend.
  ///
  /// In en, this message translates to:
  /// **'Generate view'**
  String get aiAssistantSend;

  /// No description provided for @aiAssistantWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for an owner snapshot'**
  String get aiAssistantWelcomeTitle;

  /// No description provided for @aiAssistantWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Use natural prompts to generate a focused revenue and team summary for your salon.'**
  String get aiAssistantWelcomeMessage;

  /// No description provided for @aiAssistantLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Building your dashboard view'**
  String get aiAssistantLoadingTitle;

  /// No description provided for @aiAssistantLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'The assistant is calling approved tools and preparing a compact surface.'**
  String get aiAssistantLoadingMessage;

  /// No description provided for @aiAssistantErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant unavailable'**
  String get aiAssistantErrorTitle;

  /// No description provided for @aiAssistantErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The assistant could not build a surface right now. Try again in a moment.'**
  String get aiAssistantErrorMessage;

  /// No description provided for @aiAssistantRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get aiAssistantRetry;

  /// No description provided for @aiAssistantSalonRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon required'**
  String get aiAssistantSalonRequiredTitle;

  /// No description provided for @aiAssistantSalonRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This assistant needs a valid salon before it can load owner insights.'**
  String get aiAssistantSalonRequiredMessage;

  /// No description provided for @aiAssistantSuggestionTodayRevenue.
  ///
  /// In en, this message translates to:
  /// **'show today revenue'**
  String get aiAssistantSuggestionTodayRevenue;

  /// No description provided for @aiAssistantSuggestionMonthRevenue.
  ///
  /// In en, this message translates to:
  /// **'show this month revenue'**
  String get aiAssistantSuggestionMonthRevenue;

  /// No description provided for @aiAssistantSuggestionTopBarbers.
  ///
  /// In en, this message translates to:
  /// **'show top barbers this month'**
  String get aiAssistantSuggestionTopBarbers;

  /// No description provided for @smartWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart workspace'**
  String get smartWorkspaceTitle;

  /// No description provided for @smartWorkspaceLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your workspace'**
  String get smartWorkspaceLoadingTitle;

  /// No description provided for @smartWorkspaceLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading the right payroll, analytics, or attendance assistant view.'**
  String get smartWorkspaceLoadingMessage;

  /// No description provided for @smartWorkspaceErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart workspace unavailable'**
  String get smartWorkspaceErrorTitle;

  /// No description provided for @smartWorkspaceErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The workspace could not load right now. Try again in a moment.'**
  String get smartWorkspaceErrorMessage;

  /// No description provided for @smartWorkspaceRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get smartWorkspaceRetryAction;

  /// No description provided for @smartWorkspaceSalonRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon required'**
  String get smartWorkspaceSalonRequiredTitle;

  /// No description provided for @smartWorkspaceSalonRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This workspace needs a valid salon before it can load assistant tools.'**
  String get smartWorkspaceSalonRequiredMessage;

  /// No description provided for @smartWorkspaceWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for a guided workspace'**
  String get smartWorkspaceWelcomeTitle;

  /// No description provided for @smartWorkspaceWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this assistant for payroll setup, payroll explanations, analytics summaries, and attendance corrections while keeping the business logic deterministic.'**
  String get smartWorkspaceWelcomeMessage;

  /// No description provided for @smartWorkspaceInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask smart workspace'**
  String get smartWorkspaceInputLabel;

  /// No description provided for @smartWorkspaceInputHint.
  ///
  /// In en, this message translates to:
  /// **'Try: set up payroll for Ahmed, explain Sara\'s payroll, or show payroll and expense summary for this month.'**
  String get smartWorkspaceInputHint;

  /// No description provided for @smartWorkspaceSendAction.
  ///
  /// In en, this message translates to:
  /// **'Open workspace'**
  String get smartWorkspaceSendAction;

  /// No description provided for @smartWorkspaceUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a guided assistant flow'**
  String get smartWorkspaceUnknownTitle;

  /// No description provided for @smartWorkspaceUnknownSummary.
  ///
  /// In en, this message translates to:
  /// **'The assistant only supports approved workspace flows.'**
  String get smartWorkspaceUnknownSummary;

  /// No description provided for @smartWorkspaceUnknownMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask for payroll setup, payroll explanation, analytics, or attendance correction to continue.'**
  String get smartWorkspaceUnknownMessage;

  /// No description provided for @smartWorkspaceSuggestionPayrollSetup.
  ///
  /// In en, this message translates to:
  /// **'set up payroll for this month'**
  String get smartWorkspaceSuggestionPayrollSetup;

  /// No description provided for @smartWorkspaceSuggestionPayrollExplain.
  ///
  /// In en, this message translates to:
  /// **'explain this month\'s payroll for Ahmed'**
  String get smartWorkspaceSuggestionPayrollExplain;

  /// No description provided for @smartWorkspaceSuggestionAnalytics.
  ///
  /// In en, this message translates to:
  /// **'show payroll, revenue, and expenses this month'**
  String get smartWorkspaceSuggestionAnalytics;

  /// No description provided for @smartWorkspaceSuggestionAttendance.
  ///
  /// In en, this message translates to:
  /// **'fix attendance for today\'s late barber'**
  String get smartWorkspaceSuggestionAttendance;

  /// No description provided for @smartWorkspacePayrollSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll setup assistant'**
  String get smartWorkspacePayrollSetupTitle;

  /// No description provided for @smartWorkspacePayrollSetupSummary.
  ///
  /// In en, this message translates to:
  /// **'Review who is ready for payroll and jump into the right setup screen.'**
  String get smartWorkspacePayrollSetupSummary;

  /// No description provided for @smartWorkspacePayrollSetupMissingEmployees.
  ///
  /// In en, this message translates to:
  /// **'Missing basic salary setup'**
  String get smartWorkspacePayrollSetupMissingEmployees;

  /// No description provided for @smartWorkspacePayrollSetupActiveElements.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 active payroll element available} other{{count} active payroll elements available}}'**
  String smartWorkspacePayrollSetupActiveElements(int count);

  /// No description provided for @smartWorkspacePayrollSetupEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active payroll entries} one{1 active payroll entry} other{{count} active payroll entries}}'**
  String smartWorkspacePayrollSetupEntriesCount(int count);

  /// No description provided for @smartWorkspacePayrollSetupPickEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a team member'**
  String get smartWorkspacePayrollSetupPickEmployeeTitle;

  /// No description provided for @smartWorkspacePayrollSetupPickEmployeeMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose an employee to review their payroll entries and salary setup.'**
  String get smartWorkspacePayrollSetupPickEmployeeMessage;

  /// No description provided for @smartWorkspaceEmployeePickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get smartWorkspaceEmployeePickerLabel;

  /// No description provided for @smartWorkspacePeriodSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Payroll period'**
  String get smartWorkspacePeriodSelectorLabel;

  /// No description provided for @smartWorkspacePeriodPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a month'**
  String get smartWorkspacePeriodPlaceholder;

  /// No description provided for @smartWorkspaceDateRangePickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get smartWorkspaceDateRangePickerLabel;

  /// No description provided for @smartWorkspaceDateRangePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a date range'**
  String get smartWorkspaceDateRangePlaceholder;

  /// No description provided for @smartWorkspaceOpenEmployeeSetup.
  ///
  /// In en, this message translates to:
  /// **'Open employee setup'**
  String get smartWorkspaceOpenEmployeeSetup;

  /// No description provided for @smartWorkspaceOpenPayrollRunReview.
  ///
  /// In en, this message translates to:
  /// **'Open payroll run review'**
  String get smartWorkspaceOpenPayrollRunReview;

  /// No description provided for @smartWorkspaceAddElementTitle.
  ///
  /// In en, this message translates to:
  /// **'Add payroll element'**
  String get smartWorkspaceAddElementTitle;

  /// No description provided for @smartWorkspaceAddElementSummary.
  ///
  /// In en, this message translates to:
  /// **'Confirm the proposed payroll element before saving it to your catalog.'**
  String get smartWorkspaceAddElementSummary;

  /// No description provided for @smartWorkspaceAddElementNeedsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Need more payroll element details'**
  String get smartWorkspaceAddElementNeedsDetailsTitle;

  /// No description provided for @smartWorkspaceAddElementNeedsDetailsMessage.
  ///
  /// In en, this message translates to:
  /// **'Include a name and amount, for example: add a recurring transport allowance for 150.'**
  String get smartWorkspaceAddElementNeedsDetailsMessage;

  /// No description provided for @smartWorkspaceElementClassificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get smartWorkspaceElementClassificationTitle;

  /// No description provided for @smartWorkspaceClassificationEarning.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get smartWorkspaceClassificationEarning;

  /// No description provided for @smartWorkspaceClassificationDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get smartWorkspaceClassificationDeduction;

  /// No description provided for @smartWorkspaceClassificationInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get smartWorkspaceClassificationInformation;

  /// No description provided for @smartWorkspaceElementRecurrenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get smartWorkspaceElementRecurrenceTitle;

  /// No description provided for @smartWorkspaceRecurrenceRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get smartWorkspaceRecurrenceRecurring;

  /// No description provided for @smartWorkspaceRecurrenceNonRecurring.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get smartWorkspaceRecurrenceNonRecurring;

  /// No description provided for @smartWorkspaceElementCalculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get smartWorkspaceElementCalculationTitle;

  /// No description provided for @smartWorkspaceCalculationFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get smartWorkspaceCalculationFixed;

  /// No description provided for @smartWorkspaceCalculationPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get smartWorkspaceCalculationPercentage;

  /// No description provided for @smartWorkspaceCalculationDerived.
  ///
  /// In en, this message translates to:
  /// **'Derived'**
  String get smartWorkspaceCalculationDerived;

  /// No description provided for @smartWorkspaceConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get smartWorkspaceConfirmationTitle;

  /// No description provided for @smartWorkspaceAddElementConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will save a new payroll element through the existing payroll repository.'**
  String get smartWorkspaceAddElementConfirmMessage;

  /// No description provided for @smartWorkspaceFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get smartWorkspaceFieldName;

  /// No description provided for @smartWorkspaceFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get smartWorkspaceFieldAmount;

  /// No description provided for @smartWorkspaceFieldClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get smartWorkspaceFieldClassification;

  /// No description provided for @smartWorkspaceFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get smartWorkspaceFieldDate;

  /// No description provided for @smartWorkspaceFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get smartWorkspaceFieldStatus;

  /// No description provided for @smartWorkspaceFieldCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get smartWorkspaceFieldCheckIn;

  /// No description provided for @smartWorkspaceFieldCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get smartWorkspaceFieldCheckOut;

  /// No description provided for @smartWorkspaceSaveElementAction.
  ///
  /// In en, this message translates to:
  /// **'Save payroll element'**
  String get smartWorkspaceSaveElementAction;

  /// No description provided for @smartWorkspacePayrollExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll explanation'**
  String get smartWorkspacePayrollExplanationTitle;

  /// No description provided for @smartWorkspacePayrollExplanationSummary.
  ///
  /// In en, this message translates to:
  /// **'Break down earnings and deductions using the existing payroll calculation service.'**
  String get smartWorkspacePayrollExplanationSummary;

  /// No description provided for @smartWorkspaceNetPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Net pay'**
  String get smartWorkspaceNetPayTitle;

  /// No description provided for @smartWorkspacePayrollPreviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Preview based on current payroll rules'**
  String get smartWorkspacePayrollPreviewStatus;

  /// No description provided for @smartWorkspaceEarningsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings breakdown'**
  String get smartWorkspaceEarningsBreakdownTitle;

  /// No description provided for @smartWorkspaceDeductionsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Deductions breakdown'**
  String get smartWorkspaceDeductionsBreakdownTitle;

  /// No description provided for @smartWorkspaceOpenQuickPayAction.
  ///
  /// In en, this message translates to:
  /// **'Open quick pay'**
  String get smartWorkspaceOpenQuickPayAction;

  /// No description provided for @smartWorkspaceAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dynamic analytics assistant'**
  String get smartWorkspaceAnalyticsTitle;

  /// No description provided for @smartWorkspaceRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get smartWorkspaceRevenueTitle;

  /// No description provided for @smartWorkspaceTransactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 completed transaction} other{{count} completed transactions}}'**
  String smartWorkspaceTransactionsCount(int count);

  /// No description provided for @smartWorkspaceExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get smartWorkspaceExpensesTitle;

  /// No description provided for @smartWorkspacePayrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get smartWorkspacePayrollTitle;

  /// No description provided for @smartWorkspaceDraftPayrollRuns.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No draft payroll runs} one{1 draft payroll run} other{{count} draft payroll runs}}'**
  String smartWorkspaceDraftPayrollRuns(int count);

  /// No description provided for @smartWorkspaceNetResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Net result'**
  String get smartWorkspaceNetResultTitle;

  /// No description provided for @smartWorkspaceChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent monthly trend'**
  String get smartWorkspaceChartTitle;

  /// No description provided for @smartWorkspaceChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue bars are shown with the same period context used by the assistant.'**
  String get smartWorkspaceChartSubtitle;

  /// No description provided for @smartWorkspaceOpenSalesAction.
  ///
  /// In en, this message translates to:
  /// **'Open sales'**
  String get smartWorkspaceOpenSalesAction;

  /// No description provided for @smartWorkspaceOpenExpensesAction.
  ///
  /// In en, this message translates to:
  /// **'Open expenses'**
  String get smartWorkspaceOpenExpensesAction;

  /// No description provided for @smartWorkspaceOpenPayrollAction.
  ///
  /// In en, this message translates to:
  /// **'Open payroll'**
  String get smartWorkspaceOpenPayrollAction;

  /// No description provided for @smartWorkspaceAttendanceCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction assistant'**
  String get smartWorkspaceAttendanceCorrectionTitle;

  /// No description provided for @smartWorkspaceAttendanceCorrectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Review correction-ready records and confirm approved updates through the existing attendance repository.'**
  String get smartWorkspaceAttendanceCorrectionSummary;

  /// No description provided for @smartWorkspaceAttendancePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending attendance requests'**
  String get smartWorkspaceAttendancePendingTitle;

  /// No description provided for @smartWorkspaceAttendanceCorrectionsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No records need correction} one{1 record needs correction} other{{count} records need correction}}'**
  String smartWorkspaceAttendanceCorrectionsNeeded(int count);

  /// No description provided for @smartWorkspaceAttendanceNoRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'No correction-ready record found'**
  String get smartWorkspaceAttendanceNoRecordTitle;

  /// No description provided for @smartWorkspaceAttendanceNoRecordMessage.
  ///
  /// In en, this message translates to:
  /// **'Adjust the employee or date range to find the attendance request you want to review.'**
  String get smartWorkspaceAttendanceNoRecordMessage;

  /// No description provided for @smartWorkspaceAttendanceRecordSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance status: {status}'**
  String smartWorkspaceAttendanceRecordSummary(String status);

  /// No description provided for @smartWorkspaceAttendanceConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Review the correction details before applying the approved update.'**
  String get smartWorkspaceAttendanceConfirmMessage;

  /// No description provided for @smartWorkspaceAttendancePromptForDetails.
  ///
  /// In en, this message translates to:
  /// **'Add a status or time change in your prompt to prepare a correction.'**
  String get smartWorkspaceAttendancePromptForDetails;

  /// No description provided for @smartWorkspaceApplyAttendanceAction.
  ///
  /// In en, this message translates to:
  /// **'Apply correction'**
  String get smartWorkspaceApplyAttendanceAction;

  /// No description provided for @smartWorkspaceOpenAttendanceReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Open attendance review'**
  String get smartWorkspaceOpenAttendanceReviewAction;

  /// No description provided for @ownerTooltipCycleTheme.
  ///
  /// In en, this message translates to:
  /// **'Cycle appearance (system / light / dark)'**
  String get ownerTooltipCycleTheme;

  /// No description provided for @ownerTooltipCycleThemeShort.
  ///
  /// In en, this message translates to:
  /// **'Cycle appearance'**
  String get ownerTooltipCycleThemeShort;

  /// No description provided for @ownerTooltipLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language (English / العربية)'**
  String get ownerTooltipLanguage;

  /// No description provided for @ownerTooltipLanguageShort.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get ownerTooltipLanguageShort;

  /// No description provided for @ownerTooltipSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get ownerTooltipSignOut;

  /// No description provided for @customerCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get customerCategoryAll;

  /// No description provided for @customerMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get customerMyBookings;

  /// No description provided for @customerMyBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming and past visits'**
  String get customerMyBookingsSubtitle;

  /// No description provided for @customerMyBookingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no bookings yet. Discover a salon and book an appointment.'**
  String get customerMyBookingsEmpty;

  /// No description provided for @bookingNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get bookingNotes;

  /// No description provided for @bookingDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get bookingDuration;

  /// No description provided for @bookingDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String bookingDurationMinutes(int minutes);

  /// No description provided for @bookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bookingStatus;

  /// No description provided for @bookingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingStatusCompleted;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get bookingStatusNoShow;

  /// No description provided for @bookingStatusRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get bookingStatusRescheduled;

  /// No description provided for @barberSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get barberSummaryTitle;

  /// No description provided for @barberSummaryAppointments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No appointments} one{1 appointment} other{{count} appointments}}'**
  String barberSummaryAppointments(int count);

  /// No description provided for @barberNextAppointment.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get barberNextAppointment;

  /// No description provided for @barberNextNone.
  ///
  /// In en, this message translates to:
  /// **'No more today'**
  String get barberNextNone;

  /// No description provided for @barberEarningsMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get barberEarningsMonth;

  /// No description provided for @barberQuickSale.
  ///
  /// In en, this message translates to:
  /// **'Quick sale'**
  String get barberQuickSale;

  /// No description provided for @barberAttendanceCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get barberAttendanceCardTitle;

  /// No description provided for @barberAttendanceIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get barberAttendanceIn;

  /// No description provided for @barberAttendanceOut.
  ///
  /// In en, this message translates to:
  /// **'Checked out'**
  String get barberAttendanceOut;

  /// No description provided for @barberAttendanceNone.
  ///
  /// In en, this message translates to:
  /// **'Not checked in yet'**
  String get barberAttendanceNone;

  /// No description provided for @customerSectionBarbers.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get customerSectionBarbers;

  /// No description provided for @customerBarberCardCta.
  ///
  /// In en, this message translates to:
  /// **'Book +'**
  String get customerBarberCardCta;

  /// No description provided for @customerBarberVerifiedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Salon-verified stylist'**
  String get customerBarberVerifiedTooltip;

  /// No description provided for @customerNoBarbersDetail.
  ///
  /// In en, this message translates to:
  /// **'No barbers listed for this salon yet.'**
  String get customerNoBarbersDetail;

  /// No description provided for @barberTabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get barberTabToday;

  /// No description provided for @barberTabSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get barberTabSale;

  /// No description provided for @barberTabAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get barberTabAttendance;

  /// No description provided for @barberTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s schedule'**
  String get barberTodayTitle;

  /// No description provided for @barberTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your assigned appointments.'**
  String get barberTodaySubtitle;

  /// No description provided for @barberNoEmployee.
  ///
  /// In en, this message translates to:
  /// **'Your profile is missing a team link. Contact the owner.'**
  String get barberNoEmployee;

  /// No description provided for @barberRecordSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Record sale'**
  String get barberRecordSaleTitle;

  /// No description provided for @barberSaleService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get barberSaleService;

  /// No description provided for @barberSalePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get barberSalePayment;

  /// No description provided for @barberSaleSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save sale'**
  String get barberSaleSubmit;

  /// No description provided for @barberSaleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded'**
  String get barberSaleSuccess;

  /// No description provided for @barberAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get barberAttendanceTitle;

  /// No description provided for @barberAttendanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s punches.'**
  String get barberAttendanceSubtitle;

  /// No description provided for @barberCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get barberCheckIn;

  /// No description provided for @barberCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get barberCheckOut;

  /// No description provided for @barberNoAttendance.
  ///
  /// In en, this message translates to:
  /// **'No attendance records today.'**
  String get barberNoAttendance;

  /// No description provided for @ownerMoneyPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ownerMoneyPeriodToday;

  /// No description provided for @ownerMoneyPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get ownerMoneyPeriodMonth;

  /// No description provided for @ownerMoneyPeriodCustomSoon.
  ///
  /// In en, this message translates to:
  /// **'Custom (soon)'**
  String get ownerMoneyPeriodCustomSoon;

  /// No description provided for @ownerMoneyTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Sales total'**
  String get ownerMoneyTotalSales;

  /// No description provided for @ownerMoneyTotalPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll total'**
  String get ownerMoneyTotalPayroll;

  /// No description provided for @ownerMoneyTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses total'**
  String get ownerMoneyTotalExpenses;

  /// No description provided for @ownerMoneyNetResult.
  ///
  /// In en, this message translates to:
  /// **'Net result'**
  String get ownerMoneyNetResult;

  /// No description provided for @ownerBookingsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get ownerBookingsLoadMore;

  /// No description provided for @ownerBookingsLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get ownerBookingsLoadingMore;

  /// No description provided for @ownerBookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get ownerBookingDetailsTitle;

  /// No description provided for @ownerBookingSaveNotes.
  ///
  /// In en, this message translates to:
  /// **'Save notes'**
  String get ownerBookingSaveNotes;

  /// No description provided for @ownerBookingNotesSaved.
  ///
  /// In en, this message translates to:
  /// **'Notes saved'**
  String get ownerBookingNotesSaved;

  /// No description provided for @ownerBookingNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New booking'**
  String get ownerBookingNewTitle;

  /// No description provided for @ownerBookingCustomerUid.
  ///
  /// In en, this message translates to:
  /// **'Customer user ID'**
  String get ownerBookingCustomerUid;

  /// No description provided for @ownerBookingCustomerUidHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the customer’s Firebase Auth UID (from their profile).'**
  String get ownerBookingCustomerUidHint;

  /// No description provided for @ownerBookingCustomerUidInvalid.
  ///
  /// In en, this message translates to:
  /// **'Customer user ID is required.'**
  String get ownerBookingCustomerUidInvalid;

  /// No description provided for @ownerBookingCustomerNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer name (optional)'**
  String get ownerBookingCustomerNameOptional;

  /// No description provided for @ownerBookingCreate.
  ///
  /// In en, this message translates to:
  /// **'Create booking'**
  String get ownerBookingCreate;

  /// No description provided for @ownerBookingCreated.
  ///
  /// In en, this message translates to:
  /// **'Booking created'**
  String get ownerBookingCreated;

  /// No description provided for @ownerBookingRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Booking rescheduled'**
  String get ownerBookingRescheduled;

  /// No description provided for @ownerHrSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'HR & violations'**
  String get ownerHrSettingsTitle;

  /// No description provided for @ownerHrSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage staff penalties, attendance rules and review requests.'**
  String get ownerHrSettingsSubtitle;

  /// No description provided for @ownerSettingsHrTileTitle.
  ///
  /// In en, this message translates to:
  /// **'HR & violations'**
  String get ownerSettingsHrTileTitle;

  /// No description provided for @ownerSettingsHrTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Penalty rules, attendance policies and review queue'**
  String get ownerSettingsHrTileSubtitle;

  /// No description provided for @salonAttendanceZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance zone'**
  String get salonAttendanceZoneTitle;

  /// No description provided for @salonAttendanceZoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control where your team can punch in and out.'**
  String get salonAttendanceZoneSubtitle;

  /// No description provided for @salonAttendanceZoneMapSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get salonAttendanceZoneMapSectionTitle;

  /// No description provided for @salonAttendanceZoneMapTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to move the zone center.'**
  String get salonAttendanceZoneMapTapHint;

  /// No description provided for @salonAttendanceZoneMapWebHint.
  ///
  /// In en, this message translates to:
  /// **'Use the mobile app to pick the zone on the map.'**
  String get salonAttendanceZoneMapWebHint;

  /// No description provided for @salonAttendanceZoneMapCenterMarker.
  ///
  /// In en, this message translates to:
  /// **'Zone center'**
  String get salonAttendanceZoneMapCenterMarker;

  /// No description provided for @salonAttendanceZoneCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Lat {lat}, Lng {lng}'**
  String salonAttendanceZoneCoordinates(String lat, String lng);

  /// No description provided for @salonAttendanceZonePunchRadiusMeters.
  ///
  /// In en, this message translates to:
  /// **'Allowed punch radius: {meters} meters'**
  String salonAttendanceZonePunchRadiusMeters(int meters);

  /// No description provided for @salonAttendanceZoneMetersShort.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String salonAttendanceZoneMetersShort(int meters);

  /// No description provided for @salonAttendanceZoneEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable attendance'**
  String get salonAttendanceZoneEnable;

  /// No description provided for @salonAttendanceZoneRequireInPunchIn.
  ///
  /// In en, this message translates to:
  /// **'Require inside zone for punch in'**
  String get salonAttendanceZoneRequireInPunchIn;

  /// No description provided for @salonAttendanceZoneRequireInPunchOut.
  ///
  /// In en, this message translates to:
  /// **'Require inside zone for punch out'**
  String get salonAttendanceZoneRequireInPunchOut;

  /// No description provided for @salonAttendanceZoneAllowBreaks.
  ///
  /// In en, this message translates to:
  /// **'Allow breaks'**
  String get salonAttendanceZoneAllowBreaks;

  /// No description provided for @salonAttendanceZoneAllowCorrections.
  ///
  /// In en, this message translates to:
  /// **'Allow attendance correction requests'**
  String get salonAttendanceZoneAllowCorrections;

  /// No description provided for @salonAttendanceZoneSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get salonAttendanceZoneSave;

  /// No description provided for @salonAttendanceZoneSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance settings saved'**
  String get salonAttendanceZoneSaved;

  /// No description provided for @salonAttendanceZoneSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get salonAttendanceZoneSaveFailed;

  /// No description provided for @ownerAttendanceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance settings'**
  String get ownerAttendanceSettingsTitle;

  /// No description provided for @ownerAttendanceSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage zone, punches, breaks, corrections and HR rules'**
  String get ownerAttendanceSettingsSubtitle;

  /// No description provided for @ownerAttendanceSettingsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ownerAttendanceSettingsStatusActive;

  /// No description provided for @ownerAttendanceSettingsStatusLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Location missing'**
  String get ownerAttendanceSettingsStatusLocationMissing;

  /// No description provided for @ownerAttendanceSectionZone.
  ///
  /// In en, this message translates to:
  /// **'Attendance zone'**
  String get ownerAttendanceSectionZone;

  /// No description provided for @ownerAttendanceSectionPunchRules.
  ///
  /// In en, this message translates to:
  /// **'Punch rules'**
  String get ownerAttendanceSectionPunchRules;

  /// No description provided for @ownerAttendanceSectionGrace.
  ///
  /// In en, this message translates to:
  /// **'Grace and working time'**
  String get ownerAttendanceSectionGrace;

  /// No description provided for @ownerAttendanceSectionCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction requests'**
  String get ownerAttendanceSectionCorrection;

  /// No description provided for @ownerAttendanceSectionViolations.
  ///
  /// In en, this message translates to:
  /// **'HR violation rules'**
  String get ownerAttendanceSectionViolations;

  /// No description provided for @ownerAttendanceZoneMapPickAction.
  ///
  /// In en, this message translates to:
  /// **'Pick salon location'**
  String get ownerAttendanceZoneMapPickAction;

  /// No description provided for @ownerAttendanceZoneCoordinatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the salon location.'**
  String get ownerAttendanceZoneCoordinatesEmpty;

  /// No description provided for @ownerAttendanceZoneRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Allowed radius'**
  String get ownerAttendanceZoneRadiusLabel;

  /// No description provided for @ownerAttendanceZoneLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location required to punch'**
  String get ownerAttendanceZoneLocationRequired;

  /// No description provided for @ownerAttendanceZoneLocationRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Employees must be inside the zone to punch in or out.'**
  String get ownerAttendanceZoneLocationRequiredHint;

  /// No description provided for @ownerAttendanceRulesAttendanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Attendance required'**
  String get ownerAttendanceRulesAttendanceRequired;

  /// No description provided for @ownerAttendanceRulesAttendanceRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Employees must record their day before working.'**
  String get ownerAttendanceRulesAttendanceRequiredHint;

  /// No description provided for @ownerAttendanceRulesPunchInRequired.
  ///
  /// In en, this message translates to:
  /// **'Punch in required'**
  String get ownerAttendanceRulesPunchInRequired;

  /// No description provided for @ownerAttendanceRulesPunchOutRequired.
  ///
  /// In en, this message translates to:
  /// **'Punch out required'**
  String get ownerAttendanceRulesPunchOutRequired;

  /// No description provided for @ownerAttendanceRulesBreaksEnabled.
  ///
  /// In en, this message translates to:
  /// **'Breaks enabled'**
  String get ownerAttendanceRulesBreaksEnabled;

  /// No description provided for @ownerAttendanceRulesMaxPunchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Max punches per day'**
  String get ownerAttendanceRulesMaxPunchesLabel;

  /// No description provided for @ownerAttendanceRulesMaxBreaksLabel.
  ///
  /// In en, this message translates to:
  /// **'Max breaks per day'**
  String get ownerAttendanceRulesMaxBreaksLabel;

  /// No description provided for @ownerAttendanceGraceLateLabel.
  ///
  /// In en, this message translates to:
  /// **'Late grace (minutes)'**
  String get ownerAttendanceGraceLateLabel;

  /// No description provided for @ownerAttendanceGraceEarlyExitLabel.
  ///
  /// In en, this message translates to:
  /// **'Early exit grace (minutes)'**
  String get ownerAttendanceGraceEarlyExitLabel;

  /// No description provided for @ownerAttendanceGraceMinShiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum shift (minutes)'**
  String get ownerAttendanceGraceMinShiftLabel;

  /// No description provided for @ownerAttendanceGraceMaxShiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum shift (minutes)'**
  String get ownerAttendanceGraceMaxShiftLabel;

  /// No description provided for @ownerAttendanceCorrectionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable correction requests'**
  String get ownerAttendanceCorrectionEnabled;

  /// No description provided for @ownerAttendanceCorrectionRequireReason.
  ///
  /// In en, this message translates to:
  /// **'Require correction reason'**
  String get ownerAttendanceCorrectionRequireReason;

  /// No description provided for @ownerAttendanceCorrectionRequireApproval.
  ///
  /// In en, this message translates to:
  /// **'Require owner/admin approval'**
  String get ownerAttendanceCorrectionRequireApproval;

  /// No description provided for @ownerAttendanceCorrectionMaxPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Max correction requests per month'**
  String get ownerAttendanceCorrectionMaxPerMonth;

  /// No description provided for @ownerAttendanceViolationsAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-create violations'**
  String get ownerAttendanceViolationsAuto;

  /// No description provided for @ownerAttendanceViolationsAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Generate payroll violations automatically when limits are exceeded.'**
  String get ownerAttendanceViolationsAutoHint;

  /// No description provided for @ownerAttendanceViolationsMissingCheckoutPercent.
  ///
  /// In en, this message translates to:
  /// **'Missing checkout deduction (%)'**
  String get ownerAttendanceViolationsMissingCheckoutPercent;

  /// No description provided for @ownerAttendanceViolationsAbsencePercent.
  ///
  /// In en, this message translates to:
  /// **'Absence deduction (%)'**
  String get ownerAttendanceViolationsAbsencePercent;

  /// No description provided for @ownerAttendanceViolationsLatePercent.
  ///
  /// In en, this message translates to:
  /// **'Late deduction (%)'**
  String get ownerAttendanceViolationsLatePercent;

  /// No description provided for @ownerAttendanceViolationsEarlyExitPercent.
  ///
  /// In en, this message translates to:
  /// **'Early exit deduction (%)'**
  String get ownerAttendanceViolationsEarlyExitPercent;

  /// No description provided for @ownerAttendanceViolationsLateAllowance.
  ///
  /// In en, this message translates to:
  /// **'Allowed late count per month'**
  String get ownerAttendanceViolationsLateAllowance;

  /// No description provided for @ownerAttendanceViolationsEarlyExitAllowance.
  ///
  /// In en, this message translates to:
  /// **'Allowed early exit count per month'**
  String get ownerAttendanceViolationsEarlyExitAllowance;

  /// No description provided for @ownerAttendanceViolationsMissingCheckoutAllowance.
  ///
  /// In en, this message translates to:
  /// **'Allowed missing checkout count per month'**
  String get ownerAttendanceViolationsMissingCheckoutAllowance;

  /// No description provided for @ownerAttendanceSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get ownerAttendanceSettingsSave;

  /// No description provided for @ownerAttendanceSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance settings updated'**
  String get ownerAttendanceSettingsSaved;

  /// No description provided for @ownerAttendanceSettingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save attendance settings'**
  String get ownerAttendanceSettingsSaveFailed;

  /// No description provided for @ownerAttendanceSettingsValidationLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick a salon location before saving.'**
  String get ownerAttendanceSettingsValidationLocationMissing;

  /// No description provided for @ownerAttendanceSettingsValidationRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius must be between 10 and 500 meters.'**
  String get ownerAttendanceSettingsValidationRadius;

  /// No description provided for @ownerAttendanceSettingsValidationMaxPunches.
  ///
  /// In en, this message translates to:
  /// **'Max punches must be between 2 and 10.'**
  String get ownerAttendanceSettingsValidationMaxPunches;

  /// No description provided for @ownerAttendanceSettingsValidationMaxBreaks.
  ///
  /// In en, this message translates to:
  /// **'Max breaks must be between 0 and 5.'**
  String get ownerAttendanceSettingsValidationMaxBreaks;

  /// No description provided for @ownerAttendanceSettingsValidationGraceLate.
  ///
  /// In en, this message translates to:
  /// **'Late grace must be between 0 and 120 minutes.'**
  String get ownerAttendanceSettingsValidationGraceLate;

  /// No description provided for @ownerAttendanceSettingsValidationGraceEarly.
  ///
  /// In en, this message translates to:
  /// **'Early exit grace must be between 0 and 120 minutes.'**
  String get ownerAttendanceSettingsValidationGraceEarly;

  /// No description provided for @ownerAttendanceSettingsValidationMinShift.
  ///
  /// In en, this message translates to:
  /// **'Minimum shift must be greater than 0.'**
  String get ownerAttendanceSettingsValidationMinShift;

  /// No description provided for @ownerAttendanceSettingsValidationMaxShift.
  ///
  /// In en, this message translates to:
  /// **'Maximum shift must be greater than minimum shift.'**
  String get ownerAttendanceSettingsValidationMaxShift;

  /// No description provided for @ownerAttendanceSettingsValidationDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction percentages must be between 0 and 100.'**
  String get ownerAttendanceSettingsValidationDeduction;

  /// No description provided for @ownerAttendanceSettingsValidationAllowance.
  ///
  /// In en, this message translates to:
  /// **'Allowed counts must be 0 or more.'**
  String get ownerAttendanceSettingsValidationAllowance;

  /// No description provided for @ownerMoneySalesSection.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get ownerMoneySalesSection;

  /// No description provided for @ownerMoneySalesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales'**
  String get ownerMoneySalesEmptyTitle;

  /// No description provided for @ownerMoneyEmptySales.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period yet.'**
  String get ownerMoneyEmptySales;

  /// No description provided for @ownerAddSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add sale'**
  String get ownerAddSaleTitle;

  /// No description provided for @ownerAddSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record a walk-in or counter sale quickly.'**
  String get ownerAddSaleSubtitle;

  /// No description provided for @ownerAddSaleServiceField.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get ownerAddSaleServiceField;

  /// No description provided for @ownerAddSaleBarberField.
  ///
  /// In en, this message translates to:
  /// **'Service provider'**
  String get ownerAddSaleBarberField;

  /// No description provided for @ownerAddSalePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get ownerAddSalePriceLabel;

  /// No description provided for @ownerAddSalePriceHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a service to see the price.'**
  String get ownerAddSalePriceHint;

  /// No description provided for @ownerAddSaleCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Customer name (optional)'**
  String get ownerAddSaleCustomerHint;

  /// No description provided for @ownerAddSaleSave.
  ///
  /// In en, this message translates to:
  /// **'Save sale'**
  String get ownerAddSaleSave;

  /// No description provided for @ownerAddSaleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale saved'**
  String get ownerAddSaleSuccess;

  /// No description provided for @ownerAddSaleValidation.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one service, a service provider, and a payment method.'**
  String get ownerAddSaleValidation;

  /// No description provided for @ownerAddSaleOpen.
  ///
  /// In en, this message translates to:
  /// **'Add sale'**
  String get ownerAddSaleOpen;

  /// No description provided for @ownerAddSaleNoStaff.
  ///
  /// In en, this message translates to:
  /// **'Add team members before recording sales.'**
  String get ownerAddSaleNoStaff;

  /// No description provided for @ownerServiceCategory.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get ownerServiceCategory;

  /// No description provided for @ownerServiceActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Service is active'**
  String get ownerServiceActiveLabel;

  /// No description provided for @ownerServiceInactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get ownerServiceInactiveBadge;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @adminConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin console'**
  String get adminConsoleTitle;

  /// No description provided for @adminWorkspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage staff, policies, and operations for your salon.'**
  String get adminWorkspaceSubtitle;

  /// No description provided for @adminSalonIdLine.
  ///
  /// In en, this message translates to:
  /// **'Salon ID: {salonId}'**
  String adminSalonIdLine(String salonId);

  /// No description provided for @adminSalonNotLinked.
  ///
  /// In en, this message translates to:
  /// **'No salon linked'**
  String get adminSalonNotLinked;

  /// No description provided for @roleBarber.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get roleBarber;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodDigitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital wallet'**
  String get paymentMethodDigitalWallet;

  /// No description provided for @paymentMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentMethodOther;

  /// No description provided for @payrollStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get payrollStatusDraft;

  /// No description provided for @payrollStatusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get payrollStatusPendingApproval;

  /// No description provided for @payrollStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get payrollStatusApproved;

  /// No description provided for @payrollStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payrollStatusPaid;

  /// No description provided for @payrollStatusVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get payrollStatusVoided;

  /// No description provided for @customerBookingsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get customerBookingsUpcoming;

  /// No description provided for @customerBookingsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get customerBookingsPast;

  /// No description provided for @customerBookingsUpcomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No upcoming visits.'**
  String get customerBookingsUpcomingEmpty;

  /// No description provided for @customerBookingsPastEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past visits yet.'**
  String get customerBookingsPastEmpty;

  /// No description provided for @customerBookingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get customerBookingCancel;

  /// No description provided for @customerBookingReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get customerBookingReschedule;

  /// No description provided for @customerBookingCancelledToast.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get customerBookingCancelledToast;

  /// No description provided for @customerBookingRescheduledToast.
  ///
  /// In en, this message translates to:
  /// **'Booking updated'**
  String get customerBookingRescheduledToast;

  /// No description provided for @customerBookingActionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This action is not available for this booking.'**
  String get customerBookingActionUnavailable;

  /// No description provided for @customerRescheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Reschedule booking'**
  String get customerRescheduleTitle;

  /// No description provided for @customerRescheduleSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save new time'**
  String get customerRescheduleSubmit;

  /// No description provided for @customerMyBookingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your bookings…'**
  String get customerMyBookingsLoading;

  /// No description provided for @listLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get listLoadMore;

  /// No description provided for @bookingOpMarkArrived.
  ///
  /// In en, this message translates to:
  /// **'Customer arrived'**
  String get bookingOpMarkArrived;

  /// No description provided for @bookingOpStartService.
  ///
  /// In en, this message translates to:
  /// **'Start service'**
  String get bookingOpStartService;

  /// No description provided for @bookingOpComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get bookingOpComplete;

  /// No description provided for @bookingOpNoShowCustomer.
  ///
  /// In en, this message translates to:
  /// **'No-show (customer)'**
  String get bookingOpNoShowCustomer;

  /// No description provided for @bookingOpNoShowBarber.
  ///
  /// In en, this message translates to:
  /// **'No-show (barber)'**
  String get bookingOpNoShowBarber;

  /// No description provided for @ownerViolationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Violations & penalties'**
  String get ownerViolationsTitle;

  /// No description provided for @ownerViolationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve deductions before payroll applies them.'**
  String get ownerViolationsSubtitle;

  /// No description provided for @ownerViolationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending violations.'**
  String get ownerViolationsEmpty;

  /// No description provided for @ownerViolationBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get ownerViolationBooking;

  /// No description provided for @ownerViolationAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ownerViolationAmount;

  /// No description provided for @ownerViolationApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get ownerViolationApprove;

  /// No description provided for @ownerViolationReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ownerViolationReject;

  /// No description provided for @ownerViolationReviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Violation updated'**
  String get ownerViolationReviewSaved;

  /// No description provided for @ownerPenaltySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Penalty rules'**
  String get ownerPenaltySettingsTitle;

  /// No description provided for @ownerPenaltySettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Penalty settings saved'**
  String get ownerPenaltySettingsSaved;

  /// No description provided for @ownerPenaltyLateEnabled.
  ///
  /// In en, this message translates to:
  /// **'Staff late penalties'**
  String get ownerPenaltyLateEnabled;

  /// No description provided for @ownerPenaltyGraceMinutes.
  ///
  /// In en, this message translates to:
  /// **'Grace (minutes)'**
  String get ownerPenaltyGraceMinutes;

  /// No description provided for @ownerPenaltyCalcFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat amount'**
  String get ownerPenaltyCalcFlat;

  /// No description provided for @ownerPenaltyCalcPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent of gross'**
  String get ownerPenaltyCalcPercent;

  /// No description provided for @ownerPenaltyCalcPerMinute.
  ///
  /// In en, this message translates to:
  /// **'Per minute after grace'**
  String get ownerPenaltyCalcPerMinute;

  /// No description provided for @ownerPenaltyLateValue.
  ///
  /// In en, this message translates to:
  /// **'Late penalty value'**
  String get ownerPenaltyLateValue;

  /// No description provided for @ownerPenaltyNoShowEnabled.
  ///
  /// In en, this message translates to:
  /// **'Staff no-show penalties'**
  String get ownerPenaltyNoShowEnabled;

  /// No description provided for @ownerPenaltyNoShowValue.
  ///
  /// In en, this message translates to:
  /// **'No-show penalty value'**
  String get ownerPenaltyNoShowValue;

  /// No description provided for @ownerViolationsMetricPending.
  ///
  /// In en, this message translates to:
  /// **'Pending reviews'**
  String get ownerViolationsMetricPending;

  /// No description provided for @ownerViolationsMetricRulesOn.
  ///
  /// In en, this message translates to:
  /// **'Active rules'**
  String get ownerViolationsMetricRulesOn;

  /// No description provided for @ownerPenaltyAppliesWhenLabel.
  ///
  /// In en, this message translates to:
  /// **'Penalty applies when'**
  String get ownerPenaltyAppliesWhenLabel;

  /// No description provided for @ownerPenaltyLateWhenBody.
  ///
  /// In en, this message translates to:
  /// **'Staff member checks in late after grace'**
  String get ownerPenaltyLateWhenBody;

  /// No description provided for @ownerPenaltyNoShowWhenBody.
  ///
  /// In en, this message translates to:
  /// **'Staff member misses the appointment'**
  String get ownerPenaltyNoShowWhenBody;

  /// No description provided for @ownerPenaltyMetricCalculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get ownerPenaltyMetricCalculation;

  /// No description provided for @ownerKpiNoShowToday.
  ///
  /// In en, this message translates to:
  /// **'No-shows today'**
  String get ownerKpiNoShowToday;

  /// No description provided for @ownerKpiNoShowRateMonth.
  ///
  /// In en, this message translates to:
  /// **'No-show rate (month)'**
  String get ownerKpiNoShowRateMonth;

  /// No description provided for @ownerKpiPenaltyMonth.
  ///
  /// In en, this message translates to:
  /// **'Penalties (month)'**
  String get ownerKpiPenaltyMonth;

  /// No description provided for @ownerKpiTopPenalizedBarber.
  ///
  /// In en, this message translates to:
  /// **'Top penalized (month)'**
  String get ownerKpiTopPenalizedBarber;

  /// No description provided for @payrollDeductionViolations.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get payrollDeductionViolations;

  /// No description provided for @payrollStatusRolledBack.
  ///
  /// In en, this message translates to:
  /// **'Rolled back'**
  String get payrollStatusRolledBack;

  /// No description provided for @payrollBadgeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get payrollBadgeRecurring;

  /// No description provided for @payrollBadgeNonRecurring.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get payrollBadgeNonRecurring;

  /// No description provided for @payrollLineQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty {value}'**
  String payrollLineQuantity(String value);

  /// No description provided for @payrollLineRate.
  ///
  /// In en, this message translates to:
  /// **'Rate {value}'**
  String payrollLineRate(String value);

  /// No description provided for @payrollGenericError.
  ///
  /// In en, this message translates to:
  /// **'Payroll data could not be loaded right now.'**
  String get payrollGenericError;

  /// No description provided for @payrollSummaryEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get payrollSummaryEarnings;

  /// No description provided for @payrollSummaryDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get payrollSummaryDeductions;

  /// No description provided for @payrollSummaryNetPay.
  ///
  /// In en, this message translates to:
  /// **'Net pay'**
  String get payrollSummaryNetPay;

  /// No description provided for @payrollSectionEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings lines'**
  String get payrollSectionEarnings;

  /// No description provided for @payrollSectionDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deduction lines'**
  String get payrollSectionDeductions;

  /// No description provided for @payrollSectionInformation.
  ///
  /// In en, this message translates to:
  /// **'Information lines'**
  String get payrollSectionInformation;

  /// No description provided for @payrollSectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lines for this section.'**
  String get payrollSectionEmpty;

  /// No description provided for @payrollDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get payrollDashboardTitle;

  /// No description provided for @payrollDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{monthLabel} payroll engine overview.'**
  String payrollDashboardSubtitle(String monthLabel);

  /// No description provided for @payrollQuickPayTitle.
  ///
  /// In en, this message translates to:
  /// **'QuickPay'**
  String get payrollQuickPayTitle;

  /// No description provided for @payrollQuickPayShortcutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate and process one employee quickly.'**
  String get payrollQuickPayShortcutSubtitle;

  /// No description provided for @payrollRunReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll run review'**
  String get payrollRunReviewTitle;

  /// No description provided for @payrollRunShortcutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review a monthly payroll run for multiple employees.'**
  String get payrollRunShortcutSubtitle;

  /// No description provided for @payrollStatusBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Status breakdown'**
  String get payrollStatusBreakdownTitle;

  /// No description provided for @payrollRecentRunsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent payroll runs'**
  String get payrollRecentRunsTitle;

  /// No description provided for @payrollRecentRunsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recent payroll activity will appear here.'**
  String get payrollRecentRunsEmpty;

  /// No description provided for @payrollRunGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} employees'**
  String payrollRunGroupLabel(int count);

  /// No description provided for @payrollMissingSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing payroll setup'**
  String get payrollMissingSetupTitle;

  /// No description provided for @payrollMissingSetupEmpty.
  ///
  /// In en, this message translates to:
  /// **'All active employees have a recurring payroll setup.'**
  String get payrollMissingSetupEmpty;

  /// No description provided for @payrollActionSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get payrollActionSetUp;

  /// No description provided for @payrollElementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll elements'**
  String get payrollElementsTitle;

  /// No description provided for @payrollElementsSeedDefaults.
  ///
  /// In en, this message translates to:
  /// **'Seed defaults'**
  String get payrollElementsSeedDefaults;

  /// No description provided for @payrollElementsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add element'**
  String get payrollElementsAdd;

  /// No description provided for @payrollElementsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payroll elements yet'**
  String get payrollElementsEmptyTitle;

  /// No description provided for @payrollElementsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seed the default earning, deduction, and information elements to start building payroll.'**
  String get payrollElementsEmptySubtitle;

  /// No description provided for @payrollElementsSystemTag.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get payrollElementsSystemTag;

  /// No description provided for @payrollFieldCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get payrollFieldCode;

  /// No description provided for @payrollFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get payrollFieldName;

  /// No description provided for @payrollFieldClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get payrollFieldClassification;

  /// No description provided for @payrollFieldRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get payrollFieldRecurrence;

  /// No description provided for @payrollFieldCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get payrollFieldCalculationMethod;

  /// No description provided for @payrollFieldDefaultAmount.
  ///
  /// In en, this message translates to:
  /// **'Default amount'**
  String get payrollFieldDefaultAmount;

  /// No description provided for @payrollFieldVisibleOnPayslip.
  ///
  /// In en, this message translates to:
  /// **'Visible on payslip'**
  String get payrollFieldVisibleOnPayslip;

  /// No description provided for @payrollFieldAffectsNetPay.
  ///
  /// In en, this message translates to:
  /// **'Affects net pay'**
  String get payrollFieldAffectsNetPay;

  /// No description provided for @payrollFieldElement.
  ///
  /// In en, this message translates to:
  /// **'Element'**
  String get payrollFieldElement;

  /// No description provided for @payrollFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get payrollFieldAmount;

  /// No description provided for @payrollFieldPercentageOptional.
  ///
  /// In en, this message translates to:
  /// **'Percentage (optional)'**
  String get payrollFieldPercentageOptional;

  /// No description provided for @payrollFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get payrollFieldNote;

  /// No description provided for @payrollFieldEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get payrollFieldEmployee;

  /// No description provided for @payrollFieldPayrollPeriod.
  ///
  /// In en, this message translates to:
  /// **'Payroll period'**
  String get payrollFieldPayrollPeriod;

  /// No description provided for @payrollClassificationEarning.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get payrollClassificationEarning;

  /// No description provided for @payrollClassificationDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get payrollClassificationDeduction;

  /// No description provided for @payrollClassificationInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get payrollClassificationInformation;

  /// No description provided for @payrollCalculationFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get payrollCalculationFixed;

  /// No description provided for @payrollCalculationPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get payrollCalculationPercentage;

  /// No description provided for @payrollCalculationDerived.
  ///
  /// In en, this message translates to:
  /// **'Derived'**
  String get payrollCalculationDerived;

  /// No description provided for @payrollActionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get payrollActionSave;

  /// No description provided for @payrollActionCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get payrollActionCalculate;

  /// No description provided for @payrollActionSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get payrollActionSaveDraft;

  /// No description provided for @payrollActionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get payrollActionApprove;

  /// No description provided for @payrollActionPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payrollActionPay;

  /// No description provided for @payrollActionRollback.
  ///
  /// In en, this message translates to:
  /// **'Rollback'**
  String get payrollActionRollback;

  /// No description provided for @payrollEmployeeSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee payroll setup'**
  String get payrollEmployeeSetupTitle;

  /// No description provided for @payrollEmployeeAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get payrollEmployeeAddEntry;

  /// No description provided for @payrollEmployeeSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage recurring and one-time payroll entries for this employee.'**
  String get payrollEmployeeSetupSubtitle;

  /// No description provided for @payrollEmployeeEntriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payroll entries yet'**
  String get payrollEmployeeEntriesEmptyTitle;

  /// No description provided for @payrollEmployeeEntriesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add recurring salary items and one-time adjustments for this employee.'**
  String get payrollEmployeeEntriesEmptySubtitle;

  /// No description provided for @payrollQuickPayValidation.
  ///
  /// In en, this message translates to:
  /// **'Select an employee and payroll period first.'**
  String get payrollQuickPayValidation;

  /// No description provided for @payrollQuickPayStatementEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No quick pay statement yet'**
  String get payrollQuickPayStatementEmptyTitle;

  /// No description provided for @payrollQuickPayStatementEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an employee and period to calculate earnings and deductions.'**
  String get payrollQuickPayStatementEmptySubtitle;

  /// No description provided for @payrollPayslipTitle.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get payrollPayslipTitle;

  /// No description provided for @payrollPayslipEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payslip lines found'**
  String get payrollPayslipEmptyTitle;

  /// No description provided for @payrollPayslipEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This payroll run does not have visible lines for the selected employee.'**
  String get payrollPayslipEmptySubtitle;

  /// No description provided for @payrollRunEmployeesLabel.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get payrollRunEmployeesLabel;

  /// No description provided for @payrollRunAllEmployees.
  ///
  /// In en, this message translates to:
  /// **'All active employees'**
  String get payrollRunAllEmployees;

  /// No description provided for @payrollRunValidation.
  ///
  /// In en, this message translates to:
  /// **'Choose a payroll period before calculating.'**
  String get payrollRunValidation;

  /// No description provided for @payrollRunReviewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payroll run draft yet'**
  String get payrollRunReviewEmptyTitle;

  /// No description provided for @payrollRunReviewEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a period and calculate the run to review grouped payroll totals.'**
  String get payrollRunReviewEmptySubtitle;

  /// No description provided for @payrollRunEmployeeSummary.
  ///
  /// In en, this message translates to:
  /// **'{lineCount} lines · net {netPay}'**
  String payrollRunEmployeeSummary(int lineCount, String netPay);

  /// No description provided for @violationTypeBarberLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get violationTypeBarberLate;

  /// No description provided for @violationTypeBarberNoShow.
  ///
  /// In en, this message translates to:
  /// **'Barber no-show'**
  String get violationTypeBarberNoShow;

  /// No description provided for @customerRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get customerRecommendationsTitle;

  /// No description provided for @customerRecommendationBest.
  ///
  /// In en, this message translates to:
  /// **'Best choice'**
  String get customerRecommendationBest;

  /// No description provided for @customerRecommendationFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest available'**
  String get customerRecommendationFastest;

  /// No description provided for @customerRecommendationPreferred.
  ///
  /// In en, this message translates to:
  /// **'Your barber'**
  String get customerRecommendationPreferred;

  /// No description provided for @customerRecommendationAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get customerRecommendationAlternatives;

  /// No description provided for @customerRecommendationUseSlot.
  ///
  /// In en, this message translates to:
  /// **'Use {time} · {barber}'**
  String customerRecommendationUseSlot(String time, String barber);

  /// No description provided for @recommendationReasonExperiencedWithService.
  ///
  /// In en, this message translates to:
  /// **'Experienced with this service'**
  String get recommendationReasonExperiencedWithService;

  /// No description provided for @recommendationReasonNoServiceHistoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Limited recent history for this service'**
  String get recommendationReasonNoServiceHistoryFallback;

  /// No description provided for @recommendationReasonStrongTrackRecord.
  ///
  /// In en, this message translates to:
  /// **'Strong completion record'**
  String get recommendationReasonStrongTrackRecord;

  /// No description provided for @recommendationReasonSoonestTime.
  ///
  /// In en, this message translates to:
  /// **'Soonest open time'**
  String get recommendationReasonSoonestTime;

  /// No description provided for @recommendationReasonPreferredBarber.
  ///
  /// In en, this message translates to:
  /// **'Your preferred barber'**
  String get recommendationReasonPreferredBarber;

  /// No description provided for @recommendationReasonBalancedSchedule.
  ///
  /// In en, this message translates to:
  /// **'Balanced upcoming load'**
  String get recommendationReasonBalancedSchedule;

  /// No description provided for @recommendationReasonMoreAvailabilityToday.
  ///
  /// In en, this message translates to:
  /// **'Earlier slot today'**
  String get recommendationReasonMoreAvailabilityToday;

  /// No description provided for @notificationsCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsCenterTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationsPreferencesTitle;

  /// No description provided for @notificationsPreferencesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationsPreferencesTooltip;

  /// No description provided for @notificationsPrefPushMaster.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notificationsPrefPushMaster;

  /// No description provided for @notificationsPrefBookingReminders.
  ///
  /// In en, this message translates to:
  /// **'Booking reminders'**
  String get notificationsPrefBookingReminders;

  /// No description provided for @notificationsPrefBookingChanges.
  ///
  /// In en, this message translates to:
  /// **'Booking updates'**
  String get notificationsPrefBookingChanges;

  /// No description provided for @notificationsPrefPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll alerts'**
  String get notificationsPrefPayroll;

  /// No description provided for @notificationsPrefViolations.
  ///
  /// In en, this message translates to:
  /// **'Violations and no-shows'**
  String get notificationsPrefViolations;

  /// No description provided for @notificationsPrefMarketing.
  ///
  /// In en, this message translates to:
  /// **'Tips and offers'**
  String get notificationsPrefMarketing;

  /// No description provided for @notificationsPrefMarketingHint.
  ///
  /// In en, this message translates to:
  /// **'Occasional updates from your salon or the app.'**
  String get notificationsPrefMarketingHint;

  /// No description provided for @notificationsInboxTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsInboxTooltip;

  /// No description provided for @customerNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get customerNotificationsTooltip;

  /// No description provided for @customerDiscoveryGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get customerDiscoveryGoodMorning;

  /// No description provided for @customerDiscoveryGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get customerDiscoveryGoodAfternoon;

  /// No description provided for @customerDiscoveryGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get customerDiscoveryGoodEvening;

  /// No description provided for @customerDiscoveryNameWave.
  ///
  /// In en, this message translates to:
  /// **'{name} 👋'**
  String customerDiscoveryNameWave(String name);

  /// No description provided for @customerPromoSalonEyebrow.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No salons to show yet} one{1 salon live} other{{count} salons live}}'**
  String customerPromoSalonEyebrow(int count);

  /// No description provided for @customerPromoServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Services appear as soon as salons publish them.} one{1 active service to browse} other{{count} active services to browse}}'**
  String customerPromoServicesTitle(int count);

  /// No description provided for @customerPromoCta.
  ///
  /// In en, this message translates to:
  /// **'Browse salons'**
  String get customerPromoCta;

  /// No description provided for @customerSectionQuickServices.
  ///
  /// In en, this message translates to:
  /// **'Services from salons'**
  String get customerSectionQuickServices;

  /// No description provided for @customerSectionNearbySalons.
  ///
  /// In en, this message translates to:
  /// **'Salons for you'**
  String get customerSectionNearbySalons;

  /// No description provided for @customerSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get customerSeeAll;

  /// No description provided for @customerSalonDiscoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your salon'**
  String get customerSalonDiscoveryTitle;

  /// No description provided for @customerSalonDiscoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book your next appointment'**
  String get customerSalonDiscoverySubtitle;

  /// No description provided for @customerSalonDiscoverySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search salon, service, area…'**
  String get customerSalonDiscoverySearchHint;

  /// No description provided for @customerSalonDiscoveryNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get customerSalonDiscoveryNearYou;

  /// No description provided for @customerSalonDiscoveryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No salons match yet. Try adjusting filters or search.'**
  String get customerSalonDiscoveryEmpty;

  /// No description provided for @customerSalonDiscoveryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get customerSalonDiscoveryRetry;

  /// No description provided for @customerSalonDiscoveryErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Salon list is unavailable. Check Firestore rules and indexes.'**
  String get customerSalonDiscoveryErrorPermission;

  /// No description provided for @customerSalonDiscoveryBookingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your bookings.'**
  String get customerSalonDiscoveryBookingsSignIn;

  /// No description provided for @customerSalonDiscoveryNavDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get customerSalonDiscoveryNavDiscover;

  /// No description provided for @customerSalonDiscoveryNavBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get customerSalonDiscoveryNavBookings;

  /// No description provided for @customerSalonDiscoveryNavAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get customerSalonDiscoveryNavAccount;

  /// No description provided for @customerSalonBookmarkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save salon'**
  String get customerSalonBookmarkTooltip;

  /// No description provided for @customerSalonStartingFrom.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String customerSalonStartingFrom(String price);

  /// No description provided for @customerSalonOpenNowBadge.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get customerSalonOpenNowBadge;

  /// No description provided for @customerSalonClosedBadge.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get customerSalonClosedBadge;

  /// No description provided for @customerSalonFilterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get customerSalonFilterNearby;

  /// No description provided for @customerSalonFilterOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get customerSalonFilterOpenNow;

  /// No description provided for @customerSalonFilterTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get customerSalonFilterTopRated;

  /// No description provided for @customerSalonFilterOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get customerSalonFilterOffers;

  /// No description provided for @customerSalonFilterLadies.
  ///
  /// In en, this message translates to:
  /// **'Ladies'**
  String get customerSalonFilterLadies;

  /// No description provided for @customerSalonFilterMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get customerSalonFilterMen;

  /// No description provided for @customerSalonFilterUnisex.
  ///
  /// In en, this message translates to:
  /// **'Unisex'**
  String get customerSalonFilterUnisex;

  /// No description provided for @customerProfileTabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get customerProfileTabServices;

  /// No description provided for @customerProfileTabTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get customerProfileTabTeam;

  /// No description provided for @customerProfileTabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get customerProfileTabReviews;

  /// No description provided for @customerProfileTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get customerProfileTabAbout;

  /// No description provided for @customerProfileBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get customerProfileBookAppointment;

  /// No description provided for @customerProfileActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get customerProfileActionCall;

  /// No description provided for @customerProfileActionWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get customerProfileActionWhatsApp;

  /// No description provided for @customerProfileActionMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get customerProfileActionMap;

  /// No description provided for @customerProfileActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get customerProfileActionShare;

  /// No description provided for @customerProfileEmptyServices.
  ///
  /// In en, this message translates to:
  /// **'No services available yet.'**
  String get customerProfileEmptyServices;

  /// No description provided for @customerProfileEmptyTeam.
  ///
  /// In en, this message translates to:
  /// **'No specialists available yet.'**
  String get customerProfileEmptyTeam;

  /// No description provided for @customerProfileEmptyReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get customerProfileEmptyReviews;

  /// No description provided for @customerProfileSalonNotFound.
  ///
  /// In en, this message translates to:
  /// **'This salon is not available.'**
  String get customerProfileSalonNotFound;

  /// No description provided for @customerProfileWorkingHoursPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Opening hours will appear here soon.'**
  String get customerProfileWorkingHoursPlaceholder;

  /// No description provided for @customerProfileMapPreviewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Map preview'**
  String get customerProfileMapPreviewPlaceholder;

  /// No description provided for @customerProfileAboutArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get customerProfileAboutArea;

  /// No description provided for @customerProfileAboutPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customerProfileAboutPhone;

  /// No description provided for @customerProfileAboutGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get customerProfileAboutGender;

  /// No description provided for @customerProfileGenderValue.
  ///
  /// In en, this message translates to:
  /// **'{gender}'**
  String customerProfileGenderValue(String gender);

  /// No description provided for @customerProfileMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String customerProfileMinutesShort(int minutes);

  /// No description provided for @customerServiceSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your services'**
  String get customerServiceSelectionTitle;

  /// No description provided for @customerServiceSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select one or more services'**
  String get customerServiceSelectionSubtitle;

  /// No description provided for @customerServiceSelectionStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 5'**
  String get customerServiceSelectionStepLabel;

  /// No description provided for @customerServiceSelectionProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get customerServiceSelectionProgressTitle;

  /// No description provided for @customerServiceSelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No services available yet.'**
  String get customerServiceSelectionEmpty;

  /// No description provided for @customerServiceSelectionSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String customerServiceSelectionSelectedCount(int count);

  /// No description provided for @customerServiceSelectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} min · Total: {total}'**
  String customerServiceSelectionSummary(int minutes, String total);

  /// No description provided for @customerServiceSelectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get customerServiceSelectionContinue;

  /// No description provided for @customerServiceSelectionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get customerServiceSelectionClear;

  /// No description provided for @customerServiceSelectionRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Select at least one service to continue.'**
  String get customerServiceSelectionRequiredSnack;

  /// No description provided for @customerServiceSelectionComingNext.
  ///
  /// In en, this message translates to:
  /// **'Service selection is coming next.\n\nSalon id:\n{salonId}'**
  String customerServiceSelectionComingNext(String salonId);

  /// No description provided for @customerTeamSelectionComingNext.
  ///
  /// In en, this message translates to:
  /// **'Team selection is coming next.\n\nSalon id:\n{salonId}'**
  String customerTeamSelectionComingNext(String salonId);

  /// No description provided for @customerTeamSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your specialist'**
  String get customerTeamSelectionTitle;

  /// No description provided for @customerTeamSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a team member or any available'**
  String get customerTeamSelectionSubtitle;

  /// No description provided for @customerTeamSelectionStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 5'**
  String get customerTeamSelectionStepLabel;

  /// No description provided for @customerTeamSelectionProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get customerTeamSelectionProgressTitle;

  /// No description provided for @customerTeamSelectionAnyTitle.
  ///
  /// In en, this message translates to:
  /// **'Any Available Specialist'**
  String get customerTeamSelectionAnyTitle;

  /// No description provided for @customerTeamSelectionAnySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will assign the best available specialist for your selected time.'**
  String get customerTeamSelectionAnySubtitle;

  /// No description provided for @customerTeamSelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No specialists available yet.'**
  String get customerTeamSelectionEmpty;

  /// No description provided for @customerTeamSelectionRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialist to continue.'**
  String get customerTeamSelectionRequiredSnack;

  /// No description provided for @customerTeamSelectionServicesRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one service first.'**
  String get customerTeamSelectionServicesRequiredSnack;

  /// No description provided for @customerTeamSelectionNoStaffHint.
  ///
  /// In en, this message translates to:
  /// **'Add bookable team members to continue.'**
  String get customerTeamSelectionNoStaffHint;

  /// No description provided for @customerTeamSelectionRating.
  ///
  /// In en, this message translates to:
  /// **'Rating {rating} ({count})'**
  String customerTeamSelectionRating(String rating, int count);

  /// No description provided for @customerDateTimeSelectionComingNext.
  ///
  /// In en, this message translates to:
  /// **'Date & time selection is coming next.\n\nSalon id:\n{salonId}'**
  String customerDateTimeSelectionComingNext(String salonId);

  /// No description provided for @customerDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose date & time'**
  String get customerDateTimeTitle;

  /// No description provided for @customerDateTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an available appointment slot'**
  String get customerDateTimeSubtitle;

  /// No description provided for @customerDateTimeStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 5'**
  String get customerDateTimeStepLabel;

  /// No description provided for @customerDateTimeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get customerDateTimeProgressTitle;

  /// No description provided for @customerDateTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get customerDateTimeToday;

  /// No description provided for @customerDateTimeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get customerDateTimeTomorrow;

  /// No description provided for @customerDateTimeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get customerDateTimeMorning;

  /// No description provided for @customerDateTimeAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get customerDateTimeAfternoon;

  /// No description provided for @customerDateTimeEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get customerDateTimeEvening;

  /// No description provided for @customerDateTimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No available slots'**
  String get customerDateTimeEmpty;

  /// No description provided for @customerDateTimeChooseAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Please choose another date'**
  String get customerDateTimeChooseAnotherDate;

  /// No description provided for @customerDateTimeRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Select an available time to continue.'**
  String get customerDateTimeRequiredSnack;

  /// No description provided for @customerDateTimeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} services · {specialist}'**
  String customerDateTimeSummaryTitle(int count, String specialist);

  /// No description provided for @customerDateTimeSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} min · Total: {total}'**
  String customerDateTimeSummarySubtitle(int minutes, String total);

  /// No description provided for @customerDetailsComingNext.
  ///
  /// In en, this message translates to:
  /// **'Customer details coming next.\n\nSalon id:\n{salonId}'**
  String customerDetailsComingNext(String salonId);

  /// No description provided for @customerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get customerDetailsTitle;

  /// No description provided for @customerDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add contact details for your appointment'**
  String get customerDetailsSubtitle;

  /// No description provided for @customerDetailsStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 4 of 5'**
  String get customerDetailsStepLabel;

  /// No description provided for @customerDetailsProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get customerDetailsProgressTitle;

  /// No description provided for @customerDetailsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get customerDetailsFullName;

  /// No description provided for @customerDetailsPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get customerDetailsPhoneNumber;

  /// No description provided for @customerDetailsGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get customerDetailsGender;

  /// No description provided for @customerDetailsGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get customerDetailsGenderMale;

  /// No description provided for @customerDetailsGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get customerDetailsGenderFemale;

  /// No description provided for @customerDetailsGenderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get customerDetailsGenderPreferNotToSay;

  /// No description provided for @customerDetailsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get customerDetailsNotes;

  /// No description provided for @customerDetailsNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any notes for the salon?'**
  String get customerDetailsNotesHint;

  /// No description provided for @customerDetailsPhoneInfo.
  ///
  /// In en, this message translates to:
  /// **'We will use your phone number only to confirm and find your booking.'**
  String get customerDetailsPhoneInfo;

  /// No description provided for @customerDetailsRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get customerDetailsRequiredField;

  /// No description provided for @customerDetailsInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get customerDetailsInvalidPhone;

  /// No description provided for @customerDetailsNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get customerDetailsNameTooShort;

  /// No description provided for @customerDetailsNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Notes cannot exceed 300 characters'**
  String get customerDetailsNotesTooLong;

  /// No description provided for @customerDetailsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} services · {specialist}'**
  String customerDetailsSummaryTitle(int count, String specialist);

  /// No description provided for @customerDetailsSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{dateTime} · {total}'**
  String customerDetailsSummarySubtitle(String dateTime, String total);

  /// No description provided for @customerBookingReviewComingNext.
  ///
  /// In en, this message translates to:
  /// **'Booking review coming next.\n\nSalon id:\n{salonId}'**
  String customerBookingReviewComingNext(String salonId);

  /// No description provided for @customerBookingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review booking'**
  String get customerBookingReviewTitle;

  /// No description provided for @customerBookingReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your appointment details before confirming'**
  String get customerBookingReviewSubtitle;

  /// No description provided for @customerBookingReviewStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 5 of 5'**
  String get customerBookingReviewStepLabel;

  /// No description provided for @customerBookingReviewProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get customerBookingReviewProgressTitle;

  /// No description provided for @customerBookingReviewSalon.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get customerBookingReviewSalon;

  /// No description provided for @customerBookingReviewServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get customerBookingReviewServices;

  /// No description provided for @customerBookingReviewSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get customerBookingReviewSpecialist;

  /// No description provided for @customerBookingReviewDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get customerBookingReviewDateTime;

  /// No description provided for @customerBookingReviewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerBookingReviewCustomer;

  /// No description provided for @customerBookingReviewPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get customerBookingReviewPaymentSummary;

  /// No description provided for @customerBookingReviewSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get customerBookingReviewSubtotal;

  /// No description provided for @customerBookingReviewDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get customerBookingReviewDiscount;

  /// No description provided for @customerBookingReviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get customerBookingReviewTotal;

  /// No description provided for @customerBookingReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get customerBookingReviewConfirm;

  /// No description provided for @customerBookingReviewSlotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This time slot is no longer available. Please choose another time.'**
  String get customerBookingReviewSlotUnavailable;

  /// No description provided for @customerBookingReviewChooseSpecialistAgain.
  ///
  /// In en, this message translates to:
  /// **'Please choose a specialist again.'**
  String get customerBookingReviewChooseSpecialistAgain;

  /// No description provided for @customerBookingReviewGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get customerBookingReviewGenericError;

  /// No description provided for @customerBookingSuccessPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed\n\nBooking code:\n{bookingCode}'**
  String customerBookingSuccessPlaceholder(String bookingCode);

  /// No description provided for @customerBookingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get customerBookingSuccessTitle;

  /// No description provided for @customerBookingSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been saved successfully.'**
  String get customerBookingSuccessSubtitle;

  /// No description provided for @customerBookingSuccessCode.
  ///
  /// In en, this message translates to:
  /// **'Booking code'**
  String get customerBookingSuccessCode;

  /// No description provided for @customerBookingSuccessStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get customerBookingSuccessStatus;

  /// No description provided for @customerBookingSuccessDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get customerBookingSuccessDate;

  /// No description provided for @customerBookingSuccessTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get customerBookingSuccessTime;

  /// No description provided for @customerBookingSuccessStatusFallback.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get customerBookingSuccessStatusFallback;

  /// No description provided for @customerBookingSuccessFallback.
  ///
  /// In en, this message translates to:
  /// **'Available in booking details'**
  String get customerBookingSuccessFallback;

  /// No description provided for @customerBookingSuccessSaveCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Save your booking code. You can use it later to find your appointment.'**
  String get customerBookingSuccessSaveCodeInfo;

  /// No description provided for @customerBookingSuccessViewBooking.
  ///
  /// In en, this message translates to:
  /// **'View booking'**
  String get customerBookingSuccessViewBooking;

  /// No description provided for @customerBookingSuccessBookAnother.
  ///
  /// In en, this message translates to:
  /// **'Book another appointment'**
  String get customerBookingSuccessBookAnother;

  /// No description provided for @customerBookingSuccessBackToSalon.
  ///
  /// In en, this message translates to:
  /// **'Back to salon'**
  String get customerBookingSuccessBackToSalon;

  /// No description provided for @customerBookingSuccessCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Booking code copied.'**
  String get customerBookingSuccessCodeCopied;

  /// No description provided for @customerBookingLookupTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your booking'**
  String get customerBookingLookupTitle;

  /// No description provided for @customerBookingLookupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to view your appointment'**
  String get customerBookingLookupSubtitle;

  /// No description provided for @customerBookingLookupPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get customerBookingLookupPhoneNumber;

  /// No description provided for @customerBookingLookupBookingCode.
  ///
  /// In en, this message translates to:
  /// **'Booking code'**
  String get customerBookingLookupBookingCode;

  /// No description provided for @customerBookingLookupBookingCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Booking code optional'**
  String get customerBookingLookupBookingCodeOptional;

  /// No description provided for @customerBookingLookupSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get customerBookingLookupSearch;

  /// No description provided for @customerBookingLookupPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Use the same phone number you used when booking.'**
  String get customerBookingLookupPhoneHint;

  /// No description provided for @customerBookingLookupNoBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get customerBookingLookupNoBookings;

  /// No description provided for @customerBookingLookupViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get customerBookingLookupViewDetails;

  /// No description provided for @customerBookingStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get customerBookingStatusPending;

  /// No description provided for @customerBookingStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get customerBookingStatusConfirmed;

  /// No description provided for @customerBookingStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get customerBookingStatusCheckedIn;

  /// No description provided for @customerBookingStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get customerBookingStatusCompleted;

  /// No description provided for @customerBookingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get customerBookingStatusCancelled;

  /// No description provided for @customerBookingStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get customerBookingStatusNoShow;

  /// No description provided for @customerBookingLookupInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get customerBookingLookupInvalidPhone;

  /// No description provided for @customerBookingLookupGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get customerBookingLookupGenericError;

  /// No description provided for @customerBookingLookupAnySpecialist.
  ///
  /// In en, this message translates to:
  /// **'Any available specialist'**
  String get customerBookingLookupAnySpecialist;

  /// No description provided for @customerBookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get customerBookingDetailsTitle;

  /// No description provided for @customerBookingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your appointment information'**
  String get customerBookingDetailsSubtitle;

  /// No description provided for @customerBookingDetailsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get customerBookingDetailsCopied;

  /// No description provided for @customerBookingDetailsDurationPrice.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {price}'**
  String customerBookingDetailsDurationPrice(int minutes, String price);

  /// No description provided for @customerBookingDetailsTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get customerBookingDetailsTimelineTitle;

  /// No description provided for @customerBookingDetailsTimelineCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get customerBookingDetailsTimelineCreated;

  /// No description provided for @customerBookingDetailsTimelineUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get customerBookingDetailsTimelineUpcoming;

  /// No description provided for @customerBookingDetailsTimelineConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get customerBookingDetailsTimelineConfirmed;

  /// No description provided for @customerBookingDetailsPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending confirmation'**
  String get customerBookingDetailsPendingConfirmation;

  /// No description provided for @customerBookingDetailsSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get customerBookingDetailsSpecialist;

  /// No description provided for @customerBookingDetailsCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get customerBookingDetailsCall;

  /// No description provided for @customerBookingDetailsWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get customerBookingDetailsWhatsApp;

  /// No description provided for @customerBookingDetailsWhatsAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello — I have a question about my booking.'**
  String get customerBookingDetailsWhatsAppMessage;

  /// No description provided for @customerBookingDetailsPhoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number is not available'**
  String get customerBookingDetailsPhoneUnavailable;

  /// No description provided for @customerBookingDetailsReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get customerBookingDetailsReschedule;

  /// No description provided for @customerBookingDetailsCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get customerBookingDetailsCancelBooking;

  /// No description provided for @customerBookingDetailsLeaveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Leave feedback'**
  String get customerBookingDetailsLeaveFeedback;

  /// No description provided for @customerBookingDetailsBookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book again'**
  String get customerBookingDetailsBookAgain;

  /// No description provided for @customerBookingDetailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get customerBookingDetailsComingSoon;

  /// No description provided for @customerBookingDetailsActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s next?'**
  String get customerBookingDetailsActionsTitle;

  /// No description provided for @customerBookingDetailsArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get customerBookingDetailsArea;

  /// No description provided for @customerCancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get customerCancelBookingTitle;

  /// No description provided for @customerCancelBookingConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get customerCancelBookingConfirmMessage;

  /// No description provided for @customerCancelBookingReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get customerCancelBookingReasonLabel;

  /// No description provided for @customerCancelBookingReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason optional'**
  String get customerCancelBookingReasonHint;

  /// No description provided for @customerCancelBookingKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get customerCancelBookingKeep;

  /// No description provided for @customerCancelBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm cancellation'**
  String get customerCancelBookingConfirm;

  /// No description provided for @customerCancelBookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully'**
  String get customerCancelBookingSuccess;

  /// No description provided for @customerCancelBookingCannotCancelOnline.
  ///
  /// In en, this message translates to:
  /// **'This booking cannot be cancelled online.'**
  String get customerCancelBookingCannotCancelOnline;

  /// No description provided for @customerCancelBookingTooCloseToStart.
  ///
  /// In en, this message translates to:
  /// **'This booking is too close to the appointment time to cancel online. Please contact the salon.'**
  String get customerCancelBookingTooCloseToStart;

  /// No description provided for @customerCancelBookingReasonTooLong.
  ///
  /// In en, this message translates to:
  /// **'Reason cannot exceed 200 characters'**
  String get customerCancelBookingReasonTooLong;

  /// No description provided for @customerRescheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new appointment time'**
  String get customerRescheduleSubtitle;

  /// No description provided for @customerRescheduleCurrentAppointment.
  ///
  /// In en, this message translates to:
  /// **'Current appointment'**
  String get customerRescheduleCurrentAppointment;

  /// No description provided for @customerRescheduleNewAppointment.
  ///
  /// In en, this message translates to:
  /// **'New appointment'**
  String get customerRescheduleNewAppointment;

  /// No description provided for @customerRescheduleConfirmTime.
  ///
  /// In en, this message translates to:
  /// **'Confirm new time'**
  String get customerRescheduleConfirmTime;

  /// No description provided for @customerRescheduleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking rescheduled successfully'**
  String get customerRescheduleSuccess;

  /// No description provided for @customerRescheduleCannotOnline.
  ///
  /// In en, this message translates to:
  /// **'This booking cannot be rescheduled online.'**
  String get customerRescheduleCannotOnline;

  /// No description provided for @customerRescheduleTooCloseToStart.
  ///
  /// In en, this message translates to:
  /// **'This booking is too close to the appointment time to reschedule online. Please contact the salon.'**
  String get customerRescheduleTooCloseToStart;

  /// No description provided for @customerRescheduleNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No available slots'**
  String get customerRescheduleNoSlots;

  /// No description provided for @customerRescheduleChooseAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Please choose another date'**
  String get customerRescheduleChooseAnotherDate;

  /// No description provided for @customerRescheduleStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get customerRescheduleStepLabel;

  /// No description provided for @customerRescheduleProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'New time'**
  String get customerRescheduleProgressTitle;

  /// No description provided for @customerFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave feedback'**
  String get customerFeedbackTitle;

  /// No description provided for @customerFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your appointment'**
  String get customerFeedbackSubtitle;

  /// No description provided for @customerFeedbackCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get customerFeedbackCommentHint;

  /// No description provided for @customerFeedbackCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get customerFeedbackCommentLabel;

  /// No description provided for @customerFeedbackRatingSection.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get customerFeedbackRatingSection;

  /// No description provided for @customerFeedbackWouldComeAgain.
  ///
  /// In en, this message translates to:
  /// **'Would you come again?'**
  String get customerFeedbackWouldComeAgain;

  /// No description provided for @customerFeedbackYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get customerFeedbackYes;

  /// No description provided for @customerFeedbackNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get customerFeedbackNo;

  /// No description provided for @customerFeedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get customerFeedbackSubmit;

  /// No description provided for @customerFeedbackThankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback'**
  String get customerFeedbackThankYouTitle;

  /// No description provided for @customerFeedbackThankYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We appreciate you taking the time.'**
  String get customerFeedbackThankYouSubtitle;

  /// No description provided for @customerFeedbackAlreadySubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback already submitted'**
  String get customerFeedbackAlreadySubmittedTitle;

  /// No description provided for @customerFeedbackAlreadySubmittedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can view this booking anytime from booking lookup.'**
  String get customerFeedbackAlreadySubmittedSubtitle;

  /// No description provided for @customerFeedbackSubmittedBadge.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted'**
  String get customerFeedbackSubmittedBadge;

  /// No description provided for @customerFeedbackBackToDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to booking details'**
  String get customerFeedbackBackToDetails;

  /// No description provided for @customerFeedbackRatingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get customerFeedbackRatingPoor;

  /// No description provided for @customerFeedbackRatingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get customerFeedbackRatingFair;

  /// No description provided for @customerFeedbackRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get customerFeedbackRatingGood;

  /// No description provided for @customerFeedbackRatingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get customerFeedbackRatingVeryGood;

  /// No description provided for @customerFeedbackRatingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get customerFeedbackRatingExcellent;

  /// No description provided for @customerFeedbackRatingRequired.
  ///
  /// In en, this message translates to:
  /// **'Rating is required'**
  String get customerFeedbackRatingRequired;

  /// No description provided for @customerFeedbackCommentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Comment cannot exceed 500 characters'**
  String get customerFeedbackCommentTooLong;

  /// No description provided for @customerFeedbackOnlyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Feedback can only be submitted for completed bookings.'**
  String get customerFeedbackOnlyCompleted;

  /// No description provided for @customerFeedbackGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get customerFeedbackGenericError;

  /// No description provided for @customerSalonBadgeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get customerSalonBadgeOpen;

  /// No description provided for @customerStatBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get customerStatBookings;

  /// No description provided for @customerStatSalonsVisited.
  ///
  /// In en, this message translates to:
  /// **'Salons visited'**
  String get customerStatSalonsVisited;

  /// No description provided for @customerStatUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get customerStatUpcoming;

  /// No description provided for @customerProfileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get customerProfileEdit;

  /// No description provided for @customerSettingsTileNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Booking alerts & reminders'**
  String get customerSettingsTileNotificationsSubtitle;

  /// No description provided for @customerSettingsTileBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming and past visits'**
  String get customerSettingsTileBookingsSubtitle;

  /// No description provided for @customerAppFooterVersion.
  ///
  /// In en, this message translates to:
  /// **'{appName} v{version}'**
  String customerAppFooterVersion(String appName, String version);

  /// No description provided for @customerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get customerProfileTitle;

  /// No description provided for @ownerInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart insights'**
  String get ownerInsightsTitle;

  /// No description provided for @ownerInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly highlights from sales and bookings (updates every Monday).'**
  String get ownerInsightsSubtitle;

  /// No description provided for @ownerInsightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Insights will appear after the weekly summary runs.'**
  String get ownerInsightsEmpty;

  /// No description provided for @ownerInsightsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load insights.'**
  String get ownerInsightsError;

  /// No description provided for @ownerRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer retention'**
  String get ownerRetentionTitle;

  /// No description provided for @ownerRetentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on completed visits and no-shows (salon timezone when set).'**
  String get ownerRetentionSubtitle;

  /// No description provided for @ownerRetentionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Retention metrics will appear after the weekly job runs.'**
  String get ownerRetentionEmpty;

  /// No description provided for @ownerRetentionMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'{year}-{month}'**
  String ownerRetentionMonthLabel(int year, String month);

  /// No description provided for @ownerRetentionTimeZoneUsed.
  ///
  /// In en, this message translates to:
  /// **'Timezone: {tz}'**
  String ownerRetentionTimeZoneUsed(String tz);

  /// No description provided for @ownerRetentionRepeatCustomers.
  ///
  /// In en, this message translates to:
  /// **'Repeat customers this month'**
  String get ownerRetentionRepeatCustomers;

  /// No description provided for @ownerRetentionFirstTimeCustomers.
  ///
  /// In en, this message translates to:
  /// **'First-time customers this month'**
  String get ownerRetentionFirstTimeCustomers;

  /// No description provided for @ownerRetentionDistinctThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Customers with a completed visit (MTD)'**
  String get ownerRetentionDistinctThisMonth;

  /// No description provided for @ownerRetentionReturningThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Returning customers (had a prior visit)'**
  String get ownerRetentionReturningThisMonth;

  /// No description provided for @ownerRetentionRate.
  ///
  /// In en, this message translates to:
  /// **'Retention rate'**
  String get ownerRetentionRate;

  /// No description provided for @ownerRetentionInactive30Days.
  ///
  /// In en, this message translates to:
  /// **'Customers with no visit in 30 days'**
  String get ownerRetentionInactive30Days;

  /// No description provided for @ownerRetentionNoShowTrend.
  ///
  /// In en, this message translates to:
  /// **'No-show trend (local weeks)'**
  String get ownerRetentionNoShowTrend;

  /// No description provided for @ownerRetentionNoShowLastLocalWeek.
  ///
  /// In en, this message translates to:
  /// **'Last completed local week'**
  String get ownerRetentionNoShowLastLocalWeek;

  /// No description provided for @ownerRetentionNoShowPreviousLocalWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous local week'**
  String get ownerRetentionNoShowPreviousLocalWeek;

  /// No description provided for @ownerRetentionNoShowDelta.
  ///
  /// In en, this message translates to:
  /// **'Change vs previous week'**
  String get ownerRetentionNoShowDelta;

  /// No description provided for @ownerRetentionDeltaFlat.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get ownerRetentionDeltaFlat;

  /// No description provided for @ownerRetentionDeltaUp.
  ///
  /// In en, this message translates to:
  /// **'+{n}'**
  String ownerRetentionDeltaUp(int n);

  /// No description provided for @ownerRetentionDeltaDown.
  ///
  /// In en, this message translates to:
  /// **'−{n}'**
  String ownerRetentionDeltaDown(int n);

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app.'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @onboardingLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onboardingLanguageEnglish;

  /// No description provided for @onboardingLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get onboardingLanguageArabic;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Country / region'**
  String get onboardingCountryTitle;

  /// No description provided for @onboardingCountrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used for formats and future regional options.'**
  String get onboardingCountrySubtitle;

  /// No description provided for @preAuthLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get preAuthLanguageTitle;

  /// No description provided for @preAuthLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to use in the app'**
  String get preAuthLanguageSubtitle;

  /// No description provided for @preAuthLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get preAuthLanguageEnglish;

  /// No description provided for @preAuthLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get preAuthLanguageArabic;

  /// No description provided for @preAuthContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get preAuthContinue;

  /// No description provided for @preAuthCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your country'**
  String get preAuthCountryTitle;

  /// No description provided for @preAuthCountrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us tailor the app experience'**
  String get preAuthCountrySubtitle;

  /// No description provided for @preAuthRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use the app?'**
  String get preAuthRoleTitle;

  /// No description provided for @preAuthRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the experience that fits you best'**
  String get preAuthRoleSubtitle;

  /// No description provided for @preAuthRoleCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get preAuthRoleCustomerTitle;

  /// No description provided for @preAuthRoleCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers sign in with email. Salon staff sign in with username.'**
  String get preAuthRoleCustomerSubtitle;

  /// No description provided for @preAuthRoleOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon Owner'**
  String get preAuthRoleOwnerTitle;

  /// No description provided for @preAuthRoleOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your salon, team, bookings, and business'**
  String get preAuthRoleOwnerSubtitle;

  /// No description provided for @startupEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get startupEntryTitle;

  /// No description provided for @startupEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to get started'**
  String get startupEntrySubtitle;

  /// No description provided for @startupBookOrAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Book or Access Services'**
  String get startupBookOrAccessTitle;

  /// No description provided for @startupBookOrAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find salons, book visits, or continue with your team access'**
  String get startupBookOrAccessSubtitle;

  /// No description provided for @startupManageSalonTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage My Salon'**
  String get startupManageSalonTitle;

  /// No description provided for @startupManageSalonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners sign in to run the business, team, and revenue'**
  String get startupManageSalonSubtitle;

  /// No description provided for @startupContinueAsUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue as User'**
  String get startupContinueAsUserTitle;

  /// No description provided for @startupContinueAsUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book visits, explore salons, or sign in as staff'**
  String get startupContinueAsUserSubtitle;

  /// No description provided for @startupOwnSalonTitle.
  ///
  /// In en, this message translates to:
  /// **'I Own a Salon'**
  String get startupOwnSalonTitle;

  /// No description provided for @startupOwnSalonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your business, team, bookings, and revenue'**
  String get startupOwnSalonSubtitle;

  /// No description provided for @userSelectionContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to continue'**
  String get userSelectionContinueTitle;

  /// No description provided for @userSelectionContinueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the path that matches you'**
  String get userSelectionContinueSubtitle;

  /// No description provided for @userSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use the app?'**
  String get userSelectionTitle;

  /// No description provided for @userSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers and salon staff use different sign-in methods'**
  String get userSelectionSubtitle;

  /// No description provided for @userSelectionCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue as Customer'**
  String get userSelectionCustomerTitle;

  /// No description provided for @userSelectionCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse salons and book appointments with email'**
  String get userSelectionCustomerSubtitle;

  /// No description provided for @userSelectionStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue as Staff'**
  String get userSelectionStaffTitle;

  /// No description provided for @userSelectionStaffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the username your salon shared with you'**
  String get userSelectionStaffSubtitle;

  /// No description provided for @customerProfileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get customerProfileSetupTitle;

  /// No description provided for @customerProfileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick step before you create your account'**
  String get customerProfileSetupSubtitle;

  /// No description provided for @customerProfileSetupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get customerProfileSetupContinue;

  /// No description provided for @customerProfileSetupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get customerProfileSetupNameLabel;

  /// No description provided for @customerProfileSetupNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get customerProfileSetupNameError;

  /// No description provided for @customerProfileSetupPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get customerProfileSetupPhoneLabel;

  /// No description provided for @staffLoginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Staff sign in'**
  String get staffLoginHeadline;

  /// No description provided for @staffLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the email and password your salon owner created for you, or your staff username.'**
  String get staffLoginSubtitle;

  /// No description provided for @staffLoginNoSignupHint.
  ///
  /// In en, this message translates to:
  /// **'Team accounts are created by your salon. Contact the owner if you need access.'**
  String get staffLoginNoSignupHint;

  /// No description provided for @preAuthSlideSalonTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Salons Near You'**
  String get preAuthSlideSalonTitle;

  /// No description provided for @preAuthSlideSalonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find top-rated salons and beauty experts near you — anytime, anywhere.'**
  String get preAuthSlideSalonSubtitle;

  /// No description provided for @preAuthSlideBarberTitle.
  ///
  /// In en, this message translates to:
  /// **'Book in Seconds'**
  String get preAuthSlideBarberTitle;

  /// No description provided for @preAuthSlideBarberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your barber, pick a time, and confirm instantly.'**
  String get preAuthSlideBarberSubtitle;

  /// No description provided for @preAuthSlideBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in Control'**
  String get preAuthSlideBookingTitle;

  /// No description provided for @preAuthSlideBookingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage bookings, save favorites, and enjoy a seamless experience.'**
  String get preAuthSlideBookingSubtitle;

  /// No description provided for @preAuthNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get preAuthNext;

  /// No description provided for @preAuthGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get preAuthGetStarted;

  /// No description provided for @preAuthSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get preAuthSkip;

  /// No description provided for @authGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authGateTitle;

  /// No description provided for @authGateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in, create a customer account to book visits, or register a new salon.'**
  String get authGateSubtitle;

  /// No description provided for @authGateSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authGateSignIn;

  /// No description provided for @authGateCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create customer account'**
  String get authGateCreateAccount;

  /// No description provided for @authGateCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For booking appointments only. Salon owners use “Create salon” below.'**
  String get authGateCreateAccountSubtitle;

  /// No description provided for @authGateRegionSettings.
  ///
  /// In en, this message translates to:
  /// **'Language & region settings'**
  String get authGateRegionSettings;

  /// No description provided for @appSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettingsTitle;

  /// No description provided for @appSettingsIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Customize preferences and manage settings for your salon workflow.'**
  String get appSettingsIntroBody;

  /// No description provided for @appSettingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get appSettingsLanguageSubtitle;

  /// No description provided for @appSettingsCountrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your current operating region'**
  String get appSettingsCountrySubtitle;

  /// No description provided for @appSettingsChangeAnytimeBanner.
  ///
  /// In en, this message translates to:
  /// **'You can change these anytime.'**
  String get appSettingsChangeAnytimeBanner;

  /// No description provided for @appSettingsMoreActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App information, privacy and other options'**
  String get appSettingsMoreActionSubtitle;

  /// No description provided for @signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutDialogTitle;

  /// No description provided for @hrViolationsSummaryAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get hrViolationsSummaryAwaitingApproval;

  /// No description provided for @hrViolationsSummaryActiveRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Penalty rules enabled'**
  String get hrViolationsSummaryActiveRulesSubtitle;

  /// No description provided for @hrViolationsSummaryStaffFlaggedTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff flagged'**
  String get hrViolationsSummaryStaffFlaggedTitle;

  /// No description provided for @hrViolationsEnabledChip.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get hrViolationsEnabledChip;

  /// No description provided for @hrViolationsDisabledChip.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get hrViolationsDisabledChip;

  /// No description provided for @hrViolationsLateRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Late arrival rule'**
  String get hrViolationsLateRuleTitle;

  /// No description provided for @hrViolationsNoShowRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'No-show rule'**
  String get hrViolationsNoShowRuleTitle;

  /// No description provided for @hrViolationsGraceTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grace time'**
  String get hrViolationsGraceTimeLabel;

  /// No description provided for @hrViolationsPendingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending violation requests'**
  String get hrViolationsPendingEmptyTitle;

  /// No description provided for @hrViolationsPendingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up. Any violation requests will appear here.'**
  String get hrViolationsPendingEmptyBody;

  /// No description provided for @hrViolationsAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get hrViolationsAddRule;

  /// No description provided for @hrViolationsAddRuleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More rule types are coming soon.'**
  String get hrViolationsAddRuleComingSoon;

  /// No description provided for @hrViolationsToggleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Update penalty rule?'**
  String get hrViolationsToggleConfirmTitle;

  /// No description provided for @hrViolationsToggleConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This affects payroll and deductions for your team.'**
  String get hrViolationsToggleConfirmBody;

  /// No description provided for @hrViolationsToggleConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get hrViolationsToggleConfirmAction;

  /// No description provided for @hrViolationsSummaryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load HR summary.'**
  String get hrViolationsSummaryLoadError;

  /// No description provided for @appSettingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appSettingsLanguageSection;

  /// No description provided for @appSettingsCountrySection.
  ///
  /// In en, this message translates to:
  /// **'Country / region'**
  String get appSettingsCountrySection;

  /// No description provided for @appSettingsCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get appSettingsCountryLabel;

  /// No description provided for @appSettingsCountryHint.
  ///
  /// In en, this message translates to:
  /// **'You can change these anytime here.'**
  String get appSettingsCountryHint;

  /// No description provided for @appSettingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appSettingsAppearanceSection;

  /// No description provided for @appSettingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appSettingsThemeLight;

  /// No description provided for @appSettingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appSettingsThemeDark;

  /// No description provided for @appSettingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appSettingsThemeSystem;

  /// No description provided for @appSettingsMoreSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get appSettingsMoreSectionTitle;

  /// No description provided for @appSettingsMoreSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences and other options will expand here over time.'**
  String get appSettingsMoreSectionBody;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'We need your email so we can sign you in securely.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a valid email format, like name@salon.com.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a password to protect your account.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get validationPasswordShort;

  /// No description provided for @validationPasswordMinSixChars.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get validationPasswordMinSixChars;

  /// No description provided for @authSignupTitleCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignupTitleCreateAccount;

  /// No description provided for @authSignupSubtitleGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get authSignupSubtitleGetStarted;

  /// No description provided for @authSignupPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignupPrimaryCta;

  /// No description provided for @authSignupPasswordHintMinSix.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authSignupPasswordHintMinSix;

  /// No description provided for @registerHintPhone.
  ///
  /// In en, this message translates to:
  /// **'Your mobile number'**
  String get registerHintPhone;

  /// No description provided for @registerHintCity.
  ///
  /// In en, this message translates to:
  /// **'Doha'**
  String get registerHintCity;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a phone number your team and clients can reach.'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneShort.
  ///
  /// In en, this message translates to:
  /// **'That number looks too short—include the full local or mobile number.'**
  String get validationPhoneShort;

  /// No description provided for @validationPhoneOptionalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number or leave this field empty.'**
  String get validationPhoneOptionalInvalid;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required.'**
  String validationFieldRequired(String fieldName);

  /// No description provided for @validationConfirmPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password so we know it was typed correctly.'**
  String get validationConfirmPasswordEmpty;

  /// No description provided for @validationConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Those passwords do not match. Try again.'**
  String get validationConfirmPasswordMismatch;

  /// No description provided for @validationUserLoginIdentifierRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username.'**
  String get validationUserLoginIdentifierRequired;

  /// No description provided for @validationStaffUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get validationStaffUsernameRequired;

  /// No description provided for @validationStaffUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 4–20 characters: lowercase letters, numbers, underscore, or dot only.'**
  String get validationStaffUsernameInvalid;

  /// No description provided for @fieldLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldLabelName;

  /// No description provided for @fieldLabelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldLabelFullName;

  /// No description provided for @fieldLabelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldLabelEmail;

  /// No description provided for @fieldLabelEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get fieldLabelEmailOrUsername;

  /// No description provided for @fieldLabelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldLabelPassword;

  /// No description provided for @fieldLabelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldLabelConfirmPassword;

  /// No description provided for @fieldLabelSalonName.
  ///
  /// In en, this message translates to:
  /// **'Salon name'**
  String get fieldLabelSalonName;

  /// No description provided for @fieldLabelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldLabelPhone;

  /// No description provided for @fieldLabelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldLabelAddress;

  /// No description provided for @authCommonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authCommonBack;

  /// No description provided for @authCommonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get authCommonSettings;

  /// No description provided for @authGateCreateSalon.
  ///
  /// In en, this message translates to:
  /// **'Create salon'**
  String get authGateCreateSalon;

  /// No description provided for @authGateCreateSalonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register as a salon owner, then set up your workspace. If you already have an account, sign in.'**
  String get authGateCreateSalonSubtitle;

  /// No description provided for @loginEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginEyebrow;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get loginTitle;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Book appointments as a customer or run your business as a salon owner. Team accounts sign in here too.'**
  String get loginDescription;

  /// No description provided for @loginSectionEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email & password'**
  String get loginSectionEmailPassword;

  /// No description provided for @loginSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners and customers use the same login. Your dashboard depends on your role.'**
  String get loginSectionSubtitle;

  /// No description provided for @loginHintIdentifier.
  ///
  /// In en, this message translates to:
  /// **'you@example.com or salon.username'**
  String get loginHintIdentifier;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignInButton;

  /// No description provided for @loginFooterCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get loginFooterCreateAccount;

  /// No description provided for @loginTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Barber and admin accounts are created by your salon owner. Sign in with the username they gave you.'**
  String get loginTeamHint;

  /// No description provided for @registerEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerEyebrow;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the platform.'**
  String get registerTitle;

  /// No description provided for @registerDescription.
  ///
  /// In en, this message translates to:
  /// **'After you register, you will choose customer or salon owner. Barber and admin accounts are created by the salon owner—use sign in instead.'**
  String get registerDescription;

  /// No description provided for @registerCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your customer account.'**
  String get registerCustomerTitle;

  /// No description provided for @registerCustomerDescription.
  ///
  /// In en, this message translates to:
  /// **'Book visits, see your history, and manage your profile. Barber and admin accounts are created by the salon owner—use sign in instead.'**
  String get registerCustomerDescription;

  /// No description provided for @registerSalonOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register as a salon owner.'**
  String get registerSalonOwnerTitle;

  /// No description provided for @registerSalonOwnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Next, you will add your salon details. If you already have an account, go back and sign in.'**
  String get registerSalonOwnerDescription;

  /// No description provided for @registerSalonOwnerStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Account — step 1 of 2'**
  String get registerSalonOwnerStepLabel;

  /// No description provided for @registerStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Account — step 1 of 3'**
  String get registerStepLabel;

  /// No description provided for @registerSectionYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get registerSectionYourDetails;

  /// No description provided for @registerSectionProfileHint.
  ///
  /// In en, this message translates to:
  /// **'We store your profile in Firestore under your Firebase Auth account.'**
  String get registerSectionProfileHint;

  /// No description provided for @registerContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registerContinueButton;

  /// No description provided for @registerFooterSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get registerFooterSignIn;

  /// No description provided for @registerOwnerIntentBanner.
  ///
  /// In en, this message translates to:
  /// **'Next, choose “Salon owner” to create your salon.'**
  String get registerOwnerIntentBanner;

  /// No description provided for @registerHintFullName.
  ///
  /// In en, this message translates to:
  /// **'Alex Rivera'**
  String get registerHintFullName;

  /// No description provided for @registerHintEmail.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get registerHintEmail;

  /// No description provided for @registerHintPassword.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get registerHintPassword;

  /// No description provided for @registerHintConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get registerHintConfirmPassword;

  /// No description provided for @createSalonEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Salon setup'**
  String get createSalonEyebrow;

  /// No description provided for @createSalonTitle.
  ///
  /// In en, this message translates to:
  /// **'Create the salon your team will work inside.'**
  String get createSalonTitle;

  /// No description provided for @createSalonDescription.
  ///
  /// In en, this message translates to:
  /// **'Add the core business details now. This salon record becomes the foundation for staff, attendance, payroll, and bookings later.'**
  String get createSalonDescription;

  /// No description provided for @createSalonStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Salon setup — step 2 of 2'**
  String get createSalonStepLabel;

  /// No description provided for @createSalonFooterDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get createSalonFooterDifferentAccount;

  /// No description provided for @createSalonSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon details'**
  String get createSalonSectionTitle;

  /// No description provided for @createSalonSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your salon profile to open the owner dashboard and invite your team.'**
  String get createSalonSectionSubtitle;

  /// No description provided for @createSalonOwnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Owner account'**
  String get createSalonOwnerFallback;

  /// No description provided for @createSalonButton.
  ///
  /// In en, this message translates to:
  /// **'Create salon'**
  String get createSalonButton;

  /// No description provided for @createSalonPhoneTip.
  ///
  /// In en, this message translates to:
  /// **'Spaces, dashes, and parentheses are fine—we normalize the number when you save.'**
  String get createSalonPhoneTip;

  /// No description provided for @createSalonHintSalonName.
  ///
  /// In en, this message translates to:
  /// **'Golden Chair Barber Studio'**
  String get createSalonHintSalonName;

  /// No description provided for @createSalonHintPhone.
  ///
  /// In en, this message translates to:
  /// **'+962 7X XXX XXXX'**
  String get createSalonHintPhone;

  /// No description provided for @createSalonHintAddress.
  ///
  /// In en, this message translates to:
  /// **'Amman, Abdoun, Main Street 12'**
  String get createSalonHintAddress;

  /// No description provided for @roleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Choose path'**
  String get roleEyebrow;

  /// No description provided for @roleTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use the app?'**
  String get roleTitle;

  /// No description provided for @roleDescription.
  ///
  /// In en, this message translates to:
  /// **'Customers book and manage visits. Owners set up their salon workspace. Barber and admin accounts are issued by the salon owner.'**
  String get roleDescription;

  /// No description provided for @roleStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Role — step 2 of 2'**
  String get roleStepLabel;

  /// No description provided for @roleSectionPrompt.
  ///
  /// In en, this message translates to:
  /// **'I am…'**
  String get roleSectionPrompt;

  /// No description provided for @roleCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'A customer'**
  String get roleCustomerTitle;

  /// No description provided for @roleCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book services, see history, manage your profile.'**
  String get roleCustomerSubtitle;

  /// No description provided for @roleOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'A salon owner'**
  String get roleOwnerTitle;

  /// No description provided for @roleOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your salon, invite staff, run operations.'**
  String get roleOwnerSubtitle;

  /// No description provided for @roleSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get roleSignOut;

  /// No description provided for @socialAuthOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get socialAuthOr;

  /// No description provided for @socialAuthContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with'**
  String get socialAuthContinueTitle;

  /// No description provided for @socialAuthGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get socialAuthGoogle;

  /// No description provided for @socialAuthApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get socialAuthApple;

  /// No description provided for @socialAuthFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get socialAuthFacebook;

  /// No description provided for @passwordStrengthHintWeak.
  ///
  /// In en, this message translates to:
  /// **'Add length and mix letters or numbers.'**
  String get passwordStrengthHintWeak;

  /// No description provided for @passwordStrengthHintOk.
  ///
  /// In en, this message translates to:
  /// **'Good start—consider a longer phrase.'**
  String get passwordStrengthHintOk;

  /// No description provided for @passwordStrengthHintStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong for this app’s minimum.'**
  String get passwordStrengthHintStrong;

  /// No description provided for @passwordStrengthHintExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent—hard to guess.'**
  String get passwordStrengthHintExcellent;

  /// No description provided for @passwordStrengthSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Password strength: {level}'**
  String passwordStrengthSemanticLabel(String level);

  /// No description provided for @accessibilityShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get accessibilityShowPassword;

  /// No description provided for @accessibilityHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get accessibilityHidePassword;

  /// No description provided for @loginHintEmail.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginHintEmail;

  /// No description provided for @loginHintPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get loginHintPassword;

  /// No description provided for @validationCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose your country so we can format your phone number correctly.'**
  String get validationCountryRequired;

  /// No description provided for @validationBusinessTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select what kind of salon you run.'**
  String get validationBusinessTypeRequired;

  /// No description provided for @fieldLabelCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get fieldLabelCountry;

  /// No description provided for @fieldLabelCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldLabelCity;

  /// No description provided for @fieldLabelStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get fieldLabelStreet;

  /// No description provided for @fieldLabelBuildingUnit.
  ///
  /// In en, this message translates to:
  /// **'Building / unit number'**
  String get fieldLabelBuildingUnit;

  /// No description provided for @fieldLabelPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code (optional)'**
  String get fieldLabelPostalCode;

  /// No description provided for @fieldLabelSalonPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Salon phone (optional)'**
  String get fieldLabelSalonPhoneOptional;

  /// No description provided for @fieldLabelBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get fieldLabelBusinessType;

  /// No description provided for @businessTypeBarber.
  ///
  /// In en, this message translates to:
  /// **'Barber shop'**
  String get businessTypeBarber;

  /// No description provided for @businessTypeWomenSalon.
  ///
  /// In en, this message translates to:
  /// **'Women’s salon'**
  String get businessTypeWomenSalon;

  /// No description provided for @businessTypeUnisex.
  ///
  /// In en, this message translates to:
  /// **'Unisex'**
  String get businessTypeUnisex;

  /// No description provided for @onboardingSearchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Search country or code'**
  String get onboardingSearchCountryHint;

  /// No description provided for @onboardingCountryPopularSection.
  ///
  /// In en, this message translates to:
  /// **'Popular countries'**
  String get onboardingCountryPopularSection;

  /// No description provided for @onboardingCountryAllSection.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get onboardingCountryAllSection;

  /// No description provided for @customerSignupEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerSignupEyebrow;

  /// No description provided for @customerSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your customer account'**
  String get customerSignupTitle;

  /// No description provided for @customerSignupDescription.
  ///
  /// In en, this message translates to:
  /// **'We’ll save your profile securely so you can book and manage visits.'**
  String get customerSignupDescription;

  /// No description provided for @customerSignupAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Helps salons recognize you and send booking updates.'**
  String get customerSignupAddressHint;

  /// No description provided for @customerSignupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get customerSignupSubmit;

  /// No description provided for @salonOwnerSignupEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Salon owner'**
  String get salonOwnerSignupEyebrow;

  /// No description provided for @salonOwnerSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner account — step 1 of 2'**
  String get salonOwnerSignupTitle;

  /// No description provided for @salonOwnerSignupDescription.
  ///
  /// In en, this message translates to:
  /// **'Next you’ll add your salon’s location and business type.'**
  String get salonOwnerSignupDescription;

  /// No description provided for @salonOwnerSignupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Continue to salon details'**
  String get salonOwnerSignupSubmit;

  /// No description provided for @onboardingMobileNationalHint.
  ///
  /// In en, this message translates to:
  /// **'Local number without country code'**
  String get onboardingMobileNationalHint;

  /// No description provided for @createSalonBusinessTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get createSalonBusinessTypeSection;

  /// No description provided for @createSalonLocationSection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get createSalonLocationSection;

  /// No description provided for @createSalonContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact (optional)'**
  String get createSalonContactSection;

  /// No description provided for @createSalonProfileSyncTimeout.
  ///
  /// In en, this message translates to:
  /// **'Your salon was saved but we could not confirm your profile yet. Check your connection, then pull to refresh or sign out and back in.'**
  String get createSalonProfileSyncTimeout;

  /// No description provided for @accountProfileBootstrapEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Account recovery'**
  String get accountProfileBootstrapEyebrow;

  /// No description provided for @accountProfileBootstrapTitleMissing.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your profile'**
  String get accountProfileBootstrapTitleMissing;

  /// No description provided for @accountProfileBootstrapDescriptionMissing.
  ///
  /// In en, this message translates to:
  /// **'We could not load your saved profile. Choose how you use the app to create your user record, or sign in with a different account if this one is new.'**
  String get accountProfileBootstrapDescriptionMissing;

  /// No description provided for @accountProfileBootstrapTitleStaff.
  ///
  /// In en, this message translates to:
  /// **'Team profile incomplete'**
  String get accountProfileBootstrapTitleStaff;

  /// No description provided for @accountProfileBootstrapDescriptionStaff.
  ///
  /// In en, this message translates to:
  /// **'Your account is missing salon linkage (salon or staff ID). This usually means the profile was not finished or data was removed. Sign out and ask your salon owner to re-send your team invite, or use a different account.'**
  String get accountProfileBootstrapDescriptionStaff;

  /// No description provided for @accountProfileBootstrapContinueCustomer.
  ///
  /// In en, this message translates to:
  /// **'I book appointments as a customer'**
  String get accountProfileBootstrapContinueCustomer;

  /// No description provided for @accountProfileBootstrapContinueOwner.
  ///
  /// In en, this message translates to:
  /// **'I run a salon (owner)'**
  String get accountProfileBootstrapContinueOwner;

  /// No description provided for @accountProfileBootstrapCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Create my profile'**
  String get accountProfileBootstrapCreateProfile;

  /// No description provided for @accountProfileBootstrapChoosePath.
  ///
  /// In en, this message translates to:
  /// **'Choose one to continue:'**
  String get accountProfileBootstrapChoosePath;

  /// No description provided for @accountProfileBootstrapFooterDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get accountProfileBootstrapFooterDifferentAccount;

  /// No description provided for @accountProfileBootstrapErrorNoAuthUser.
  ///
  /// In en, this message translates to:
  /// **'No signed-in user. Please sign in again.'**
  String get accountProfileBootstrapErrorNoAuthUser;

  /// No description provided for @accountProfileBootstrapErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Try again.'**
  String get accountProfileBootstrapErrorGeneric;

  /// No description provided for @ownerStaffInviteSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Team member added'**
  String get ownerStaffInviteSuccessTitle;

  /// No description provided for @ownerStaffInviteSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{name} can sign in with this email and a temporary password. Ask them to change their password after logging in.\n\nEmail:\n{email}\n\nTemporary password:\n{password}'**
  String ownerStaffInviteSuccessBody(
    String name,
    String email,
    String password,
  );

  /// No description provided for @ownerStaffInviteOk.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ownerStaffInviteOk;

  /// No description provided for @staffInviteErrorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken or the account already exists'**
  String get staffInviteErrorEmailTaken;

  /// No description provided for @staffInviteErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Only owners and admins can create staff accounts'**
  String get staffInviteErrorPermission;

  /// No description provided for @staffInviteErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get staffInviteErrorNetwork;

  /// No description provided for @staffInviteErrorInvalidArgs.
  ///
  /// In en, this message translates to:
  /// **'Some information looks invalid. Check the form and try again.'**
  String get staffInviteErrorInvalidArgs;

  /// No description provided for @staffInviteErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to create barber account. Please try again.'**
  String get staffInviteErrorGeneric;

  /// No description provided for @ownerHeaderGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String ownerHeaderGreeting(String name);

  /// No description provided for @ownerOverviewGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get ownerOverviewGreetingMorning;

  /// No description provided for @ownerOverviewGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get ownerOverviewGreetingAfternoon;

  /// No description provided for @ownerOverviewGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get ownerOverviewGreetingEvening;

  /// No description provided for @ownerOverviewHeroSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search team, revenue, and requests'**
  String get ownerOverviewHeroSearchHint;

  /// No description provided for @ownerOverviewRevenueMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue this month'**
  String get ownerOverviewRevenueMonthLabel;

  /// No description provided for @ownerOverviewRevenueMonthHintEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded yet.'**
  String get ownerOverviewRevenueMonthHintEmpty;

  /// No description provided for @ownerOverviewRevenueThisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue this week'**
  String get ownerOverviewRevenueThisWeekTitle;

  /// No description provided for @ownerOverviewRevenueThisWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue trend for the current week'**
  String get ownerOverviewRevenueThisWeekSubtitle;

  /// No description provided for @ownerOverviewRevenueThisWeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'No revenue yet this week'**
  String get ownerOverviewRevenueThisWeekEmpty;

  /// No description provided for @ownerOverviewRevenueThisWeekTotal.
  ///
  /// In en, this message translates to:
  /// **'Week total: {amount}'**
  String ownerOverviewRevenueThisWeekTotal(String amount);

  /// No description provided for @ownerOverviewKpiPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get ownerOverviewKpiPendingRequests;

  /// No description provided for @ownerOverviewDashboardTagline.
  ///
  /// In en, this message translates to:
  /// **'Track revenue, team, and bookings in one place.'**
  String get ownerOverviewDashboardTagline;

  /// No description provided for @ownerOverviewTodayInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s insight'**
  String get ownerOverviewTodayInsightTitle;

  /// No description provided for @ownerOverviewTodayInsightNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet today. Start by adding a sale or booking.'**
  String get ownerOverviewTodayInsightNoActivity;

  /// No description provided for @ownerOverviewTodayInsightRevenue.
  ///
  /// In en, this message translates to:
  /// **'You’re doing well today. Revenue is {amount}.'**
  String ownerOverviewTodayInsightRevenue(String amount);

  /// No description provided for @ownerOverviewTodayInsightBookings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You have 1 booking today. Turn it into a smooth visit.} other{You have {count} bookings today. Keep the calendar moving.}}'**
  String ownerOverviewTodayInsightBookings(int count);

  /// No description provided for @ownerOverviewTodayInsightPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 request needs review.} other{{count} requests need review.}}'**
  String ownerOverviewTodayInsightPendingRequests(int count);

  /// No description provided for @ownerOverviewRecentServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent services'**
  String get ownerOverviewRecentServicesTitle;

  /// No description provided for @ownerOverviewRecentServicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active services yet.'**
  String get ownerOverviewRecentServicesEmpty;

  /// No description provided for @ownerOverviewPerformanceNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get ownerOverviewPerformanceNoData;

  /// No description provided for @ownerOverviewBestServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Best service this week · 1 sale} other{Best service this week · {count} sales}}'**
  String ownerOverviewBestServiceSubtitle(int count);

  /// No description provided for @ownerOverviewBestBarberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best barber today · {amount}'**
  String ownerOverviewBestBarberSubtitle(String amount);

  /// No description provided for @ownerOverviewRecentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get ownerOverviewRecentActivityTitle;

  /// No description provided for @ownerOverviewRecentActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet'**
  String get ownerOverviewRecentActivityEmpty;

  /// No description provided for @ownerOverviewLatestSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last sale: {service} · {amount}'**
  String ownerOverviewLatestSaleSubtitle(String service, String amount);

  /// No description provided for @ownerOverviewLatestSaleFallbackService.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get ownerOverviewLatestSaleFallbackService;

  /// No description provided for @ownerOverviewViewTeam.
  ///
  /// In en, this message translates to:
  /// **'View team'**
  String get ownerOverviewViewTeam;

  /// No description provided for @ownerOverviewSmartCardServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first service'**
  String get ownerOverviewSmartCardServiceTitle;

  /// No description provided for @ownerOverviewSmartCardServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers need a menu to book.'**
  String get ownerOverviewSmartCardServiceSubtitle;

  /// No description provided for @ownerOverviewSmartCardBarberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first barber'**
  String get ownerOverviewSmartCardBarberTitle;

  /// No description provided for @ownerOverviewSmartCardBarberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff appear on the floor and in payroll.'**
  String get ownerOverviewSmartCardBarberSubtitle;

  /// No description provided for @ownerOverviewSmartCardBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first booking'**
  String get ownerOverviewSmartCardBookingTitle;

  /// No description provided for @ownerOverviewSmartCardBookingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill the calendar and track revenue.'**
  String get ownerOverviewSmartCardBookingSubtitle;

  /// No description provided for @ownerOverviewRevenueTodayLine.
  ///
  /// In en, this message translates to:
  /// **'Today: {amount}'**
  String ownerOverviewRevenueTodayLine(String amount);

  /// No description provided for @ownerOverviewRevenueDeltaUp.
  ///
  /// In en, this message translates to:
  /// **'{percent} vs last month'**
  String ownerOverviewRevenueDeltaUp(String percent);

  /// No description provided for @ownerOverviewRevenueDeltaDown.
  ///
  /// In en, this message translates to:
  /// **'{percent} vs last month'**
  String ownerOverviewRevenueDeltaDown(String percent);

  /// No description provided for @ownerOverviewStatRevenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue today'**
  String get ownerOverviewStatRevenueToday;

  /// No description provided for @ownerOverviewStatBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'Bookings today'**
  String get ownerOverviewStatBookingsToday;

  /// No description provided for @ownerOverviewStatCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get ownerOverviewStatCompletedToday;

  /// No description provided for @ownerOverviewStatCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get ownerOverviewStatCheckedIn;

  /// No description provided for @ownerOverviewQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get ownerOverviewQuickActionsTitle;

  /// No description provided for @ownerOverviewQuickAddSale.
  ///
  /// In en, this message translates to:
  /// **'Add sale'**
  String get ownerOverviewQuickAddSale;

  /// No description provided for @ownerOverviewQuickAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get ownerOverviewQuickAddExpense;

  /// No description provided for @ownerOverviewNeedsAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get ownerOverviewNeedsAttentionTitle;

  /// No description provided for @ownerOverviewNeedsAttentionNone.
  ///
  /// In en, this message translates to:
  /// **'All clear. Nothing urgent right now.'**
  String get ownerOverviewNeedsAttentionNone;

  /// No description provided for @ownerOverviewFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get ownerOverviewFabLabel;

  /// No description provided for @ownerOverviewRunPayroll.
  ///
  /// In en, this message translates to:
  /// **'Run payroll'**
  String get ownerOverviewRunPayroll;

  /// No description provided for @ownerOverviewSmartSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart suggestions'**
  String get ownerOverviewSmartSuggestionsTitle;

  /// No description provided for @ownerOverviewSmartSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the essentials so bookings and payouts stay accurate.'**
  String get ownerOverviewSmartSuggestionsSubtitle;

  /// No description provided for @ownerOverviewSmartAddBarber.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get ownerOverviewSmartAddBarber;

  /// No description provided for @ownerOverviewSmartAddService.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get ownerOverviewSmartAddService;

  /// No description provided for @ownerOverviewSmartCreateBooking.
  ///
  /// In en, this message translates to:
  /// **'Create booking'**
  String get ownerOverviewSmartCreateBooking;

  /// No description provided for @ownerOverviewStatDeltaSameAsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Same as yesterday'**
  String get ownerOverviewStatDeltaSameAsYesterday;

  /// No description provided for @ownerOverviewStatDeltaVsYesterday.
  ///
  /// In en, this message translates to:
  /// **'{amount} vs yesterday'**
  String ownerOverviewStatDeltaVsYesterday(String amount);

  /// No description provided for @ownerOverviewKpiBadgeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get ownerOverviewKpiBadgeLive;

  /// No description provided for @ownerOverviewKpiBadgeQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get ownerOverviewKpiBadgeQuiet;

  /// No description provided for @ownerOverviewKpiBadgeBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get ownerOverviewKpiBadgeBusy;

  /// No description provided for @ownerOverviewKpiBadgeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ownerOverviewKpiBadgeDone;

  /// No description provided for @ownerOverviewKpiBadgeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get ownerOverviewKpiBadgeNone;

  /// No description provided for @ownerOverviewKpiBadgeOnFloor.
  ///
  /// In en, this message translates to:
  /// **'On floor'**
  String get ownerOverviewKpiBadgeOnFloor;

  /// No description provided for @ownerOverviewRevenueLastMonthTotal.
  ///
  /// In en, this message translates to:
  /// **'Last month: {amount}'**
  String ownerOverviewRevenueLastMonthTotal(String amount);

  /// No description provided for @ownerOverviewRevenueNoPriorMonthCompare.
  ///
  /// In en, this message translates to:
  /// **'No completed sales last month to compare'**
  String get ownerOverviewRevenueNoPriorMonthCompare;

  /// No description provided for @ownerOverviewRevenueDeltaFlatVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Flat vs last month'**
  String get ownerOverviewRevenueDeltaFlatVsLastMonth;

  /// No description provided for @ownerOverviewAttentionPendingBookings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 booking awaiting confirmation} other{{count} bookings awaiting confirmation}}'**
  String ownerOverviewAttentionPendingBookings(int count);

  /// No description provided for @ownerOverviewAttentionPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 attendance request to review} other{{count} attendance requests to review}}'**
  String ownerOverviewAttentionPendingApprovals(int count);

  /// No description provided for @ownerOverviewAttentionPayrollPending.
  ///
  /// In en, this message translates to:
  /// **'Payroll hasn\'t been run for this month yet.'**
  String get ownerOverviewAttentionPayrollPending;

  /// No description provided for @ownerOverviewAttentionNoServices.
  ///
  /// In en, this message translates to:
  /// **'Add at least one service so customers can book.'**
  String get ownerOverviewAttentionNoServices;

  /// No description provided for @ownerOverviewReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get ownerOverviewReview;

  /// No description provided for @ownerOverviewSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get ownerOverviewSeeAll;

  /// No description provided for @ownerOverviewTeamCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get ownerOverviewTeamCardTitle;

  /// No description provided for @ownerOverviewTeamCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {checkedIn} checked in today'**
  String ownerOverviewTeamCardSubtitle(int active, int checkedIn);

  /// No description provided for @ownerOverviewTeamCardTopBarber.
  ///
  /// In en, this message translates to:
  /// **'Top team member today: {name}'**
  String ownerOverviewTeamCardTopBarber(String name);

  /// No description provided for @ownerOverviewTeamCardInactive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 inactive member} other{{count} inactive members}}'**
  String ownerOverviewTeamCardInactive(int count);

  /// No description provided for @ownerOverviewServicesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get ownerOverviewServicesCardTitle;

  /// No description provided for @ownerOverviewServicesCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active services yet} one{1 active service} other{{count} active services}}'**
  String ownerOverviewServicesCardSubtitle(int count);

  /// No description provided for @ownerOverviewServicesAveragePrice.
  ///
  /// In en, this message translates to:
  /// **'Average price: {amount}'**
  String ownerOverviewServicesAveragePrice(String amount);

  /// No description provided for @ownerOverviewServicesTopToday.
  ///
  /// In en, this message translates to:
  /// **'Top today: {name}'**
  String ownerOverviewServicesTopToday(String name);

  /// No description provided for @ownerOverviewServicesTopMonth.
  ///
  /// In en, this message translates to:
  /// **'Most booked this month: {name}'**
  String ownerOverviewServicesTopMonth(String name);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @ownerOverviewAttentionInactiveEmployees.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 inactive team member to review} other{{count} inactive team members to review}}'**
  String ownerOverviewAttentionInactiveEmployees(int count);

  /// No description provided for @ownerOverviewInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get ownerOverviewInsightsTitle;

  /// No description provided for @ownerOverviewInsightRevenueUp.
  ///
  /// In en, this message translates to:
  /// **'Revenue is up {percent} vs last month.'**
  String ownerOverviewInsightRevenueUp(String percent);

  /// No description provided for @ownerOverviewInsightRevenueDown.
  ///
  /// In en, this message translates to:
  /// **'Revenue is down {percent} vs last month.'**
  String ownerOverviewInsightRevenueDown(String percent);

  /// No description provided for @ownerOverviewInsightRevenueFlat.
  ///
  /// In en, this message translates to:
  /// **'Revenue is flat vs last month.'**
  String get ownerOverviewInsightRevenueFlat;

  /// No description provided for @ownerOverviewInsightRevenueFresh.
  ///
  /// In en, this message translates to:
  /// **'New revenue this month — nothing to compare yet.'**
  String get ownerOverviewInsightRevenueFresh;

  /// No description provided for @ownerOverviewInsightTopBarberContribution.
  ///
  /// In en, this message translates to:
  /// **'{name} generated {percent} of today\'s revenue.'**
  String ownerOverviewInsightTopBarberContribution(String name, String percent);

  /// No description provided for @ownerOverviewInsightTopBarberEmpty.
  ///
  /// In en, this message translates to:
  /// **'No team member activity yet today.'**
  String get ownerOverviewInsightTopBarberEmpty;

  /// No description provided for @ownerOverviewInsightPopularService.
  ///
  /// In en, this message translates to:
  /// **'{name} is the most popular service this month.'**
  String ownerOverviewInsightPopularService(String name);

  /// No description provided for @ownerOverviewAddExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get ownerOverviewAddExpenseTitle;

  /// No description provided for @ownerOverviewAddExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record a salon expense in seconds.'**
  String get ownerOverviewAddExpenseSubtitle;

  /// No description provided for @ownerOverviewAddExpenseTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get ownerOverviewAddExpenseTitleField;

  /// No description provided for @ownerOverviewAddExpenseCategoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ownerOverviewAddExpenseCategoryField;

  /// No description provided for @ownerOverviewAddExpenseAmountField.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ownerOverviewAddExpenseAmountField;

  /// No description provided for @ownerOverviewAddExpenseVendorField.
  ///
  /// In en, this message translates to:
  /// **'Vendor (optional)'**
  String get ownerOverviewAddExpenseVendorField;

  /// No description provided for @ownerOverviewAddExpenseNotesField.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get ownerOverviewAddExpenseNotesField;

  /// No description provided for @ownerOverviewAddExpenseSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get ownerOverviewAddExpenseSubmit;

  /// No description provided for @ownerOverviewAddExpenseDateField.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ownerOverviewAddExpenseDateField;

  /// No description provided for @ownerOverviewAddExpenseSuggestedCategories.
  ///
  /// In en, this message translates to:
  /// **'Suggested categories'**
  String get ownerOverviewAddExpenseSuggestedCategories;

  /// No description provided for @ownerOverviewAddExpenseValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill title, category, and a positive amount.'**
  String get ownerOverviewAddExpenseValidationError;

  /// No description provided for @ownerOverviewExpenseCreated.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded'**
  String get ownerOverviewExpenseCreated;

  /// No description provided for @ownerOverviewSummaryEarnedFromSales.
  ///
  /// In en, this message translates to:
  /// **'Today you earned {amount} from {count, plural, one{1 completed sale} other{{count} completed sales}}.'**
  String ownerOverviewSummaryEarnedFromSales(String amount, int count);

  /// No description provided for @ownerOverviewSummaryEarnedOnly.
  ///
  /// In en, this message translates to:
  /// **'Today you earned {amount}.'**
  String ownerOverviewSummaryEarnedOnly(String amount);

  /// No description provided for @ownerOverviewSummaryNoSalesToday.
  ///
  /// In en, this message translates to:
  /// **'No completed sales yet today.'**
  String get ownerOverviewSummaryNoSalesToday;

  /// No description provided for @ownerOverviewSummaryPendingSegment.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No bookings pending} one{1 booking pending} other{{count} bookings pending}}'**
  String ownerOverviewSummaryPendingSegment(int count);

  /// No description provided for @ownerOverviewSummaryBarbersCheckedInSegment.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No team members checked in} one{1 team member checked in} other{{count} team members checked in}}'**
  String ownerOverviewSummaryBarbersCheckedInSegment(int count);

  /// No description provided for @ownerOverviewSummaryPayrollPendingSegment.
  ///
  /// In en, this message translates to:
  /// **'Payroll pending'**
  String get ownerOverviewSummaryPayrollPendingSegment;

  /// No description provided for @ownerOverviewEmptyBookingsTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookings today.'**
  String get ownerOverviewEmptyBookingsTodayTitle;

  /// No description provided for @ownerOverviewEmptyCompletedTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'No services completed yet today.'**
  String get ownerOverviewEmptyCompletedTodayTitle;

  /// No description provided for @ownerOverviewEmptyCheckedInTitle.
  ///
  /// In en, this message translates to:
  /// **'No one has checked in yet.'**
  String get ownerOverviewEmptyCheckedInTitle;

  /// No description provided for @ownerOverviewTeamMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get ownerOverviewTeamMarkAttendance;

  /// No description provided for @ownerOverviewTeamActiveBarbersLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No team members yet} one{1 active team member} other{{count} active team members}}'**
  String ownerOverviewTeamActiveBarbersLabel(int count);

  /// No description provided for @ownerOverviewTeamCheckedInShort.
  ///
  /// In en, this message translates to:
  /// **'{count} checked in'**
  String ownerOverviewTeamCheckedInShort(int count);

  /// No description provided for @ownerOverviewTeamEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No team members added yet.'**
  String get ownerOverviewTeamEmptyTitle;

  /// No description provided for @ownerOverviewTeamEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first team member to start tracking attendance and sales.'**
  String get ownerOverviewTeamEmptyBody;

  /// No description provided for @ownerOverviewTeamStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get ownerOverviewTeamStatusCheckedIn;

  /// No description provided for @ownerOverviewTeamStatusNotCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Not checked in'**
  String get ownerOverviewTeamStatusNotCheckedIn;

  /// No description provided for @ownerOverviewTeamStatusOnService.
  ///
  /// In en, this message translates to:
  /// **'On service'**
  String get ownerOverviewTeamStatusOnService;

  /// No description provided for @ownerOverviewTeamStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get ownerOverviewTeamStatusLate;

  /// No description provided for @ownerOverviewInsightTopServiceWeek.
  ///
  /// In en, this message translates to:
  /// **'{name} is the top service this week.'**
  String ownerOverviewInsightTopServiceWeek(String name);

  /// No description provided for @ownerOverviewInsightBookingsUp.
  ///
  /// In en, this message translates to:
  /// **'Bookings are up {percent} compared with yesterday.'**
  String ownerOverviewInsightBookingsUp(String percent);

  /// No description provided for @ownerOverviewInsightBookingsDown.
  ///
  /// In en, this message translates to:
  /// **'Bookings are down {percent} compared with yesterday.'**
  String ownerOverviewInsightBookingsDown(String percent);

  /// No description provided for @ownerOverviewInsightNoBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'No bookings today — quieter than yesterday.'**
  String get ownerOverviewInsightNoBookingsToday;

  /// No description provided for @ownerOverviewInsightsGrowing.
  ///
  /// In en, this message translates to:
  /// **'Insights will appear as your salon activity grows.'**
  String get ownerOverviewInsightsGrowing;

  /// No description provided for @ownerOverviewAttentionBarbersNotCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 team member has not checked in} other{{count} team members have not checked in}}'**
  String ownerOverviewAttentionBarbersNotCheckedIn(int count);

  /// No description provided for @ownerOverviewFabSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get ownerOverviewFabSheetTitle;

  /// No description provided for @ownerOverviewFabBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get ownerOverviewFabBookAppointment;

  /// No description provided for @attendanceReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance requests'**
  String get attendanceReviewTitle;

  /// No description provided for @attendanceReviewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending attendance requests'**
  String get attendanceReviewEmptyTitle;

  /// No description provided for @attendanceReviewEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything is up to date.'**
  String get attendanceReviewEmptyMessage;

  /// No description provided for @attendanceReviewErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests'**
  String get attendanceReviewErrorTitle;

  /// No description provided for @attendanceReviewStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get attendanceReviewStatusPending;

  /// No description provided for @attendanceReviewApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get attendanceReviewApprove;

  /// No description provided for @attendanceReviewReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get attendanceReviewReject;

  /// No description provided for @attendanceReviewRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a rejection note'**
  String get attendanceReviewRejectDialogTitle;

  /// No description provided for @attendanceReviewRejectDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — helps the employee understand.'**
  String get attendanceReviewRejectDialogHint;

  /// No description provided for @attendanceReviewRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get attendanceReviewRejectConfirm;

  /// No description provided for @attendanceReviewCheckInAt.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {time}'**
  String attendanceReviewCheckInAt(String time);

  /// No description provided for @attendanceReviewCheckOutAt.
  ///
  /// In en, this message translates to:
  /// **'Checked out at {time}'**
  String attendanceReviewCheckOutAt(String time);

  /// No description provided for @attendanceReviewSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted at {time}'**
  String attendanceReviewSubmittedAt(String time);

  /// No description provided for @attendanceReviewUnknownEmployee.
  ///
  /// In en, this message translates to:
  /// **'Unknown team member'**
  String get attendanceReviewUnknownEmployee;

  /// No description provided for @attendanceReviewTypePresent.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction'**
  String get attendanceReviewTypePresent;

  /// No description provided for @attendanceReviewTypeAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absence request'**
  String get attendanceReviewTypeAbsent;

  /// No description provided for @attendanceReviewTypeLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave request'**
  String get attendanceReviewTypeLeave;

  /// No description provided for @attendanceReviewTypeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Attendance request'**
  String get attendanceReviewTypeGeneric;

  /// No description provided for @attendanceReviewApprovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Attendance approved'**
  String get attendanceReviewApprovedSnackbar;

  /// No description provided for @attendanceReviewRejectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Attendance rejected'**
  String get attendanceReviewRejectedSnackbar;

  /// No description provided for @attendanceReviewErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Could not update: {message}'**
  String attendanceReviewErrorSnackbar(String message);

  /// No description provided for @teamManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamManagementTitle;

  /// No description provided for @teamManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your team members and admins'**
  String get teamManagementSubtitle;

  /// No description provided for @teamSummaryTotalBarbers.
  ///
  /// In en, this message translates to:
  /// **'Total team members'**
  String get teamSummaryTotalBarbers;

  /// No description provided for @teamSummaryCheckedInToday.
  ///
  /// In en, this message translates to:
  /// **'Checked in today'**
  String get teamSummaryCheckedInToday;

  /// No description provided for @teamSummarySalesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get teamSummarySalesToday;

  /// No description provided for @teamSummaryCommissionToday.
  ///
  /// In en, this message translates to:
  /// **'Commission today'**
  String get teamSummaryCommissionToday;

  /// No description provided for @teamSummaryTotalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get teamSummaryTotalMembers;

  /// No description provided for @teamSummaryTotalMembersHelper.
  ///
  /// In en, this message translates to:
  /// **'Team roster'**
  String get teamSummaryTotalMembersHelper;

  /// No description provided for @teamSummaryWorkingNow.
  ///
  /// In en, this message translates to:
  /// **'Working Now'**
  String get teamSummaryWorkingNow;

  /// No description provided for @teamSummaryWorkingNowHelper.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members yet} one{of 1 member} other{of {count} members}}'**
  String teamSummaryWorkingNowHelper(int count);

  /// No description provided for @teamSummaryAbsentToday.
  ///
  /// In en, this message translates to:
  /// **'Absent Today'**
  String get teamSummaryAbsentToday;

  /// No description provided for @teamSummaryAbsentTodayHelper.
  ///
  /// In en, this message translates to:
  /// **'Needs follow-up'**
  String get teamSummaryAbsentTodayHelper;

  /// No description provided for @teamSummaryRevenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue Today'**
  String get teamSummaryRevenueToday;

  /// No description provided for @teamSummaryRevenueTodayHelper.
  ///
  /// In en, this message translates to:
  /// **'Live sales'**
  String get teamSummaryRevenueTodayHelper;

  /// No description provided for @teamAnalyticsAction.
  ///
  /// In en, this message translates to:
  /// **'Team analytics'**
  String get teamAnalyticsAction;

  /// No description provided for @teamAnalyticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Team analytics will be available soon.'**
  String get teamAnalyticsComingSoon;

  /// No description provided for @teamAnalyticsActiveInactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active / Inactive'**
  String get teamAnalyticsActiveInactiveLabel;

  /// No description provided for @teamAnalyticsTopPerformerLabel.
  ///
  /// In en, this message translates to:
  /// **'Top performer'**
  String get teamAnalyticsTopPerformerLabel;

  /// No description provided for @teamGuideDescription.
  ///
  /// In en, this message translates to:
  /// **'Team members help you run attendance, services, sales, commissions, and payroll in one place.'**
  String get teamGuideDescription;

  /// No description provided for @teamFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get teamFilterAll;

  /// No description provided for @teamFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get teamFilterActive;

  /// No description provided for @teamFilterCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get teamFilterCheckedIn;

  /// No description provided for @teamFilterWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get teamFilterWorking;

  /// No description provided for @teamFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get teamFilterInactive;

  /// No description provided for @teamFilterTopSellers.
  ///
  /// In en, this message translates to:
  /// **'Top sellers'**
  String get teamFilterTopSellers;

  /// No description provided for @teamFilterTopPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get teamFilterTopPerformers;

  /// No description provided for @teamFilterNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get teamFilterNeedsAttention;

  /// No description provided for @teamAddBarberAction.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get teamAddBarberAction;

  /// No description provided for @teamHeroSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search members by name or phone'**
  String get teamHeroSearchHint;

  /// No description provided for @teamSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get teamSearchHint;

  /// No description provided for @teamMemberWhatsAppNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number on file for this team member'**
  String get teamMemberWhatsAppNoPhone;

  /// No description provided for @teamFilterAction.
  ///
  /// In en, this message translates to:
  /// **'Filter team'**
  String get teamFilterAction;

  /// No description provided for @teamEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No team members yet'**
  String get teamEmptyTitle;

  /// No description provided for @teamEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first team member to start tracking attendance, sales, and payroll.'**
  String get teamEmptySubtitle;

  /// No description provided for @teamEmptyBuildTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your team'**
  String get teamEmptyBuildTitle;

  /// No description provided for @teamEmptyBuildSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first team member or admin to start tracking attendance, sales, commissions, and payroll.'**
  String get teamEmptyBuildSubtitle;

  /// No description provided for @teamEmptyNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching team member'**
  String get teamEmptyNoMatchTitle;

  /// No description provided for @teamEmptyNoMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find anyone matching \"{query}\". Try another name, phone, employee number, or role.'**
  String teamEmptyNoMatchSubtitle(String query);

  /// No description provided for @teamEmptyNoFilterResultTitle.
  ///
  /// In en, this message translates to:
  /// **'No {filter} team members found'**
  String teamEmptyNoFilterResultTitle(String filter);

  /// No description provided for @teamEmptyNoFilterResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No team members are currently in {filter}. Clear filters or choose a different status.'**
  String teamEmptyNoFilterResultSubtitle(String filter);

  /// No description provided for @teamEmptyPrimaryClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get teamEmptyPrimaryClearSearch;

  /// No description provided for @teamEmptyPrimaryAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get teamEmptyPrimaryAddMember;

  /// No description provided for @teamEmptySecondaryAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get teamEmptySecondaryAddMember;

  /// No description provided for @teamEmptySecondaryLearnHow.
  ///
  /// In en, this message translates to:
  /// **'Learn how team works'**
  String get teamEmptySecondaryLearnHow;

  /// No description provided for @teamLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load team'**
  String get teamLoadErrorTitle;

  /// No description provided for @teamStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get teamStatusActive;

  /// No description provided for @teamStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get teamStatusCheckedIn;

  /// No description provided for @teamStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get teamStatusLate;

  /// No description provided for @teamStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get teamStatusInactive;

  /// No description provided for @teamMemberMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get teamMemberMoreActions;

  /// No description provided for @teamMemberViewProfileAction.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get teamMemberViewProfileAction;

  /// No description provided for @teamMemberEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit member'**
  String get teamMemberEditAction;

  /// No description provided for @teamMemberAttendanceAction.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get teamMemberAttendanceAction;

  /// No description provided for @teamMemberPayrollAction.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get teamMemberPayrollAction;

  /// No description provided for @teamMemberDeactivateAction.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get teamMemberDeactivateAction;

  /// No description provided for @teamMemberActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get teamMemberActivateAction;

  /// No description provided for @teamMemberResetPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Reset password later'**
  String get teamMemberResetPasswordPlaceholder;

  /// No description provided for @teamMemberSalesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get teamMemberSalesToday;

  /// No description provided for @teamMemberServicesToday.
  ///
  /// In en, this message translates to:
  /// **'Services today'**
  String get teamMemberServicesToday;

  /// No description provided for @teamMemberServicesShort.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get teamMemberServicesShort;

  /// No description provided for @teamMemberRevenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get teamMemberRevenueToday;

  /// No description provided for @teamMemberPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get teamMemberPerformance;

  /// No description provided for @teamMemberPerformancePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String teamMemberPerformancePercent(int percent);

  /// No description provided for @teamMemberCommissionToday.
  ///
  /// In en, this message translates to:
  /// **'Commission today'**
  String get teamMemberCommissionToday;

  /// No description provided for @employeeDashboardFirestorePermissionBanner.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your attendance. Please ask your admin to deploy the latest permissions.'**
  String get employeeDashboardFirestorePermissionBanner;

  /// No description provided for @employeeDashboardAttendanceNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get employeeDashboardAttendanceNotStartedYet;

  /// No description provided for @teamMemberNoAttendanceToday.
  ///
  /// In en, this message translates to:
  /// **'No attendance yet today'**
  String get teamMemberNoAttendanceToday;

  /// No description provided for @teamMemberNotCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Not checked in'**
  String get teamMemberNotCheckedIn;

  /// No description provided for @teamMemberInactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get teamMemberInactiveStatus;

  /// No description provided for @teamCardAttendanceNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Attendance not required'**
  String get teamCardAttendanceNotRequired;

  /// No description provided for @teamCardAttendanceOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get teamCardAttendanceOnBreak;

  /// No description provided for @teamCardAccountFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get teamCardAccountFrozen;

  /// No description provided for @teamMemberLateAt.
  ///
  /// In en, this message translates to:
  /// **'Late · {time}'**
  String teamMemberLateAt(String time);

  /// No description provided for @teamMemberCheckedOutAt.
  ///
  /// In en, this message translates to:
  /// **'Checked out at {time}'**
  String teamMemberCheckedOutAt(String time);

  /// No description provided for @teamMemberCheckedInAt.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {time}'**
  String teamMemberCheckedInAt(String time);

  /// No description provided for @teamMemberAddSaleAction.
  ///
  /// In en, this message translates to:
  /// **'Add sale'**
  String get teamMemberAddSaleAction;

  /// No description provided for @teamMemberMarkAttendanceAction.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get teamMemberMarkAttendanceAction;

  /// No description provided for @teamMemberViewDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get teamMemberViewDetailsAction;

  /// No description provided for @teamFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get teamFieldFullName;

  /// No description provided for @teamFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get teamFieldEmail;

  /// No description provided for @teamFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get teamFieldUsername;

  /// No description provided for @teamFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get teamFieldPhone;

  /// No description provided for @teamFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get teamFieldRole;

  /// No description provided for @teamRoleRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a role.'**
  String get teamRoleRequired;

  /// No description provided for @teamCommissionValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a commission value.'**
  String get teamCommissionValueRequired;

  /// No description provided for @teamCommissionValueInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid commission value.'**
  String get teamCommissionValueInvalid;

  /// No description provided for @teamCommissionValueNegative.
  ///
  /// In en, this message translates to:
  /// **'Commission cannot be negative.'**
  String get teamCommissionValueNegative;

  /// No description provided for @teamSaveErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not save team member details.'**
  String get teamSaveErrorGeneric;

  /// No description provided for @teamAddBarberSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} was added to the team.'**
  String teamAddBarberSuccess(String name);

  /// No description provided for @teamEditBarberSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} was updated.'**
  String teamEditBarberSuccess(String name);

  /// No description provided for @teamAddBarberSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get teamAddBarberSheetTitle;

  /// No description provided for @teamEditBarberSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit team member'**
  String get teamEditBarberSheetTitle;

  /// No description provided for @teamAddBarberSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the basics now and keep the profile ready for attendance, sales, payroll, and future booking.'**
  String get teamAddBarberSheetSubtitle;

  /// No description provided for @teamPhotoPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get teamPhotoPickerTitle;

  /// No description provided for @teamPhotoActionTake.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get teamPhotoActionTake;

  /// No description provided for @teamPhotoActionGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get teamPhotoActionGallery;

  /// No description provided for @teamPhotoActionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get teamPhotoActionRemove;

  /// No description provided for @teamPhotoActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get teamPhotoActionCancel;

  /// No description provided for @teamRolePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose role'**
  String get teamRolePickerTitle;

  /// No description provided for @teamRolePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select what this team member can access in the salon.'**
  String get teamRolePickerSubtitle;

  /// No description provided for @teamRolePickerBarberTitle.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get teamRolePickerBarberTitle;

  /// No description provided for @teamRolePickerBarberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Can record services, view own attendance, sales, and payslips.'**
  String get teamRolePickerBarberSubtitle;

  /// No description provided for @teamRolePickerBarberBadge.
  ///
  /// In en, this message translates to:
  /// **'Service staff'**
  String get teamRolePickerBarberBadge;

  /// No description provided for @teamRolePickerAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get teamRolePickerAdminTitle;

  /// No description provided for @teamRolePickerAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Can manage daily operations based on permissions set by the owner.'**
  String get teamRolePickerAdminSubtitle;

  /// No description provided for @teamRolePickerAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get teamRolePickerAdminBadge;

  /// No description provided for @teamCommissionPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission type'**
  String get teamCommissionPickerTitle;

  /// No description provided for @teamCommissionPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how this team member earns commission.'**
  String get teamCommissionPickerSubtitle;

  /// No description provided for @teamCommissionPickerPercentageTitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage only'**
  String get teamCommissionPickerPercentageTitle;

  /// No description provided for @teamCommissionPickerPercentageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Commission is calculated as a percentage of sales.'**
  String get teamCommissionPickerPercentageSubtitle;

  /// No description provided for @teamCommissionPickerFixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount only'**
  String get teamCommissionPickerFixedTitle;

  /// No description provided for @teamCommissionPickerFixedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Team member earns a fixed amount per service or period.'**
  String get teamCommissionPickerFixedSubtitle;

  /// No description provided for @teamCommissionPickerMixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage + fixed amount'**
  String get teamCommissionPickerMixedTitle;

  /// No description provided for @teamCommissionPickerMixedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Combine percentage commission with a fixed amount.'**
  String get teamCommissionPickerMixedSubtitle;

  /// No description provided for @addBarberSheetHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new team member account and set up their basic details.'**
  String get addBarberSheetHeroSubtitle;

  /// No description provided for @addBarberSectionLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Login & password'**
  String get addBarberSectionLoginPassword;

  /// No description provided for @addBarberSectionCommissionWork.
  ///
  /// In en, this message translates to:
  /// **'Commission & work settings'**
  String get addBarberSectionCommissionWork;

  /// No description provided for @addBarberProfilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get addBarberProfilePhotoTitle;

  /// No description provided for @addBarberProfilePhotoCaption.
  ///
  /// In en, this message translates to:
  /// **'Add a clear team member photo'**
  String get addBarberProfilePhotoCaption;

  /// No description provided for @addBarberProfilePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addBarberProfilePhotoButton;

  /// No description provided for @addBarberProfilePhotoAfterCreateSnack.
  ///
  /// In en, this message translates to:
  /// **'You can add a profile photo after the account is created from the team member profile.'**
  String get addBarberProfilePhotoAfterCreateSnack;

  /// No description provided for @addBarberMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Team member account details'**
  String get addBarberMainTitle;

  /// No description provided for @addBarberMainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a login for the team member and set a temporary starting password'**
  String get addBarberMainSubtitle;

  /// No description provided for @addBarberSectionPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get addBarberSectionPersonalDetails;

  /// No description provided for @addBarberSectionAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get addBarberSectionAccountAccess;

  /// No description provided for @addBarberFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get addBarberFieldFullName;

  /// No description provided for @addBarberFieldEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get addBarberFieldEmailAddress;

  /// No description provided for @addBarberFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get addBarberFieldUsername;

  /// No description provided for @addBarberFieldPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get addBarberFieldPhoneNumber;

  /// No description provided for @addBarberFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get addBarberFieldRole;

  /// No description provided for @addBarberFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get addBarberFieldPassword;

  /// No description provided for @addBarberFieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get addBarberFieldConfirmPassword;

  /// No description provided for @addBarberPlaceholderFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get addBarberPlaceholderFullName;

  /// No description provided for @addBarberPlaceholderEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get addBarberPlaceholderEmail;

  /// No description provided for @addBarberHelperEmailLogin.
  ///
  /// In en, this message translates to:
  /// **'This email is used to sign in with their password. They can also use their username on the User login screen.'**
  String get addBarberHelperEmailLogin;

  /// No description provided for @addBarberPlaceholderUsername.
  ///
  /// In en, this message translates to:
  /// **'e.g. jane.doe'**
  String get addBarberPlaceholderUsername;

  /// No description provided for @addBarberPlaceholderPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get addBarberPlaceholderPhone;

  /// No description provided for @addBarberPlaceholderPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get addBarberPlaceholderPassword;

  /// No description provided for @addBarberPlaceholderConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get addBarberPlaceholderConfirmPassword;

  /// No description provided for @addBarberHelperPasswordShared.
  ///
  /// In en, this message translates to:
  /// **'Password will be shared with the team member by the salon owner'**
  String get addBarberHelperPasswordShared;

  /// No description provided for @addBarberHelperMustChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Team member will be asked to change the password on first login'**
  String get addBarberHelperMustChangePassword;

  /// No description provided for @addBarberPasswordRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters, including upper and lower case letters and a number'**
  String get addBarberPasswordRulesHint;

  /// No description provided for @addBarberValidationFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get addBarberValidationFullNameRequired;

  /// No description provided for @addBarberValidationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get addBarberValidationEmailRequired;

  /// No description provided for @addBarberValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get addBarberValidationEmailInvalid;

  /// No description provided for @addBarberValidationEmailInternalNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Use the team member\'s own email address, not an internal staff address.'**
  String get addBarberValidationEmailInternalNotAllowed;

  /// No description provided for @addBarberValidationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get addBarberValidationPasswordRequired;

  /// No description provided for @addBarberValidationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get addBarberValidationConfirmPasswordRequired;

  /// No description provided for @addBarberValidationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get addBarberValidationPasswordMinLength;

  /// No description provided for @addBarberValidationPasswordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Password must include uppercase, lowercase, and a number'**
  String get addBarberValidationPasswordComplexity;

  /// No description provided for @addBarberValidationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get addBarberValidationPasswordsMismatch;

  /// No description provided for @addBarberButtonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Team Member'**
  String get addBarberButtonCreate;

  /// No description provided for @addBarberButtonCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating team member...'**
  String get addBarberButtonCreating;

  /// No description provided for @addBarberSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Team member has been created successfully'**
  String get addBarberSuccessMessage;

  /// No description provided for @addBarberSuccessSubtext.
  ///
  /// In en, this message translates to:
  /// **'Ask them to sign in on the User screen with this email or their username and the password you set, then change it on first login if required'**
  String get addBarberSuccessSubtext;

  /// No description provided for @addBarberRequirePasswordChangeOnFirstLogin.
  ///
  /// In en, this message translates to:
  /// **'Require password change on first login'**
  String get addBarberRequirePasswordChangeOnFirstLogin;

  /// No description provided for @addBarberChecklistMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get addBarberChecklistMinLength;

  /// No description provided for @addBarberChecklistUppercase.
  ///
  /// In en, this message translates to:
  /// **'Contains uppercase letter'**
  String get addBarberChecklistUppercase;

  /// No description provided for @addBarberChecklistLowercase.
  ///
  /// In en, this message translates to:
  /// **'Contains lowercase letter'**
  String get addBarberChecklistLowercase;

  /// No description provided for @addBarberChecklistDigit.
  ///
  /// In en, this message translates to:
  /// **'Contains a number'**
  String get addBarberChecklistDigit;

  /// No description provided for @addBarberChecklistPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get addBarberChecklistPasswordsMatch;

  /// No description provided for @teamFieldCommissionType.
  ///
  /// In en, this message translates to:
  /// **'Commission type'**
  String get teamFieldCommissionType;

  /// No description provided for @teamCommissionTypePercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage only'**
  String get teamCommissionTypePercentage;

  /// No description provided for @teamCommissionTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount only'**
  String get teamCommissionTypeFixed;

  /// No description provided for @teamCommissionTypePercentagePlusFixed.
  ///
  /// In en, this message translates to:
  /// **'Percentage + fixed amount'**
  String get teamCommissionTypePercentagePlusFixed;

  /// No description provided for @teamFieldCommissionPercentagePercent.
  ///
  /// In en, this message translates to:
  /// **'Commission rate (%)'**
  String get teamFieldCommissionPercentagePercent;

  /// No description provided for @teamFieldCommissionFixedSar.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount (SAR)'**
  String get teamFieldCommissionFixedSar;

  /// No description provided for @teamCommissionPercentInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a rate like 2, 10, or 25'**
  String get teamCommissionPercentInputHint;

  /// No description provided for @teamCommissionHelperPercentage.
  ///
  /// In en, this message translates to:
  /// **'The rate applies to total sales and services.'**
  String get teamCommissionHelperPercentage;

  /// No description provided for @teamCommissionHelperFixed.
  ///
  /// In en, this message translates to:
  /// **'A fixed amount is added to the team member\'s commission.'**
  String get teamCommissionHelperFixed;

  /// No description provided for @teamCommissionHelperPercentagePlusFixed.
  ///
  /// In en, this message translates to:
  /// **'Combines a sales-based rate with a fixed amount.'**
  String get teamCommissionHelperPercentagePlusFixed;

  /// No description provided for @teamCommissionPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated commission'**
  String get teamCommissionPreviewLabel;

  /// No description provided for @teamCommissionPreviewDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This value is for preview only'**
  String get teamCommissionPreviewDisclaimer;

  /// No description provided for @teamCommissionPreviewSampleNote.
  ///
  /// In en, this message translates to:
  /// **'Illustrative example only — not saved payroll'**
  String get teamCommissionPreviewSampleNote;

  /// No description provided for @teamCommissionPreviewEquationPercent.
  ///
  /// In en, this message translates to:
  /// **'{sales} × {percent} = {result}'**
  String teamCommissionPreviewEquationPercent(
    String sales,
    String percent,
    String result,
  );

  /// No description provided for @teamCommissionPreviewEquationFixed.
  ///
  /// In en, this message translates to:
  /// **'{result}'**
  String teamCommissionPreviewEquationFixed(String result);

  /// No description provided for @teamCommissionPreviewEquationMixed.
  ///
  /// In en, this message translates to:
  /// **'{fixed} + ({sales} × {percent}) = {result}'**
  String teamCommissionPreviewEquationMixed(
    String fixed,
    String sales,
    String percent,
    String result,
  );

  /// No description provided for @teamCommissionPercentRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a commission rate greater than 0.'**
  String get teamCommissionPercentRequired;

  /// No description provided for @teamCommissionPercentInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Rate must be between 0 and 100.'**
  String get teamCommissionPercentInvalidRange;

  /// No description provided for @teamCommissionFixedInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid fixed amount (0 or more).'**
  String get teamCommissionFixedInvalid;

  /// No description provided for @teamCommissionCombinedInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid rate and/or fixed amount.'**
  String get teamCommissionCombinedInvalid;

  /// No description provided for @teamCommissionSummaryFixed.
  ///
  /// In en, this message translates to:
  /// **'{amount} SAR'**
  String teamCommissionSummaryFixed(String amount);

  /// No description provided for @teamCommissionSummaryMixed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% + {amount} SAR'**
  String teamCommissionSummaryMixed(String percent, String amount);

  /// No description provided for @teamFieldCommissionValue.
  ///
  /// In en, this message translates to:
  /// **'Commission value'**
  String get teamFieldCommissionValue;

  /// No description provided for @teamCommissionValueHelper.
  ///
  /// In en, this message translates to:
  /// **'Percentage value used for sales and payroll calculations.'**
  String get teamCommissionValueHelper;

  /// No description provided for @teamFieldAttendanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Attendance required'**
  String get teamFieldAttendanceRequired;

  /// No description provided for @teamFieldAttendanceRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Attendance tracking can be adjusted manually when needed.'**
  String get teamFieldAttendanceRequiredHint;

  /// No description provided for @teamFieldBookable.
  ///
  /// In en, this message translates to:
  /// **'Bookable later'**
  String get teamFieldBookable;

  /// No description provided for @teamFieldBookableHint.
  ///
  /// In en, this message translates to:
  /// **'Prepare this profile for a future customer booking flow.'**
  String get teamFieldBookableHint;

  /// No description provided for @teamFieldActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Active status'**
  String get teamFieldActiveStatus;

  /// No description provided for @teamFieldActiveStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Inactive team members stay hidden from operational actions.'**
  String get teamFieldActiveStatusHint;

  /// No description provided for @teamSaveBarberAction.
  ///
  /// In en, this message translates to:
  /// **'Save team member'**
  String get teamSaveBarberAction;

  /// No description provided for @teamSaveChangesAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get teamSaveChangesAction;

  /// No description provided for @teamResetPasswordPlaceholderNotice.
  ///
  /// In en, this message translates to:
  /// **'Password reset will be added in a later update.'**
  String get teamResetPasswordPlaceholderNotice;

  /// No description provided for @teamMemberDeactivated.
  ///
  /// In en, this message translates to:
  /// **'{name} was deactivated.'**
  String teamMemberDeactivated(String name);

  /// No description provided for @teamMemberActivated.
  ///
  /// In en, this message translates to:
  /// **'{name} was activated.'**
  String teamMemberActivated(String name);

  /// No description provided for @teamAttendanceMarkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked.'**
  String get teamAttendanceMarkedSuccess;

  /// No description provided for @teamAttendanceCheckoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check-out recorded.'**
  String get teamAttendanceCheckoutSuccess;

  /// No description provided for @teamAttendanceAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s attendance is already complete.'**
  String get teamAttendanceAlreadyCompleted;

  /// No description provided for @teamAttendanceMarkError.
  ///
  /// In en, this message translates to:
  /// **'Could not update attendance.'**
  String get teamAttendanceMarkError;

  /// No description provided for @teamMemberAttendanceAdminNoRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'No attendance today'**
  String get teamMemberAttendanceAdminNoRecordTitle;

  /// No description provided for @teamMemberAttendanceAdminNoRecordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} has not checked in yet.'**
  String teamMemberAttendanceAdminNoRecordSubtitle(String name);

  /// No description provided for @teamMemberAttendanceAdminCheckedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Currently checked in'**
  String get teamMemberAttendanceAdminCheckedInTitle;

  /// No description provided for @teamMemberAttendanceAdminCheckedInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in recorded; check-out is still pending.'**
  String get teamMemberAttendanceAdminCheckedInSubtitle;

  /// No description provided for @teamMemberAttendanceAdminCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance completed'**
  String get teamMemberAttendanceAdminCompletedTitle;

  /// No description provided for @teamMemberAttendanceAdminCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in and check-out are recorded for today.'**
  String get teamMemberAttendanceAdminCompletedSubtitle;

  /// No description provided for @teamMemberAttendanceStatusNone.
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get teamMemberAttendanceStatusNone;

  /// No description provided for @teamMemberAttendanceCheckInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get teamMemberAttendanceCheckInLabel;

  /// No description provided for @teamMemberAttendanceCheckOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get teamMemberAttendanceCheckOutLabel;

  /// No description provided for @teamMemberAttendanceAddManual.
  ///
  /// In en, this message translates to:
  /// **'Add attendance manually'**
  String get teamMemberAttendanceAddManual;

  /// No description provided for @teamMemberAttendanceEditManual.
  ///
  /// In en, this message translates to:
  /// **'Edit attendance record'**
  String get teamMemberAttendanceEditManual;

  /// No description provided for @teamMemberAttendanceSummaryWeek.
  ///
  /// In en, this message translates to:
  /// **'Attendance this week'**
  String get teamMemberAttendanceSummaryWeek;

  /// No description provided for @teamMemberAttendanceSummaryLateMonth.
  ///
  /// In en, this message translates to:
  /// **'Late count'**
  String get teamMemberAttendanceSummaryLateMonth;

  /// No description provided for @teamMemberAttendanceSummaryLateMonthHint.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get teamMemberAttendanceSummaryLateMonthHint;

  /// No description provided for @teamMemberAttendanceSummaryMissingCheckout.
  ///
  /// In en, this message translates to:
  /// **'Missing check-outs'**
  String get teamMemberAttendanceSummaryMissingCheckout;

  /// No description provided for @teamMemberAttendanceSummaryMissingCheckoutHint.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get teamMemberAttendanceSummaryMissingCheckoutHint;

  /// No description provided for @teamMemberAttendanceSummaryPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get teamMemberAttendanceSummaryPendingRequests;

  /// No description provided for @teamMemberAttendanceSummaryPendingRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'corrections'**
  String get teamMemberAttendanceSummaryPendingRequestsHint;

  /// No description provided for @teamMemberAttendanceSummaryDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get teamMemberAttendanceSummaryDaysUnit;

  /// No description provided for @teamMemberAttendanceCorrectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction requests'**
  String get teamMemberAttendanceCorrectionsTitle;

  /// No description provided for @teamMemberAttendanceCorrectionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No correction requests'**
  String get teamMemberAttendanceCorrectionEmptyTitle;

  /// No description provided for @teamMemberAttendanceCorrectionEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This team member’s requests will appear here.'**
  String get teamMemberAttendanceCorrectionEmptySubtitle;

  /// No description provided for @teamMemberAttendanceApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get teamMemberAttendanceApprove;

  /// No description provided for @teamMemberAttendanceReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get teamMemberAttendanceReject;

  /// No description provided for @teamMemberAttendanceRequestTypeMissingCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Missing check-in'**
  String get teamMemberAttendanceRequestTypeMissingCheckIn;

  /// No description provided for @teamMemberAttendanceRequestTypeMissingCheckout.
  ///
  /// In en, this message translates to:
  /// **'Missing check-out'**
  String get teamMemberAttendanceRequestTypeMissingCheckout;

  /// No description provided for @teamMemberAttendanceRequestTypeWrongCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Wrong check-in time'**
  String get teamMemberAttendanceRequestTypeWrongCheckIn;

  /// No description provided for @teamMemberAttendanceRequestTypeWrongCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Wrong check-out time'**
  String get teamMemberAttendanceRequestTypeWrongCheckOut;

  /// No description provided for @teamMemberAttendanceRequestTypeAbsence.
  ///
  /// In en, this message translates to:
  /// **'Absence correction'**
  String get teamMemberAttendanceRequestTypeAbsence;

  /// No description provided for @teamMemberAttendanceRequestTypeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction'**
  String get teamMemberAttendanceRequestTypeGeneric;

  /// No description provided for @teamMemberAttendanceStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get teamMemberAttendanceStatusPending;

  /// No description provided for @teamMemberAttendanceStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get teamMemberAttendanceStatusApproved;

  /// No description provided for @teamMemberAttendanceStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get teamMemberAttendanceStatusRejected;

  /// No description provided for @teamMemberAttendanceNoReason.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get teamMemberAttendanceNoReason;

  /// No description provided for @teamMemberAttendanceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent attendance'**
  String get teamMemberAttendanceHistoryTitle;

  /// No description provided for @teamMemberAttendanceViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get teamMemberAttendanceViewAll;

  /// No description provided for @teamMemberAttendanceHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet'**
  String get teamMemberAttendanceHistoryEmpty;

  /// No description provided for @teamMemberAttendanceRecordStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get teamMemberAttendanceRecordStatusPresent;

  /// No description provided for @teamMemberAttendanceRecordStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get teamMemberAttendanceRecordStatusLate;

  /// No description provided for @teamMemberAttendanceRecordStatusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get teamMemberAttendanceRecordStatusIncomplete;

  /// No description provided for @teamMemberAttendanceRecordStatusManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get teamMemberAttendanceRecordStatusManual;

  /// No description provided for @teamMemberAttendanceRecordStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get teamMemberAttendanceRecordStatusAbsent;

  /// No description provided for @teamMemberAttendanceManualSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance record saved.'**
  String get teamMemberAttendanceManualSaved;

  /// No description provided for @teamMemberAttendanceCorrectionApproved.
  ///
  /// In en, this message translates to:
  /// **'Correction request approved.'**
  String get teamMemberAttendanceCorrectionApproved;

  /// No description provided for @teamMemberAttendanceCorrectionRejected.
  ///
  /// In en, this message translates to:
  /// **'Correction request rejected.'**
  String get teamMemberAttendanceCorrectionRejected;

  /// No description provided for @teamMemberAttendanceManualSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual attendance'**
  String get teamMemberAttendanceManualSheetTitle;

  /// No description provided for @teamMemberAttendanceSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get teamMemberAttendanceSave;

  /// No description provided for @teamMemberAttendanceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get teamMemberAttendanceDateLabel;

  /// No description provided for @teamMemberAttendanceStatusFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get teamMemberAttendanceStatusFieldLabel;

  /// No description provided for @teamMemberAttendanceLateMinutes.
  ///
  /// In en, this message translates to:
  /// **'Late minutes'**
  String get teamMemberAttendanceLateMinutes;

  /// No description provided for @teamMemberAttendanceEarlyExitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Early exit minutes'**
  String get teamMemberAttendanceEarlyExitMinutes;

  /// No description provided for @teamMemberAttendanceMissingCheckoutSwitch.
  ///
  /// In en, this message translates to:
  /// **'Missing check-out'**
  String get teamMemberAttendanceMissingCheckoutSwitch;

  /// No description provided for @teamMemberAttendanceNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get teamMemberAttendanceNotes;

  /// No description provided for @teamMemberAttendanceReviewApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve correction'**
  String get teamMemberAttendanceReviewApproveTitle;

  /// No description provided for @teamMemberAttendanceReviewRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject correction'**
  String get teamMemberAttendanceReviewRejectTitle;

  /// No description provided for @teamMemberAttendanceReviewNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get teamMemberAttendanceReviewNoteLabel;

  /// No description provided for @teamMemberAttendanceReviewConfirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get teamMemberAttendanceReviewConfirmApprove;

  /// No description provided for @teamMemberAttendanceReviewConfirmReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get teamMemberAttendanceReviewConfirmReject;

  /// No description provided for @teamDetailsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load team member details'**
  String get teamDetailsLoadErrorTitle;

  /// No description provided for @teamDetailsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get teamDetailsTabOverview;

  /// No description provided for @teamDetailsTabSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get teamDetailsTabSales;

  /// No description provided for @teamDetailsTabAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get teamDetailsTabAttendance;

  /// No description provided for @teamDetailsTabPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get teamDetailsTabPayroll;

  /// No description provided for @teamDetailsTabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get teamDetailsTabServices;

  /// No description provided for @teamDetailsTabBookingPrep.
  ///
  /// In en, this message translates to:
  /// **'Booking Prep'**
  String get teamDetailsTabBookingPrep;

  /// No description provided for @teamDetailsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get teamDetailsStatusLabel;

  /// No description provided for @teamDetailsJoinDate.
  ///
  /// In en, this message translates to:
  /// **'Join date'**
  String get teamDetailsJoinDate;

  /// No description provided for @teamDetailsCommissionRate.
  ///
  /// In en, this message translates to:
  /// **'Commission %'**
  String get teamDetailsCommissionRate;

  /// No description provided for @teamDetailsBookableLater.
  ///
  /// In en, this message translates to:
  /// **'Bookable later'**
  String get teamDetailsBookableLater;

  /// No description provided for @teamProfileStatusFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get teamProfileStatusFrozen;

  /// No description provided for @teamProfileJoinDateMissing.
  ///
  /// In en, this message translates to:
  /// **'Join date not available'**
  String get teamProfileJoinDateMissing;

  /// No description provided for @teamProfileSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get teamProfileSectionContact;

  /// No description provided for @teamProfileSectionWorkSettings.
  ///
  /// In en, this message translates to:
  /// **'Work settings'**
  String get teamProfileSectionWorkSettings;

  /// No description provided for @teamProfileTodaySalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Today sales'**
  String get teamProfileTodaySalesLabel;

  /// No description provided for @teamProfileServicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get teamProfileServicesLabel;

  /// No description provided for @teamProfileAttendanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get teamProfileAttendanceLabel;

  /// No description provided for @teamProfileActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get teamProfileActionCall;

  /// No description provided for @teamProfileActionAddBooking.
  ///
  /// In en, this message translates to:
  /// **'Add booking'**
  String get teamProfileActionAddBooking;

  /// No description provided for @teamProfilePhoneMissingSnack.
  ///
  /// In en, this message translates to:
  /// **'Phone number is not available'**
  String get teamProfilePhoneMissingSnack;

  /// No description provided for @teamProfileDialerErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not open phone dialer'**
  String get teamProfileDialerErrorSnack;

  /// No description provided for @teamProfileWhatsAppUnavailableSnack.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not available on this device'**
  String get teamProfileWhatsAppUnavailableSnack;

  /// No description provided for @teamProfileBookingUnavailableSnack.
  ///
  /// In en, this message translates to:
  /// **'This team member is not available for booking'**
  String get teamProfileBookingUnavailableSnack;

  /// No description provided for @teamProfileAttendanceNotRequiredSummary.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get teamProfileAttendanceNotRequiredSummary;

  /// No description provided for @teamProfilePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view this team member.'**
  String get teamProfilePermissionDenied;

  /// No description provided for @teamProfileLoadGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading this team member.'**
  String get teamProfileLoadGenericError;

  /// No description provided for @teamProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Team member was not found.'**
  String get teamProfileNotFound;

  /// No description provided for @teamValueNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get teamValueNotAvailable;

  /// No description provided for @teamValueYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get teamValueYes;

  /// No description provided for @teamValueNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get teamValueNo;

  /// No description provided for @teamValueEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get teamValueEnabled;

  /// No description provided for @teamValueDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get teamValueDisabled;

  /// No description provided for @teamCommissionPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String teamCommissionPercentValue(String value);

  /// No description provided for @teamNoSalesTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded today'**
  String get teamNoSalesTodayTitle;

  /// No description provided for @teamNoSalesTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record the first sale for this team member.'**
  String get teamNoSalesTodaySubtitle;

  /// No description provided for @teamSalesRecentSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sales'**
  String get teamSalesRecentSalesTitle;

  /// No description provided for @teamSalesTopServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top sold services'**
  String get teamSalesTopServicesTitle;

  /// No description provided for @teamTopServicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No service performance yet.'**
  String get teamTopServicesEmpty;

  /// No description provided for @teamSalesTopServiceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sold'**
  String teamSalesTopServiceCount(int count);

  /// No description provided for @teamSalesAverageTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Average ticket value'**
  String get teamSalesAverageTicketTitle;

  /// No description provided for @teamPlaceholderLaterReady.
  ///
  /// In en, this message translates to:
  /// **'Later-ready placeholder'**
  String get teamPlaceholderLaterReady;

  /// No description provided for @teamSalesRevenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue today'**
  String get teamSalesRevenueToday;

  /// No description provided for @teamSalesRevenueWeek.
  ///
  /// In en, this message translates to:
  /// **'Revenue this week'**
  String get teamSalesRevenueWeek;

  /// No description provided for @teamSalesRevenueMonth.
  ///
  /// In en, this message translates to:
  /// **'Revenue this month'**
  String get teamSalesRevenueMonth;

  /// No description provided for @teamSalesServicesToday.
  ///
  /// In en, this message translates to:
  /// **'Services today'**
  String get teamSalesServicesToday;

  /// No description provided for @teamSalesServicesMonth.
  ///
  /// In en, this message translates to:
  /// **'Services this month'**
  String get teamSalesServicesMonth;

  /// No description provided for @teamSalesCommissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission {value}'**
  String teamSalesCommissionLabel(String value);

  /// No description provided for @teamMemberSalesHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales history'**
  String get teamMemberSalesHistoryTitle;

  /// No description provided for @teamMemberSalesFilterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get teamMemberSalesFilterThisMonth;

  /// No description provided for @teamMemberSalesFilterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get teamMemberSalesFilterToday;

  /// No description provided for @teamMemberSalesFilterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get teamMemberSalesFilterThisWeek;

  /// No description provided for @teamMemberSalesFilterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get teamMemberSalesFilterCustom;

  /// No description provided for @teamMemberSalesShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing: {filter}'**
  String teamMemberSalesShowing(String filter);

  /// No description provided for @teamMemberSalesHistoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String teamMemberSalesHistoryTotal(String amount);

  /// No description provided for @teamMemberSalesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sales. Please try again.'**
  String get teamMemberSalesLoadError;

  /// No description provided for @teamMemberSalesPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view these sales.'**
  String get teamMemberSalesPermissionDenied;

  /// No description provided for @teamMemberSalesEmptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period'**
  String get teamMemberSalesEmptyHistoryTitle;

  /// No description provided for @teamMemberSalesEmptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another date range or record a new sale.'**
  String get teamMemberSalesEmptyHistorySubtitle;

  /// No description provided for @teamMemberSalesWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer'**
  String get teamMemberSalesWalkInCustomer;

  /// No description provided for @teamMemberSalesServiceSummaryFallback.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get teamMemberSalesServiceSummaryFallback;

  /// No description provided for @teamMemberSalesSmartSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart summary'**
  String get teamMemberSalesSmartSummaryTitle;

  /// No description provided for @teamMemberSalesNotAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get teamMemberSalesNotAvailableShort;

  /// No description provided for @teamNoAttendanceTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'No attendance yet today'**
  String get teamNoAttendanceTodayTitle;

  /// No description provided for @teamNoAttendanceTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance to start the day.'**
  String get teamNoAttendanceTodaySubtitle;

  /// No description provided for @teamAttendanceTodayStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s attendance'**
  String get teamAttendanceTodayStatusTitle;

  /// No description provided for @teamAttendanceCheckedInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in time'**
  String get teamAttendanceCheckedInLabel;

  /// No description provided for @teamAttendanceCheckedOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-out time'**
  String get teamAttendanceCheckedOutLabel;

  /// No description provided for @teamAttendanceStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance status'**
  String get teamAttendanceStatusLabel;

  /// No description provided for @teamAttendanceWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly attendance'**
  String get teamAttendanceWeeklySummary;

  /// No description provided for @teamAttendanceLateCount.
  ///
  /// In en, this message translates to:
  /// **'Late count'**
  String get teamAttendanceLateCount;

  /// No description provided for @teamAttendanceMissingCheckoutCount.
  ///
  /// In en, this message translates to:
  /// **'Missing checkout'**
  String get teamAttendanceMissingCheckoutCount;

  /// No description provided for @teamAttendanceCorrectionRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction requests'**
  String get teamAttendanceCorrectionRequestsTitle;

  /// No description provided for @teamPayrollCommissionPercentage.
  ///
  /// In en, this message translates to:
  /// **'Commission percentage'**
  String get teamPayrollCommissionPercentage;

  /// No description provided for @teamPayrollCommissionToday.
  ///
  /// In en, this message translates to:
  /// **'Commission today'**
  String get teamPayrollCommissionToday;

  /// No description provided for @teamPayrollCommissionMonth.
  ///
  /// In en, this message translates to:
  /// **'Commission this month'**
  String get teamPayrollCommissionMonth;

  /// No description provided for @teamPayrollBonusesTotal.
  ///
  /// In en, this message translates to:
  /// **'Bonuses total'**
  String get teamPayrollBonusesTotal;

  /// No description provided for @teamPayrollDeductionsTotal.
  ///
  /// In en, this message translates to:
  /// **'Deductions total'**
  String get teamPayrollDeductionsTotal;

  /// No description provided for @teamPayrollEstimatedPayout.
  ///
  /// In en, this message translates to:
  /// **'Estimated payout'**
  String get teamPayrollEstimatedPayout;

  /// No description provided for @teamPayrollHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payroll history yet'**
  String get teamPayrollHistoryEmptyTitle;

  /// No description provided for @teamPayrollHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly payroll history will appear here as records are generated.'**
  String get teamPayrollHistoryEmptySubtitle;

  /// No description provided for @teamPayrollHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll history'**
  String get teamPayrollHistoryTitle;

  /// No description provided for @teamServicesEditAssignmentsAction.
  ///
  /// In en, this message translates to:
  /// **'Edit service assignment'**
  String get teamServicesEditAssignmentsAction;

  /// No description provided for @teamServicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services assigned yet'**
  String get teamServicesEmptyTitle;

  /// No description provided for @teamServicesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign services to prepare this team member for operations and future booking.'**
  String get teamServicesEmptySubtitle;

  /// No description provided for @teamServicesAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned services'**
  String get teamServicesAssignedTitle;

  /// No description provided for @teamServicesServiceActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get teamServicesServiceActive;

  /// No description provided for @teamServicesServiceInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get teamServicesServiceInactive;

  /// No description provided for @teamBookingPrepPublicDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Public display name'**
  String get teamBookingPrepPublicDisplayName;

  /// No description provided for @teamBookingPrepPublicBio.
  ///
  /// In en, this message translates to:
  /// **'Public bio'**
  String get teamBookingPrepPublicBio;

  /// No description provided for @teamBookingPrepWorkingHoursProfile.
  ///
  /// In en, this message translates to:
  /// **'Working hours profile'**
  String get teamBookingPrepWorkingHoursProfile;

  /// No description provided for @teamBookingPrepSlotDuration.
  ///
  /// In en, this message translates to:
  /// **'Booking slot duration'**
  String get teamBookingPrepSlotDuration;

  /// No description provided for @teamBookingPrepDisplayOrder.
  ///
  /// In en, this message translates to:
  /// **'Display order'**
  String get teamBookingPrepDisplayOrder;

  /// No description provided for @teamBookingPrepProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile image'**
  String get teamBookingPrepProfileImage;

  /// No description provided for @teamBookingPrepVisibleServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Visible services for customers'**
  String get teamBookingPrepVisibleServicesTitle;

  /// No description provided for @teamBookingPrepVisibleServicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No customer-visible services yet.'**
  String get teamBookingPrepVisibleServicesEmpty;

  /// No description provided for @moneyDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get moneyDashboardTitle;

  /// No description provided for @moneyDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly finance signals, trends, and operational insights.'**
  String get moneyDashboardSubtitle;

  /// No description provided for @moneyDashboardErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load money dashboard'**
  String get moneyDashboardErrorTitle;

  /// No description provided for @moneyDashboardErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get moneyDashboardErrorMessage;

  /// No description provided for @moneyDashboardRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get moneyDashboardRetry;

  /// No description provided for @moneyDashboardTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales vs expenses'**
  String get moneyDashboardTrendTitle;

  /// No description provided for @moneyDashboardTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track how revenue and costs moved across the selected month.'**
  String get moneyDashboardTrendSubtitle;

  /// No description provided for @moneyDashboardSalesLegend.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get moneyDashboardSalesLegend;

  /// No description provided for @moneyDashboardExpensesLegend.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get moneyDashboardExpensesLegend;

  /// No description provided for @moneyDashboardInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get moneyDashboardInsightsTitle;

  /// No description provided for @moneyDashboardInsightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'More insights will appear as sales, payroll, and expenses build up.'**
  String get moneyDashboardInsightsEmpty;

  /// No description provided for @moneyDashboardSalesNavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the transaction engine and record sales.'**
  String get moneyDashboardSalesNavSubtitle;

  /// No description provided for @moneyDashboardExpensesNavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review costs, categories, and recent expenses.'**
  String get moneyDashboardExpensesNavSubtitle;

  /// No description provided for @moneyDashboardSummaryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Financial snapshot'**
  String get moneyDashboardSummaryHeadline;

  /// No description provided for @moneyDashboardSalesTotal.
  ///
  /// In en, this message translates to:
  /// **'Sales total'**
  String get moneyDashboardSalesTotal;

  /// No description provided for @moneyDashboardExpensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Expenses total'**
  String get moneyDashboardExpensesTotal;

  /// No description provided for @moneyDashboardPayrollTotal.
  ///
  /// In en, this message translates to:
  /// **'Payroll total'**
  String get moneyDashboardPayrollTotal;

  /// No description provided for @moneyDashboardNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get moneyDashboardNetProfit;

  /// No description provided for @moneyDashboardInsightTopBarber.
  ///
  /// In en, this message translates to:
  /// **'{name} leads this month with {amount} in sales.'**
  String moneyDashboardInsightTopBarber(Object name, Object amount);

  /// No description provided for @moneyDashboardInsightTopService.
  ///
  /// In en, this message translates to:
  /// **'{service} is the top earning service at {amount}.'**
  String moneyDashboardInsightTopService(Object service, Object amount);

  /// No description provided for @moneyDashboardInsightExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} accounts for the largest expense share at {share}.'**
  String moneyDashboardInsightExpenseCategory(Object category, Object share);

  /// No description provided for @moneyDashboardUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get moneyDashboardUncategorized;

  /// No description provided for @moneyDashboardNetLossWarning.
  ///
  /// In en, this message translates to:
  /// **'Net profit is negative after payroll. Trim discretionary expenses, revisit pricing, and review payroll timing for this month.'**
  String get moneyDashboardNetLossWarning;

  /// No description provided for @moneyDashboardTrendPeakSalesSummary.
  ///
  /// In en, this message translates to:
  /// **'Peak sales day {day} · {amount}'**
  String moneyDashboardTrendPeakSalesSummary(Object day, Object amount);

  /// No description provided for @moneyDashboardInsightActionTopBarber.
  ///
  /// In en, this message translates to:
  /// **'Double down on {name} ({amount} sales) — protect their chair time, clone what works in consultations, and rebalance quieter books.'**
  String moneyDashboardInsightActionTopBarber(Object name, Object amount);

  /// No description provided for @moneyDashboardInsightActionTopService.
  ///
  /// In en, this message translates to:
  /// **'Feature {service} in bundles and upsells — it earned {amount} this month.'**
  String moneyDashboardInsightActionTopService(Object service, Object amount);

  /// No description provided for @moneyDashboardInsightActionExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Spend clusters in {category} ({share}) — audit vendors, subscriptions, and category rules before they compound.'**
  String moneyDashboardInsightActionExpenseCategory(
    Object category,
    Object share,
  );

  /// No description provided for @moneyDashboardSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search team, revenue, and requests'**
  String get moneyDashboardSearchHint;

  /// No description provided for @moneyDashboardChartGranularityDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get moneyDashboardChartGranularityDaily;

  /// No description provided for @moneyDashboardKpiTrendNoData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get moneyDashboardKpiTrendNoData;

  /// No description provided for @moneyDashboardKpiTrendNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get moneyDashboardKpiTrendNew;

  /// No description provided for @moneyDashboardKpiTrendUpVsMonth.
  ///
  /// In en, this message translates to:
  /// **'↗ {percent}% vs {month}'**
  String moneyDashboardKpiTrendUpVsMonth(Object percent, Object month);

  /// No description provided for @moneyDashboardKpiTrendDownVsMonth.
  ///
  /// In en, this message translates to:
  /// **'↘ {percent}% vs {month}'**
  String moneyDashboardKpiTrendDownVsMonth(Object percent, Object month);

  /// No description provided for @moneyDashboardKpiTrendFlatVsMonth.
  ///
  /// In en, this message translates to:
  /// **'→ {percent}% vs {month}'**
  String moneyDashboardKpiTrendFlatVsMonth(Object percent, Object month);

  /// No description provided for @moneyDashboardQuickPayrollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review monthly payroll runs and payslips.'**
  String get moneyDashboardQuickPayrollSubtitle;

  /// No description provided for @moneyDashboardQuickSalesBody.
  ///
  /// In en, this message translates to:
  /// **'Record transactions and monitor service revenue.'**
  String get moneyDashboardQuickSalesBody;

  /// No description provided for @moneyDashboardQuickExpensesBody.
  ///
  /// In en, this message translates to:
  /// **'Track costs, categories, and recent spending.'**
  String get moneyDashboardQuickExpensesBody;

  /// No description provided for @salesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesScreenTitle;

  /// No description provided for @salesScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track revenue, services and performance.'**
  String get salesScreenSubtitle;

  /// No description provided for @salesScreenAddSale.
  ///
  /// In en, this message translates to:
  /// **'Add sale'**
  String get salesScreenAddSale;

  /// No description provided for @salesScreenErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load sales'**
  String get salesScreenErrorTitle;

  /// No description provided for @salesScreenErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The transaction feed is unavailable right now.'**
  String get salesScreenErrorMessage;

  /// No description provided for @salesScreenSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart summary'**
  String get salesScreenSummaryTitle;

  /// No description provided for @salesScreenTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get salesScreenTransactionCount;

  /// No description provided for @salesScreenAverageTicket.
  ///
  /// In en, this message translates to:
  /// **'Average ticket'**
  String get salesScreenAverageTicket;

  /// No description provided for @salesScreenTopBarber.
  ///
  /// In en, this message translates to:
  /// **'Top team member'**
  String get salesScreenTopBarber;

  /// No description provided for @salesScreenTopService.
  ///
  /// In en, this message translates to:
  /// **'Top service'**
  String get salesScreenTopService;

  /// No description provided for @salesScreenValuePending.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get salesScreenValuePending;

  /// No description provided for @salesScreenCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range: {start} - {end}'**
  String salesScreenCustomRange(Object start, Object end);

  /// No description provided for @salesScreenBarberFilter.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get salesScreenBarberFilter;

  /// No description provided for @salesScreenAllBarbers.
  ///
  /// In en, this message translates to:
  /// **'All team members'**
  String get salesScreenAllBarbers;

  /// No description provided for @salesScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get salesScreenEmptyTitle;

  /// No description provided for @salesScreenEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Record the first sale to start tracking revenue here.'**
  String get salesScreenEmptyMessage;

  /// No description provided for @salesScreenDayTotal.
  ///
  /// In en, this message translates to:
  /// **'Day total {amount}'**
  String salesScreenDayTotal(Object amount);

  /// No description provided for @salesScreenUnknownService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get salesScreenUnknownService;

  /// No description provided for @salesScreenAllPayments.
  ///
  /// In en, this message translates to:
  /// **'All payments'**
  String get salesScreenAllPayments;

  /// No description provided for @salesScreenFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get salesScreenFiltersButton;

  /// No description provided for @salesScreenFiltersSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Refine sales'**
  String get salesScreenFiltersSheetTitle;

  /// No description provided for @salesScreenTopServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top services by revenue'**
  String get salesScreenTopServicesTitle;

  /// No description provided for @salesScreenBarberRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Team performance'**
  String get salesScreenBarberRankingTitle;

  /// No description provided for @salesScreenTopServicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Service mix will show once sales include line items.'**
  String get salesScreenTopServicesEmpty;

  /// No description provided for @salesScreenPaymentSingleMethod.
  ///
  /// In en, this message translates to:
  /// **'All sales used {method}. Consider promoting card or wallet to reduce cash handling.'**
  String salesScreenPaymentSingleMethod(Object method);

  /// No description provided for @salesDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale details'**
  String get salesDetailsTitle;

  /// No description provided for @salesDetailsNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale not found'**
  String get salesDetailsNotFoundTitle;

  /// No description provided for @salesDetailsNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This sale is no longer available for your salon.'**
  String get salesDetailsNotFoundMessage;

  /// No description provided for @salesDetailsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get salesDetailsOverviewTitle;

  /// No description provided for @salesDetailsLineItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Line items'**
  String get salesDetailsLineItemsTitle;

  /// No description provided for @salesDetailsCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get salesDetailsCustomerLabel;

  /// No description provided for @salesDetailsRecordedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded by'**
  String get salesDetailsRecordedByLabel;

  /// No description provided for @salesDetailsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get salesDetailsStatusLabel;

  /// No description provided for @salesDetailsPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get salesDetailsPaymentLabel;

  /// No description provided for @salesDetailsSoldAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Sold at'**
  String get salesDetailsSoldAtLabel;

  /// No description provided for @salesDetailsSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get salesDetailsSubtotalLabel;

  /// No description provided for @salesDetailsTaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get salesDetailsTaxLabel;

  /// No description provided for @salesDetailsDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get salesDetailsDiscountLabel;

  /// No description provided for @salesDetailsCommissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get salesDetailsCommissionLabel;

  /// No description provided for @salesStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get salesStatusCompleted;

  /// No description provided for @salesStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get salesStatusPending;

  /// No description provided for @salesStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get salesStatusRefunded;

  /// No description provided for @salesStatusVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get salesStatusVoided;

  /// No description provided for @salesDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get salesDateToday;

  /// No description provided for @salesDateThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get salesDateThisWeek;

  /// No description provided for @salesDateThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get salesDateThisMonth;

  /// No description provided for @salesDateCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get salesDateCustom;

  /// No description provided for @salesHeroTotalSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total sales'**
  String get salesHeroTotalSalesLabel;

  /// No description provided for @salesChartSalesVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Sales vs Expenses'**
  String get salesChartSalesVsExpenses;

  /// No description provided for @salesChartLegendSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesChartLegendSales;

  /// No description provided for @salesChartLegendExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get salesChartLegendExpenses;

  /// No description provided for @salesInsightTopServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By revenue'**
  String get salesInsightTopServicesSubtitle;

  /// No description provided for @salesInsightBarberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By revenue'**
  String get salesInsightBarberSubtitle;

  /// No description provided for @salesInsightPaymentMixTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method mix'**
  String get salesInsightPaymentMixTitle;

  /// No description provided for @salesInsightPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By method'**
  String get salesInsightPaymentSubtitle;

  /// No description provided for @salesInsightHelperTopServices.
  ///
  /// In en, this message translates to:
  /// **'Record sales to see your top performing services.'**
  String get salesInsightHelperTopServices;

  /// No description provided for @salesInsightHelperBarber.
  ///
  /// In en, this message translates to:
  /// **'Record sales to see your team members\' performance.'**
  String get salesInsightHelperBarber;

  /// No description provided for @salesInsightHelperPayment.
  ///
  /// In en, this message translates to:
  /// **'Record sales to see your payment mix.'**
  String get salesInsightHelperPayment;

  /// No description provided for @salesInsightActionAddServices.
  ///
  /// In en, this message translates to:
  /// **'Add services'**
  String get salesInsightActionAddServices;

  /// No description provided for @salesInsightActionAddSales.
  ///
  /// In en, this message translates to:
  /// **'Add sales'**
  String get salesInsightActionAddSales;

  /// No description provided for @salesRecentCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sales'**
  String get salesRecentCardTitle;

  /// No description provided for @salesRecentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get salesRecentEmptyTitle;

  /// No description provided for @salesRecentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start adding sales to see your recent transactions here.'**
  String get salesRecentEmptyBody;

  /// No description provided for @paymentMethodMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get paymentMethodMixed;

  /// No description provided for @addSaleSelectServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select services'**
  String get addSaleSelectServicesTitle;

  /// No description provided for @addSaleManageServices.
  ///
  /// In en, this message translates to:
  /// **'Manage services'**
  String get addSaleManageServices;

  /// No description provided for @addSaleSearchServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get addSaleSearchServicesHint;

  /// No description provided for @addSaleSelectedServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected services ({count})'**
  String addSaleSelectedServicesTitle(int count);

  /// No description provided for @addSaleAddAnotherService.
  ///
  /// In en, this message translates to:
  /// **'Add another service'**
  String get addSaleAddAnotherService;

  /// No description provided for @addSaleBarberLabel.
  ///
  /// In en, this message translates to:
  /// **'Service provider'**
  String get addSaleBarberLabel;

  /// No description provided for @addSaleWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer'**
  String get addSaleWalkInCustomer;

  /// No description provided for @addSaleAddNameLink.
  ///
  /// In en, this message translates to:
  /// **'Add name'**
  String get addSaleAddNameLink;

  /// No description provided for @addSaleOrderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get addSaleOrderSummaryTitle;

  /// No description provided for @addSaleSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get addSaleSubtotal;

  /// No description provided for @addSaleDiscountLink.
  ///
  /// In en, this message translates to:
  /// **'Add discount'**
  String get addSaleDiscountLink;

  /// No description provided for @addSaleDiscountTitle.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get addSaleDiscountTitle;

  /// No description provided for @addSaleDiscountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount to subtract from subtotal'**
  String get addSaleDiscountHint;

  /// No description provided for @addSaleTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get addSaleTotal;

  /// No description provided for @addSaleRecordSale.
  ///
  /// In en, this message translates to:
  /// **'Record sale'**
  String get addSaleRecordSale;

  /// No description provided for @addSaleDiscountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Discount cannot exceed the subtotal.'**
  String get addSaleDiscountInvalid;

  /// No description provided for @expensesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesScreenTitle;

  /// No description provided for @expensesScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your salon\'s spending in one place.'**
  String get expensesScreenSubtitle;

  /// No description provided for @expensesScreenSalonMissing.
  ///
  /// In en, this message translates to:
  /// **'Salon profile not found.'**
  String get expensesScreenSalonMissing;

  /// No description provided for @expensesScreenRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get expensesScreenRetry;

  /// No description provided for @expensesScreenTotalExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get expensesScreenTotalExpensesLabel;

  /// No description provided for @expensesScreenTransactionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get expensesScreenTransactionsLabel;

  /// No description provided for @expensesScreenTransactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 transaction} other{{count} transactions}}'**
  String expensesScreenTransactionsCount(int count);

  /// No description provided for @expensesScreenViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get expensesScreenViewAll;

  /// No description provided for @expensesScreenNoCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get expensesScreenNoCategoriesTitle;

  /// No description provided for @expensesScreenNoCategoriesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to see category insights.'**
  String get expensesScreenNoCategoriesMessage;

  /// No description provided for @expensesScreenRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent expenses'**
  String get expensesScreenRecentTitle;

  /// No description provided for @expensesScreenReportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reports are coming soon.'**
  String get expensesScreenReportComingSoon;

  /// No description provided for @expensesScreenRecordedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded by'**
  String get expensesScreenRecordedByLabel;

  /// No description provided for @expensesScreenAllCreators.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get expensesScreenAllCreators;

  /// No description provided for @expensesScreenClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get expensesScreenClearFilters;

  /// No description provided for @expensesScreenApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get expensesScreenApplyFilters;

  /// No description provided for @expensesScreenAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expensesScreenAddExpense;

  /// No description provided for @expensesScreenErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load expenses'**
  String get expensesScreenErrorTitle;

  /// No description provided for @expensesScreenErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The expense feed is unavailable right now.'**
  String get expensesScreenErrorMessage;

  /// No description provided for @expensesScreenSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart summary'**
  String get expensesScreenSummaryTitle;

  /// No description provided for @expensesScreenCount.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesScreenCount;

  /// No description provided for @expensesScreenTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get expensesScreenTopCategory;

  /// No description provided for @expensesScreenValuePending.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get expensesScreenValuePending;

  /// No description provided for @expensesScreenAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expensesScreenAllCategories;

  /// No description provided for @expensesScreenBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get expensesScreenBreakdownTitle;

  /// No description provided for @expensesScreenBreakdownEmpty.
  ///
  /// In en, this message translates to:
  /// **'Breakdown will appear after you log expenses.'**
  String get expensesScreenBreakdownEmpty;

  /// No description provided for @expensesScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expensesScreenEmptyTitle;

  /// No description provided for @expensesScreenEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the first expense to start tracking costs here.'**
  String get expensesScreenEmptyMessage;

  /// No description provided for @expensesScreenDayTotal.
  ///
  /// In en, this message translates to:
  /// **'Day total {amount}'**
  String expensesScreenDayTotal(Object amount);

  /// No description provided for @expensesScreenUnknownExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expensesScreenUnknownExpense;

  /// No description provided for @expensesScreenFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get expensesScreenFiltersButton;

  /// No description provided for @expensesScreenFiltersSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Refine expenses'**
  String get expensesScreenFiltersSheetTitle;

  /// No description provided for @expensesScreenAverageExpense.
  ///
  /// In en, this message translates to:
  /// **'Avg / expense'**
  String get expensesScreenAverageExpense;

  /// No description provided for @expensesScreenHighestExpense.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get expensesScreenHighestExpense;

  /// No description provided for @expensesScreenTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get expensesScreenTrend;

  /// No description provided for @expensesScreenTrendVsPrior.
  ///
  /// In en, this message translates to:
  /// **'{percent} vs prior window'**
  String expensesScreenTrendVsPrior(Object percent);

  /// No description provided for @expenseScreenLinkedBarber.
  ///
  /// In en, this message translates to:
  /// **'Related team member'**
  String get expenseScreenLinkedBarber;

  /// No description provided for @addSalePaymentMethodField.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get addSalePaymentMethodField;

  /// No description provided for @employeeAddSaleFab.
  ///
  /// In en, this message translates to:
  /// **'Add Sale'**
  String get employeeAddSaleFab;

  /// No description provided for @employeeSectionPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view this section.'**
  String get employeeSectionPermissionDenied;

  /// No description provided for @employeeTodayWorkspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your workspace today'**
  String get employeeTodayWorkspaceSubtitle;

  /// No description provided for @employeeTodayAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Today attendance'**
  String get employeeTodayAttendanceTitle;

  /// No description provided for @employeeTodayAttendanceTagline.
  ///
  /// In en, this message translates to:
  /// **'Stay on time, stay awesome.'**
  String get employeeTodayAttendanceTagline;

  /// No description provided for @employeeTodayStatusNotCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Not checked in'**
  String get employeeTodayStatusNotCheckedIn;

  /// No description provided for @employeeTodayStatusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get employeeTodayStatusCheckedIn;

  /// No description provided for @employeeTodayStatusOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get employeeTodayStatusOnBreak;

  /// No description provided for @employeeTodayStatusBackFromBreak.
  ///
  /// In en, this message translates to:
  /// **'Back from break'**
  String get employeeTodayStatusBackFromBreak;

  /// No description provided for @employeeTodayStatusCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'Checked out'**
  String get employeeTodayStatusCheckedOut;

  /// No description provided for @employeeTodayStatusInvalidSequence.
  ///
  /// In en, this message translates to:
  /// **'Invalid punch sequence'**
  String get employeeTodayStatusInvalidSequence;

  /// No description provided for @employeeTodayZoneInside.
  ///
  /// In en, this message translates to:
  /// **'Inside salon zone'**
  String get employeeTodayZoneInside;

  /// No description provided for @employeeTodayZoneOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside salon zone'**
  String get employeeTodayZoneOutside;

  /// No description provided for @employeeTodaySalonLabel.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get employeeTodaySalonLabel;

  /// No description provided for @employeeTodayAddressOnFile.
  ///
  /// In en, this message translates to:
  /// **'Address on file'**
  String get employeeTodayAddressOnFile;

  /// No description provided for @employeeTodayDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'About {meters} m from center'**
  String employeeTodayDistanceMeters(int meters);

  /// No description provided for @employeeTodayAttendanceRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance request'**
  String get employeeTodayAttendanceRequestTitle;

  /// No description provided for @employeeTodayAttendanceRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot a punch? Submit a request for admin approval.'**
  String get employeeTodayAttendanceRequestSubtitle;

  /// No description provided for @employeeTodayRequestCorrection.
  ///
  /// In en, this message translates to:
  /// **'Request correction'**
  String get employeeTodayRequestCorrection;

  /// No description provided for @employeeTodayPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending: {count}'**
  String employeeTodayPendingCount(int count);

  /// No description provided for @employeeTodayNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet today.'**
  String get employeeTodayNoActivity;

  /// No description provided for @employeeTodayPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'You can only view your own attendance, sales, and requests.'**
  String get employeeTodayPrivacyNote;

  /// No description provided for @employeeTodayViewPolicy.
  ///
  /// In en, this message translates to:
  /// **'View policy'**
  String get employeeTodayViewPolicy;

  /// No description provided for @employeeTodaySalonLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Salon attendance location is not configured. Please contact the owner.'**
  String get employeeTodaySalonLocationMissing;

  /// No description provided for @employeeTodayPunchIn.
  ///
  /// In en, this message translates to:
  /// **'Punch in'**
  String get employeeTodayPunchIn;

  /// No description provided for @employeeTodayPunchOut.
  ///
  /// In en, this message translates to:
  /// **'Punch out'**
  String get employeeTodayPunchOut;

  /// No description provided for @employeeTodayBreakOut.
  ///
  /// In en, this message translates to:
  /// **'Break out'**
  String get employeeTodayBreakOut;

  /// No description provided for @employeeTodayBreakIn.
  ///
  /// In en, this message translates to:
  /// **'Break in'**
  String get employeeTodayBreakIn;

  /// No description provided for @employeeTodayCompletedForToday.
  ///
  /// In en, this message translates to:
  /// **'Completed for today'**
  String get employeeTodayCompletedForToday;

  /// No description provided for @employeeTodayHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String employeeTodayHoursLabel(Object hours);

  /// No description provided for @employeeTodaySalesAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} sales'**
  String employeeTodaySalesAmount(Object amount);

  /// No description provided for @employeeTodayServicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} services'**
  String employeeTodayServicesCount(int count);

  /// No description provided for @employeeTodayTeamMemberFallback.
  ///
  /// In en, this message translates to:
  /// **'Team member'**
  String get employeeTodayTeamMemberFallback;

  /// No description provided for @employeeTodayPunchRecorded.
  ///
  /// In en, this message translates to:
  /// **'{action} recorded'**
  String employeeTodayPunchRecorded(Object action);

  /// No description provided for @employeeTodayOfflinePunch.
  ///
  /// In en, this message translates to:
  /// **'You need an internet connection to punch.'**
  String get employeeTodayOfflinePunch;

  /// No description provided for @employeeTodayPunchUnavailableAttendanceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Attendance is turned off for this salon.'**
  String get employeeTodayPunchUnavailableAttendanceDisabled;

  /// No description provided for @employeeTodayPunchUnavailableMoveToZone.
  ///
  /// In en, this message translates to:
  /// **'Move inside the salon zone to punch in or out.'**
  String get employeeTodayPunchUnavailableMoveToZone;

  /// No description provided for @employeeTodayPunchUnavailableShiftComplete.
  ///
  /// In en, this message translates to:
  /// **'You have reached today\'s punch limit. If something looks wrong, submit a correction request.'**
  String get employeeTodayPunchUnavailableShiftComplete;

  /// No description provided for @employeeTodayPunchUnavailableGeneric.
  ///
  /// In en, this message translates to:
  /// **'No punch actions are available right now.'**
  String get employeeTodayPunchUnavailableGeneric;

  /// No description provided for @employeeTodayPrimaryPunchInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your work session'**
  String get employeeTodayPrimaryPunchInSubtitle;

  /// No description provided for @employeeTodayPrimaryPunchOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'End your current session'**
  String get employeeTodayPrimaryPunchOutSubtitle;

  /// No description provided for @employeeTodayPrimaryBreakOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a break'**
  String get employeeTodayPrimaryBreakOutSubtitle;

  /// No description provided for @employeeTodayPrimaryBreakInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resume your shift'**
  String get employeeTodayPrimaryBreakInSubtitle;

  /// No description provided for @employeeTodayNoAction.
  ///
  /// In en, this message translates to:
  /// **'No action'**
  String get employeeTodayNoAction;

  /// No description provided for @employeeTodayActionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Action is unavailable'**
  String get employeeTodayActionUnavailable;

  /// No description provided for @employeeTodayPunchUnavailableMissingPunch.
  ///
  /// In en, this message translates to:
  /// **'Please request a correction for the missing punch.'**
  String get employeeTodayPunchUnavailableMissingPunch;

  /// No description provided for @employeeTodayAttendanceLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance unavailable'**
  String get employeeTodayAttendanceLoadErrorTitle;

  /// No description provided for @employeeTodayAttendanceStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get employeeTodayAttendanceStatusLabel;

  /// No description provided for @employeeTodayLastPunchLabel.
  ///
  /// In en, this message translates to:
  /// **'Last punch'**
  String get employeeTodayLastPunchLabel;

  /// No description provided for @employeeTodayLocationContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get employeeTodayLocationContextLabel;

  /// No description provided for @employeeTodayShiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get employeeTodayShiftLabel;

  /// No description provided for @employeeTodayGpsVerified.
  ///
  /// In en, this message translates to:
  /// **'GPS Verified'**
  String get employeeTodayGpsVerified;

  /// No description provided for @employeeTodayGpsLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating GPS'**
  String get employeeTodayGpsLocating;

  /// No description provided for @employeeTodayPunchNotAllowedNow.
  ///
  /// In en, this message translates to:
  /// **'This punch is not allowed now'**
  String get employeeTodayPunchNotAllowedNow;

  /// No description provided for @employeeQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get employeeQuickActionsTitle;

  /// No description provided for @employeeQuickActionAddSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record a service or payment'**
  String get employeeQuickActionAddSaleSubtitle;

  /// No description provided for @employeeQuickActionRequestCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Request correction'**
  String get employeeQuickActionRequestCorrectionTitle;

  /// No description provided for @employeeQuickActionRequestCorrectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fix a missing or wrong punch'**
  String get employeeQuickActionRequestCorrectionSubtitle;

  /// No description provided for @employeeQuickActionViewPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance rules and violations'**
  String get employeeQuickActionViewPolicySubtitle;

  /// No description provided for @employeeQuickActionPayrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get employeeQuickActionPayrollTitle;

  /// No description provided for @employeeQuickActionPayrollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payslips and payroll history'**
  String get employeeQuickActionPayrollSubtitle;

  /// No description provided for @employeeTodaySectionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this section.'**
  String get employeeTodaySectionLoadFailed;

  /// No description provided for @employeeTodayTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get employeeTodayTryAgain;

  /// No description provided for @employeeTodayNoActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No punches yet'**
  String get employeeTodayNoActivityTitle;

  /// No description provided for @employeeTodayNoActivityBody.
  ///
  /// In en, this message translates to:
  /// **'Your timeline will fill in as you punch in and out.'**
  String get employeeTodayNoActivityBody;

  /// No description provided for @employeeTodaySemanticNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get employeeTodaySemanticNotifications;

  /// No description provided for @employeeTodaySemanticSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get employeeTodaySemanticSettings;

  /// No description provided for @employeeActivityTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Today activity'**
  String get employeeActivityTimelineTitle;

  /// No description provided for @employeeActivityTimelineLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get employeeActivityTimelineLive;

  /// No description provided for @employeeActivityTimelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No punches yet today.'**
  String get employeeActivityTimelineEmpty;

  /// No description provided for @employeeSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Sales'**
  String get employeeSalesTitle;

  /// No description provided for @employeeSalesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your revenue and commission'**
  String get employeeSalesSubtitle;

  /// No description provided for @employeeSalesNotAllowedAdd.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to add sales. Please contact the salon owner.'**
  String get employeeSalesNotAllowedAdd;

  /// No description provided for @employeeSaleRecordedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded successfully.'**
  String get employeeSaleRecordedSuccess;

  /// No description provided for @employeeSalesEmptyPeriod.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded for this period yet.'**
  String get employeeSalesEmptyPeriod;

  /// No description provided for @employeeSalesEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Sale to record your first sale today.'**
  String get employeeSalesEmptyCta;

  /// No description provided for @employeeSalesRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sales'**
  String get employeeSalesRecentTitle;

  /// No description provided for @employeeSalesViewReceipts.
  ///
  /// In en, this message translates to:
  /// **'View receipts'**
  String get employeeSalesViewReceipts;

  /// No description provided for @employeeSalesViewReceiptsHint.
  ///
  /// In en, this message translates to:
  /// **'Receipt review for owners is coming soon.'**
  String get employeeSalesViewReceiptsHint;

  /// No description provided for @employeeSalesTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get employeeSalesTotalLabel;

  /// No description provided for @employeeSalesHeroNoSales.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded for this period yet.'**
  String get employeeSalesHeroNoSales;

  /// No description provided for @employeeSalesKpiTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get employeeSalesKpiTotal;

  /// No description provided for @employeeSalesKpiServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get employeeSalesKpiServices;

  /// No description provided for @employeeSalesKpiCommission.
  ///
  /// In en, this message translates to:
  /// **'Est. Commission'**
  String get employeeSalesKpiCommission;

  /// No description provided for @employeeSalesKpiAvgService.
  ///
  /// In en, this message translates to:
  /// **'Avg. Service'**
  String get employeeSalesKpiAvgService;

  /// No description provided for @employeeSalesCommissionRate.
  ///
  /// In en, this message translates to:
  /// **'Commission rate'**
  String get employeeSalesCommissionRate;

  /// No description provided for @employeeSalesCommissionHint.
  ///
  /// In en, this message translates to:
  /// **'Your commission percentage'**
  String get employeeSalesCommissionHint;

  /// No description provided for @employeeSalesEstimatedCommission.
  ///
  /// In en, this message translates to:
  /// **'Estimated commission'**
  String get employeeSalesEstimatedCommission;

  /// No description provided for @employeeSalesFromSales.
  ///
  /// In en, this message translates to:
  /// **'From {amount} sales'**
  String employeeSalesFromSales(Object amount);

  /// No description provided for @employeeSalesCustomersLabel.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get employeeSalesCustomersLabel;

  /// No description provided for @employeeSalesServicesCustomersRow.
  ///
  /// In en, this message translates to:
  /// **'{services} services · {customers} customers'**
  String employeeSalesServicesCustomersRow(Object services, Object customers);

  /// No description provided for @employeeSalesShowingLatest.
  ///
  /// In en, this message translates to:
  /// **'Showing latest {count} sales'**
  String employeeSalesShowingLatest(int count);

  /// No description provided for @addSaleReceiptSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get addSaleReceiptSectionTitle;

  /// No description provided for @addSaleReceiptSectionBody.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the card receipt, cash receipt, or payment proof.'**
  String get addSaleReceiptSectionBody;

  /// No description provided for @addSaleReceiptTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get addSaleReceiptTakePhoto;

  /// No description provided for @addSaleReceiptRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get addSaleReceiptRetake;

  /// No description provided for @addSaleReceiptRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get addSaleReceiptRemove;

  /// No description provided for @addSaleReceiptRequiredCard.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo is required for card payments.'**
  String get addSaleReceiptRequiredCard;

  /// No description provided for @addSaleReceiptRequiredMixed.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo is required because this sale includes card payment.'**
  String get addSaleReceiptRequiredMixed;

  /// No description provided for @addSaleOptionalCashPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: take a photo of cash received or a handwritten receipt.'**
  String get addSaleOptionalCashPhotoHint;

  /// No description provided for @addSaleCashCardSplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash & card amounts'**
  String get addSaleCashCardSplitTitle;

  /// No description provided for @addSaleCashAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get addSaleCashAmountHint;

  /// No description provided for @addSaleCardAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get addSaleCardAmountHint;

  /// No description provided for @addSalePaymentSplitInvalid.
  ///
  /// In en, this message translates to:
  /// **'Cash plus card must equal the total sale amount.'**
  String get addSalePaymentSplitInvalid;

  /// No description provided for @ownerAddSaleAutoPrice.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled price'**
  String get ownerAddSaleAutoPrice;

  /// No description provided for @authV2WelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations, simplified.'**
  String get authV2WelcomeTitle;

  /// No description provided for @authV2WelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run bookings, team, payroll, and money in one premium workspace.'**
  String get authV2WelcomeSubtitle;

  /// No description provided for @authV2WelcomeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authV2WelcomeContinue;

  /// No description provided for @authV2FieldLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get authV2FieldLanguage;

  /// No description provided for @authV2FieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get authV2FieldCountry;

  /// No description provided for @authV2RoleTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to use Zurano?'**
  String get authV2RoleTitle;

  /// No description provided for @authV2RoleOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a salon'**
  String get authV2RoleOwnerTitle;

  /// No description provided for @authV2RoleOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register your business, team, and operations.'**
  String get authV2RoleOwnerSubtitle;

  /// No description provided for @authV2RoleCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue as User'**
  String get authV2RoleCustomerTitle;

  /// No description provided for @authV2RoleCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover salons and book appointments.'**
  String get authV2RoleCustomerSubtitle;

  /// No description provided for @authV2OwnerLoginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authV2OwnerLoginHeadline;

  /// No description provided for @authV2OwnerLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your salon.'**
  String get authV2OwnerLoginSubtitle;

  /// No description provided for @authV2UserLoginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authV2UserLoginHeadline;

  /// No description provided for @authV2UserLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get authV2UserLoginSubtitle;

  /// No description provided for @authV2UserLoginIdentifierHelper.
  ///
  /// In en, this message translates to:
  /// **'Employees sign in with username. Customers sign in with email.'**
  String get authV2UserLoginIdentifierHelper;

  /// No description provided for @userLoginForgotPasswordNeedEmail.
  ///
  /// In en, this message translates to:
  /// **'Password reset works with email. Add “@” if you are signing in with email.'**
  String get userLoginForgotPasswordNeedEmail;

  /// No description provided for @authLoginErrorIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email, username, or password.'**
  String get authLoginErrorIncorrect;

  /// No description provided for @authLoginErrorDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authLoginErrorDisabled;

  /// No description provided for @authLoginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authLoginErrorInvalidEmail;

  /// No description provided for @authLoginErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait and try again, or reset your password.'**
  String get authLoginErrorTooManyRequests;

  /// No description provided for @authLoginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get authLoginErrorNetwork;

  /// No description provided for @authLoginErrorStaffUseUsername.
  ///
  /// In en, this message translates to:
  /// **'Salon staff sign in with the email or username from the salon owner. Customers use their own email here.'**
  String get authLoginErrorStaffUseUsername;

  /// No description provided for @authLoginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get authLoginErrorGeneric;

  /// No description provided for @authStaffLoginUserDocMissing.
  ///
  /// In en, this message translates to:
  /// **'User profile not found. Contact your salon owner.'**
  String get authStaffLoginUserDocMissing;

  /// No description provided for @authStaffLoginUserInactive.
  ///
  /// In en, this message translates to:
  /// **'This account is paused. Contact your salon owner.'**
  String get authStaffLoginUserInactive;

  /// No description provided for @authStaffLoginEmployeeDocMissing.
  ///
  /// In en, this message translates to:
  /// **'Your staff profile is not linked to the salon. Contact your salon owner.'**
  String get authStaffLoginEmployeeDocMissing;

  /// No description provided for @authStaffLoginEmployeeInactive.
  ///
  /// In en, this message translates to:
  /// **'Your access has been turned off by the salon owner.'**
  String get authStaffLoginEmployeeInactive;

  /// No description provided for @authStaffLoginWrongPortal.
  ///
  /// In en, this message translates to:
  /// **'This entrance is for salon team only. Customers and owners should use the matching sign-in option.'**
  String get authStaffLoginWrongPortal;

  /// No description provided for @changeTemporaryPasswordFieldCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changeTemporaryPasswordFieldCurrent;

  /// No description provided for @changeTemporaryPasswordFieldNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changeTemporaryPasswordFieldNew;

  /// No description provided for @changeTemporaryPasswordFieldConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changeTemporaryPasswordFieldConfirm;

  /// No description provided for @changeTemporaryPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get changeTemporaryPasswordTitle;

  /// No description provided for @changeTemporaryPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your salon owner set a temporary password. Choose a new one to continue.'**
  String get changeTemporaryPasswordSubtitle;

  /// No description provided for @changeTemporaryPasswordSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get changeTemporaryPasswordSignOut;

  /// No description provided for @changeTemporaryPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get changeTemporaryPasswordSubmit;

  /// No description provided for @changeTemporaryPasswordSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get changeTemporaryPasswordSuccessSnack;

  /// No description provided for @changeTemporaryPasswordErrorCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get changeTemporaryPasswordErrorCurrentRequired;

  /// No description provided for @changeTemporaryPasswordErrorNewMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters.'**
  String get changeTemporaryPasswordErrorNewMinLength;

  /// No description provided for @changeTemporaryPasswordErrorNewRequiresLetterAndNumber.
  ///
  /// In en, this message translates to:
  /// **'New password must include at least one letter and one number.'**
  String get changeTemporaryPasswordErrorNewRequiresLetterAndNumber;

  /// No description provided for @changeTemporaryPasswordErrorConfirmMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get changeTemporaryPasswordErrorConfirmMismatch;

  /// No description provided for @changeTemporaryPasswordErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get changeTemporaryPasswordErrorWrongPassword;

  /// No description provided for @changeTemporaryPasswordErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Try a longer mix of letters and numbers.'**
  String get changeTemporaryPasswordErrorWeakPassword;

  /// No description provided for @changeTemporaryPasswordErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign out and sign in again, then retry.'**
  String get changeTemporaryPasswordErrorRequiresRecentLogin;

  /// No description provided for @changeTemporaryPasswordErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get changeTemporaryPasswordErrorNetwork;

  /// No description provided for @changeTemporaryPasswordErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Please try again.'**
  String get changeTemporaryPasswordErrorGeneric;

  /// No description provided for @changeTemporaryPasswordFirestorePartialFailure.
  ///
  /// In en, this message translates to:
  /// **'Password changed, but account status could not be updated. Please contact the salon owner.'**
  String get changeTemporaryPasswordFirestorePartialFailure;

  /// No description provided for @authLoginErrorStaffNotFound.
  ///
  /// In en, this message translates to:
  /// **'No staff account found for this username. Check spelling or ask your salon owner.'**
  String get authLoginErrorStaffNotFound;

  /// No description provided for @authLoginErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to complete this action.'**
  String get authLoginErrorPermission;

  /// No description provided for @authV2LoginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authV2LoginHeadline;

  /// No description provided for @authV2LoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your work email to access your workspace.'**
  String get authV2LoginSubtitle;

  /// No description provided for @authV2SignupHeadline.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authV2SignupHeadline;

  /// No description provided for @authV2SignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick setup — you can add details later.'**
  String get authV2SignupSubtitle;

  /// No description provided for @authV2ForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authV2ForgotPassword;

  /// No description provided for @authV2ForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authV2ForgotPasswordTitle;

  /// No description provided for @authV2ForgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get authV2ForgotPasswordDescription;

  /// No description provided for @authV2ForgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for reset instructions.'**
  String get authV2ForgotPasswordSent;

  /// No description provided for @authV2SendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get authV2SendResetLink;

  /// No description provided for @authV2OrDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authV2OrDivider;

  /// No description provided for @authV2ContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authV2ContinueGoogle;

  /// No description provided for @authV2ContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authV2ContinueApple;

  /// No description provided for @authV2ContinueFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get authV2ContinueFacebook;

  /// No description provided for @authV2SignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authV2SignUpLink;

  /// No description provided for @authV2SignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authV2SignInLink;

  /// No description provided for @authV2LoginSignupPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Zurano?'**
  String get authV2LoginSignupPrompt;

  /// No description provided for @authV2SignupSigninPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authV2SignupSigninPrompt;

  /// No description provided for @authV2PasswordHintRules.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authV2PasswordHintRules;

  /// No description provided for @authV2CreateSalonTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your salon details'**
  String get authV2CreateSalonTitle;

  /// No description provided for @authV2CreateSalonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your salon name and city to start managing bookings and your team.'**
  String get authV2CreateSalonSubtitle;

  /// No description provided for @authV2CurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get authV2CurrencyLabel;

  /// No description provided for @authV2OptionalAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get authV2OptionalAddressLabel;

  /// No description provided for @authV2CreateSalonCta.
  ///
  /// In en, this message translates to:
  /// **'Create salon'**
  String get authV2CreateSalonCta;

  /// No description provided for @createSalonCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Finish country selection in onboarding before creating your salon.'**
  String get createSalonCountryRequired;

  /// No description provided for @createSalonCitiesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading cities for your country…'**
  String get createSalonCitiesLoading;

  /// No description provided for @createSalonNoCitiesForCountry.
  ///
  /// In en, this message translates to:
  /// **'No city list is available for this country. Enter your city manually.'**
  String get createSalonNoCitiesForCountry;

  /// No description provided for @createSalonEnterCityManually.
  ///
  /// In en, this message translates to:
  /// **'Enter city manually'**
  String get createSalonEnterCityManually;

  /// No description provided for @createSalonPickFromList.
  ///
  /// In en, this message translates to:
  /// **'Pick from list'**
  String get createSalonPickFromList;

  /// No description provided for @createSalonSelectCityHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to search and select a city'**
  String get createSalonSelectCityHint;

  /// No description provided for @bentoDashboardScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations hub'**
  String get bentoDashboardScreenTitle;

  /// No description provided for @firstTimeRoleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get firstTimeRoleEyebrow;

  /// No description provided for @firstTimeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use Zurano?'**
  String get firstTimeRoleTitle;

  /// No description provided for @firstTimeRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to finish setting up your profile.'**
  String get firstTimeRoleDescription;

  /// No description provided for @firstTimeRoleUserTitle.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get firstTimeRoleUserTitle;

  /// No description provided for @firstTimeRoleUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book services, explore salons, and manage appointments.'**
  String get firstTimeRoleUserSubtitle;

  /// No description provided for @firstTimeRoleOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon Owner'**
  String get firstTimeRoleOwnerTitle;

  /// No description provided for @firstTimeRoleOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your salon, manage staff, bookings, payroll, and operations.'**
  String get firstTimeRoleOwnerSubtitle;

  /// No description provided for @firstTimeRoleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get firstTimeRoleContinue;

  /// No description provided for @firstTimeRoleDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get firstTimeRoleDifferentAccount;

  /// No description provided for @firstTimeRoleError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t finish setting up your profile. Please try again.'**
  String get firstTimeRoleError;

  /// No description provided for @ownerTabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get ownerTabCustomers;

  /// No description provided for @ownerTabFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get ownerTabFinance;

  /// No description provided for @ownerDashboardSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get ownerDashboardSettingsTooltip;

  /// No description provided for @ownerServicesWaitingForSalon.
  ///
  /// In en, this message translates to:
  /// **'Waiting for salon on your profile…'**
  String get ownerServicesWaitingForSalon;

  /// No description provided for @onboardingSalonCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon created'**
  String get onboardingSalonCreatedTitle;

  /// No description provided for @onboardingSalonCreatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opening your dashboard…'**
  String get onboardingSalonCreatedSubtitle;

  /// No description provided for @splashBootstrapErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Startup failed due to a network or Firestore issue. Please retry.'**
  String get splashBootstrapErrorMessage;

  /// No description provided for @splashRetryStartup.
  ///
  /// In en, this message translates to:
  /// **'Retry startup'**
  String get splashRetryStartup;

  /// No description provided for @customersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersScreenTitle;

  /// No description provided for @customersHeroGreeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name} 👋'**
  String customersHeroGreeting(String greeting, String name);

  /// No description provided for @customersSalonOnlyBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'{salonName} customers only'**
  String customersSalonOnlyBannerTitle(String salonName);

  /// No description provided for @customersSalonOnlyBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Salon-owned list for visits, bookings, and spending.'**
  String get customersSalonOnlyBannerSubtitle;

  /// No description provided for @customersGlobalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search team, revenue, and requests'**
  String get customersGlobalSearchHint;

  /// No description provided for @customersCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String customersCountBadge(int count);

  /// No description provided for @customersAddCustomerFab.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get customersAddCustomerFab;

  /// No description provided for @customersPermissionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to these customers.'**
  String get customersPermissionErrorTitle;

  /// No description provided for @customersPermissionErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check salon membership or permissions.'**
  String get customersPermissionErrorSubtitle;

  /// No description provided for @customersGenericLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load customers. Please try again.'**
  String get customersGenericLoadError;

  /// No description provided for @customersCategoryNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get customersCategoryNewBadge;

  /// No description provided for @customersCategoryRegularBadge.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get customersCategoryRegularBadge;

  /// No description provided for @customersStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get customersStatusActive;

  /// No description provided for @customersStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get customersStatusInactive;

  /// No description provided for @customersLastVisitShort.
  ///
  /// In en, this message translates to:
  /// **'Last visit: {date}'**
  String customersLastVisitShort(String date);

  /// No description provided for @customersVisitsShort.
  ///
  /// In en, this message translates to:
  /// **'Visits: {count}'**
  String customersVisitsShort(int count);

  /// No description provided for @customersSpentShort.
  ///
  /// In en, this message translates to:
  /// **'Spent: {amount}'**
  String customersSpentShort(String amount);

  /// No description provided for @customersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or phone'**
  String get customersSearchHint;

  /// No description provided for @customersTagAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get customersTagAll;

  /// No description provided for @customersTagNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get customersTagNew;

  /// No description provided for @customersTagRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get customersTagRegular;

  /// No description provided for @customersTagVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get customersTagVip;

  /// No description provided for @customersTagInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get customersTagInactive;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptyMessageCanCreate.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer to start tracking visits and spending.'**
  String get customersEmptyMessageCanCreate;

  /// No description provided for @customersEmptyMessageNoAccess.
  ///
  /// In en, this message translates to:
  /// **'No customers are available for your account.'**
  String get customersEmptyMessageNoAccess;

  /// No description provided for @customersAddFirstCta.
  ///
  /// In en, this message translates to:
  /// **'Add first customer'**
  String get customersAddFirstCta;

  /// No description provided for @customersLastVisitNever.
  ///
  /// In en, this message translates to:
  /// **'No visit yet'**
  String get customersLastVisitNever;

  /// No description provided for @customersPreferredBarberNone.
  ///
  /// In en, this message translates to:
  /// **'No preferred team member'**
  String get customersPreferredBarberNone;

  /// No description provided for @customersPreferredBarberLine.
  ///
  /// In en, this message translates to:
  /// **'{phone} · {barber}'**
  String customersPreferredBarberLine(String phone, String barber);

  /// No description provided for @customersPreferredBarberLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred team member: {name}'**
  String customersPreferredBarberLabel(String name);

  /// No description provided for @customersLastVisitLine.
  ///
  /// In en, this message translates to:
  /// **'Last visit: {date} ({relative})'**
  String customersLastVisitLine(String date, String relative);

  /// No description provided for @customersVisitsPointsLine.
  ///
  /// In en, this message translates to:
  /// **'Visits: {visits} · Points: {points}'**
  String customersVisitsPointsLine(int visits, int points);

  /// No description provided for @customersTotalSpentLine.
  ///
  /// In en, this message translates to:
  /// **'Total spent: {amount}'**
  String customersTotalSpentLine(String amount);

  /// No description provided for @customersVipBadge.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get customersVipBadge;

  /// No description provided for @customersTimeNever.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get customersTimeNever;

  /// No description provided for @customersTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get customersTimeJustNow;

  /// No description provided for @customersTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String customersTimeMinutesAgo(int n);

  /// No description provided for @customersTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String customersTimeHoursAgo(int n);

  /// No description provided for @customersTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String customersTimeDaysAgo(int n);

  /// No description provided for @customersTimeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}mo ago'**
  String customersTimeMonthsAgo(int n);

  /// No description provided for @customersTimeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}y ago'**
  String customersTimeYearsAgo(int n);

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFound;

  /// No description provided for @customerNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This customer may have been deleted or you do not have permission to view it.'**
  String get customerNotFoundSubtitle;

  /// No description provided for @customerBackToCustomers.
  ///
  /// In en, this message translates to:
  /// **'Back to customers'**
  String get customerBackToCustomers;

  /// No description provided for @customerDetailsCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get customerDetailsCall;

  /// No description provided for @customerDetailsWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get customerDetailsWhatsApp;

  /// No description provided for @customerDetailsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get customerDetailsEdit;

  /// No description provided for @customerDetailsBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get customerDetailsBook;

  /// No description provided for @customerDetailsAddService.
  ///
  /// In en, this message translates to:
  /// **'Add sale'**
  String get customerDetailsAddService;

  /// No description provided for @customerDetailsUpcomingSection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments'**
  String get customerDetailsUpcomingSection;

  /// No description provided for @customerDetailsHistorySection.
  ///
  /// In en, this message translates to:
  /// **'Visit history'**
  String get customerDetailsHistorySection;

  /// No description provided for @customerDetailsBookSameServiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Book same service again'**
  String get customerDetailsBookSameServiceAgain;

  /// No description provided for @customerDetailsSpendingSummary.
  ///
  /// In en, this message translates to:
  /// **'Spending summary: {amount}'**
  String customerDetailsSpendingSummary(String amount);

  /// No description provided for @customerDetailsNotesWithValue.
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String customerDetailsNotesWithValue(String notes);

  /// No description provided for @customerDetailsNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get customerDetailsNotesEmpty;

  /// No description provided for @customerDetailsServiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get customerDetailsServiceFallback;

  /// No description provided for @customerInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer insights'**
  String get customerInsightsTitle;

  /// No description provided for @customerProfileVipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'VIP customer · enabled by owner'**
  String get customerProfileVipSubtitle;

  /// No description provided for @customerInsightNoVisits.
  ///
  /// In en, this message translates to:
  /// **'No previous visits yet'**
  String get customerInsightNoVisits;

  /// No description provided for @customerInsightLastVisitDays.
  ///
  /// In en, this message translates to:
  /// **'Last visit {days, plural, =0{today} =1{1 day ago} other{{days} days ago}}'**
  String customerInsightLastVisitDays(int days);

  /// No description provided for @customerInsightTotalVisitsLine.
  ///
  /// In en, this message translates to:
  /// **'Total visits: {count}'**
  String customerInsightTotalVisitsLine(int count);

  /// No description provided for @customerInsightTotalSpentLine.
  ///
  /// In en, this message translates to:
  /// **'Total spend: {amount}'**
  String customerInsightTotalSpentLine(String amount);

  /// No description provided for @customerSuggestedActionVip.
  ///
  /// In en, this message translates to:
  /// **'High-value customer — consider a tailored offer'**
  String get customerSuggestedActionVip;

  /// No description provided for @customerSuggestedActionNew.
  ///
  /// In en, this message translates to:
  /// **'New customer — follow up with a welcome offer'**
  String get customerSuggestedActionNew;

  /// No description provided for @customerSuggestedActionRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular customer — keep the relationship warm'**
  String get customerSuggestedActionRegular;

  /// No description provided for @customerSuggestedActionInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive — consider a win-back offer'**
  String get customerSuggestedActionInactive;

  /// No description provided for @customerTypeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer type'**
  String get customerTypeSectionTitle;

  /// No description provided for @customerTypeChipsHint.
  ///
  /// In en, this message translates to:
  /// **'Types help you tailor offers. VIP is set by the owner.'**
  String get customerTypeChipsHint;

  /// No description provided for @customerTypeVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get customerTypeVip;

  /// No description provided for @customerTypeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get customerTypeNew;

  /// No description provided for @customerTypeRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get customerTypeRegular;

  /// No description provided for @customerTypeInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get customerTypeInactive;

  /// No description provided for @customerDiscountBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer discount'**
  String get customerDiscountBoxTitle;

  /// No description provided for @customerDiscountBoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applied automatically when recording a sale'**
  String get customerDiscountBoxSubtitle;

  /// No description provided for @customerDiscountEditSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit discount'**
  String get customerDiscountEditSheetTitle;

  /// No description provided for @customerDiscountPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get customerDiscountPercentLabel;

  /// No description provided for @customerDiscountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 0 and 100'**
  String get customerDiscountInvalid;

  /// No description provided for @customerSalesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get customerSalesSectionTitle;

  /// No description provided for @customerSalesTotalSpentSummary.
  ///
  /// In en, this message translates to:
  /// **'Total spent: {amount}'**
  String customerSalesTotalSpentSummary(String amount);

  /// No description provided for @customerSalesLastVisitSummary.
  ///
  /// In en, this message translates to:
  /// **'Last visit: {date}'**
  String customerSalesLastVisitSummary(String date);

  /// No description provided for @customerSalesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get customerSalesEmptyTitle;

  /// No description provided for @customerSalesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales for this customer will appear here.'**
  String get customerSalesEmptySubtitle;

  /// No description provided for @customerUpcomingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments'**
  String get customerUpcomingSectionTitle;

  /// No description provided for @customerUpcomingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get customerUpcomingEmptyTitle;

  /// No description provided for @customerNotesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get customerNotesSectionTitle;

  /// No description provided for @createBookingSearchCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Search customer'**
  String get createBookingSearchCustomerLabel;

  /// No description provided for @createBookingAddNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get createBookingAddNewCustomer;

  /// No description provided for @createBookingDateWithValue.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String createBookingDateWithValue(String date);

  /// No description provided for @createBookingTimeWithValue.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String createBookingTimeWithValue(String time);

  /// No description provided for @createBookingPickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get createBookingPickTime;

  /// No description provided for @createBookingValidationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please complete customer, service, team member, date and time.'**
  String get createBookingValidationIncomplete;

  /// No description provided for @createBookingSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Booking created successfully'**
  String get createBookingSuccessSnackbar;

  /// No description provided for @createBookingSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save booking'**
  String get createBookingSaveCta;

  /// No description provided for @addCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new customer'**
  String get addCustomerTitle;

  /// No description provided for @addCustomerSaveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Save customer'**
  String get addCustomerSaveCustomer;

  /// No description provided for @addCustomerSaveAndBook.
  ///
  /// In en, this message translates to:
  /// **'Save and book'**
  String get addCustomerSaveAndBook;

  /// No description provided for @addCustomerFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get addCustomerFieldFullName;

  /// No description provided for @addCustomerFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get addCustomerFullNameRequired;

  /// No description provided for @addCustomerFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get addCustomerFieldPhone;

  /// No description provided for @addCustomerFieldSource.
  ///
  /// In en, this message translates to:
  /// **'Source (walk-in, Instagram, referral…)'**
  String get addCustomerFieldSource;

  /// No description provided for @addCustomerFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get addCustomerFieldNotes;

  /// No description provided for @addCustomerSavedWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer saved successfully.'**
  String get addCustomerSavedWithPhone;

  /// No description provided for @addCustomerSavedNoPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer saved. No phone number added.'**
  String get addCustomerSavedNoPhone;

  /// No description provided for @accountProfileRecoveryInlineError.
  ///
  /// In en, this message translates to:
  /// **'Account created, but profile setup did not finish. Tap “Create profile” to recover your account.'**
  String get accountProfileRecoveryInlineError;

  /// No description provided for @profileFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFieldFullName;

  /// No description provided for @profileFieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get profileFieldMobile;

  /// No description provided for @profileFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileFieldCity;

  /// No description provided for @authHintEmailExample.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authHintEmailExample;

  /// No description provided for @customerBookingMoreDays.
  ///
  /// In en, this message translates to:
  /// **'More days'**
  String get customerBookingMoreDays;

  /// No description provided for @barberAttendanceInOutLine.
  ///
  /// In en, this message translates to:
  /// **'In: {checkIn} · Out: {checkOut}'**
  String barberAttendanceInOutLine(String checkIn, String checkOut);

  /// No description provided for @barberAttendanceStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get barberAttendanceStatusPresent;

  /// No description provided for @barberAttendanceStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get barberAttendanceStatusAbsent;

  /// No description provided for @barberAttendanceStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get barberAttendanceStatusLate;

  /// No description provided for @barberAttendanceStatusLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get barberAttendanceStatusLeave;

  /// No description provided for @preAuthLanguageEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'English interface'**
  String get preAuthLanguageEnglishHint;

  /// No description provided for @preAuthLanguageArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Arabic interface'**
  String get preAuthLanguageArabicHint;

  /// No description provided for @semanticIllustrationSalonOwnerSignup.
  ///
  /// In en, this message translates to:
  /// **'Salon owner signup illustration'**
  String get semanticIllustrationSalonOwnerSignup;

  /// No description provided for @semanticIllustrationCustomerSignup.
  ///
  /// In en, this message translates to:
  /// **'Customer signup illustration'**
  String get semanticIllustrationCustomerSignup;

  /// No description provided for @semanticIllustrationEmptyServices.
  ///
  /// In en, this message translates to:
  /// **'Empty services illustration'**
  String get semanticIllustrationEmptyServices;

  /// No description provided for @semanticIllustrationWelcomeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Welcome onboarding illustration'**
  String get semanticIllustrationWelcomeOnboarding;

  /// No description provided for @employeePayrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get employeePayrollTitle;

  /// No description provided for @employeePayrollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your salary and payslip'**
  String get employeePayrollSubtitle;

  /// No description provided for @employeePayrollSelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get employeePayrollSelectMonth;

  /// No description provided for @employeePayrollNetPay.
  ///
  /// In en, this message translates to:
  /// **'Net pay'**
  String get employeePayrollNetPay;

  /// No description provided for @employeePayrollEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get employeePayrollEarnings;

  /// No description provided for @employeePayrollDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get employeePayrollDeductions;

  /// No description provided for @employeePayrollNetSalary.
  ///
  /// In en, this message translates to:
  /// **'Net salary'**
  String get employeePayrollNetSalary;

  /// No description provided for @employeePayrollStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get employeePayrollStatusPaid;

  /// No description provided for @employeePayrollStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get employeePayrollStatusApproved;

  /// No description provided for @employeePayrollServicesStat.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get employeePayrollServicesStat;

  /// No description provided for @employeePayrollThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get employeePayrollThisMonth;

  /// No description provided for @employeePayrollCommissionStat.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get employeePayrollCommissionStat;

  /// No description provided for @employeePayrollOnServices.
  ///
  /// In en, this message translates to:
  /// **'On services'**
  String get employeePayrollOnServices;

  /// No description provided for @employeePayrollAttendanceStat.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get employeePayrollAttendanceStat;

  /// No description provided for @employeePayrollDaysPresent.
  ///
  /// In en, this message translates to:
  /// **'Days present'**
  String get employeePayrollDaysPresent;

  /// No description provided for @employeePayrollViewFullPayslip.
  ///
  /// In en, this message translates to:
  /// **'View full payslip'**
  String get employeePayrollViewFullPayslip;

  /// No description provided for @employeePayrollDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get employeePayrollDownloadPdf;

  /// No description provided for @employeePayrollRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent payslips'**
  String get employeePayrollRecentTitle;

  /// No description provided for @employeePayrollViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get employeePayrollViewAll;

  /// No description provided for @employeePayrollEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Payslip is not generated yet for this month'**
  String get employeePayrollEmptyTitle;

  /// No description provided for @employeePayrollEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your payslip will appear here once the salon owner generates payroll for this period.'**
  String get employeePayrollEmptyBody;

  /// No description provided for @employeeWorkspaceNotLinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee profile not linked'**
  String get employeeWorkspaceNotLinkedTitle;

  /// No description provided for @employeeWorkspaceNotLinkedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is not linked to an employee profile yet. Ask your salon owner to complete staff provisioning.'**
  String get employeeWorkspaceNotLinkedBody;

  /// No description provided for @employeeStaffWorkspaceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff workspace unavailable'**
  String get employeeStaffWorkspaceUnavailableTitle;

  /// No description provided for @employeeStaffWorkspaceUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Your user account or staff profile is inactive, or your employee record could not be loaded. Ask your salon owner if this should be restored.'**
  String get employeeStaffWorkspaceUnavailableBody;

  /// No description provided for @employeeMapLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your position on the map.'**
  String get employeeMapLocationPermissionRequired;

  /// No description provided for @employeeMapUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Map could not be loaded. You can still punch using GPS when enabled.'**
  String get employeeMapUnavailableBody;

  /// No description provided for @employeePayrollErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load payroll'**
  String get employeePayrollErrorTitle;

  /// No description provided for @employeePayrollSalaryNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary notes'**
  String get employeePayrollSalaryNotesTitle;

  /// No description provided for @employeePayrollNoWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No workspace'**
  String get employeePayrollNoWorkspace;

  /// No description provided for @employeePayrollHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payslip history'**
  String get employeePayrollHistoryTitle;

  /// No description provided for @employeePayrollDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get employeePayrollDetailsTitle;

  /// No description provided for @employeePayrollPdfShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get employeePayrollPdfShareSubject;

  /// No description provided for @employeePayrollTotalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total earnings'**
  String get employeePayrollTotalEarnings;

  /// No description provided for @employeePayrollTotalDeductions.
  ///
  /// In en, this message translates to:
  /// **'Total deductions'**
  String get employeePayrollTotalDeductions;

  /// No description provided for @employeePayrollPeriod.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String employeePayrollPeriod(String start, String end);

  /// No description provided for @employeeTodayLocationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Location unknown'**
  String get employeeTodayLocationUnknown;

  /// No description provided for @employeeTodayNoAddressSet.
  ///
  /// In en, this message translates to:
  /// **'No address set'**
  String get employeeTodayNoAddressSet;

  /// No description provided for @employeeAttendanceZoneNotConfiguredAdmin.
  ///
  /// In en, this message translates to:
  /// **'Attendance zone is not configured yet. Please contact your salon admin.'**
  String get employeeAttendanceZoneNotConfiguredAdmin;

  /// No description provided for @employeeAttendanceNotRequiredOrDisabled.
  ///
  /// In en, this message translates to:
  /// **'Attendance is not required or disabled.'**
  String get employeeAttendanceNotRequiredOrDisabled;

  /// No description provided for @employeeTodayCheckedOutForToday.
  ///
  /// In en, this message translates to:
  /// **'You are checked out for today.'**
  String get employeeTodayCheckedOutForToday;

  /// No description provided for @employeeTodayCorrectionRequestsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Correction requests are disabled for your salon.'**
  String get employeeTodayCorrectionRequestsDisabled;

  /// No description provided for @employeeTodayAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get employeeTodayAwaitingApproval;

  /// No description provided for @employeeTodayNoOpenRequests.
  ///
  /// In en, this message translates to:
  /// **'No open requests'**
  String get employeeTodayNoOpenRequests;

  /// No description provided for @employeeAttendanceSalonLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Salon location'**
  String get employeeAttendanceSalonLocationTitle;

  /// No description provided for @employeeAttendanceLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get employeeAttendanceLocating;

  /// No description provided for @employeeAttendanceGpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy: {accuracy}'**
  String employeeAttendanceGpsAccuracy(String accuracy);

  /// No description provided for @employeeAttendanceSalonLocationOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'Salon location is not configured. Please contact the owner.'**
  String get employeeAttendanceSalonLocationOwnerNote;

  /// No description provided for @employeeAttendanceRetryLocation.
  ///
  /// In en, this message translates to:
  /// **'Retry location'**
  String get employeeAttendanceRetryLocation;

  /// No description provided for @employeeAttendanceWithinRange.
  ///
  /// In en, this message translates to:
  /// **'Within range'**
  String get employeeAttendanceWithinRange;

  /// No description provided for @employeeAttendanceOutsideRange.
  ///
  /// In en, this message translates to:
  /// **'Outside range'**
  String get employeeAttendanceOutsideRange;

  /// No description provided for @employeeAttendanceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get employeeAttendanceScreenTitle;

  /// No description provided for @employeeAttendanceScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your work hours and stay punctual'**
  String get employeeAttendanceScreenSubtitle;

  /// No description provided for @employeeAttendanceGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get employeeAttendanceGreetingMorning;

  /// No description provided for @employeeAttendanceGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get employeeAttendanceGreetingAfternoon;

  /// No description provided for @employeeAttendanceGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get employeeAttendanceGreetingEvening;

  /// No description provided for @employeeAttendanceProductiveDay.
  ///
  /// In en, this message translates to:
  /// **'Have a productive day! 👋'**
  String get employeeAttendanceProductiveDay;

  /// No description provided for @employeePunchNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next action'**
  String get employeePunchNextAction;

  /// No description provided for @employeePunchMissingDetectedWithCorrection.
  ///
  /// In en, this message translates to:
  /// **'Missing punch detected. Submit a request for approval.'**
  String get employeePunchMissingDetectedWithCorrection;

  /// No description provided for @employeePunchDoneForToday.
  ///
  /// In en, this message translates to:
  /// **'You are done for today.'**
  String get employeePunchDoneForToday;

  /// No description provided for @employeePunchMustBeInZone.
  ///
  /// In en, this message translates to:
  /// **'You must be within the salon zone to punch in.'**
  String get employeePunchMustBeInZone;

  /// No description provided for @employeePunchTapWhenArrive.
  ///
  /// In en, this message translates to:
  /// **'Tap when you arrive at the salon.'**
  String get employeePunchTapWhenArrive;

  /// No description provided for @employeePunchBreakLimitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Your daily break limit is {minutes} minutes total.'**
  String employeePunchBreakLimitMinutes(int minutes);

  /// No description provided for @employeePunchReturnFromBreak.
  ///
  /// In en, this message translates to:
  /// **'Tap when you return from break.'**
  String get employeePunchReturnFromBreak;

  /// No description provided for @employeePunchEndWorkingDay.
  ///
  /// In en, this message translates to:
  /// **'End your working day.'**
  String get employeePunchEndWorkingDay;

  /// No description provided for @employeePunchSubmitCorrection.
  ///
  /// In en, this message translates to:
  /// **'Submit correction'**
  String get employeePunchSubmitCorrection;

  /// No description provided for @employeePunchMissingAskAdmin.
  ///
  /// In en, this message translates to:
  /// **'Missing punch detected. Ask your owner or admin to enable correction requests.'**
  String get employeePunchMissingAskAdmin;

  /// No description provided for @employeePunchCompletedTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get employeePunchCompletedTodayTitle;

  /// No description provided for @employeeTimelineTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s timeline'**
  String get employeeTimelineTodayTitle;

  /// No description provided for @employeeTimelineBreakOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Break out'**
  String get employeeTimelineBreakOutTitle;

  /// No description provided for @employeeTimelineBreakInTitle.
  ///
  /// In en, this message translates to:
  /// **'Break in'**
  String get employeeTimelineBreakInTitle;

  /// No description provided for @employeeTimelineWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get employeeTimelineWorkingHours;

  /// No description provided for @employeeTimelineShiftNotSet.
  ///
  /// In en, this message translates to:
  /// **'Shift times not set'**
  String get employeeTimelineShiftNotSet;

  /// No description provided for @employeeTodayStatusCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s status'**
  String get employeeTodayStatusCardTitle;

  /// No description provided for @employeeAttendanceWorkedLabel.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get employeeAttendanceWorkedLabel;

  /// No description provided for @employeeAttendanceExpectedCheckoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected checkout'**
  String get employeeAttendanceExpectedCheckoutLabel;

  /// No description provided for @employeeAttendanceStatusMissingPunch.
  ///
  /// In en, this message translates to:
  /// **'Missing punch'**
  String get employeeAttendanceStatusMissingPunch;

  /// No description provided for @employeeAttendanceStatusIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get employeeAttendanceStatusIncomplete;

  /// No description provided for @employeeAttendanceStatusNotCheckedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Not checked in'**
  String get employeeAttendanceStatusNotCheckedInTitle;

  /// No description provided for @employeeRecentAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent attendance'**
  String get employeeRecentAttendanceTitle;

  /// No description provided for @employeeAttendanceSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get employeeAttendanceSeeAll;

  /// No description provided for @employeeRecentAttendanceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load recent days.'**
  String get employeeRecentAttendanceLoadError;

  /// No description provided for @employeeRecentAttendanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance record yet.\nTap Punch In when you arrive at the salon.'**
  String get employeeRecentAttendanceEmpty;

  /// No description provided for @employeeAttendanceStatusOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get employeeAttendanceStatusOnTime;

  /// No description provided for @employeeAttendanceOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance overview (this month)'**
  String get employeeAttendanceOverviewTitle;

  /// No description provided for @employeeAttendanceViewCalendar.
  ///
  /// In en, this message translates to:
  /// **'View calendar'**
  String get employeeAttendanceViewCalendar;

  /// No description provided for @employeeAttendanceOverviewFootnote.
  ///
  /// In en, this message translates to:
  /// **'Includes days without a record before today as absent.'**
  String get employeeAttendanceOverviewFootnote;

  /// No description provided for @employeeAttendanceSummaryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load attendance summary.'**
  String get employeeAttendanceSummaryLoadError;

  /// No description provided for @employeeAttendanceNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get employeeAttendanceNoDataYet;

  /// No description provided for @employeeAttendanceOverviewDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get employeeAttendanceOverviewDays;

  /// No description provided for @employeeAttendanceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load attendance.'**
  String get employeeAttendanceLoadError;

  /// No description provided for @employeeAttendanceCorrectionFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction'**
  String get employeeAttendanceCorrectionFlowTitle;

  /// No description provided for @employeeAttendanceCorrectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a missed punch request for approval.'**
  String get employeeAttendanceCorrectionSubtitle;

  /// No description provided for @employeeCorrectionSelectPunchType.
  ///
  /// In en, this message translates to:
  /// **'Please select a punch type.'**
  String get employeeCorrectionSelectPunchType;

  /// No description provided for @employeeCorrectionSelectValidDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid date.'**
  String get employeeCorrectionSelectValidDate;

  /// No description provided for @employeeCorrectionSelectValidTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid time.'**
  String get employeeCorrectionSelectValidTime;

  /// No description provided for @employeeCorrectionFutureNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'The request date cannot be in the future.'**
  String get employeeCorrectionFutureNotAllowed;

  /// No description provided for @employeeCorrectionTooOld.
  ///
  /// In en, this message translates to:
  /// **'This request is older than the allowed correction period.'**
  String get employeeCorrectionTooOld;

  /// No description provided for @employeeCorrectionReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason.'**
  String get employeeCorrectionReasonRequired;

  /// No description provided for @employeeCorrectionReasonMinLength.
  ///
  /// In en, this message translates to:
  /// **'Reason must be at least 10 characters.'**
  String get employeeCorrectionReasonMinLength;

  /// No description provided for @employeeCorrectionReasonMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Reason cannot exceed 250 characters.'**
  String get employeeCorrectionReasonMaxLength;

  /// No description provided for @employeeCorrectionSubmittedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get employeeCorrectionSubmittedSnackbar;

  /// No description provided for @employeeCorrectionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Correction details'**
  String get employeeCorrectionDetailsTitle;

  /// No description provided for @employeeCorrectionRequestedPunchLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested punch'**
  String get employeeCorrectionRequestedPunchLabel;

  /// No description provided for @employeeCorrectionSelectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get employeeCorrectionSelectPlaceholder;

  /// No description provided for @employeeAttendanceReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get employeeAttendanceReasonLabel;

  /// No description provided for @employeeCorrectionAdminReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Your request will be reviewed by an admin.'**
  String get employeeCorrectionAdminReviewNote;

  /// No description provided for @employeeCorrectionSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get employeeCorrectionSubmitCta;

  /// No description provided for @employeeCorrectionRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent requests'**
  String get employeeCorrectionRecentTitle;

  /// No description provided for @employeePolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance policy'**
  String get employeePolicyTitle;

  /// No description provided for @employeePolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple rules for your workday'**
  String get employeePolicySubtitle;

  /// No description provided for @employeePolicySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Policy summary'**
  String get employeePolicySummaryTitle;

  /// No description provided for @employeePolicyGpsSummary.
  ///
  /// In en, this message translates to:
  /// **'Your salon uses GPS attendance when enabled. Punch limits: {maxPunches} per day, up to {maxBreaks} breaks.'**
  String employeePolicyGpsSummary(int maxPunches, int maxBreaks);

  /// No description provided for @employeePolicyRulePunchSession.
  ///
  /// In en, this message translates to:
  /// **'Punch In starts your work session; Punch Out ends it.'**
  String get employeePolicyRulePunchSession;

  /// No description provided for @employeePolicyRuleBreakPair.
  ///
  /// In en, this message translates to:
  /// **'Break Out / Break In must be used as a pair.'**
  String get employeePolicyRuleBreakPair;

  /// No description provided for @employeePolicyRuleGpsZone.
  ///
  /// In en, this message translates to:
  /// **'GPS may be required when you punch — stay inside the salon zone.'**
  String get employeePolicyRuleGpsZone;

  /// No description provided for @employeePolicyUpdatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Policy updated'**
  String get employeePolicyUpdatedSnackbar;

  /// No description provided for @employeePolicyRegenerateCta.
  ///
  /// In en, this message translates to:
  /// **'Regenerate policy'**
  String get employeePolicyRegenerateCta;

  /// No description provided for @employeePolicyPunchRules.
  ///
  /// In en, this message translates to:
  /// **'Punch rules'**
  String get employeePolicyPunchRules;

  /// No description provided for @employeePolicyLateEarly.
  ///
  /// In en, this message translates to:
  /// **'Late & early exit'**
  String get employeePolicyLateEarly;

  /// No description provided for @employeePolicyCorrectionSection.
  ///
  /// In en, this message translates to:
  /// **'Correction requests'**
  String get employeePolicyCorrectionSection;

  /// No description provided for @employeePolicyDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance policy'**
  String get employeePolicyDefaultTitle;

  /// No description provided for @employeeTodaySubmitCorrection.
  ///
  /// In en, this message translates to:
  /// **'Submit correction'**
  String get employeeTodaySubmitCorrection;

  /// No description provided for @employeeTodayStatusMissingPunch.
  ///
  /// In en, this message translates to:
  /// **'Missing punch'**
  String get employeeTodayStatusMissingPunch;

  /// No description provided for @employeeTodayStatusCheckedInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are currently on duty'**
  String get employeeTodayStatusCheckedInSubtitle;

  /// No description provided for @employeeTodayStatusOnBreakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap back when your break ends'**
  String get employeeTodayStatusOnBreakSubtitle;

  /// No description provided for @employeeTodayStatusBackFromBreakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can check out later'**
  String get employeeTodayStatusBackFromBreakSubtitle;

  /// No description provided for @employeeTodayStatusCheckedOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get employeeTodayStatusCheckedOutSubtitle;

  /// No description provided for @employeeTodayStatusMissingPunchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please submit a correction request for the missing punch'**
  String get employeeTodayStatusMissingPunchSubtitle;

  /// No description provided for @employeeTodayStatusInvalidSequenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please submit a correction request'**
  String get employeeTodayStatusInvalidSequenceSubtitle;

  /// No description provided for @employeeTodayLastPunchAt.
  ///
  /// In en, this message translates to:
  /// **'Last punch: {time}'**
  String employeeTodayLastPunchAt(String time);

  /// No description provided for @employeeMapOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get employeeMapOpenInMaps;

  /// No description provided for @employeePolicySummaryStatic.
  ///
  /// In en, this message translates to:
  /// **'These rules follow your salon’s attendance settings. Your owner can change them anytime.'**
  String get employeePolicySummaryStatic;

  /// No description provided for @employeePolicyDeductionsSection.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get employeePolicyDeductionsSection;

  /// No description provided for @employeePolicyRuleMaxPunchesOneLine.
  ///
  /// In en, this message translates to:
  /// **'You can record up to {max} punches per calendar day.'**
  String employeePolicyRuleMaxPunchesOneLine(int max);

  /// No description provided for @employeePolicyRuleMaxBreakMinutesOneLine.
  ///
  /// In en, this message translates to:
  /// **'Total break time is limited to {minutes} minutes per day (combined breaks).'**
  String employeePolicyRuleMaxBreakMinutesOneLine(int minutes);

  /// No description provided for @employeePolicyRuleBreakOrderOneLine.
  ///
  /// In en, this message translates to:
  /// **'Break Out must always be followed by Break In before other punches.'**
  String get employeePolicyRuleBreakOrderOneLine;

  /// No description provided for @employeePolicyRuleGpsRequiredOneLine.
  ///
  /// In en, this message translates to:
  /// **'Attendance requires your phone location. Stay within {radius} m of the salon center when punching.'**
  String employeePolicyRuleGpsRequiredOneLine(int radius);

  /// No description provided for @employeePolicyRuleGpsOptionalOneLine.
  ///
  /// In en, this message translates to:
  /// **'GPS may be used to verify punches. Stay inside the salon zone when your owner requires it.'**
  String get employeePolicyRuleGpsOptionalOneLine;

  /// No description provided for @employeePolicyRuleCorrectionForgotOneLine.
  ///
  /// In en, this message translates to:
  /// **'If you miss a punch, submit an attendance correction request for admin approval.'**
  String get employeePolicyRuleCorrectionForgotOneLine;

  /// No description provided for @employeePolicyRuleCorrectionApprovedOneLine.
  ///
  /// In en, this message translates to:
  /// **'Approved corrections are added safely to your punch history.'**
  String get employeePolicyRuleCorrectionApprovedOneLine;

  /// No description provided for @employeePolicyRuleLateGraceOneLine.
  ///
  /// In en, this message translates to:
  /// **'Late arrival is counted only after {grace} minutes grace.'**
  String employeePolicyRuleLateGraceOneLine(int grace);

  /// No description provided for @employeePolicyRuleLateMonthlyOneLine.
  ///
  /// In en, this message translates to:
  /// **'You may have up to {count} late arrivals per month after grace before extra review applies.'**
  String employeePolicyRuleLateMonthlyOneLine(int count);

  /// No description provided for @employeePolicyRuleEarlyGraceOneLine.
  ///
  /// In en, this message translates to:
  /// **'Early exit is counted only after {grace} minutes grace.'**
  String employeePolicyRuleEarlyGraceOneLine(int grace);

  /// No description provided for @employeePolicyRuleEarlyMonthlyOneLine.
  ///
  /// In en, this message translates to:
  /// **'You may have up to {count} early exits per month after grace before extra review applies.'**
  String employeePolicyRuleEarlyMonthlyOneLine(int count);

  /// No description provided for @employeePolicyDeductionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get employeePolicyDeductionNone;

  /// No description provided for @employeePolicyDeductionPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String employeePolicyDeductionPercentValue(int percent);

  /// No description provided for @employeePolicyDeductionMissingCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing checkout'**
  String get employeePolicyDeductionMissingCheckoutTitle;

  /// No description provided for @employeePolicyDeductionMissingCheckoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configured deduction when checkout is missing.'**
  String get employeePolicyDeductionMissingCheckoutSubtitle;

  /// No description provided for @employeePolicyDeductionAbsenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Absence'**
  String get employeePolicyDeductionAbsenceTitle;

  /// No description provided for @employeePolicyDeductionAbsenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configured deduction for unexcused absence days.'**
  String get employeePolicyDeductionAbsenceSubtitle;

  /// No description provided for @employeeCalendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load calendar'**
  String get employeeCalendarLoadError;

  /// No description provided for @employeeAttendanceDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance day'**
  String get employeeAttendanceDayTitle;

  /// No description provided for @employeeAttendanceDayNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No record for this day.'**
  String get employeeAttendanceDayNoRecord;

  /// No description provided for @employeeAttendanceDayStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String employeeAttendanceDayStatusLine(String status);

  /// No description provided for @employeeAttendanceDayWorkedBreakLine.
  ///
  /// In en, this message translates to:
  /// **'Worked: {worked} min · Break: {breakMin} min'**
  String employeeAttendanceDayWorkedBreakLine(int worked, int breakMin);

  /// No description provided for @employeeAttendanceDayPunchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Punches'**
  String get employeeAttendanceDayPunchesTitle;

  /// No description provided for @employeeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get employeeHistoryTitle;

  /// No description provided for @employeeHistoryRequestCta.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get employeeHistoryRequestCta;

  /// No description provided for @employeeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attendance days yet.'**
  String get employeeHistoryEmpty;

  /// No description provided for @employeeAttendanceRequestAddReason.
  ///
  /// In en, this message translates to:
  /// **'Please add a reason.'**
  String get employeeAttendanceRequestAddReason;

  /// No description provided for @employeeAttendanceRequestFutureTime.
  ///
  /// In en, this message translates to:
  /// **'Requested time cannot be in the future.'**
  String get employeeAttendanceRequestFutureTime;

  /// No description provided for @employeeAttendanceRequestDuplicatePending.
  ///
  /// In en, this message translates to:
  /// **'You already have a pending request for this.'**
  String get employeeAttendanceRequestDuplicatePending;

  /// No description provided for @employeeAttendanceRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get employeeAttendanceRequestSubmitted;

  /// No description provided for @employeeRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get employeeRequestFailed;

  /// No description provided for @employeeAttendanceRequestScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance correction'**
  String get employeeAttendanceRequestScreenTitle;

  /// No description provided for @employeeAttendanceRequestPunchLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested punch'**
  String get employeeAttendanceRequestPunchLabel;

  /// No description provided for @employeeAttendanceRequestSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get employeeAttendanceRequestSubmitCta;

  /// No description provided for @employeeMapPreviewMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Map preview is available on the mobile app.'**
  String get employeeMapPreviewMobileOnly;

  /// No description provided for @employeeMapZoneNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Zone not configured'**
  String get employeeMapZoneNotConfigured;

  /// No description provided for @employeeMapMarkerSalonZone.
  ///
  /// In en, this message translates to:
  /// **'Salon zone'**
  String get employeeMapMarkerSalonZone;

  /// No description provided for @employeeMapMarkerYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get employeeMapMarkerYourLocation;

  /// No description provided for @employeeTodayStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'My today'**
  String get employeeTodayStatsTitle;

  /// No description provided for @employeeTodayStatsSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get employeeTodayStatsSalesLabel;

  /// No description provided for @employeeTodayStatsHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get employeeTodayStatsHoursLabel;

  /// No description provided for @employeeTodayDistanceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Distance —'**
  String get employeeTodayDistanceUnknown;

  /// No description provided for @employeeBottomNavToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get employeeBottomNavToday;

  /// No description provided for @employeeBottomNavSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get employeeBottomNavSales;

  /// No description provided for @employeeBottomNavAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get employeeBottomNavAttendance;

  /// No description provided for @employeeBottomNavPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get employeeBottomNavPayroll;

  /// No description provided for @employeeBottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get employeeBottomNavProfile;

  /// No description provided for @employeeProfileTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get employeeProfileTabOverview;

  /// No description provided for @employeeProfileTabAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account info'**
  String get employeeProfileTabAccountInfo;

  /// No description provided for @employeeProfilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get employeeProfilePhotoTitle;

  /// No description provided for @employeeProfilePhotoUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update photo'**
  String get employeeProfilePhotoUpdateAction;

  /// No description provided for @employeeProfileResetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Send a reset link to your account email.'**
  String get employeeProfileResetPasswordHint;

  /// No description provided for @employeeProfileResetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get employeeProfileResetPasswordAction;

  /// No description provided for @employeeProfileUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get employeeProfileUsernameLabel;

  /// No description provided for @employeeProfileRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get employeeProfileRoleLabel;

  /// No description provided for @employeeProfileAccountStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get employeeProfileAccountStatusLabel;

  /// No description provided for @employeeSettingsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile, security, and app preferences.'**
  String get employeeSettingsHeaderSubtitle;

  /// No description provided for @employeeProfileSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your workspace profile updated.'**
  String get employeeProfileSummarySubtitle;

  /// No description provided for @employeeProfileUpdateShort.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get employeeProfileUpdateShort;

  /// No description provided for @employeeNoData.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get employeeNoData;

  /// No description provided for @ownerCustomerBookingTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer booking'**
  String get ownerCustomerBookingTileTitle;

  /// No description provided for @ownerCustomerBookingTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control online booking, availability, and public visibility'**
  String get ownerCustomerBookingTileSubtitle;

  /// No description provided for @ownerCustomerBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer booking'**
  String get ownerCustomerBookingTitle;

  /// No description provided for @ownerCustomerBookingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control how customers discover your salon, book online, and see availability.'**
  String get ownerCustomerBookingSubtitle;

  /// No description provided for @ownerCustomerBookingSectionPublic.
  ///
  /// In en, this message translates to:
  /// **'Public visibility'**
  String get ownerCustomerBookingSectionPublic;

  /// No description provided for @ownerCustomerBookingSectionPublicHint.
  ///
  /// In en, this message translates to:
  /// **'Listing and discovery'**
  String get ownerCustomerBookingSectionPublicHint;

  /// No description provided for @ownerCustomerBookingShowSalon.
  ///
  /// In en, this message translates to:
  /// **'Show salon to customers'**
  String get ownerCustomerBookingShowSalon;

  /// No description provided for @ownerCustomerBookingShowSalonHint.
  ///
  /// In en, this message translates to:
  /// **'If off, your salon will not appear in customer discovery.'**
  String get ownerCustomerBookingShowSalonHint;

  /// No description provided for @ownerCustomerBookingSectionAvailability.
  ///
  /// In en, this message translates to:
  /// **'Booking availability'**
  String get ownerCustomerBookingSectionAvailability;

  /// No description provided for @ownerCustomerBookingEnableBooking.
  ///
  /// In en, this message translates to:
  /// **'Enable customer booking'**
  String get ownerCustomerBookingEnableBooking;

  /// No description provided for @ownerCustomerBookingAutoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Auto-confirm bookings'**
  String get ownerCustomerBookingAutoConfirm;

  /// No description provided for @ownerCustomerBookingAnySpecialist.
  ///
  /// In en, this message translates to:
  /// **'Allow any available specialist'**
  String get ownerCustomerBookingAnySpecialist;

  /// No description provided for @ownerCustomerBookingRequireCode.
  ///
  /// In en, this message translates to:
  /// **'Require booking code for lookup'**
  String get ownerCustomerBookingRequireCode;

  /// No description provided for @ownerCustomerBookingShowPrices.
  ///
  /// In en, this message translates to:
  /// **'Show prices to customers'**
  String get ownerCustomerBookingShowPrices;

  /// No description provided for @ownerCustomerBookingAllowNotes.
  ///
  /// In en, this message translates to:
  /// **'Allow customer notes'**
  String get ownerCustomerBookingAllowNotes;

  /// No description provided for @ownerCustomerBookingAllowFeedback.
  ///
  /// In en, this message translates to:
  /// **'Allow customer feedback'**
  String get ownerCustomerBookingAllowFeedback;

  /// No description provided for @ownerCustomerBookingSectionRules.
  ///
  /// In en, this message translates to:
  /// **'Booking rules'**
  String get ownerCustomerBookingSectionRules;

  /// No description provided for @ownerCustomerBookingSlotInterval.
  ///
  /// In en, this message translates to:
  /// **'Slot interval'**
  String get ownerCustomerBookingSlotInterval;

  /// No description provided for @ownerCustomerBookingMaxAdvance.
  ///
  /// In en, this message translates to:
  /// **'Max advance booking days'**
  String get ownerCustomerBookingMaxAdvance;

  /// No description provided for @ownerCustomerBookingCancelCutoff.
  ///
  /// In en, this message translates to:
  /// **'Cancellation cutoff'**
  String get ownerCustomerBookingCancelCutoff;

  /// No description provided for @ownerCustomerBookingRescheduleCutoff.
  ///
  /// In en, this message translates to:
  /// **'Reschedule cutoff'**
  String get ownerCustomerBookingRescheduleCutoff;

  /// No description provided for @ownerCustomerBookingSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Public contact info'**
  String get ownerCustomerBookingSectionContact;

  /// No description provided for @ownerCustomerBookingPublicArea.
  ///
  /// In en, this message translates to:
  /// **'Public area'**
  String get ownerCustomerBookingPublicArea;

  /// No description provided for @ownerCustomerBookingPublicPhone.
  ///
  /// In en, this message translates to:
  /// **'Public phone'**
  String get ownerCustomerBookingPublicPhone;

  /// No description provided for @ownerCustomerBookingPublicWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Public WhatsApp'**
  String get ownerCustomerBookingPublicWhatsapp;

  /// No description provided for @ownerCustomerBookingGenderTarget.
  ///
  /// In en, this message translates to:
  /// **'Gender target'**
  String get ownerCustomerBookingGenderTarget;

  /// No description provided for @ownerCustomerBookingGenderMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get ownerCustomerBookingGenderMen;

  /// No description provided for @ownerCustomerBookingGenderLadies.
  ///
  /// In en, this message translates to:
  /// **'Ladies'**
  String get ownerCustomerBookingGenderLadies;

  /// No description provided for @ownerCustomerBookingGenderUnisex.
  ///
  /// In en, this message translates to:
  /// **'Unisex'**
  String get ownerCustomerBookingGenderUnisex;

  /// No description provided for @ownerCustomerBookingWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get ownerCustomerBookingWorkingHours;

  /// No description provided for @ownerCustomerBookingCopyMonday.
  ///
  /// In en, this message translates to:
  /// **'Copy Monday to Tue–Thu'**
  String get ownerCustomerBookingCopyMonday;

  /// No description provided for @ownerCustomerBookingCloseAll.
  ///
  /// In en, this message translates to:
  /// **'Close all'**
  String get ownerCustomerBookingCloseAll;

  /// No description provided for @ownerCustomerBookingOpenAll.
  ///
  /// In en, this message translates to:
  /// **'Open all'**
  String get ownerCustomerBookingOpenAll;

  /// No description provided for @ownerCustomerBookingSave.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get ownerCustomerBookingSave;

  /// No description provided for @ownerCustomerBookingSaved.
  ///
  /// In en, this message translates to:
  /// **'Customer booking settings saved'**
  String get ownerCustomerBookingSaved;

  /// No description provided for @ownerCustomerBookingValidationTimeOrder.
  ///
  /// In en, this message translates to:
  /// **'Start time must be before end time on open days.'**
  String get ownerCustomerBookingValidationTimeOrder;

  /// No description provided for @ownerCustomerBookingValidationWorkingDay.
  ///
  /// In en, this message translates to:
  /// **'At least one working day is required when booking is public.'**
  String get ownerCustomerBookingValidationWorkingDay;

  /// No description provided for @ownerCustomerBookingPublicAreaRequired.
  ///
  /// In en, this message translates to:
  /// **'Public area is required when the salon is public and booking is on.'**
  String get ownerCustomerBookingPublicAreaRequired;

  /// No description provided for @ownerCustomerBookingValidationSlotInterval.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid slot interval (15, 20, 30, 45, or 60 minutes).'**
  String get ownerCustomerBookingValidationSlotInterval;

  /// No description provided for @ownerCustomerBookingValidationMaxAdvance.
  ///
  /// In en, this message translates to:
  /// **'Max advance days must be between 1 and 90.'**
  String get ownerCustomerBookingValidationMaxAdvance;

  /// No description provided for @ownerCustomerBookingValidationCutoff.
  ///
  /// In en, this message translates to:
  /// **'Cutoff must be between 0 and 10080 minutes.'**
  String get ownerCustomerBookingValidationCutoff;

  /// No description provided for @ownerCustomerBookingValidationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number or leave the field empty.'**
  String get ownerCustomerBookingValidationPhone;

  /// No description provided for @ownerCustomerBookingDayOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get ownerCustomerBookingDayOpen;

  /// No description provided for @ownerCustomerBookingDayClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get ownerCustomerBookingDayClosed;

  /// No description provided for @ownerCustomerBookingSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control how customers can book appointments'**
  String get ownerCustomerBookingSettingsSubtitle;

  /// No description provided for @ownerCustomerBookingStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get ownerCustomerBookingStatusEnabled;

  /// No description provided for @ownerCustomerBookingStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get ownerCustomerBookingStatusDisabled;

  /// No description provided for @ownerCustomerBookingSameDay.
  ///
  /// In en, this message translates to:
  /// **'Allow same-day booking'**
  String get ownerCustomerBookingSameDay;

  /// No description provided for @ownerCustomerBookingRequirePhone.
  ///
  /// In en, this message translates to:
  /// **'Require customer phone'**
  String get ownerCustomerBookingRequirePhone;

  /// No description provided for @ownerCustomerBookingRequireName.
  ///
  /// In en, this message translates to:
  /// **'Require customer name'**
  String get ownerCustomerBookingRequireName;

  /// No description provided for @ownerCustomerBookingTimeRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Time rules'**
  String get ownerCustomerBookingTimeRulesTitle;

  /// No description provided for @ownerCustomerBookingMinNotice.
  ///
  /// In en, this message translates to:
  /// **'Minimum notice before booking'**
  String get ownerCustomerBookingMinNotice;

  /// No description provided for @ownerCustomerBookingMaxDaysAhead.
  ///
  /// In en, this message translates to:
  /// **'Maximum days ahead'**
  String get ownerCustomerBookingMaxDaysAhead;

  /// No description provided for @ownerCustomerBookingSlotDuration.
  ///
  /// In en, this message translates to:
  /// **'Slot duration'**
  String get ownerCustomerBookingSlotDuration;

  /// No description provided for @ownerCustomerBookingBuffer.
  ///
  /// In en, this message translates to:
  /// **'Buffer between bookings'**
  String get ownerCustomerBookingBuffer;

  /// No description provided for @ownerCustomerBookingCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation rules'**
  String get ownerCustomerBookingCancellationTitle;

  /// No description provided for @ownerCustomerBookingAllowCancel.
  ///
  /// In en, this message translates to:
  /// **'Allow customer cancellation'**
  String get ownerCustomerBookingAllowCancel;

  /// No description provided for @ownerCustomerBookingCancelNotice.
  ///
  /// In en, this message translates to:
  /// **'Cancellation minimum notice'**
  String get ownerCustomerBookingCancelNotice;

  /// No description provided for @ownerCustomerBookingPublicMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Public booking message'**
  String get ownerCustomerBookingPublicMessageTitle;

  /// No description provided for @ownerCustomerBookingPublicMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Shown to customers when booking is open.'**
  String get ownerCustomerBookingPublicMessageHint;

  /// No description provided for @ownerCustomerBookingSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ownerCustomerBookingSaveCta;

  /// No description provided for @ownerCustomerBookingSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking settings updated'**
  String get ownerCustomerBookingSaveSuccess;

  /// No description provided for @ownerCustomerBookingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings'**
  String get ownerCustomerBookingSaveError;

  /// No description provided for @ownerCustomerBookingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load booking settings'**
  String get ownerCustomerBookingLoadError;

  /// No description provided for @ownerCustomerBookingValidationMinNotice.
  ///
  /// In en, this message translates to:
  /// **'Minimum notice cannot be negative.'**
  String get ownerCustomerBookingValidationMinNotice;

  /// No description provided for @ownerCustomerBookingValidationMaxDays.
  ///
  /// In en, this message translates to:
  /// **'Maximum days ahead must be greater than 0.'**
  String get ownerCustomerBookingValidationMaxDays;

  /// No description provided for @ownerCustomerBookingValidationSlot.
  ///
  /// In en, this message translates to:
  /// **'Slot duration must be greater than 0.'**
  String get ownerCustomerBookingValidationSlot;

  /// No description provided for @ownerCustomerBookingValidationBuffer.
  ///
  /// In en, this message translates to:
  /// **'Buffer cannot be negative.'**
  String get ownerCustomerBookingValidationBuffer;

  /// No description provided for @ownerCustomerBookingValidationCancelHours.
  ///
  /// In en, this message translates to:
  /// **'Cancellation notice must be greater than 0 when cancellation is allowed.'**
  String get ownerCustomerBookingValidationCancelHours;

  /// No description provided for @ownerCustomerBookingValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Message cannot exceed 250 characters.'**
  String get ownerCustomerBookingValidationMessage;

  /// No description provided for @ownerCustomerBookingMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String ownerCustomerBookingMinutesShort(int n);

  /// No description provided for @ownerCustomerBookingHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{n} h'**
  String ownerCustomerBookingHoursShort(int n);

  /// No description provided for @ownerCustomerBookingMinutesDay.
  ///
  /// In en, this message translates to:
  /// **'24 h'**
  String get ownerCustomerBookingMinutesDay;

  /// No description provided for @customerBookingClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Online booking is closed'**
  String get customerBookingClosedTitle;

  /// No description provided for @customerBookingClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This salon is not accepting new online bookings right now.'**
  String get customerBookingClosedMessage;

  /// No description provided for @addSaleSelectAtLeastOneService.
  ///
  /// In en, this message translates to:
  /// **'Select at least one service to continue.'**
  String get addSaleSelectAtLeastOneService;

  /// No description provided for @addSaleSelectStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Pick the staff member who delivered this service.'**
  String get addSaleSelectStaffMember;

  /// No description provided for @addSaleTotalMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Total must be greater than zero.'**
  String get addSaleTotalMustBePositive;

  /// No description provided for @addSaleMixedPaymentMustEqualTotal.
  ///
  /// In en, this message translates to:
  /// **'Cash + card must equal the total.'**
  String get addSaleMixedPaymentMustEqualTotal;

  /// No description provided for @addSaleNoActiveServicesYet.
  ///
  /// In en, this message translates to:
  /// **'No active services yet'**
  String get addSaleNoActiveServicesYet;

  /// No description provided for @addSaleCreateServicesFirst.
  ///
  /// In en, this message translates to:
  /// **'Create services first to record sales.'**
  String get addSaleCreateServicesFirst;

  /// No description provided for @addSaleUnableToLoadServices.
  ///
  /// In en, this message translates to:
  /// **'Unable to load services'**
  String get addSaleUnableToLoadServices;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
