// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Zurano';

  @override
  String get splashTitle => 'صالون الحلاقة';

  @override
  String get splashTagline => 'قصّات بذوق وهدوء في الحجز.';

  @override
  String get genericError => 'حدث خطأ ما.';

  @override
  String get loadingPlaceholder => '…';

  @override
  String get customerDiscoverTitle => 'استكشف';

  @override
  String get customerHomeMenuTooltip => 'المزيد';

  @override
  String get customerHomeEmptyTitle => 'لا صالونات للعرض';

  @override
  String get customerHomeResetFilters => 'إعادة ضبط البحث';

  @override
  String get customerSignOut => 'تسجيل الخروج';

  @override
  String get signOutSubtitle =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام حسابك.';

  @override
  String get customerSearchHint => 'ابحث عن الصالونات أو المناطق…';

  @override
  String customerGreeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get customerGuestName => 'ضيفنا';

  @override
  String get customerNoSalons => 'لا توجد صالونات مطابقة.';

  @override
  String get customerSalonDetails => 'الصالون';

  @override
  String get customerBook => 'احجز موعدًا';

  @override
  String get customerServicesPreview => 'خدمات شائعة';

  @override
  String get customerNoServicesListed => 'لا توجد خدمات بعد.';

  @override
  String customerServiceMeta(int minutes, String price) {
    return '$minutes د · $price';
  }

  @override
  String get customerSalonNotFound => 'هذا الصالون غير متاح.';

  @override
  String get customerBookAppointment => 'احجز موعدًا';

  @override
  String get customerSelectDate => 'التاريخ';

  @override
  String get customerSelectService => 'الخدمة';

  @override
  String get customerSelectBarber => 'عضو الفريق';

  @override
  String get customerSelectTime => 'الوقت';

  @override
  String get customerNotes => 'ملاحظات (اختياري)';

  @override
  String get customerConfirmBooking => 'تأكيد الحجز';

  @override
  String get customerBookingSubmitted => 'تم تأكيد حجزك';

  @override
  String get customerBackHome => 'العودة للرئيسية';

  @override
  String get bookingConfirmationTitle => 'التأكيد';

  @override
  String get bookingWhen => 'الموعد';

  @override
  String get bookingBarber => 'عضو الفريق';

  @override
  String get bookingService => 'الخدمة';

  @override
  String get bookingSalon => 'الصالون';

  @override
  String get bookingReference => 'المرجع';

  @override
  String get bookingNotFound => 'الحجز غير موجود.';

  @override
  String get customerNoBarbers => 'لا يوجد أعضاء فريق متاحون بعد.';

  @override
  String get customerNoSlots =>
      'لا توجد أوقات متاحة لهذا اليوم. جرّب تاريخًا أو عضو فريق آخر.';

  @override
  String get customerBookingIncomplete => 'اختر الخدمة وعضو الفريق والوقت.';

  @override
  String get customerBookingSignInRequired => 'سجّل الدخول لإكمال الحجز.';

  @override
  String get customerBookingSlotTaken =>
      'هذا الوقت لم يعد متاحًا. اختر وقتًا آخر.';

  @override
  String get customerBookingSlotInvalid =>
      'هذا الوقت غير متاح. اختر وقتًا مختلفًا.';

  @override
  String customerBookingNotesTooLong(int maxChars) {
    return 'لا يمكن أن تتجاوز الملاحظات $maxChars حرفًا.';
  }

  @override
  String get customerBookingScreenHint =>
      'اختر التاريخ والخدمة وعضو الفريق والوقت. الاقتراحات أدناه تملأ عضو الفريق والوقت تلقائيًا.';

  @override
  String get customerBookingSummaryTitle => 'زيارتك';

  @override
  String get ownerTabOverview => 'نظرة عامة';

  @override
  String get ownerTabTeam => 'الفريق';

  @override
  String get ownerTabServices => 'الخدمات';

  @override
  String get ownerTabBookings => 'الحجوزات';

  @override
  String get ownerTabMoney => 'المالية';

  @override
  String get ownerWorkspaceWide => 'مساحة عملك اليوم';

  @override
  String get ownerWorkspaceNarrow => 'نظرة اليوم';

  @override
  String get ownerLoadError => 'تعذر تحميل مساحة العمل. سجّل الدخول مجددًا.';

  @override
  String ownerSalonChip(String id) {
    return 'الصالون · $id';
  }

  @override
  String get ownerSalonSetupTitle => 'أضف تفاصيل صالونك';

  @override
  String get ownerSalonSetupMessage =>
      'اختر اسم الصالون والمدينة لبدء إدارة الحجوزات والفريق.';

  @override
  String get ownerSalonSetupCta => 'إعداد الصالون';

  @override
  String get ownerSales7 => 'آخر 7 أيام';

  @override
  String get ownerSales30 => 'آخر 30 يومًا';

  @override
  String get ownerSalesAll => 'الكل';

  @override
  String get ownerOverviewTitle => 'يومك في لمحة';

  @override
  String get ownerOverviewSubtitle => 'إجماليات مباشرة من صالونك.';

  @override
  String get ownerOverviewQuickService => 'إضافة خدمة';

  @override
  String get ownerOverviewQuickBooking => 'إضافة حجز';

  @override
  String get ownerOverviewQuickBarber => 'إضافة حلاق';

  @override
  String get ownerOverviewEmptyRevenueToday => 'لا مبيعات مسجلة اليوم.';

  @override
  String get ownerOverviewEmptyBookingsToday => 'لا حجوزات مجدولة لليوم.';

  @override
  String get ownerOverviewEmptyTopBarberMonth =>
      'لا مبيعات لأعضاء الفريق هذا الشهر بعد.';

  @override
  String get ownerOverviewEmptyTopServiceMonth =>
      'لا استخدام لخدمات هذا الشهر بعد.';

  @override
  String get ownerOverviewLoadingMetrics => 'جاري تحميل المؤشرات…';

  @override
  String get ownerOverviewTotalRevenueLabel => 'إجمالي الإيرادات';

  @override
  String get ownerOverviewTotalRevenuePeriod => 'هذا الشهر';

  @override
  String get ownerOverviewTotalRevenueEmpty =>
      'لا مبيعات مكتملة هذا الشهر بعد.';

  @override
  String get ownerOverviewServicesPanelCaption => 'الأسعار والمدة';

  @override
  String ownerServicesCategoryBanner(String category) {
    return '$category — الأسعار والمدة';
  }

  @override
  String get ownerServicesCategoryAll => 'كل الخدمات';

  @override
  String get ownerOverviewTeamColumnMember => 'العضو';

  @override
  String get ownerOverviewTeamColumnRole => 'الدور';

  @override
  String get ownerOverviewTeamColumnEmail => 'البريد';

  @override
  String ownerOverviewServiceUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count استخدام',
      many: '$count استخدامًا',
      few: '$count استخدامات',
      two: 'استخدامان',
      one: 'استخدام واحد',
      zero: 'لا استخدامات',
    );
    return '$_temp0';
  }

  @override
  String get ownerStatTodayBookings => 'حجوزات اليوم';

  @override
  String get ownerStatRevenue => 'الإيرادات (الفترة)';

  @override
  String get ownerStatUpcoming => 'القادمة';

  @override
  String get ownerNoBookingsStat => '0';

  @override
  String get ownerBookingsListTitle => 'الحجوزات';

  @override
  String get ownerBookingCancel => 'إلغاء';

  @override
  String get ownerBookingCancelled => 'تم إلغاء الحجز';

  @override
  String get ownerFilterStatus => 'الحالة';

  @override
  String get ownerFilterAll => 'الكل';

  @override
  String get ownerTeamTitle => 'الفريق';

  @override
  String get ownerTeamSubtitle => 'إدارة أعضاء الفريق والمسؤولين.';

  @override
  String get ownerTeamCardRoleLabel => 'الدور';

  @override
  String get ownerTeamCardStatusLabel => 'الحالة';

  @override
  String get ownerTeamCardStatusActive => 'نشط';

  @override
  String get ownerTeamCardStatusInactive => 'غير نشط';

  @override
  String get ownerTeamCardManage => 'إدارة';

  @override
  String get ownerAddMember => 'إضافة عضو';

  @override
  String get ownerEmployeeName => 'الاسم';

  @override
  String get ownerEmployeeEmail => 'البريد';

  @override
  String get ownerEmployeeRole => 'الدور';

  @override
  String get ownerEmployeePhone => 'الهاتف';

  @override
  String get ownerSave => 'حفظ';

  @override
  String get ownerEditMember => 'تعديل العضو';

  @override
  String get ownerDeactivate => 'تعطيل';

  @override
  String get ownerActivate => 'تفعيل';

  @override
  String get ownerServicesTitle => 'الخدمات';

  @override
  String get ownerServicesSubtitle => 'إدارة ما يمكن للعملاء حجزه وشراؤه';

  @override
  String get ownerServicesSearchPlaceholder => 'ابحث عن خدمة';

  @override
  String get ownerServicesStatTotal => 'الإجمالي';

  @override
  String get ownerServicesStatActive => 'نشطة';

  @override
  String get ownerServicesStatInactive => 'غير نشطة';

  @override
  String get ownerServicesChipAll => 'الكل';

  @override
  String get ownerServicesChipHair => 'شعر';

  @override
  String get ownerServicesChipBeard => 'لحية';

  @override
  String get ownerServicesChipFacial => 'عناية بالبشرة';

  @override
  String get ownerServicesChipPackages => 'باقات';

  @override
  String get ownerServicesChipColoring => 'صبغة';

  @override
  String get ownerServiceCategoryHair => 'الشعر';

  @override
  String get ownerServiceCategoryBarberBeard => 'الحلاقة واللحية';

  @override
  String get ownerServiceCategoryNails => 'الأظافر';

  @override
  String get ownerServiceCategoryHairRemovalWaxing => 'إزالة الشعر والشمع';

  @override
  String get ownerServiceCategoryOther => 'أخرى';

  @override
  String get ownerServiceCategoryBrowsLashes => 'الحواجب والرموش';

  @override
  String get ownerServiceCategoryFacialSkincare => 'العناية بالبشرة والوجه';

  @override
  String get ownerServiceCategoryMakeup => 'المكياج';

  @override
  String get ownerServiceCategoryMassageSpa => 'المساج والسبا';

  @override
  String get ownerServiceCategoryPackages => 'الباقات';

  @override
  String get ownerServiceCategoryColoring => 'الصبغات';

  @override
  String get ownerServiceCategoryTexturedHair => 'الشعر الكيرلي / المجعد';

  @override
  String get ownerServiceCategoryBridal => 'العرائس';

  @override
  String get ownerServiceCategoryTanning => 'التسمير';

  @override
  String get ownerServiceCategoryMedSpa => 'العناية الطبية التجميلية';

  @override
  String get ownerServiceCategoryMenGrooming => 'العناية الرجالية';

  @override
  String get ownerServiceCategoryHaircutStyling => 'قص وتصفيف الشعر';

  @override
  String get ownerServiceCategoryHairTreatments => 'علاجات الشعر';

  @override
  String get ownerServiceCategoryScalpTreatments => 'علاجات فروة الرأس';

  @override
  String get ownerServiceCategoryKeratinSmoothing => 'الكيراتين وتنعيم الشعر';

  @override
  String get ownerServiceCategoryHairExtensions => 'وصلات الشعر';

  @override
  String get ownerServiceCategoryKidsServices => 'خدمات الأطفال';

  @override
  String get ownerServiceCategoryManicurePedicure => 'مانيكير وباديكير';

  @override
  String get ownerServiceCategoryNailArt => 'فن الأظافر';

  @override
  String get ownerServiceCategoryThreading => 'الخيط';

  @override
  String get ownerServiceCategoryLashExtensions => 'تمديد الرموش';

  @override
  String get ownerServiceCategoryBodyTreatments => 'علاجات الجسم';

  @override
  String get ownerServiceCategoryMakeupPermanent => 'المكياج الدائم';

  @override
  String get ownerServiceCustomCategoryLabel => 'اسم التصنيف';

  @override
  String get ownerServiceValidationCategoryRequired => 'اختر تصنيفاً.';

  @override
  String get ownerServiceValidationCustomCategoryRequired =>
      'أدخل اسم التصنيف.';

  @override
  String get ownerServiceValidationDuplicateCustomCategory =>
      'لديك بالفعل تصنيف مخصص بهذا الاسم.';

  @override
  String get ownerServiceCategoriesMore => 'المزيد';

  @override
  String get ownerServiceCategoriesMoreTitle => 'تصنيفات إضافية';

  @override
  String get ownerServiceCategoryAllOther => 'كل خدمات «أخرى»';

  @override
  String get ownerServicesEmptyTitle => 'لا توجد خدمات بعد';

  @override
  String get ownerServicesEmptyDescription =>
      'أضف أول خدمة ليتمكن العملاء من اكتشاف عروضك وحجزها.';

  @override
  String get ownerServicesNoMatches => 'لا توجد خدمات مطابقة لبحثك أو للتصفية.';

  @override
  String get ownerServicesFabTooltip => 'إضافة خدمة';

  @override
  String get ownerServiceSaveCta => 'حفظ الخدمة';

  @override
  String get ownerServiceSavedSuccess => 'تم حفظ الخدمة.';

  @override
  String get ownerServiceDeletedSuccess => 'تم حذف الخدمة.';

  @override
  String get ownerServiceValidationDurationInvalid => 'أدخل مدة أكبر من صفر.';

  @override
  String get ownerServiceValidationPriceInvalid => 'أدخل سعراً أكبر من صفر.';

  @override
  String get ownerServiceValidationArabicNameRequired =>
      'أدخل اسم الخدمة بالعربية.';

  @override
  String get ownerServiceDeleteConfirmTitle => 'حذف الخدمة؟';

  @override
  String get ownerServiceDeleteConfirmBody =>
      'سيُزال هذا العنصر من قائمة الخدمات. لا يمكن التراجع.';

  @override
  String get ownerServiceActionCancel => 'إلغاء';

  @override
  String get ownerServiceActionDelete => 'حذف';

  @override
  String get ownerServiceActionEdit => 'تعديل';

  @override
  String get ownerServiceStatusActive => 'نشطة';

  @override
  String get ownerServiceStatusInactive => 'غير نشطة';

  @override
  String ownerServiceTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استُخدمت $count مرة',
      many: 'استُخدمت $count مرة',
      few: 'استُخدمت $count مرات',
      two: 'استُخدمت مرتين',
      one: 'استُخدمت مرة واحدة',
      zero: 'لم يُستخدم',
    );
    return '$_temp0';
  }

  @override
  String ownerServiceTotalRevenue(String amount) {
    return 'الإيرادات $amount';
  }

  @override
  String get ownerServiceAnalyticsPlaceholder =>
      'يظهر الاستخدام والإيراد عند البيع.';

  @override
  String get ownerServiceFormImageUrlHint => 'رابط الصورة (اختياري)';

  @override
  String get ownerServicePhotoSectionLabel => 'صورة الخدمة';

  @override
  String get ownerServiceUploadPhotoAction => 'رفع صورة';

  @override
  String get ownerServicePhotoChooseGallery => 'ألبوم الصور';

  @override
  String get ownerServicePhotoChooseCamera => 'التقاط صورة';

  @override
  String get ownerServicePhotoRemove => 'إزالة الصورة';

  @override
  String get ownerServicePhotoUploading => 'جارٍ الرفع…';

  @override
  String get ownerServicePhotoTooLarge => 'اختر صورة أصغر من 5 ميجابايت.';

  @override
  String get ownerServicePhotoUploadError => 'تعذّر رفع الصورة. حاول مرة أخرى.';

  @override
  String get ownerServiceFormDescriptionHint => 'الوصف (اختياري)';

  @override
  String get ownerServiceCategoryPickerLabel => 'التصنيف';

  @override
  String get ownerServiceCategoryIconPreviewHint =>
      'تظهر هذه الأيقونة في الحجز والمبيعات وتطبيق العميل.';

  @override
  String get ownerServiceCategoryNone => 'بدون';

  @override
  String get ownerAddService => 'إضافة خدمة';

  @override
  String get ownerEditService => 'تعديل الخدمة';

  @override
  String get ownerServiceName => 'اسم الخدمة (بالإنجليزية)';

  @override
  String get ownerServiceNameArabic => 'اسم الخدمة (بالعربية)';

  @override
  String get ownerAddServiceSheetSubtitle => 'أنشئ خدمة قابلة للحجز لعملائك';

  @override
  String get ownerServiceSectionDetailsTitle => 'تفاصيل الخدمة';

  @override
  String get ownerServiceSectionDetailsSubtitle => 'معلومات أساسية عن الخدمة';

  @override
  String get ownerServiceSectionDurationTitle => 'المدة والتسعير';

  @override
  String get ownerServiceSectionDurationSubtitle =>
      'حدد المدة المطلوبة والتكلفة';

  @override
  String get ownerServiceSectionPhotoSubtitle => 'أضف صورة لعرض الخدمة';

  @override
  String get ownerServiceSectionDescriptionSubtitle =>
      'أضف المزيد من التفاصيل عن هذه الخدمة';

  @override
  String get ownerServiceActiveSubtitle => 'إظهار هذه الخدمة للعملاء';

  @override
  String get ownerServiceNamePlaceholder => 'مثال: Classic Haircut';

  @override
  String get ownerServiceNameArabicPlaceholder => 'مثال: قصة شعر كلاسيكية';

  @override
  String get ownerServiceDescriptionPlaceholderLong =>
      'صف الخدمة وما يتضمنه والفوائد، إلخ.';

  @override
  String get ownerServicePhotoFormatsHint => 'PNG أو JPG حتى 5 ميجابايت';

  @override
  String get ownerServicePhotoSizeHint => 'الحجم الموصى به: 1200×800 بكسل';

  @override
  String get ownerServiceSuffixMin => 'دقيقة';

  @override
  String get ownerServiceDuration => 'المدة (دقائق)';

  @override
  String get ownerServicePrice => 'السعر';

  @override
  String get ownerDeleteService => 'حذف';

  @override
  String get ownerMoneyTitle => 'المالية';

  @override
  String get ownerMoneySubtitle => 'المبيعات والرواتب والمصروفات.';

  @override
  String get ownerKpiNone => '—';

  @override
  String get ownerKpiTodayRevenue => 'إيرادات اليوم';

  @override
  String get ownerKpiMonthRevenue => 'إيرادات الشهر';

  @override
  String get ownerKpiBookingsToday => 'حجوزات اليوم';

  @override
  String get ownerKpiEmployees => 'الموظفون النشطون';

  @override
  String get ownerKpiTopBarber => 'أفضل حلاق (الشهر)';

  @override
  String get ownerKpiTopService => 'أفضل خدمة (الشهر)';

  @override
  String get ownerKpiCompletedToday => 'مكتمل اليوم';

  @override
  String get ownerKpiCancelledToday => 'ملغاة اليوم';

  @override
  String get ownerKpiRescheduledToday => 'أعيد جدولتها اليوم';

  @override
  String get ownerKpiCompletionRateMonth => 'معدل الإكمال (الشهر)';

  @override
  String get ownerKpiCancellationRateMonth => 'معدل الإلغاء (الشهر)';

  @override
  String get ownerKpiTopBarberCompletionsMonth => 'أفضل حلاق · إكمال (الشهر)';

  @override
  String get ownerMoneyRecognitionOperational => 'تشغيلي';

  @override
  String get ownerMoneyRecognitionCash => 'نقدي';

  @override
  String get ownerMoneySalesMonth => 'المبيعات (هذا الشهر)';

  @override
  String get ownerMoneyPayrollSection => 'الرواتب';

  @override
  String get ownerMoneyExpensesSection => 'المصروفات';

  @override
  String get ownerMoneyEmptyPayroll => 'لا سجلات رواتب بعد.';

  @override
  String get ownerMoneyEmptyExpenses => 'لا مصروفات مسجلة بعد.';

  @override
  String get ownerMoneyPayrollEmptyTitle => 'لا رواتب';

  @override
  String get ownerMoneyExpensesEmptyTitle => 'لا مصروفات';

  @override
  String get ownerDashboardTitle => 'مساحة العمل';

  @override
  String get ownerAiAssistantTooltip => 'افتح مساعد لوحة التحكم';

  @override
  String get aiAssistantTitle => 'مساعد لوحة التحكم';

  @override
  String get aiAssistantInputLabel => 'اسأل المساعد';

  @override
  String get aiAssistantInputHint =>
      'اطلب إيراد اليوم أو إيراد الشهر أو أفضل الحلاقين.';

  @override
  String get aiAssistantSend => 'أنشئ العرض';

  @override
  String get aiAssistantWelcomeTitle => 'اطلب لقطة سريعة للمالك';

  @override
  String get aiAssistantWelcomeMessage =>
      'استخدم طلبات طبيعية لإنشاء ملخص مركز للإيرادات وأداء الفريق داخل الصالون.';

  @override
  String get aiAssistantLoadingTitle => 'جارٍ بناء عرض لوحة التحكم';

  @override
  String get aiAssistantLoadingMessage =>
      'يستدعي المساعد الأدوات المعتمدة ويجهز سطحًا موجزًا ومناسبًا للجوال.';

  @override
  String get aiAssistantErrorTitle => 'المساعد غير متاح';

  @override
  String get aiAssistantErrorMessage =>
      'تعذر على المساعد إنشاء العرض الآن. حاول مرة أخرى بعد قليل.';

  @override
  String get aiAssistantRetry => 'حاول مرة أخرى';

  @override
  String get aiAssistantSalonRequiredTitle => 'الصالون مطلوب';

  @override
  String get aiAssistantSalonRequiredMessage =>
      'يحتاج هذا المساعد إلى صالون صالح قبل تحميل رؤى المالك.';

  @override
  String get aiAssistantSuggestionTodayRevenue => 'اعرض إيراد اليوم';

  @override
  String get aiAssistantSuggestionMonthRevenue => 'اعرض إيراد هذا الشهر';

  @override
  String get aiAssistantSuggestionTopBarbers => 'اعرض أفضل الحلاقين هذا الشهر';

  @override
  String get smartWorkspaceTitle => 'مساحة العمل الذكية';

  @override
  String get smartWorkspaceLoadingTitle => 'جارٍ تجهيز مساحة العمل';

  @override
  String get smartWorkspaceLoadingMessage =>
      'يتم تحميل العرض المناسب لمساعد الرواتب أو التحليلات أو تصحيح الحضور.';

  @override
  String get smartWorkspaceErrorTitle => 'مساحة العمل الذكية غير متاحة';

  @override
  String get smartWorkspaceErrorMessage =>
      'تعذّر تحميل مساحة العمل الآن. حاول مرة أخرى بعد قليل.';

  @override
  String get smartWorkspaceRetryAction => 'حاول مرة أخرى';

  @override
  String get smartWorkspaceSalonRequiredTitle => 'الصالون مطلوب';

  @override
  String get smartWorkspaceSalonRequiredMessage =>
      'تحتاج هذه المساحة إلى صالون صالح قبل تحميل أدوات المساعد.';

  @override
  String get smartWorkspaceWelcomeTitle => 'اطلب مساحة عمل موجهة';

  @override
  String get smartWorkspaceWelcomeMessage =>
      'استخدم هذا المساعد لإعداد الرواتب وشرحها وعرض التحليلات وتصحيح الحضور مع إبقاء منطق العمل حتميًا.';

  @override
  String get smartWorkspaceInputLabel => 'اسأل مساحة العمل الذكية';

  @override
  String get smartWorkspaceInputHint =>
      'جرّب: جهّز الرواتب لهذا الشهر، اشرح راتب أحمد، أو اعرض ملخص الرواتب والإيرادات والمصروفات لهذا الشهر.';

  @override
  String get smartWorkspaceSendAction => 'افتح المساحة';

  @override
  String get smartWorkspaceUnknownTitle => 'اختر تدفقًا موجّهًا';

  @override
  String get smartWorkspaceUnknownSummary =>
      'المساعد يدعم فقط تدفقات مساحة العمل المعتمدة.';

  @override
  String get smartWorkspaceUnknownMessage =>
      'اطلب إعداد الرواتب أو شرحها أو التحليلات أو تصحيح الحضور للمتابعة.';

  @override
  String get smartWorkspaceSuggestionPayrollSetup => 'جهّز الرواتب لهذا الشهر';

  @override
  String get smartWorkspaceSuggestionPayrollExplain =>
      'اشرح راتب أحمد لهذا الشهر';

  @override
  String get smartWorkspaceSuggestionAnalytics =>
      'اعرض الرواتب والإيرادات والمصروفات لهذا الشهر';

  @override
  String get smartWorkspaceSuggestionAttendance =>
      'صحّح حضور الحلاق المتأخر اليوم';

  @override
  String get smartWorkspacePayrollSetupTitle => 'مساعد إعداد الرواتب';

  @override
  String get smartWorkspacePayrollSetupSummary =>
      'راجع من هو جاهز للرواتب وافتح شاشة الإعداد المناسبة بسرعة.';

  @override
  String get smartWorkspacePayrollSetupMissingEmployees =>
      'موظفون بدون إعداد راتب أساسي';

  @override
  String smartWorkspacePayrollSetupActiveElements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر رواتب نشط متاح',
      many: '$count عنصر رواتب نشط متاح',
      few: '$count عناصر رواتب نشطة متاحة',
      two: 'عنصران نشطان للرواتب متاحان',
      one: 'عنصر رواتب نشط واحد متاح',
    );
    return '$_temp0';
  }

  @override
  String smartWorkspacePayrollSetupEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قيد رواتب نشط',
      many: '$count قيد رواتب نشط',
      few: '$count قيود رواتب نشطة',
      two: 'قيدان نشطان للرواتب',
      one: 'قيد رواتب نشط واحد',
      zero: 'لا توجد قيود رواتب نشطة',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspacePayrollSetupPickEmployeeTitle => 'اختر موظفًا';

  @override
  String get smartWorkspacePayrollSetupPickEmployeeMessage =>
      'اختر موظفًا لمراجعة قيود الرواتب الحالية وإعداد الراتب.';

  @override
  String get smartWorkspaceEmployeePickerLabel => 'الموظف';

  @override
  String get smartWorkspacePeriodSelectorLabel => 'فترة الرواتب';

  @override
  String get smartWorkspacePeriodPlaceholder => 'اختر شهرًا';

  @override
  String get smartWorkspaceDateRangePickerLabel => 'النطاق الزمني';

  @override
  String get smartWorkspaceDateRangePlaceholder => 'اختر نطاقًا زمنيًا';

  @override
  String get smartWorkspaceOpenEmployeeSetup => 'افتح إعداد الموظف';

  @override
  String get smartWorkspaceOpenPayrollRunReview => 'افتح مراجعة دورة الرواتب';

  @override
  String get smartWorkspaceAddElementTitle => 'إضافة عنصر راتب';

  @override
  String get smartWorkspaceAddElementSummary =>
      'أكّد العنصر المقترح قبل حفظه في كتالوج الرواتب.';

  @override
  String get smartWorkspaceAddElementNeedsDetailsTitle =>
      'نحتاج تفاصيل أكثر للعنصر';

  @override
  String get smartWorkspaceAddElementNeedsDetailsMessage =>
      'أضف الاسم والمبلغ، مثل: أضف بدل نقل شهري بقيمة 150.';

  @override
  String get smartWorkspaceElementClassificationTitle => 'التصنيف';

  @override
  String get smartWorkspaceClassificationEarning => 'استحقاق';

  @override
  String get smartWorkspaceClassificationDeduction => 'خصم';

  @override
  String get smartWorkspaceClassificationInformation => 'معلومة';

  @override
  String get smartWorkspaceElementRecurrenceTitle => 'التكرار';

  @override
  String get smartWorkspaceRecurrenceRecurring => 'متكرر';

  @override
  String get smartWorkspaceRecurrenceNonRecurring => 'مرة واحدة';

  @override
  String get smartWorkspaceElementCalculationTitle => 'طريقة الحساب';

  @override
  String get smartWorkspaceCalculationFixed => 'مبلغ ثابت';

  @override
  String get smartWorkspaceCalculationPercentage => 'نسبة مئوية';

  @override
  String get smartWorkspaceCalculationDerived => 'محسوب';

  @override
  String get smartWorkspaceConfirmationTitle => 'تأكيد';

  @override
  String get smartWorkspaceAddElementConfirmMessage =>
      'سيتم حفظ عنصر رواتب جديد عبر مستودع الرواتب الحالي.';

  @override
  String get smartWorkspaceFieldName => 'الاسم';

  @override
  String get smartWorkspaceFieldAmount => 'المبلغ';

  @override
  String get smartWorkspaceFieldClassification => 'التصنيف';

  @override
  String get smartWorkspaceFieldDate => 'التاريخ';

  @override
  String get smartWorkspaceFieldStatus => 'الحالة';

  @override
  String get smartWorkspaceFieldCheckIn => 'تسجيل الدخول';

  @override
  String get smartWorkspaceFieldCheckOut => 'تسجيل الخروج';

  @override
  String get smartWorkspaceSaveElementAction => 'احفظ عنصر الراتب';

  @override
  String get smartWorkspacePayrollExplanationTitle => 'شرح الراتب';

  @override
  String get smartWorkspacePayrollExplanationSummary =>
      'اعرض تفاصيل الاستحقاقات والخصومات باستخدام خدمة حساب الرواتب الحالية.';

  @override
  String get smartWorkspaceNetPayTitle => 'صافي الراتب';

  @override
  String get smartWorkspacePayrollPreviewStatus =>
      'معاينة مبنية على قواعد الرواتب الحالية';

  @override
  String get smartWorkspaceEarningsBreakdownTitle => 'تفصيل الاستحقاقات';

  @override
  String get smartWorkspaceDeductionsBreakdownTitle => 'تفصيل الخصومات';

  @override
  String get smartWorkspaceOpenQuickPayAction => 'افتح الدفع السريع';

  @override
  String get smartWorkspaceAnalyticsTitle => 'مساعد التحليلات الديناميكي';

  @override
  String get smartWorkspaceRevenueTitle => 'الإيرادات';

  @override
  String smartWorkspaceTransactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية مكتملة',
      many: '$count عملية مكتملة',
      few: '$count عمليات مكتملة',
      two: 'عمليتان مكتملتان',
      one: 'عملية مكتملة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspaceExpensesTitle => 'المصروفات';

  @override
  String get smartWorkspacePayrollTitle => 'الرواتب';

  @override
  String smartWorkspaceDraftPayrollRuns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دورة رواتب مسودة',
      many: '$count دورة رواتب مسودة',
      few: '$count دورات رواتب مسودة',
      two: 'دورتا رواتب مسودتان',
      one: 'دورة رواتب مسودة واحدة',
      zero: 'لا توجد دورات رواتب مسودة',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspaceNetResultTitle => 'النتيجة الصافية';

  @override
  String get smartWorkspaceChartTitle => 'اتجاه الأشهر الأخيرة';

  @override
  String get smartWorkspaceChartSubtitle =>
      'يتم عرض الإيرادات بنفس سياق الفترة الذي يستخدمه المساعد.';

  @override
  String get smartWorkspaceOpenSalesAction => 'افتح المبيعات';

  @override
  String get smartWorkspaceOpenExpensesAction => 'افتح المصروفات';

  @override
  String get smartWorkspaceOpenPayrollAction => 'افتح الرواتب';

  @override
  String get smartWorkspaceAttendanceCorrectionTitle => 'مساعد تصحيح الحضور';

  @override
  String get smartWorkspaceAttendanceCorrectionSummary =>
      'راجع السجلات الجاهزة للتصحيح وأكّد التعديلات المعتمدة عبر مستودع الحضور الحالي.';

  @override
  String get smartWorkspaceAttendancePendingTitle => 'طلبات الحضور المعلّقة';

  @override
  String smartWorkspaceAttendanceCorrectionsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سجل يحتاج تصحيحًا',
      many: '$count سجلًا يحتاج تصحيحًا',
      few: '$count سجلات تحتاج تصحيحًا',
      two: 'سجلان يحتاجان تصحيحًا',
      one: 'سجل واحد يحتاج تصحيحًا',
      zero: 'لا توجد سجلات تحتاج تصحيحًا',
    );
    return '$_temp0';
  }

  @override
  String get smartWorkspaceAttendanceNoRecordTitle =>
      'لم يتم العثور على سجل مناسب للتصحيح';

  @override
  String get smartWorkspaceAttendanceNoRecordMessage =>
      'عدّل الموظف أو النطاق الزمني للعثور على طلب الحضور الذي تريد مراجعته.';

  @override
  String smartWorkspaceAttendanceRecordSummary(String status) {
    return 'حالة الحضور: $status';
  }

  @override
  String get smartWorkspaceAttendanceConfirmMessage =>
      'راجع تفاصيل التصحيح قبل تطبيق التحديث المعتمد.';

  @override
  String get smartWorkspaceAttendancePromptForDetails =>
      'أضف الحالة أو الوقت المطلوب تعديله في طلبك لتحضير التصحيح.';

  @override
  String get smartWorkspaceApplyAttendanceAction => 'طبّق التصحيح';

  @override
  String get smartWorkspaceOpenAttendanceReviewAction => 'افتح مراجعة الحضور';

  @override
  String get ownerTooltipCycleTheme => 'تبديل المظهر (النظام / فاتح / داكن)';

  @override
  String get ownerTooltipCycleThemeShort => 'تبديل المظهر';

  @override
  String get ownerTooltipLanguage => 'تبديل اللغة (English / العربية)';

  @override
  String get ownerTooltipLanguageShort => 'اللغة';

  @override
  String get ownerTooltipSignOut => 'تسجيل الخروج';

  @override
  String get customerCategoryAll => 'الكل';

  @override
  String get customerMyBookings => 'حجوزاتي';

  @override
  String get customerMyBookingsSubtitle => 'زياراتك القادمة والسابقة';

  @override
  String get customerMyBookingsEmpty =>
      'لا توجد حجوزات بعد. استكشف صالونًا واحجز موعدًا.';

  @override
  String get bookingNotes => 'ملاحظات';

  @override
  String get bookingDuration => 'المدة';

  @override
  String bookingDurationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get bookingStatus => 'الحالة';

  @override
  String get bookingStatusPending => 'قيد الانتظار';

  @override
  String get bookingStatusConfirmed => 'مؤكد';

  @override
  String get bookingStatusCompleted => 'مكتمل';

  @override
  String get bookingStatusCancelled => 'ملغى';

  @override
  String get bookingStatusNoShow => 'لم يحضر';

  @override
  String get bookingStatusRescheduled => 'أعيد جدولته';

  @override
  String get barberSummaryTitle => 'اليوم';

  @override
  String barberSummaryAppointments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موعد',
      many: '$count موعدًا',
      few: '$count مواعيد',
      two: 'موعدان',
      one: 'موعد واحد',
      zero: 'لا مواعيد',
    );
    return '$_temp0';
  }

  @override
  String get barberNextAppointment => 'التالي';

  @override
  String get barberNextNone => 'لا مواعيد أخرى اليوم';

  @override
  String get barberEarningsMonth => 'هذا الشهر';

  @override
  String get barberQuickSale => 'بيع سريع';

  @override
  String get barberAttendanceCardTitle => 'الحضور';

  @override
  String get barberAttendanceIn => 'تم تسجيل الدخول';

  @override
  String get barberAttendanceOut => 'تم تسجيل الخروج';

  @override
  String get barberAttendanceNone => 'لم يُسجَّل الدخول بعد';

  @override
  String get customerSectionBarbers => 'الفريق';

  @override
  String get customerBarberCardCta => 'احجز +';

  @override
  String get customerBarberVerifiedTooltip => 'حلاق معتمد من الصالون';

  @override
  String get customerNoBarbersDetail =>
      'لا يوجد حلاقون مدرجون لهذا الصالون بعد.';

  @override
  String get barberTabToday => 'اليوم';

  @override
  String get barberTabSale => 'بيع';

  @override
  String get barberTabAttendance => 'الحضور';

  @override
  String get barberTodayTitle => 'جدول اليوم';

  @override
  String get barberTodaySubtitle => 'مواعيدك.';

  @override
  String get barberNoEmployee =>
      'ملفك لا يحتوي ربطًا بالفريق. تواصل مع المالك.';

  @override
  String get barberRecordSaleTitle => 'تسجيل بيع';

  @override
  String get barberSaleService => 'الخدمة';

  @override
  String get barberSalePayment => 'الدفع';

  @override
  String get barberSaleSubmit => 'حفظ البيع';

  @override
  String get barberSaleSuccess => 'تم تسجيل البيع';

  @override
  String get barberAttendanceTitle => 'الحضور';

  @override
  String get barberAttendanceSubtitle => 'تسجيلات اليوم.';

  @override
  String get barberCheckIn => 'تسجيل دخول';

  @override
  String get barberCheckOut => 'تسجيل خروج';

  @override
  String get barberNoAttendance => 'لا سجلات حضور لليوم.';

  @override
  String get ownerMoneyPeriodToday => 'اليوم';

  @override
  String get ownerMoneyPeriodMonth => 'هذا الشهر';

  @override
  String get ownerMoneyPeriodCustomSoon => 'مخصص (قريبًا)';

  @override
  String get ownerMoneyTotalSales => 'إجمالي المبيعات';

  @override
  String get ownerMoneyTotalPayroll => 'إجمالي الرواتب';

  @override
  String get ownerMoneyTotalExpenses => 'إجمالي المصروفات';

  @override
  String get ownerMoneyNetResult => 'صافي النتيجة';

  @override
  String get ownerBookingsLoadMore => 'تحميل المزيد';

  @override
  String get ownerBookingsLoadingMore => 'جارٍ التحميل…';

  @override
  String get ownerBookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get ownerBookingSaveNotes => 'حفظ الملاحظات';

  @override
  String get ownerBookingNotesSaved => 'تم حفظ الملاحظات';

  @override
  String get ownerBookingNewTitle => 'حجز جديد';

  @override
  String get ownerBookingCustomerUid => 'معرّف المستخدم للعميل';

  @override
  String get ownerBookingCustomerUidHint =>
      'الصق معرّف Firebase Auth للعميل (من ملفه).';

  @override
  String get ownerBookingCustomerUidInvalid => 'معرّف المستخدم للعميل مطلوب.';

  @override
  String get ownerBookingCustomerNameOptional => 'اسم العميل (اختياري)';

  @override
  String get ownerBookingCreate => 'إنشاء الحجز';

  @override
  String get ownerBookingCreated => 'تم إنشاء الحجز';

  @override
  String get ownerBookingRescheduled => 'تمت إعادة جدولة الحجز';

  @override
  String get ownerHrSettingsTitle => 'الموارد البشرية والمخالفات';

  @override
  String get ownerHrSettingsSubtitle =>
      'إدارة غرامات الموظفين وقواعد الحضور وطلبات المراجعة.';

  @override
  String get ownerSettingsHrTileTitle => 'الموارد البشرية والمخالفات';

  @override
  String get ownerSettingsHrTileSubtitle =>
      'قواعد الغرامات وسياسات الحضور وقائمة المراجعة';

  @override
  String get salonAttendanceZoneTitle => 'منطقة الحضور';

  @override
  String get salonAttendanceZoneSubtitle => 'حدد مكان تسجيل دخول وخروج فريقك.';

  @override
  String get salonAttendanceZoneMapSectionTitle => 'الخريطة';

  @override
  String get salonAttendanceZoneMapTapHint =>
      'اضغط على الخريطة لنقل مركز المنطقة.';

  @override
  String get salonAttendanceZoneMapWebHint =>
      'استخدم تطبيق الجوال لاختيار المنطقة على الخريطة.';

  @override
  String get salonAttendanceZoneMapCenterMarker => 'مركز المنطقة';

  @override
  String salonAttendanceZoneCoordinates(String lat, String lng) {
    return 'دائرة العرض $lat، خط الطول $lng';
  }

  @override
  String salonAttendanceZonePunchRadiusMeters(int meters) {
    return 'نصف قطر تسجيل الحضور المسموح: $meters مترًا';
  }

  @override
  String salonAttendanceZoneMetersShort(int meters) {
    return '$meters م';
  }

  @override
  String get salonAttendanceZoneEnable => 'تفعيل الحضور';

  @override
  String get salonAttendanceZoneRequireInPunchIn =>
      'الاشتراط على التواجد داخل المنطقة عند تسجيل الدخول';

  @override
  String get salonAttendanceZoneRequireInPunchOut =>
      'الاشتراط على التواجد داخل المنطقة عند تسجيل الخروج';

  @override
  String get salonAttendanceZoneAllowBreaks => 'السماح بفترات الاستراحة';

  @override
  String get salonAttendanceZoneAllowCorrections =>
      'السماح بطلبات تصحيح الحضور';

  @override
  String get salonAttendanceZoneSave => 'حفظ';

  @override
  String get salonAttendanceZoneSaved => 'تم حفظ إعدادات الحضور';

  @override
  String get salonAttendanceZoneSaveFailed => 'تعذّر الحفظ';

  @override
  String get ownerAttendanceSettingsTitle => 'إعدادات الحضور';

  @override
  String get ownerAttendanceSettingsSubtitle =>
      'إدارة المنطقة، البصمات، الاستراحات، طلبات التصحيح وقواعد الموارد البشرية';

  @override
  String get ownerAttendanceSettingsStatusActive => 'مفعّل';

  @override
  String get ownerAttendanceSettingsStatusLocationMissing => 'الموقع غير محدّد';

  @override
  String get ownerAttendanceSectionZone => 'منطقة الحضور';

  @override
  String get ownerAttendanceSectionPunchRules => 'قواعد البصمة';

  @override
  String get ownerAttendanceSectionGrace => 'السماح وأوقات العمل';

  @override
  String get ownerAttendanceSectionCorrection => 'طلبات التصحيح';

  @override
  String get ownerAttendanceSectionViolations => 'قواعد المخالفات';

  @override
  String get ownerAttendanceZoneMapPickAction => 'اختيار موقع الصالون';

  @override
  String get ownerAttendanceZoneCoordinatesEmpty =>
      'اضغط على الخريطة لتحديد موقع الصالون.';

  @override
  String get ownerAttendanceZoneRadiusLabel => 'نطاق البصمة';

  @override
  String get ownerAttendanceZoneLocationRequired =>
      'يجب وجود الموظف داخل الموقع';

  @override
  String get ownerAttendanceZoneLocationRequiredHint =>
      'يلزم وجود الموظف داخل المنطقة لتسجيل الدخول أو الخروج.';

  @override
  String get ownerAttendanceRulesAttendanceRequired => 'الحضور إلزامي';

  @override
  String get ownerAttendanceRulesAttendanceRequiredHint =>
      'يجب على الموظفين تسجيل اليوم قبل العمل.';

  @override
  String get ownerAttendanceRulesPunchInRequired => 'بصمة الدخول إلزامية';

  @override
  String get ownerAttendanceRulesPunchOutRequired => 'بصمة الخروج إلزامية';

  @override
  String get ownerAttendanceRulesBreaksEnabled => 'السماح بفترات الاستراحة';

  @override
  String get ownerAttendanceRulesMaxPunchesLabel =>
      'الحد الأقصى للبصمات يوميًا';

  @override
  String get ownerAttendanceRulesMaxBreaksLabel =>
      'الحد الأقصى للاستراحات يوميًا';

  @override
  String get ownerAttendanceGraceLateLabel => 'سماح التأخير (دقائق)';

  @override
  String get ownerAttendanceGraceEarlyExitLabel =>
      'سماح الانصراف المبكر (دقائق)';

  @override
  String get ownerAttendanceGraceMinShiftLabel => 'أقل دوام (دقائق)';

  @override
  String get ownerAttendanceGraceMaxShiftLabel => 'أقصى دوام (دقائق)';

  @override
  String get ownerAttendanceCorrectionEnabled => 'تفعيل طلبات التصحيح';

  @override
  String get ownerAttendanceCorrectionRequireReason => 'إلزام كتابة السبب';

  @override
  String get ownerAttendanceCorrectionRequireApproval =>
      'اشتراط موافقة المالك/المسؤول';

  @override
  String get ownerAttendanceCorrectionMaxPerMonth =>
      'الحد الأقصى لطلبات التصحيح شهريًا';

  @override
  String get ownerAttendanceViolationsAuto => 'إنشاء المخالفات تلقائيًا';

  @override
  String get ownerAttendanceViolationsAutoHint =>
      'إنشاء مخالفات الرواتب تلقائيًا عند تجاوز الحدود.';

  @override
  String get ownerAttendanceViolationsMissingCheckoutPercent =>
      'خصم بصمة الخروج المفقودة (%)';

  @override
  String get ownerAttendanceViolationsAbsencePercent => 'خصم الغياب (%)';

  @override
  String get ownerAttendanceViolationsLatePercent => 'خصم التأخير (%)';

  @override
  String get ownerAttendanceViolationsEarlyExitPercent =>
      'خصم الانصراف المبكر (%)';

  @override
  String get ownerAttendanceViolationsLateAllowance =>
      'عدد التأخيرات المسموح بها شهريًا';

  @override
  String get ownerAttendanceViolationsEarlyExitAllowance =>
      'عدد الانصرافات المبكرة المسموح بها شهريًا';

  @override
  String get ownerAttendanceViolationsMissingCheckoutAllowance =>
      'عدد بصمات الخروج المفقودة المسموح بها شهريًا';

  @override
  String get ownerAttendanceSettingsSave => 'حفظ التغييرات';

  @override
  String get ownerAttendanceSettingsSaved => 'تم تحديث إعدادات الحضور';

  @override
  String get ownerAttendanceSettingsSaveFailed => 'تعذّر حفظ إعدادات الحضور';

  @override
  String get ownerAttendanceSettingsValidationLocationMissing =>
      'حدد موقع الصالون قبل الحفظ.';

  @override
  String get ownerAttendanceSettingsValidationRadius =>
      'يجب أن يكون النطاق بين 10 و 500 متر.';

  @override
  String get ownerAttendanceSettingsValidationMaxPunches =>
      'يجب أن يكون الحد الأقصى للبصمات بين 2 و 10.';

  @override
  String get ownerAttendanceSettingsValidationMaxBreaks =>
      'يجب أن يكون الحد الأقصى للاستراحات بين 0 و 5.';

  @override
  String get ownerAttendanceSettingsValidationGraceLate =>
      'يجب أن يكون سماح التأخير بين 0 و 120 دقيقة.';

  @override
  String get ownerAttendanceSettingsValidationGraceEarly =>
      'يجب أن يكون سماح الانصراف المبكر بين 0 و 120 دقيقة.';

  @override
  String get ownerAttendanceSettingsValidationMinShift =>
      'يجب أن يكون أقل دوام أكبر من صفر.';

  @override
  String get ownerAttendanceSettingsValidationMaxShift =>
      'يجب أن يكون أقصى دوام أكبر من أقل دوام.';

  @override
  String get ownerAttendanceSettingsValidationDeduction =>
      'يجب أن تكون نسب الخصم بين 0 و 100.';

  @override
  String get ownerAttendanceSettingsValidationAllowance =>
      'يجب أن تكون الأعداد المسموح بها صفرًا أو أكبر.';

  @override
  String get ownerMoneySalesSection => 'المبيعات';

  @override
  String get ownerMoneySalesEmptyTitle => 'لا مبيعات';

  @override
  String get ownerMoneyEmptySales => 'لا مبيعات في هذه الفترة بعد.';

  @override
  String get ownerAddSaleTitle => 'إضافة بيع';

  @override
  String get ownerAddSaleSubtitle =>
      'سجّل بيعًا سريعًا من الزائر أو من الكاشير.';

  @override
  String get ownerAddSaleServiceField => 'الخدمة';

  @override
  String get ownerAddSaleBarberField => 'مقدم الخدمة';

  @override
  String get ownerAddSalePriceLabel => 'السعر';

  @override
  String get ownerAddSalePriceHint => 'اختر خدمة لعرض السعر.';

  @override
  String get ownerAddSaleCustomerHint => 'اسم العميل (اختياري)';

  @override
  String get ownerAddSaleSave => 'حفظ البيع';

  @override
  String get ownerAddSaleSuccess => 'تم حفظ البيع';

  @override
  String get ownerAddSaleValidation =>
      'اختر خدمة واحدة على الأقل ومقدم خدمة وطريقة دفع.';

  @override
  String get ownerAddSaleOpen => 'إضافة بيع';

  @override
  String get ownerAddSaleNoStaff => 'أضف أعضاء الفريق قبل تسجيل المبيعات.';

  @override
  String get ownerServiceCategory => 'التصنيف (اختياري)';

  @override
  String get ownerServiceActiveLabel => 'الخدمة نشطة';

  @override
  String get ownerServiceInactiveBadge => 'غير نشطة';

  @override
  String get roleOwner => 'مالك';

  @override
  String get roleAdmin => 'مسؤول';

  @override
  String get adminConsoleTitle => 'لوحة المسؤول';

  @override
  String get adminWorkspaceSubtitle =>
      'إدارة الموظفين والسياسات وتشغيل الصالون.';

  @override
  String adminSalonIdLine(String salonId) {
    return 'معرّف الصالون: $salonId';
  }

  @override
  String get adminSalonNotLinked => 'لا يوجد صالون مرتبط';

  @override
  String get roleBarber => 'عضو فريق';

  @override
  String get roleCustomer => 'عميل';

  @override
  String get paymentMethodCash => 'نقدًا';

  @override
  String get paymentMethodCard => 'بطاقة';

  @override
  String get paymentMethodDigitalWallet => 'محفظة رقمية';

  @override
  String get paymentMethodOther => 'أخرى';

  @override
  String get payrollStatusDraft => 'مسودة';

  @override
  String get payrollStatusPendingApproval => 'بانتظار الموافقة';

  @override
  String get payrollStatusApproved => 'معتمد';

  @override
  String get payrollStatusPaid => 'مدفوع';

  @override
  String get payrollStatusVoided => 'ملغى';

  @override
  String get customerBookingsUpcoming => 'القادمة';

  @override
  String get customerBookingsPast => 'السابقة';

  @override
  String get customerBookingsUpcomingEmpty => 'لا زيارات قادمة.';

  @override
  String get customerBookingsPastEmpty => 'لا زيارات سابقة بعد.';

  @override
  String get customerBookingCancel => 'إلغاء';

  @override
  String get customerBookingReschedule => 'إعادة جدولة';

  @override
  String get customerBookingCancelledToast => 'تم إلغاء الحجز';

  @override
  String get customerBookingRescheduledToast => 'تم تحديث الحجز';

  @override
  String get customerBookingActionUnavailable =>
      'لا يمكن تنفيذ هذا الإجراء لهذا الحجز.';

  @override
  String get customerRescheduleTitle => 'إعادة جدولة الحجز';

  @override
  String get customerRescheduleSubmit => 'حفظ الوقت الجديد';

  @override
  String get customerMyBookingsLoading => 'جارٍ تحميل حجوزاتك…';

  @override
  String get listLoadMore => 'تحميل المزيد';

  @override
  String get bookingOpMarkArrived => 'وصول العميل';

  @override
  String get bookingOpStartService => 'بدء الخدمة';

  @override
  String get bookingOpComplete => 'إكمال';

  @override
  String get bookingOpNoShowCustomer => 'عدم حضور (عميل)';

  @override
  String get bookingOpNoShowBarber => 'عدم حضور (حلاق)';

  @override
  String get ownerViolationsTitle => 'المخالفات والغرامات';

  @override
  String get ownerViolationsSubtitle =>
      'اعتماد الخصومات قبل تطبيقها على الرواتب.';

  @override
  String get ownerViolationsEmpty => 'لا مخالفات معلّقة.';

  @override
  String get ownerViolationBooking => 'الحجز';

  @override
  String get ownerViolationAmount => 'المبلغ';

  @override
  String get ownerViolationApprove => 'اعتماد';

  @override
  String get ownerViolationReject => 'رفض';

  @override
  String get ownerViolationReviewSaved => 'تم تحديث المخالفة';

  @override
  String get ownerPenaltySettingsTitle => 'قواعد الغرامات';

  @override
  String get ownerPenaltySettingsSaved => 'تم حفظ إعدادات الغرامات';

  @override
  String get ownerPenaltyLateEnabled => 'غرامات تأخر الموظفين';

  @override
  String get ownerPenaltyGraceMinutes => 'فترة السماح (دقائق)';

  @override
  String get ownerPenaltyCalcFlat => 'مبلغ ثابت';

  @override
  String get ownerPenaltyCalcPercent => 'نسبة من الإجمالي';

  @override
  String get ownerPenaltyCalcPerMinute => 'لكل دقيقة بعد السماح';

  @override
  String get ownerPenaltyLateValue => 'قيمة غرامة التأخر';

  @override
  String get ownerPenaltyNoShowEnabled => 'غرامات عدم حضور الموظفين';

  @override
  String get ownerPenaltyNoShowValue => 'قيمة غرامة عدم الحضور';

  @override
  String get ownerViolationsMetricPending => 'مخالفات قيد المراجعة';

  @override
  String get ownerViolationsMetricRulesOn => 'قواعد نشطة';

  @override
  String get ownerPenaltyAppliesWhenLabel => 'تُطبّق الغرامة عند';

  @override
  String get ownerPenaltyLateWhenBody =>
      'تسجيل عضو الطاقم حضورًا متأخرًا بعد فترة السماح';

  @override
  String get ownerPenaltyNoShowWhenBody => 'تفويت عضو الطاقم للموعد';

  @override
  String get ownerPenaltyMetricCalculation => 'طريقة الاحتساب';

  @override
  String get ownerKpiNoShowToday => 'عدم حضور اليوم';

  @override
  String get ownerKpiNoShowRateMonth => 'معدل عدم الحضور (الشهر)';

  @override
  String get ownerKpiPenaltyMonth => 'الغرامات (الشهر)';

  @override
  String get ownerKpiTopPenalizedBarber => 'الأكثر غرامات (الشهر)';

  @override
  String get payrollDeductionViolations => 'الخصومات';

  @override
  String get payrollStatusRolledBack => 'تم التراجع';

  @override
  String get payrollBadgeRecurring => 'متكرر';

  @override
  String get payrollBadgeNonRecurring => 'مرة واحدة';

  @override
  String payrollLineQuantity(String value) {
    return 'الكمية $value';
  }

  @override
  String payrollLineRate(String value) {
    return 'المعدل $value';
  }

  @override
  String get payrollGenericError => 'تعذّر تحميل بيانات الرواتب الآن.';

  @override
  String get payrollEmployeeAlreadyPaidForPeriod =>
      'هذا العضو لديه بالفعل راتب مدفوع لهذه الفترة.';

  @override
  String get payrollAllStaffAlreadyPaidForPeriod =>
      'جميع الأشخاص في قائمتك لديهم بالفعل راتب مدفوع لهذه الفترة.';

  @override
  String get payrollSummaryEarnings => 'الاستحقاقات';

  @override
  String get payrollSummaryDeductions => 'الخصومات';

  @override
  String get payrollSummaryNetPay => 'صافي الراتب';

  @override
  String get payrollSectionEarnings => 'بنود الاستحقاقات';

  @override
  String get payrollSectionDeductions => 'بنود الخصومات';

  @override
  String get payrollSectionInformation => 'بنود المعلومات';

  @override
  String get payrollSectionEmpty => 'لا توجد بنود في هذا القسم.';

  @override
  String get payrollDashboardTitle => 'الرواتب';

  @override
  String payrollDashboardSubtitle(String monthLabel) {
    return 'نظرة عامة على محرك رواتب $monthLabel.';
  }

  @override
  String get ownerPayrollFinanceBreadcrumb => 'المالية · الرواتب';

  @override
  String get ownerPayrollRunReviewBreadcrumb =>
      'المالية · الرواتب · مراجعة التشغيل';

  @override
  String get payrollRunReviewEngineHint =>
      'يشمل العمولات من المبيعات، والحضور، والمخالفات، وعناصر الرواتب لديك.';

  @override
  String get payrollRunReviewConfigureSectionTitle => 'الفترة والفريق';

  @override
  String get payrollRunReviewCadenceLabel => 'نوع فترة الرواتب';

  @override
  String get payrollRunReviewCadenceMonthly => 'شهري';

  @override
  String get payrollRunReviewCadenceWeekly => 'أسبوعي';

  @override
  String get payrollRunWeeklyPaidDaysHint =>
      'يُحتسب الراتب فقط للأيام التقويمية التي تختارها (شاملة البداية والنهاية).';

  @override
  String get payrollRunWeeklyStartLabel => 'تاريخ البداية';

  @override
  String get payrollRunWeeklyEndLabel => 'تاريخ النهاية';

  @override
  String get payrollRunWeeklyRangeInvalid =>
      'اختر فترة أسبوعية صالحة (1–31 يومًا، والنهاية في أو بعد البداية).';

  @override
  String get payrollRunNoMatchingStaffForCadence =>
      'لا يوجد أعضاء فريق يستخدمون فترة الرواتب هذه. عيّن شهريًا أو أسبوعيًا من الفريق → فترة الرواتب، أو غيّر نوع الفترة أعلاه.';

  @override
  String get payrollRunReviewViewPayslip => 'عرض قسيمة الراتب';

  @override
  String get payrollRollbackConfirmTitle => 'تراجع عن تشغيل الرواتب هذا؟';

  @override
  String get payrollRollbackConfirmMessage =>
      'سيؤدي ذلك إلى عكس لقطات قسائم الرواتب والتعديلات المرتبطة بهذا التشغيل. إذا كان التشغيل مدفوعاً، تُزال القسائم من تطبيق الموظفين—تأكد أن ذلك يطابق سجلاتك المصرفية والمحاسبية. المتابعة؟';

  @override
  String get payrollRollbackConfirmAction => 'تراجع';

  @override
  String get payrollRunReviewStatusPaidHint =>
      'تشغيل مدفوع. استخدم التراجع أدناه فقط عند الحاجة لعكس المدفوعات—تختفي القسائم من تطبيق الموظفين وتُعاد المخالفات المرتبطة حيث ينطبق ذلك.';

  @override
  String get payrollRunReviewStatusRolledBackHint =>
      'تم التراجع عن هذا التشغيل. يمكنك إعادة الاحتساب عند الجاهزية.';

  @override
  String get payrollRunReviewKpiHeadcountTrend => 'في هذا التشغيل';

  @override
  String get payrollRunReviewWorkflowTitle => 'الخطوات التالية';

  @override
  String get payrollRunReviewWorkflowSubtitle =>
      'اعتمِد عند الجاهزية، ثم علّق كمدفوع بعد التحويل.';

  @override
  String get payrollRunReviewTeamPreviewTitle => 'تفصيل الفريق';

  @override
  String get payrollDashboardKpiTrendLabel => 'هذا الشهر';

  @override
  String get payrollDashboardKpiThisWeek => 'هذا الأسبوع';

  @override
  String get payrollDashboardKpiRunsLabel => 'تشغيلات الرواتب';

  @override
  String get payrollDashboardKpiRunsHint => 'عدد التشغيلات في هذا الشهر';

  @override
  String get payrollDashboardKpiRunsHintWeek =>
      'عدد التشغيلات في أسبوع ISO المحدد';

  @override
  String payrollDashboardSubtitleWeek(String weekLabel) {
    return 'نظرة عامة على الرواتب لـ $weekLabel.';
  }

  @override
  String payrollIsoWeekShortLabel(int weekYear, String weekNumberPadded) {
    return '$weekYear-W$weekNumberPadded';
  }

  @override
  String get payrollWeekPickerHelp => 'اختر أي يوم داخل أسبوع الرواتب';

  @override
  String get payrollStatusBreakdownSubtitleWeek => 'الأعداد لأسبوع ISO المحدد.';

  @override
  String get payrollRecentRunsSectionSubtitleWeek =>
      'عمليات الرواتب المُنجَزة في أسبوع ISO المحدد.';

  @override
  String get settingsPayrollCadenceTitle => 'فترة الرواتب';

  @override
  String get settingsPayrollCadenceSubtitle =>
      'التقويم الافتراضي لتشغيلات الرواتب والدفع السريع ومركز الرواتب.';

  @override
  String get settingsPayrollCadenceSave => 'حفظ';

  @override
  String get settingsPayrollCadenceSaved => 'تم تحديث فترة الرواتب';

  @override
  String get settingsPayrollCadenceMonthly => 'شهري';

  @override
  String get settingsPayrollCadenceWeekly => 'أسبوعي (أسابيع ISO)';

  @override
  String get teamPayrollPeriodLabel => 'فترة الرواتب';

  @override
  String get teamPayrollPeriodHint =>
      'تبدأ من إعداد فترة الرواتب في الصالون. غيّرها فقط إذا كان يجب أن يستخدم هذا الشخص الإيقاع الآخر.';

  @override
  String get teamPayrollPeriodInherit => 'نفس إعداد الصالون';

  @override
  String teamPayrollPeriodInheritDetail(String periodLabel) {
    return 'مثل الصالون · $periodLabel';
  }

  @override
  String get teamPayrollPeriodMonthly => 'شهري';

  @override
  String get teamPayrollPeriodWeekly => 'أسبوعي (أسابيع ISO)';

  @override
  String get payrollRecentRunsSectionSubtitle =>
      'عمليات الرواتب المُنجَزة في الشهر المحدد.';

  @override
  String get payrollStatusBreakdownSubtitle => 'الأعداد للشهر المحدد.';

  @override
  String get payrollQuickPayTitle => 'الدفع السريع';

  @override
  String get payrollQuickPayScreenSubtitle =>
      'اختر من تدفع له وأي شهر. احسب ثم احفظ كمسودة أو اعتمد أو سجّل كمدفوع—نفس مسار تشغيلات الرواتب.';

  @override
  String get payrollQuickPayShortcutSubtitle =>
      'اختر الموظف والشهر واحسب ثم ادفع لهذه الفترة.';

  @override
  String get payrollQuickPaySetupCardTitle => 'الفترة والموظف';

  @override
  String get payrollQuickPayStaffSheetTitle => 'اختر الموظف';

  @override
  String get payrollQuickPayStaffPickerLabel => 'عضو الفريق';

  @override
  String get payrollQuickPayStaffEmpty => 'لا يوجد موظفون مؤهلون للرواتب.';

  @override
  String get payrollQuickPayStatementCardTitle => 'كشف الدفع';

  @override
  String get payrollQuickPayRunStatusLabel => 'حالة التشغيل';

  @override
  String get payrollQuickPaySearchHint => 'ابحث بالاسم';

  @override
  String get payrollQuickPaySearchEmpty => 'لا يوجد تطابق.';

  @override
  String get payrollRunReviewTitle => 'مراجعة تشغيل الرواتب';

  @override
  String get payrollRunShortcutSubtitle => 'راجع تشغيل رواتب شهري لعدة موظفين.';

  @override
  String get payrollStatusBreakdownTitle => 'توزيع الحالات';

  @override
  String get payrollRecentRunsTitle => 'آخر تشغيلات الرواتب';

  @override
  String get payrollRecentRunsEmpty => 'ستظهر هنا آخر أنشطة الرواتب.';

  @override
  String payrollRunGroupLabel(int count) {
    return '$count موظف';
  }

  @override
  String get payrollMissingSetupTitle => 'موظفون بدون إعداد رواتب';

  @override
  String get payrollMissingSetupEmpty =>
      'كل الموظفين النشطين لديهم إعداد رواتب متكرر.';

  @override
  String get payrollDashboardSetupCardTitle => 'إعداد الرواتب';

  @override
  String get payrollSetupEveryoneReadyHeading => 'الفريق جاهز للرواتب';

  @override
  String get payrollSetupNeedsAttentionSubtitle =>
      'أضِف على الأقل بندًا متكرّرًا لـ\"راتب أساسي\" لكل زميل بالأسفل (يفتح إعداد رواتبه).';

  @override
  String get payrollSetupWhereToConfigureTitle => 'أين تُضبَط الإعدادات';

  @override
  String get payrollSetupShortcutCatalogTitle => 'كتالوج الرواتب';

  @override
  String get payrollSetupShortcutCatalogSubtitle =>
      'إضافة الافتراضيات وقواعد الاستحقاق والخصومات';

  @override
  String get payrollSetupShortcutTeamTitle => 'الفريق';

  @override
  String get payrollSetupShortcutTeamSubtitle =>
      'من ملفّ الحلّاق ثم قسم الرواتب لإضافة بنود الراتب';

  @override
  String get payrollActionSetUp => 'إعداد';

  @override
  String get payrollElementsTitle => 'عناصر الرواتب';

  @override
  String get payrollElementsSeedDefaults => 'إضافة العناصر الافتراضية';

  @override
  String get payrollElementsAdd => 'إضافة عنصر';

  @override
  String get payrollElementsEmptyTitle => 'لا توجد عناصر رواتب بعد';

  @override
  String get payrollElementsEmptySubtitle =>
      'أضف عناصر الاستحقاقات والخصومات والمعلومات الافتراضية لبدء بناء الرواتب.';

  @override
  String get payrollElementsSystemTag => 'نظامي';

  @override
  String get payrollFieldCode => 'الرمز';

  @override
  String get payrollFieldName => 'الاسم';

  @override
  String get payrollFieldClassification => 'التصنيف';

  @override
  String get payrollFieldRecurrence => 'التكرار';

  @override
  String get payrollFieldCalculationMethod => 'طريقة الاحتساب';

  @override
  String get payrollFieldDefaultAmount => 'المبلغ الافتراضي';

  @override
  String get payrollFieldVisibleOnPayslip => 'يظهر في قسيمة الراتب';

  @override
  String get payrollFieldAffectsNetPay => 'يؤثر على صافي الراتب';

  @override
  String get payrollFieldElement => 'العنصر';

  @override
  String get payrollFieldAmount => 'المبلغ';

  @override
  String get payrollFieldPercentageOptional => 'النسبة (اختياري)';

  @override
  String get payrollFieldNote => 'ملاحظة';

  @override
  String get payrollFieldEmployee => 'الموظف';

  @override
  String get payrollFieldPayrollPeriod => 'فترة الرواتب';

  @override
  String get payrollClassificationEarning => 'استحقاق';

  @override
  String get payrollClassificationDeduction => 'خصم';

  @override
  String get payrollClassificationInformation => 'معلومة';

  @override
  String get payrollCalculationFixed => 'ثابت';

  @override
  String get payrollCalculationPercentage => 'نسبة';

  @override
  String get payrollCalculationDerived => 'مشتق';

  @override
  String get payrollActionSave => 'حفظ';

  @override
  String get payrollActionCalculate => 'احتساب';

  @override
  String get payrollActionSaveDraft => 'حفظ كمسودة';

  @override
  String get payrollActionApprove => 'اعتماد';

  @override
  String get payrollActionPay => 'دفع';

  @override
  String get payrollActionRollback => 'تراجع';

  @override
  String get payrollReversalTitle => 'عكس الرواتب';

  @override
  String get payrollReversalShortcutSubtitle =>
      'اختر تشغيلاً، ثم عكس التشغيل بالكامل أو موظفاً واحداً.';

  @override
  String get payrollReversalScreenTitle => 'عكس تشغيل رواتب';

  @override
  String get payrollReversalScreenSubtitle =>
      'اختر مسودة أو معتمداً أو مدفوعاً. التشغيلات المدفوعة تزيل قسائم الراتب من تطبيق الموظفين—راجع بعناية.';

  @override
  String get payrollReversalScopeWholeRun => 'التشغيل بالكامل';

  @override
  String get payrollReversalScopeOneMember => 'موظف واحد';

  @override
  String get payrollReversalSelectRunHint => 'اختر تشغيل الرواتب';

  @override
  String get payrollReversalSelectMemberHint => 'اختر موظفاً';

  @override
  String get payrollReversalNoRunsMessage =>
      'لا توجد تشغيلات رواتب قابلة للعكس حالياً.';

  @override
  String get payrollReversalPartialUnavailableHint =>
      'هذا التشغيل يشمل شخصاً واحداً فقط—استخدم «التشغيل بالكامل» للعكس.';

  @override
  String get payrollReversalConfirmTitle => 'عكس الرواتب؟';

  @override
  String get payrollReversalConfirmWholeRunMessage =>
      'سيتم التراجع عن التشغيل بالكامل واستعادة المخالفات المرتبطة حيث ينطبق ذلك وحذف قسائم الراتب لهذه الفترة.';

  @override
  String payrollReversalConfirmOneMemberMessage(String employeeName) {
    return 'سيتم إزالة $employeeName من هذا التشغيل والتراجع عن مخالفاتهم المرتبطة حيث ينطبق ذلك وحذف قسيمة راتبهم لهذه الفترة.';
  }

  @override
  String get payrollReversalSuccess => 'تم إكمال عكس الرواتب.';

  @override
  String get payrollEmployeeSetupTitle => 'إعداد رواتب الموظف';

  @override
  String get payrollEmployeeAddEntry => 'إضافة بند';

  @override
  String get payrollEmployeeSetupSubtitle =>
      'أدر البنود المتكررة والمرات الواحدة لهذا الموظف.';

  @override
  String get payrollEmployeeEntriesEmptyTitle => 'لا توجد بنود رواتب بعد';

  @override
  String get payrollEmployeeEntriesEmptySubtitle =>
      'أضف عناصر راتب متكررة وتعديلات لمرة واحدة لهذا الموظف.';

  @override
  String get payrollQuickPayValidation => 'اختر الموظف وفترة الرواتب أولاً.';

  @override
  String get payrollQuickPayStatementEmptyTitle => 'لا يوجد كشف دفع سريع بعد';

  @override
  String get payrollQuickPayStatementEmptySubtitle =>
      'اختر الموظف والفترة لاحتساب الاستحقاقات والخصومات.';

  @override
  String get payrollPayslipTitle => 'قسيمة الراتب';

  @override
  String get payrollPayslipEmptyTitle => 'لا توجد بنود في القسيمة';

  @override
  String get payrollPayslipEmptySubtitle =>
      'لا يحتوي تشغيل الرواتب هذا على بنود ظاهرة للموظف المحدد.';

  @override
  String get payrollRunEmployeesLabel => 'الموظفون';

  @override
  String get payrollRunAllEmployees => 'كل الموظفين النشطين';

  @override
  String get payrollRunAllMatchingStaff => 'كل الموظفين المطابقين';

  @override
  String get payrollRunValidation => 'اختر فترة الرواتب قبل الاحتساب.';

  @override
  String get payrollRunReviewHistoryTitle => 'سجل الرواتب';

  @override
  String get payrollRunReviewHistorySubtitle =>
      'تشغيلات معتمدة ومدفوعة (المسودات مخفية). المسّ تشغيلاً معتمداً للدفع أو التراجع.';

  @override
  String get payrollRunReviewHistoryEmpty =>
      'لا توجد عمليات رواتب بعد. احتسب تشغيلاً أعلاه للبدء.';

  @override
  String get payrollHistoryApprovedSheetTitle => 'معتمد — غير مدفوع بعد';

  @override
  String get payrollHistoryApprovedSheetBody =>
      'علّق كمدفوع بعد تحويل الأموال، أو تراجع لإلغاء الاعتماد.';

  @override
  String get payrollHistoryMarkedPaidSnack => 'تم التعليق كمدفوع.';

  @override
  String get payrollHistoryRollbackSnack => 'تم التراجع عن تشغيل الرواتب.';

  @override
  String payrollRunEmployeeSummary(int lineCount, String netPay) {
    return '$lineCount بنود · الصافي $netPay';
  }

  @override
  String get violationTypeBarberLate => 'تأخر';

  @override
  String get violationTypeBarberNoShow => 'عدم حضور الحلاق';

  @override
  String get customerRecommendationsTitle => 'اقتراحات';

  @override
  String get customerRecommendationBest => 'الخيار الأفضل';

  @override
  String get customerRecommendationFastest => 'أسرع موعد';

  @override
  String get customerRecommendationPreferred => 'حلاقك المفضّل';

  @override
  String get customerRecommendationAlternatives => 'بدائل';

  @override
  String customerRecommendationUseSlot(String time, String barber) {
    return '$time · $barber';
  }

  @override
  String get recommendationReasonExperiencedWithService => 'خبرة بهذه الخدمة';

  @override
  String get recommendationReasonNoServiceHistoryFallback =>
      'لا بيانات تاريخية حديثة لهذه الخدمة';

  @override
  String get recommendationReasonStrongTrackRecord => 'سجل إنجاز قوي';

  @override
  String get recommendationReasonSoonestTime => 'أقرب وقت متاح';

  @override
  String get recommendationReasonPreferredBarber => 'حلاقك المفضّل';

  @override
  String get recommendationReasonBalancedSchedule =>
      'جدول أخف في الأيام القادمة';

  @override
  String get recommendationReasonMoreAvailabilityToday => 'موعد أبكر اليوم';

  @override
  String get notificationsCenterTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد.';

  @override
  String get notificationsPreferencesTitle => 'إعدادات الإشعارات';

  @override
  String get notificationsPreferencesTooltip => 'إعدادات الإشعارات';

  @override
  String get notificationsPrefPushMaster => 'إشعارات الدفع';

  @override
  String get notificationsPrefBookingReminders => 'تذكيرات المواعيد';

  @override
  String get notificationsPrefBookingChanges => 'تحديثات الحجز';

  @override
  String get notificationsPrefPayroll => 'تنبيهات الرواتب';

  @override
  String get notificationsPrefViolations => 'المخالفات وعدم الحضور';

  @override
  String get notificationsPrefMarketing => 'نصائح وعروض';

  @override
  String get notificationsPrefMarketingHint =>
      'تحديثات خفيفة من الصالون أو التطبيق.';

  @override
  String get notificationsFilterAll => 'الكل';

  @override
  String get notificationsFilterUnread => 'غير المقروءة';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptySubtitle =>
      'ستظهر هنا تحديثات الحجوزات والحضور والرواتب ونشاط الفريق.';

  @override
  String get notificationsFirestoreIndexBuildingSubtitle =>
      'سيُحمَّل صندوق الوارد قريبًا — جاري إعداد فهرس الإشعارات في Firestore. اسحب للتحديث أو أعد المحاولة بعد دقيقة.';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsSettingBookingUpdates => 'تحديثات الحجوزات';

  @override
  String get notificationsSettingAttendanceUpdates => 'تحديثات الحضور';

  @override
  String get notificationsSettingPayrollUpdates => 'تحديثات الرواتب';

  @override
  String get notificationsSettingApprovals => 'طلبات الموافقة';

  @override
  String get notificationsSettingSystemAlerts => 'تنبيهات النظام';

  @override
  String get notificationsInboxTooltip => 'الإشعارات';

  @override
  String get customerNotificationsTooltip => 'الإشعارات';

  @override
  String get customerDiscoveryGoodMorning => 'صباح الخير';

  @override
  String get customerDiscoveryGoodAfternoon => 'مساء الخير';

  @override
  String get customerDiscoveryGoodEvening => 'مساء الخير';

  @override
  String customerDiscoveryNameWave(String name) {
    return '$name 👋';
  }

  @override
  String customerPromoSalonEyebrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صالونات متاحة',
      one: 'صالون واحد متاح',
      zero: 'لا صالونات للعرض بعد',
    );
    return '$_temp0';
  }

  @override
  String customerPromoServicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خدمات للتصفّح',
      one: 'خدمة واحدة للتصفّح',
      zero: 'ستظهر الخدمات عند نشرها من الصالونات.',
    );
    return '$_temp0';
  }

  @override
  String get customerPromoCta => 'تصفّح الصالونات';

  @override
  String get customerSectionQuickServices => 'خدمات من الصالونات';

  @override
  String get customerSectionNearbySalons => 'صالونات لك';

  @override
  String get customerSeeAll => 'عرض الكل';

  @override
  String get customerSalonDiscoveryTitle => 'اعثر على صالونك';

  @override
  String get customerSalonDiscoverySubtitle => 'احجز موعدك القادم';

  @override
  String get customerSalonDiscoverySearchHint => 'ابحث عن صالون، خدمة، منطقة…';

  @override
  String get customerSalonDiscoveryNearYou => 'بالقرب منك';

  @override
  String get customerSalonDiscoveryEmpty =>
      'لا توجد صالونات مطابقة. جرّب تغيير الفلاتر أو البحث.';

  @override
  String get customerSalonDiscoveryRetry => 'إعادة المحاولة';

  @override
  String get customerSalonDiscoveryErrorPermission =>
      'تعذّر تحميل قائمة الصالونات. تحقّق من قواعد الفهرس في Firestore.';

  @override
  String get customerSalonDiscoveryBookingsSignIn =>
      'سجّل الدخول لعرض حجوزاتك.';

  @override
  String get customerSalonDiscoveryNavDiscover => 'استكشف';

  @override
  String get customerSalonDiscoveryNavBookings => 'الحجوزات';

  @override
  String get customerSalonDiscoveryNavAccount => 'الحساب';

  @override
  String get customerSalonBookmarkTooltip => 'حفظ الصالون';

  @override
  String customerSalonStartingFrom(String price) {
    return 'ابتداءً من $price';
  }

  @override
  String get customerSalonOpenNowBadge => 'مفتوح الآن';

  @override
  String get customerSalonClosedBadge => 'مغلق';

  @override
  String get customerSalonFilterNearby => 'بالقرب';

  @override
  String get customerSalonFilterOpenNow => 'مفتوح الآن';

  @override
  String get customerSalonFilterTopRated => 'الأعلى تقييماً';

  @override
  String get customerSalonFilterOffers => 'عروض';

  @override
  String get customerSalonFilterLadies => 'سيدات';

  @override
  String get customerSalonFilterMen => 'رجال';

  @override
  String get customerSalonFilterUnisex => 'للكل';

  @override
  String get customerProfileTabServices => 'الخدمات';

  @override
  String get customerProfileTabTeam => 'الفريق';

  @override
  String get customerProfileTabReviews => 'التقييمات';

  @override
  String get customerProfileTabAbout => 'عن الصالون';

  @override
  String get customerProfileBookAppointment => 'احجز موعدًا';

  @override
  String get customerProfileActionCall => 'اتصال';

  @override
  String get customerProfileActionWhatsApp => 'واتساب';

  @override
  String get customerProfileActionMap => 'الخريطة';

  @override
  String get customerProfileActionShare => 'مشاركة';

  @override
  String get customerProfileEmptyServices => 'لا توجد خدمات متاحة بعد.';

  @override
  String get customerProfileEmptyTeam => 'لا يوجد أخصائيون متاحون بعد.';

  @override
  String get customerProfileEmptyReviews => 'لا توجد تقييمات بعد.';

  @override
  String get customerProfileSalonNotFound => 'هذا الصالون غير متاح.';

  @override
  String get customerProfileWorkingHoursPlaceholder =>
      'ساعات العمل ستظهر هنا قريبًا.';

  @override
  String get customerProfileMapPreviewPlaceholder => 'معاينة الخريطة';

  @override
  String get customerProfileAboutArea => 'المنطقة';

  @override
  String get customerProfileAboutPhone => 'الهاتف';

  @override
  String get customerProfileAboutGender => 'الجنس';

  @override
  String customerProfileGenderValue(String gender) {
    return '$gender';
  }

  @override
  String customerProfileMinutesShort(int minutes) {
    return '$minutes د';
  }

  @override
  String get customerServiceSelectionTitle => 'اختر خدماتك';

  @override
  String get customerServiceSelectionSubtitle => 'اختر خدمة واحدة أو أكثر';

  @override
  String get customerServiceSelectionStepLabel => 'الخطوة 1 من 5';

  @override
  String get customerServiceSelectionProgressTitle => 'الخدمات';

  @override
  String get customerServiceSelectionEmpty => 'لا توجد خدمات متاحة بعد.';

  @override
  String customerServiceSelectionSelectedCount(int count) {
    return '$count محددة';
  }

  @override
  String customerServiceSelectionSummary(int minutes, String total) {
    return 'المدة: $minutes د · الإجمالي: $total';
  }

  @override
  String get customerServiceSelectionContinue => 'متابعة';

  @override
  String get customerServiceSelectionClear => 'مسح';

  @override
  String get customerServiceSelectionRequiredSnack =>
      'اختر خدمة واحدة على الأقل للمتابعة.';

  @override
  String customerServiceSelectionComingNext(String salonId) {
    return 'اختيار الخدمات قادم في الخطوة التالية.\n\nمعرّف الصالون:\n$salonId';
  }

  @override
  String customerTeamSelectionComingNext(String salonId) {
    return 'اختيار الفريق قادم في الخطوة التالية.\n\nمعرّف الصالون:\n$salonId';
  }

  @override
  String get customerTeamSelectionTitle => 'اختر الأخصائي';

  @override
  String get customerTeamSelectionSubtitle => 'اختر عضوًا من الفريق أو أي متاح';

  @override
  String get customerTeamSelectionStepLabel => 'الخطوة 2 من 5';

  @override
  String get customerTeamSelectionProgressTitle => 'الأخصائي';

  @override
  String get customerTeamSelectionAnyTitle => 'أي أخصائي متاح';

  @override
  String get customerTeamSelectionAnySubtitle =>
      'سنختار لك أفضل أخصائي متاح في الوقت الذي تحدده.';

  @override
  String get customerTeamSelectionEmpty => 'لا يوجد أخصائيون متاحون بعد.';

  @override
  String get customerTeamSelectionRequiredSnack => 'اختر أخصائيًا للمتابعة.';

  @override
  String get customerTeamSelectionServicesRequiredSnack =>
      'اختر خدمة واحدة على الأقل أولاً.';

  @override
  String get customerTeamSelectionNoStaffHint =>
      'أضف أعضاء فريق قابلين للحجز للمتابعة.';

  @override
  String customerTeamSelectionRating(String rating, int count) {
    return 'التقييم $rating ($count)';
  }

  @override
  String customerDateTimeSelectionComingNext(String salonId) {
    return 'اختيار التاريخ والوقت قادم في الخطوة التالية.\n\nمعرّف الصالون:\n$salonId';
  }

  @override
  String get customerDateTimeTitle => 'اختر التاريخ والوقت';

  @override
  String get customerDateTimeSubtitle => 'اختر موعدًا متاحًا للحجز';

  @override
  String get customerDateTimeStepLabel => 'الخطوة 3 من 5';

  @override
  String get customerDateTimeProgressTitle => 'التاريخ والوقت';

  @override
  String get customerDateTimeToday => 'اليوم';

  @override
  String get customerDateTimeTomorrow => 'غدًا';

  @override
  String get customerDateTimeMorning => 'الصباح';

  @override
  String get customerDateTimeAfternoon => 'بعد الظهر';

  @override
  String get customerDateTimeEvening => 'المساء';

  @override
  String get customerDateTimeEmpty => 'لا توجد مواعيد متاحة';

  @override
  String get customerDateTimeChooseAnotherDate => 'يرجى اختيار تاريخ آخر';

  @override
  String get customerDateTimeRequiredSnack => 'اختر وقتًا متاحًا للمتابعة.';

  @override
  String customerDateTimeSummaryTitle(int count, String specialist) {
    return '$count خدمات · $specialist';
  }

  @override
  String customerDateTimeSummarySubtitle(int minutes, String total) {
    return 'المدة: $minutes د · الإجمالي: $total';
  }

  @override
  String customerDetailsComingNext(String salonId) {
    return 'تفاصيل العميل قادمة في الخطوة التالية.\n\nمعرّف الصالون:\n$salonId';
  }

  @override
  String get customerDetailsTitle => 'تفاصيل العميل';

  @override
  String get customerDetailsSubtitle => 'أضف بيانات التواصل لموعدك';

  @override
  String get customerDetailsStepLabel => 'الخطوة 4 من 5';

  @override
  String get customerDetailsProgressTitle => 'البيانات';

  @override
  String get customerDetailsFullName => 'الاسم الكامل';

  @override
  String get customerDetailsPhoneNumber => 'رقم الهاتف';

  @override
  String get customerDetailsGender => 'الجنس';

  @override
  String get customerDetailsGenderMale => 'ذكر';

  @override
  String get customerDetailsGenderFemale => 'أنثى';

  @override
  String get customerDetailsGenderPreferNotToSay => 'أفضل عدم الإجابة';

  @override
  String get customerDetailsNotes => 'ملاحظات';

  @override
  String get customerDetailsNotesHint => 'أي ملاحظات للصالون؟';

  @override
  String get customerDetailsPhoneInfo =>
      'سنستخدم رقم هاتفك فقط لتأكيد الحجز والعثور عليه.';

  @override
  String get customerDetailsRequiredField => 'حقل مطلوب';

  @override
  String get customerDetailsInvalidPhone => 'أدخل رقم هاتف صحيح';

  @override
  String get customerDetailsNameTooShort => 'يجب ألا يقل الاسم عن حرفين';

  @override
  String get customerDetailsNotesTooLong =>
      'لا يمكن أن تتجاوز الملاحظات 300 حرف';

  @override
  String customerDetailsSummaryTitle(int count, String specialist) {
    return '$count خدمات · $specialist';
  }

  @override
  String customerDetailsSummarySubtitle(String dateTime, String total) {
    return '$dateTime · $total';
  }

  @override
  String customerBookingReviewComingNext(String salonId) {
    return 'مراجعة الحجز قادمة في الخطوة التالية.\n\nمعرّف الصالون:\n$salonId';
  }

  @override
  String get customerBookingReviewTitle => 'راجع الحجز';

  @override
  String get customerBookingReviewSubtitle =>
      'تأكد من تفاصيل موعدك قبل التأكيد';

  @override
  String get customerBookingReviewStepLabel => 'الخطوة 5 من 5';

  @override
  String get customerBookingReviewProgressTitle => 'المراجعة';

  @override
  String get customerBookingReviewSalon => 'الصالون';

  @override
  String get customerBookingReviewServices => 'الخدمات';

  @override
  String get customerBookingReviewSpecialist => 'المختص';

  @override
  String get customerBookingReviewDateTime => 'التاريخ والوقت';

  @override
  String get customerBookingReviewCustomer => 'العميل';

  @override
  String get customerBookingReviewPaymentSummary => 'ملخص الدفع';

  @override
  String get customerBookingReviewSubtotal => 'المجموع الفرعي';

  @override
  String get customerBookingReviewDiscount => 'الخصم';

  @override
  String get customerBookingReviewTotal => 'الإجمالي';

  @override
  String get customerBookingReviewConfirm => 'تأكيد الحجز';

  @override
  String get customerBookingReviewSlotUnavailable =>
      'هذا الموعد لم يعد متاحاً. يرجى اختيار وقت آخر.';

  @override
  String get customerBookingReviewChooseSpecialistAgain =>
      'يرجى اختيار مختص مرة أخرى.';

  @override
  String get customerBookingReviewGenericError =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String customerBookingSuccessPlaceholder(String bookingCode) {
    return 'تم تأكيد الحجز\n\nرمز الحجز:\n$bookingCode';
  }

  @override
  String get customerBookingSuccessTitle => 'تم تأكيد الحجز';

  @override
  String get customerBookingSuccessSubtitle => 'تم حفظ موعدك بنجاح.';

  @override
  String get customerBookingSuccessCode => 'رمز الحجز';

  @override
  String get customerBookingSuccessStatus => 'الحالة';

  @override
  String get customerBookingSuccessDate => 'التاريخ';

  @override
  String get customerBookingSuccessTime => 'الوقت';

  @override
  String get customerBookingSuccessStatusFallback => 'محفوظ';

  @override
  String get customerBookingSuccessFallback => 'متاح في تفاصيل الحجز';

  @override
  String get customerBookingSuccessSaveCodeInfo =>
      'احفظ رمز الحجز. يمكنك استخدامه لاحقاً للعثور على موعدك.';

  @override
  String get customerBookingSuccessViewBooking => 'عرض الحجز';

  @override
  String get customerBookingSuccessBookAnother => 'حجز موعد آخر';

  @override
  String get customerBookingSuccessBackToSalon => 'العودة إلى الصالون';

  @override
  String get customerBookingSuccessCodeCopied => 'تم نسخ رمز الحجز.';

  @override
  String get customerBookingLookupTitle => 'ابحث عن حجزك';

  @override
  String get customerBookingLookupSubtitle => 'أدخل رقم هاتفك لعرض موعدك';

  @override
  String get customerBookingLookupPhoneNumber => 'رقم الهاتف';

  @override
  String get customerBookingLookupBookingCode => 'رمز الحجز';

  @override
  String get customerBookingLookupBookingCodeOptional => 'رمز الحجز اختياري';

  @override
  String get customerBookingLookupSearch => 'بحث';

  @override
  String get customerBookingLookupPhoneHint =>
      'استخدم نفس رقم الهاتف الذي استخدمته عند الحجز.';

  @override
  String get customerBookingLookupNoBookings => 'لم يتم العثور على حجوزات';

  @override
  String get customerBookingLookupViewDetails => 'عرض التفاصيل';

  @override
  String get customerBookingStatusPending => 'قيد الانتظار';

  @override
  String get customerBookingStatusConfirmed => 'مؤكد';

  @override
  String get customerBookingStatusCheckedIn => 'تم تسجيل الوصول';

  @override
  String get customerBookingStatusCompleted => 'مكتمل';

  @override
  String get customerBookingStatusCancelled => 'ملغى';

  @override
  String get customerBookingStatusNoShow => 'لم يحضر';

  @override
  String get customerBookingLookupInvalidPhone => 'أدخل رقم هاتف صحيح';

  @override
  String get customerBookingLookupGenericError =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get customerBookingLookupAnySpecialist => 'أي مختص متاح';

  @override
  String get customerBookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get customerBookingDetailsSubtitle => 'اعرض معلومات موعدك';

  @override
  String get customerBookingDetailsCopied => 'تم النسخ';

  @override
  String customerBookingDetailsDurationPrice(int minutes, String price) {
    return '$minutes د · $price';
  }

  @override
  String get customerBookingDetailsTimelineTitle => 'المراحل';

  @override
  String get customerBookingDetailsTimelineCreated => 'تم الإنشاء';

  @override
  String get customerBookingDetailsTimelineUpcoming => 'قادم';

  @override
  String get customerBookingDetailsTimelineConfirmed => 'مؤكد';

  @override
  String get customerBookingDetailsPendingConfirmation => 'بانتظار التأكيد';

  @override
  String get customerBookingDetailsSpecialist => 'المختص';

  @override
  String get customerBookingDetailsCall => 'اتصال';

  @override
  String get customerBookingDetailsWhatsApp => 'واتساب';

  @override
  String get customerBookingDetailsWhatsAppMessage =>
      'مرحبًا — لدي سؤال بخصوص حجزي.';

  @override
  String get customerBookingDetailsPhoneUnavailable => 'رقم الهاتف غير متوفر';

  @override
  String get customerBookingDetailsReschedule => 'إعادة الجدولة';

  @override
  String get customerBookingDetailsCancelBooking => 'إلغاء الحجز';

  @override
  String get customerBookingDetailsLeaveFeedback => 'ترك ملاحظة';

  @override
  String get customerBookingDetailsBookAgain => 'احجز مجددًا';

  @override
  String get customerBookingDetailsComingSoon => 'قريبًا';

  @override
  String get customerBookingDetailsActionsTitle => 'الخطوة التالية';

  @override
  String get customerBookingDetailsArea => 'المنطقة';

  @override
  String get customerCancelBookingTitle => 'إلغاء الحجز';

  @override
  String get customerCancelBookingConfirmMessage =>
      'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟';

  @override
  String get customerCancelBookingReasonLabel => 'السبب';

  @override
  String get customerCancelBookingReasonHint => 'السبب (اختياري)';

  @override
  String get customerCancelBookingKeep => 'الإبقاء على الحجز';

  @override
  String get customerCancelBookingConfirm => 'تأكيد الإلغاء';

  @override
  String get customerCancelBookingSuccess => 'تم إلغاء الحجز بنجاح';

  @override
  String get customerCancelBookingCannotCancelOnline =>
      'لا يمكن إلغاء هذا الحجز عبر الإنترنت.';

  @override
  String get customerCancelBookingTooCloseToStart =>
      'اقترب موعد الحجز كثيرًا لإلغائه عبر الإنترنت. يُرجى التواصل مع الصالون.';

  @override
  String get customerCancelBookingReasonTooLong =>
      'لا يمكن أن يتجاوز السبب 200 حرف';

  @override
  String get customerRescheduleSubtitle => 'اختر موعدًا جديدًا';

  @override
  String get customerRescheduleCurrentAppointment => 'الموعد الحالي';

  @override
  String get customerRescheduleNewAppointment => 'الموعد الجديد';

  @override
  String get customerRescheduleConfirmTime => 'تأكيد الوقت الجديد';

  @override
  String get customerRescheduleSuccess => 'تمت إعادة جدولة الحجز بنجاح';

  @override
  String get customerRescheduleCannotOnline =>
      'لا يمكن إعادة جدولة هذا الحجز عبر الإنترنت.';

  @override
  String get customerRescheduleTooCloseToStart =>
      'اقترب موعد الحجز كثيرًا لإعادة جدولته عبر الإنترنت. يُرجى التواصل مع الصالون.';

  @override
  String get customerRescheduleNoSlots => 'لا توجد أوقات متاحة';

  @override
  String get customerRescheduleChooseAnotherDate => 'يُرجى اختيار تاريخ آخر';

  @override
  String get customerRescheduleStepLabel => 'إعادة الجدولة';

  @override
  String get customerRescheduleProgressTitle => 'وقت جديد';

  @override
  String get customerFeedbackTitle => 'ترك ملاحظة';

  @override
  String get customerFeedbackSubtitle => 'أخبرنا عن تجربتك في الموعد';

  @override
  String get customerFeedbackCommentHint => 'شارك تجربتك';

  @override
  String get customerFeedbackCommentLabel => 'تعليق';

  @override
  String get customerFeedbackRatingSection => 'تقييمك';

  @override
  String get customerFeedbackWouldComeAgain => 'هل ستعود مرة أخرى؟';

  @override
  String get customerFeedbackYes => 'نعم';

  @override
  String get customerFeedbackNo => 'لا';

  @override
  String get customerFeedbackSubmit => 'إرسال الملاحظة';

  @override
  String get customerFeedbackThankYouTitle => 'شكرًا لملاحظتك';

  @override
  String get customerFeedbackThankYouSubtitle => 'نقدّر وقتك.';

  @override
  String get customerFeedbackAlreadySubmittedTitle =>
      'تم إرسال الملاحظة مسبقًا';

  @override
  String get customerFeedbackAlreadySubmittedSubtitle =>
      'يمكنك عرض هذا الحجز في أي وقت من البحث عن الحجز.';

  @override
  String get customerFeedbackSubmittedBadge => 'تم إرسال الملاحظة';

  @override
  String get customerFeedbackBackToDetails => 'العودة إلى تفاصيل الحجز';

  @override
  String get customerFeedbackRatingPoor => 'ضعيف';

  @override
  String get customerFeedbackRatingFair => 'مقبول';

  @override
  String get customerFeedbackRatingGood => 'جيد';

  @override
  String get customerFeedbackRatingVeryGood => 'جيد جدًا';

  @override
  String get customerFeedbackRatingExcellent => 'ممتاز';

  @override
  String get customerFeedbackRatingRequired => 'التقييم مطلوب';

  @override
  String get customerFeedbackCommentTooLong =>
      'لا يمكن أن يتجاوز التعليق 500 حرفًا';

  @override
  String get customerFeedbackOnlyCompleted =>
      'لا يمكن إرسال الملاحظة إلا للحجوزات المكتملة.';

  @override
  String get customerFeedbackGenericError =>
      'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get customerSalonBadgeOpen => 'مفتوح';

  @override
  String get customerStatBookings => 'الحجوزات';

  @override
  String get customerStatSalonsVisited => 'صالونات زرتها';

  @override
  String get customerStatUpcoming => 'قادمة';

  @override
  String get customerProfileEdit => 'تعديل';

  @override
  String get customerSettingsTileNotificationsSubtitle =>
      'تنبيهات الحجز والتذكيرات';

  @override
  String get customerSettingsTileBookingsSubtitle =>
      'الزيارات القادمة والسابقة';

  @override
  String customerAppFooterVersion(String appName, String version) {
    return '$appName الإصدار $version';
  }

  @override
  String get customerProfileTitle => 'الملف الشخصي';

  @override
  String get ownerInsightsTitle => 'رؤى ذكية';

  @override
  String get ownerInsightsSubtitle =>
      'أبرز المؤشرات أسبوعياً من المبيعات والحجوزات (تُحدَّث كل اثنين).';

  @override
  String get ownerInsightsEmpty => 'ستظهر الرؤى بعد تشغيل الملخص الأسبوعي.';

  @override
  String get ownerInsightsError => 'تعذّر تحميل الرؤى.';

  @override
  String get ownerRetentionTitle => 'احتفاظ بالعملاء';

  @override
  String get ownerRetentionSubtitle =>
      'يعتمد على الزيارات المكتملة وعدم الحضور (منطقة زمنية للصالون عند ضبطها).';

  @override
  String get ownerRetentionEmpty =>
      'ستظهر مؤشرات الاحتفاظ بعد تشغيل المهمة الأسبوعية.';

  @override
  String ownerRetentionMonthLabel(int year, String month) {
    return '$year-$month';
  }

  @override
  String ownerRetentionTimeZoneUsed(String tz) {
    return 'المنطقة الزمنية: $tz';
  }

  @override
  String get ownerRetentionRepeatCustomers => 'عملاء متكررون هذا الشهر';

  @override
  String get ownerRetentionFirstTimeCustomers => 'عملاء لأول مرة هذا الشهر';

  @override
  String get ownerRetentionDistinctThisMonth =>
      'عملاء بزيارة مكتملة (منذ بداية الشهر)';

  @override
  String get ownerRetentionReturningThisMonth =>
      'عملاء عائدون (لديهم زيارة سابقة)';

  @override
  String get ownerRetentionRate => 'معدل الاحتفاظ';

  @override
  String get ownerRetentionInactive30Days => 'عملاء بلا زيارة منذ 30 يومًا';

  @override
  String get ownerRetentionNoShowTrend => 'اتجاه عدم الحضور (أسابيع محلية)';

  @override
  String get ownerRetentionNoShowLastLocalWeek => 'آخر أسبوع محلي مكتمل';

  @override
  String get ownerRetentionNoShowPreviousLocalWeek => 'الأسبوع المحلي السابق';

  @override
  String get ownerRetentionNoShowDelta => 'التغيير مقارنة بالأسبوع السابق';

  @override
  String get ownerRetentionDeltaFlat => 'لا تغيير';

  @override
  String ownerRetentionDeltaUp(int n) {
    return '+$n';
  }

  @override
  String ownerRetentionDeltaDown(int n) {
    return '−$n';
  }

  @override
  String get onboardingLanguageTitle => 'اللغة';

  @override
  String get onboardingLanguageSubtitle => 'اختر لغة التطبيق المفضّلة لديك.';

  @override
  String get onboardingLanguageEnglish => 'الإنجليزية';

  @override
  String get onboardingLanguageArabic => 'العربية';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingCountryTitle => 'البلد / المنطقة';

  @override
  String get onboardingCountrySubtitle =>
      'تُستخدم للتنسيقات وخيارات إقليمية لاحقًا.';

  @override
  String get preAuthLanguageTitle => 'اختر اللغة';

  @override
  String get preAuthLanguageSubtitle =>
      'اختر اللغة التي تريد استخدامها في التطبيق';

  @override
  String get preAuthLanguageEnglish => 'الإنجليزية';

  @override
  String get preAuthLanguageArabic => 'العربية';

  @override
  String get preAuthContinue => 'متابعة';

  @override
  String get preAuthCountryTitle => 'اختر الدولة';

  @override
  String get preAuthCountrySubtitle => 'هذا يساعدنا على تخصيص تجربة التطبيق لك';

  @override
  String get preAuthRoleTitle => 'كيف تريد استخدام التطبيق؟';

  @override
  String get preAuthRoleSubtitle => 'اختر التجربة المناسبة لك';

  @override
  String get preAuthRoleCustomerTitle => 'مستخدم';

  @override
  String get preAuthRoleCustomerSubtitle =>
      'العملاء يسجّلون بالبريد. موظفو الصالون باسم المستخدم.';

  @override
  String get preAuthRoleOwnerTitle => 'صاحب صالون';

  @override
  String get preAuthRoleOwnerSubtitle =>
      'أدر الصالون والفريق والحجوزات والأعمال';

  @override
  String get startupEntryTitle => 'مرحبًا';

  @override
  String get startupEntrySubtitle => 'اختر كيف تريد البدء';

  @override
  String get startupBookOrAccessTitle => 'احجز أو استخدم الخدمات';

  @override
  String get startupBookOrAccessSubtitle =>
      'اعثر على الصالونات، احجز زياراتك، أو تابع مع صلاحية فريقك';

  @override
  String get startupManageSalonTitle => 'أدير صالوني';

  @override
  String get startupManageSalonSubtitle =>
      'يُدير المالكون الصالون والفريق والإيرادات من هنا';

  @override
  String get startupContinueAsUserTitle => 'متابعة كمستخدم';

  @override
  String get startupContinueAsUserSubtitle =>
      'احجز الزيارات، استكشف الصالونات، أو سجّل دخولك كطاقم';

  @override
  String get startupOwnSalonTitle => 'أملك صالونًا';

  @override
  String get startupOwnSalonSubtitle => 'أدر عملك وفريقك وحجوزاتك وإيراداتك';

  @override
  String get userSelectionContinueTitle => 'اختر كيف تريد المتابعة';

  @override
  String get userSelectionContinueSubtitle => 'اختر المسار المناسب لك';

  @override
  String get userSelectionTitle => 'كيف ستستخدم التطبيق؟';

  @override
  String get userSelectionSubtitle =>
      'العملاء وطاقم الصالون يستخدمون طرق تسجيل مختلفة';

  @override
  String get userSelectionCustomerTitle => 'متابعة كعميل';

  @override
  String get userSelectionCustomerSubtitle =>
      'تصفّح الصالونات واحجز المواعيد بالبريد';

  @override
  String get userSelectionStaffTitle => 'متابعة كطاقم';

  @override
  String get userSelectionStaffSubtitle =>
      'استخدم اسم المستخدم الذي شاركه صالونك معك';

  @override
  String get customerProfileSetupTitle => 'ملفك';

  @override
  String get customerProfileSetupSubtitle => 'خطوة سريعة قبل إنشاء حسابك';

  @override
  String get customerProfileSetupContinue => 'متابعة';

  @override
  String get customerProfileSetupNameLabel => 'الاسم الكامل';

  @override
  String get customerProfileSetupNameError => 'أدخل اسمك';

  @override
  String get customerProfileSetupPhoneLabel => 'الهاتف (اختياري)';

  @override
  String get staffLoginHeadline => 'تسجيل دخول الطاقم';

  @override
  String get staffLoginSubtitle =>
      'سجّل بالبريد وكلمة المرور التي أنشأها مالك الصالون لك، أو باسم المستخدم إن وُجد.';

  @override
  String get staffLoginNoSignupHint =>
      'حسابات الطاقم تُنشأ من الصالون. تواصل مع المالك إذا احتجت صلاحية.';

  @override
  String get preAuthSlideSalonTitle => 'اكتشف صالونات قريبة منك';

  @override
  String get preAuthSlideSalonSubtitle =>
      'اعثر على أفضل الصالونات وخبراء التجميل قربك — في أي وقت وأي مكان.';

  @override
  String get preAuthSlideBarberTitle => 'احجز في ثوانٍ';

  @override
  String get preAuthSlideBarberSubtitle =>
      'اختر الحلاق والوقت وأكد الحجز فورًا.';

  @override
  String get preAuthSlideBookingTitle => 'تحكم بكل شيء';

  @override
  String get preAuthSlideBookingSubtitle =>
      'أدر الحجوزات واحفظ المفضّلة واستمتع بتجربة سلسة.';

  @override
  String get preAuthNext => 'التالي';

  @override
  String get preAuthGetStarted => 'ابدأ الآن';

  @override
  String get preAuthSkip => 'تخطي';

  @override
  String get authGateTitle => 'مرحبًا';

  @override
  String get authGateSubtitle =>
      'سجّل الدخول، أو أنشئ حساب عميل للحجز، أو سجّل صالونًا جديدًا.';

  @override
  String get authGateSignIn => 'تسجيل الدخول';

  @override
  String get authGateCreateAccount => 'إنشاء حساب عميل';

  @override
  String get authGateCreateAccountSubtitle =>
      'لحجز المواعيد فقط. مالكو الصالون يستخدمون «إنشاء صالون» أدناه.';

  @override
  String get authGateRegionSettings => 'إعدادات اللغة والمنطقة';

  @override
  String get appSettingsTitle => 'إعدادات التطبيق';

  @override
  String get appSettingsIntroBody =>
      'خصّص التفضيلات وأدر الإعدادات لتناسب سير عمل صالونك.';

  @override
  String get appSettingsLanguageSubtitle => 'اختر لغتك المفضّلة';

  @override
  String get appSettingsCountrySubtitle => 'حدّد منطقة التشغيل الحالية';

  @override
  String get appSettingsChangeAnytimeBanner => 'يمكنك تغيير ذلك في أي وقت.';

  @override
  String get appSettingsMoreActionSubtitle =>
      'معلومات التطبيق والخصوصية وخيارات أخرى';

  @override
  String get signOutDialogTitle => 'تسجيل الخروج؟';

  @override
  String get hrViolationsSummaryAwaitingApproval => 'بانتظار الموافقة';

  @override
  String get hrViolationsSummaryActiveRulesSubtitle => 'قواعد غرامات مفعّلة';

  @override
  String get hrViolationsSummaryStaffFlaggedTitle => 'طاقم مُعلَم';

  @override
  String get hrViolationsEnabledChip => 'مفعّل';

  @override
  String get hrViolationsDisabledChip => 'غير مفعّل';

  @override
  String get hrViolationsLateRuleTitle => 'قاعدة التأخر';

  @override
  String get hrViolationsNoShowRuleTitle => 'قاعدة عدم الحضور';

  @override
  String get hrViolationsGraceTimeLabel => 'فترة السماح';

  @override
  String get hrViolationsPendingEmptyTitle => 'لا طلبات مخالفات معلّقة';

  @override
  String get hrViolationsPendingEmptyBody =>
      'لا يوجد شيء معلّق. ستظهر طلبات المخالفات هنا عند وصولها.';

  @override
  String get hrViolationsAddRule => 'إضافة قاعدة';

  @override
  String get hrViolationsAddRuleComingSoon => 'المزيد من أنواع القواعد قريبًا.';

  @override
  String get hrViolationsToggleConfirmTitle => 'تحديث قاعدة الغرامة؟';

  @override
  String get hrViolationsToggleConfirmBody =>
      'يؤثر ذلك على الرواتب والخصومات لفريقك.';

  @override
  String get hrViolationsToggleConfirmAction => 'تحديث';

  @override
  String get hrViolationsSummaryLoadError =>
      'تعذّر تحميل ملخص الموارد البشرية.';

  @override
  String get appSettingsLanguageSection => 'اللغة';

  @override
  String get appSettingsCountrySection => 'البلد / المنطقة';

  @override
  String get appSettingsCountryLabel => 'البلد';

  @override
  String get appSettingsCountryHint => 'يمكنك تغيير ذلك في أي وقت من هنا.';

  @override
  String get appSettingsAppearanceSection => 'المظهر';

  @override
  String get appSettingsThemeLight => 'فاتح';

  @override
  String get appSettingsThemeDark => 'داكن';

  @override
  String get appSettingsThemeSystem => 'حسب النظام';

  @override
  String get appSettingsMoreSectionTitle => 'المزيد';

  @override
  String get appSettingsMoreSectionBody =>
      'ستُضاف لاحقًا خيارات الإشعارات والمزيد.';

  @override
  String get validationEmailRequired => 'نحتاج بريدك لتسجيل الدخول بأمان.';

  @override
  String get validationEmailInvalid =>
      'استخدم بريدًا صالحًا، مثل name@salon.com.';

  @override
  String get validationPasswordRequired => 'اختر كلمة مرور لحماية حسابك.';

  @override
  String get validationPasswordShort => 'استخدم 8 أحرف على الأقل.';

  @override
  String get validationPasswordMinSixChars => 'استخدم 6 أحرف على الأقل.';

  @override
  String get authSignupTitleCreateAccount => 'إنشاء حساب';

  @override
  String get authSignupSubtitleGetStarted => 'سجّل للبدء';

  @override
  String get authSignupPrimaryCta => 'إنشاء الحساب';

  @override
  String get authSignupPasswordHintMinSix => '6 أحرف على الأقل';

  @override
  String get registerHintPhone => 'رقم جوالك';

  @override
  String get registerHintCity => 'الدوحة';

  @override
  String get validationPhoneRequired => 'أضف رقمًا يصل به فريقك وعملاؤك.';

  @override
  String get validationPhoneShort => 'الرقم قصير جدًا—أدخل الرقم كاملًا.';

  @override
  String get validationPhoneOptionalInvalid =>
      'أدخل رقمًا صالحًا أو اترك الحقل فارغًا.';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName مطلوب.';
  }

  @override
  String get validationConfirmPasswordEmpty => 'أعد إدخال كلمة المرور للتأكد.';

  @override
  String get validationConfirmPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get validationUserLoginIdentifierRequired =>
      'أدخل البريد أو اسم المستخدم.';

  @override
  String get validationStaffUsernameRequired => 'اسم المستخدم مطلوب.';

  @override
  String get validationStaffUsernameInvalid =>
      'من 4 إلى 20 حرفًا: أحرف صغيرة وأرقام وشرطة سفلية أو نقطة فقط.';

  @override
  String get fieldLabelName => 'الاسم';

  @override
  String get fieldLabelFullName => 'الاسم الكامل';

  @override
  String get fieldLabelEmail => 'البريد الإلكتروني';

  @override
  String get fieldLabelEmailOrUsername => 'البريد أو اسم المستخدم';

  @override
  String get fieldLabelPassword => 'كلمة المرور';

  @override
  String get fieldLabelConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fieldLabelSalonName => 'اسم الصالون';

  @override
  String get fieldLabelPhone => 'الهاتف';

  @override
  String get fieldLabelAddress => 'العنوان';

  @override
  String get authCommonBack => 'رجوع';

  @override
  String get authCommonSettings => 'الإعدادات';

  @override
  String get authGateCreateSalon => 'إنشاء صالون';

  @override
  String get authGateCreateSalonSubtitle =>
      'سجّل كمالك صالون ثم أعد مساحة عملك. إن كان لديك حساب، استخدم تسجيل الدخول.';

  @override
  String get loginEyebrow => 'تسجيل الدخول';

  @override
  String get loginTitle => 'مرحبًا بعودتك.';

  @override
  String get loginDescription =>
      'احجز كعميل أو أدر صالونك كمالك. حسابات الفريق تسجّل الدخول من هنا أيضًا.';

  @override
  String get loginSectionEmailPassword => 'البريد وكلمة المرور';

  @override
  String get loginSectionSubtitle =>
      'العملاء والمالكون يستخدمون نفس تسجيل الدخول. لوحة التحكم تعتمد على دورك.';

  @override
  String get loginHintIdentifier => 'you@example.com أو اسم.مستخدم';

  @override
  String get loginSignInButton => 'تسجيل الدخول';

  @override
  String get loginFooterCreateAccount => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get loginTeamHint =>
      'يُنشئ مالك الصالون حسابات الحلاق والمسؤولين. سجّل الدخول باسم المستخدم الذي زوّدك به.';

  @override
  String get registerEyebrow => 'إنشاء حساب';

  @override
  String get registerTitle => 'انضم إلى المنصة.';

  @override
  String get registerDescription =>
      'بعد التسجيل ستختار عميلًا أو مالك صالون. يُنشئ مالك الصالون حسابات الحلاق والمسؤولين—استخدم تسجيل الدخول بدلًا من ذلك.';

  @override
  String get registerCustomerTitle => 'أنشئ حسابك كعميل.';

  @override
  String get registerCustomerDescription =>
      'احجز الزيارات، تابع سجلك، وأدر ملفك. يُنشئ مالك الصالون حسابات الحلاق والمسؤولين—استخدم تسجيل الدخول بدلًا من ذلك.';

  @override
  String get registerSalonOwnerTitle => 'سجّل كمالك صالون.';

  @override
  String get registerSalonOwnerDescription =>
      'بعدها ستضيف تفاصيل صالونك. إن كان لديك حساب، ارجع وسجّل الدخول.';

  @override
  String get registerSalonOwnerStepLabel => 'الحساب — الخطوة 1 من 2';

  @override
  String get registerStepLabel => 'الحساب — الخطوة 1 من 3';

  @override
  String get registerSectionYourDetails => 'بياناتك';

  @override
  String get registerSectionProfileHint =>
      'نخزّن ملفك في Firestore مرتبطًا بحساب Firebase Auth.';

  @override
  String get registerContinueButton => 'متابعة';

  @override
  String get registerFooterSignIn => 'لديك حساب؟ سجّل الدخول';

  @override
  String get registerOwnerIntentBanner =>
      'في الخطوة التالية اختر «مالك صالون» لإنشاء صالونك.';

  @override
  String get registerHintFullName => 'أحمد الراشد';

  @override
  String get registerHintEmail => 'you@example.com';

  @override
  String get registerHintPassword => '8 أحرف على الأقل';

  @override
  String get registerHintConfirmPassword => 'أعد كتابة كلمة المرور';

  @override
  String get createSalonEyebrow => 'إعداد الصالون';

  @override
  String get createSalonTitle => 'أنشئ الصالون الذي سيعمل فيه فريقك.';

  @override
  String get createSalonDescription =>
      'أضف البيانات الأساسية الآن. هذا السجل أساس للموظفين والحضور والرواتب والحجوزات لاحقًا.';

  @override
  String get createSalonStepLabel => 'إعداد الصالون — الخطوة 2 من 2';

  @override
  String get createSalonFooterDifferentAccount => 'استخدام حساب آخر';

  @override
  String get createSalonSectionTitle => 'تفاصيل الصالون';

  @override
  String get createSalonSectionSubtitle =>
      'أكمل ملف الصالون لفتح لوحة المالك ودعوة فريقك.';

  @override
  String get createSalonOwnerFallback => 'حساب المالك';

  @override
  String get createSalonButton => 'إنشاء الصالون';

  @override
  String get createSalonPhoneTip =>
      'المسافات والشرطات والأقواس مسموحة—نُطبّع الرقم عند الحفظ.';

  @override
  String get createSalonHintSalonName => 'صالون الكرسي الذهبي';

  @override
  String get createSalonHintPhone => '+962 7X XXX XXXX';

  @override
  String get createSalonHintAddress => 'عمان، عبدون، الشارع الرئيسي 12';

  @override
  String get roleEyebrow => 'اختر المسار';

  @override
  String get roleTitle => 'كيف ستستخدم التطبيق؟';

  @override
  String get roleDescription =>
      'العملاء يحجزون ويديرون الزيارات. المالكون يجهّزون مساحة الصالون. يصدر مالك الصالون حسابات الحلاق والمسؤولين.';

  @override
  String get roleStepLabel => 'الدور — الخطوة 2 من 2';

  @override
  String get roleSectionPrompt => 'أنا…';

  @override
  String get roleCustomerTitle => 'عميل';

  @override
  String get roleCustomerSubtitle => 'احجز الخدمات، تابع السجل، وأدر ملفك.';

  @override
  String get roleOwnerTitle => 'مالك صالون';

  @override
  String get roleOwnerSubtitle => 'أنشئ صالونك، ادعُ الموظفين، وأدر التشغيل.';

  @override
  String get roleSignOut => 'تسجيل الخروج';

  @override
  String get socialAuthOr => 'أو';

  @override
  String get socialAuthContinueTitle => 'المتابعة عبر';

  @override
  String get socialAuthGoogle => 'Google';

  @override
  String get socialAuthApple => 'Apple';

  @override
  String get socialAuthFacebook => 'Facebook';

  @override
  String get passwordStrengthHintWeak => 'أضف طولًا وامزج أحرفًا وأرقامًا.';

  @override
  String get passwordStrengthHintOk => 'بداية جيدة—فكّر بعبارة أطول.';

  @override
  String get passwordStrengthHintStrong => 'قوية وفق الحد الأدنى للتطبيق.';

  @override
  String get passwordStrengthHintExcellent => 'ممتازة—صعبة التخمين.';

  @override
  String passwordStrengthSemanticLabel(String level) {
    return 'قوة كلمة المرور: $level';
  }

  @override
  String get accessibilityShowPassword => 'إظهار كلمة المرور';

  @override
  String get accessibilityHidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginHintEmail => 'you@example.com';

  @override
  String get loginHintPassword => 'كلمة المرور';

  @override
  String get validationCountryRequired =>
      'اختر بلدك لننسّق رقم هاتفك بشكل صحيح.';

  @override
  String get validationBusinessTypeRequired => 'اختر نوع الصالون.';

  @override
  String get fieldLabelCountry => 'البلد';

  @override
  String get fieldLabelCity => 'المدينة';

  @override
  String get fieldLabelStreet => 'الشارع';

  @override
  String get fieldLabelBuildingUnit => 'المبنى / الوحدة';

  @override
  String get fieldLabelPostalCode => 'الرمز البريدي (اختياري)';

  @override
  String get fieldLabelSalonPhoneOptional => 'هاتف الصالون (اختياري)';

  @override
  String get fieldLabelBusinessType => 'نوع النشاط';

  @override
  String get businessTypeBarber => 'صالون حلاقة';

  @override
  String get businessTypeWomenSalon => 'صالون نسائي';

  @override
  String get businessTypeUnisex => 'للجميع';

  @override
  String get onboardingSearchCountryHint => 'ابحث عن البلد أو الرمز';

  @override
  String get onboardingCountryPopularSection => 'دول شائعة';

  @override
  String get onboardingCountryAllSection => 'جميع الدول';

  @override
  String get customerSignupEyebrow => 'عميل';

  @override
  String get customerSignupTitle => 'أنشئ حسابك كعميل';

  @override
  String get customerSignupDescription =>
      'نحفظ ملفك بأمان لحجز الزيارات وإدارتها.';

  @override
  String get customerSignupAddressHint =>
      'يساعد الصالونات على التعرّف عليك وإرسال تحديثات الحجز.';

  @override
  String get customerSignupSubmit => 'إنشاء الحساب';

  @override
  String get salonOwnerSignupEyebrow => 'مالك صالون';

  @override
  String get salonOwnerSignupTitle => 'حساب المالك — الخطوة 1 من 2';

  @override
  String get salonOwnerSignupDescription =>
      'بعدها ستضيف موقع الصالون ونوع النشاط.';

  @override
  String get salonOwnerSignupSubmit => 'متابعة لتفاصيل الصالون';

  @override
  String get onboardingMobileNationalHint => 'الرقم المحلي بدون مفتاح البلد';

  @override
  String get createSalonBusinessTypeSection => 'نوع النشاط';

  @override
  String get createSalonLocationSection => 'الموقع';

  @override
  String get createSalonContactSection => 'التواصل (اختياري)';

  @override
  String get createSalonProfileSyncTimeout =>
      'تم حفظ الصالون لكن لم نتمكن من تأكيد ملفك بعد. تحقق من الاتصال ثم اسحب للتحديث أو سجّل الخروج والدخول مجددًا.';

  @override
  String get accountProfileBootstrapEyebrow => 'استكمال الحساب';

  @override
  String get accountProfileBootstrapTitleMissing => 'أكمل إعداد ملفك';

  @override
  String get accountProfileBootstrapDescriptionMissing =>
      'تعذّر تحميل ملفك المحفوظ. اختر كيف تستخدم التطبيق لإنشاء سجل المستخدم، أو سجّل الدخول بحساب آخر إذا كان هذا الحساب جديدًا.';

  @override
  String get accountProfileBootstrapTitleStaff => 'ملف عضو الفريق غير مكتمل';

  @override
  String get accountProfileBootstrapDescriptionStaff =>
      'حسابك يفتقد الربط بالصالون (معرّف الصالون أو الموظف). يحدث هذا عادة إذا لم يكتمل الملف أو حُذفت بيانات. سجّل الخروج واطلب من مالك الصالون إعادة دعوتك، أو استخدم حسابًا آخر.';

  @override
  String get accountProfileBootstrapContinueCustomer => 'أحجز كعميل';

  @override
  String get accountProfileBootstrapContinueOwner => 'أدير صالونًا (مالك)';

  @override
  String get accountProfileBootstrapCreateProfile => 'إنشاء ملفي';

  @override
  String get accountProfileBootstrapChoosePath => 'اختر أحد الخيارين للمتابعة:';

  @override
  String get accountProfileBootstrapFooterDifferentAccount =>
      'استخدام حساب آخر';

  @override
  String get accountProfileBootstrapErrorNoAuthUser =>
      'لا يوجد مستخدم مسجّل. سجّل الدخول مجددًا.';

  @override
  String get accountProfileBootstrapErrorGeneric =>
      'تعذّر حفظ الملف. حاول مرة أخرى.';

  @override
  String get ownerStaffInviteSuccessTitle => 'تمت إضافة عضو الفريق';

  @override
  String ownerStaffInviteSuccessBody(
    String name,
    String email,
    String password,
  ) {
    return 'يمكن لـ $name تسجيل الدخول بهذا البريد وكلمة مرور مؤقتة. اطلب منه تغيير كلمة المرور بعد أول دخول.\n\nالبريد:\n$email\n\nكلمة المرور المؤقتة:\n$password';
  }

  @override
  String get ownerStaffInviteOk => 'تم';

  @override
  String get staffInviteErrorEmailTaken =>
      'اسم المستخدم محجوز أو الحساب موجود مسبقًا';

  @override
  String get staffInviteErrorPermission =>
      'يمكن للمالكين والمشرفين فقط إنشاء حسابات للموظفين';

  @override
  String get staffInviteErrorNetwork =>
      'خطأ في الشبكة. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get staffInviteErrorInvalidArgs =>
      'بعض البيانات غير صالحة. راجع الحقول وحاول مرة أخرى.';

  @override
  String get staffInviteErrorGeneric =>
      'تعذّر إنشاء حساب الحلاق. حاول مرة أخرى.';

  @override
  String ownerHeaderGreeting(String name) {
    return 'أهلاً، $name';
  }

  @override
  String get ownerOverviewGreetingMorning => 'صباح الخير';

  @override
  String get ownerOverviewGreetingAfternoon => 'مساء الخير';

  @override
  String get ownerOverviewGreetingEvening => 'مساء الخير';

  @override
  String get ownerOverviewHeroSearchHint =>
      'ابحث في فريقك، الإيرادات، والطلبات';

  @override
  String get ownerOverviewRevenueMonthLabel => 'إيرادات هذا الشهر';

  @override
  String get ownerOverviewRevenueMonthHintEmpty => 'لم يتم تسجيل مبيعات بعد';

  @override
  String get ownerOverviewRevenueMonthSubtitle =>
      'اتجاه الإيرادات للشهر الحالي';

  @override
  String get ownerOverviewRevenueMonthEmpty => 'لا توجد إيرادات هذا الشهر بعد';

  @override
  String ownerOverviewRevenueMonthTotal(String amount) {
    return 'إجمالي الشهر: $amount';
  }

  @override
  String get ownerOverviewRevenuePeriodDay => 'يوم';

  @override
  String get ownerOverviewRevenuePeriodMonth => 'شهر';

  @override
  String get ownerOverviewRevenuePeriodWeek => 'أسبوع';

  @override
  String get ownerOverviewRevenueTodayByHourTitle => 'إيراد اليوم';

  @override
  String get ownerOverviewRevenueTodayByHourSubtitle =>
      'حسب الساعة (بتوقيتك المحلي)';

  @override
  String get ownerOverviewRevenueTodayByHourEmpty => 'لا إيراد مسجّل اليوم بعد';

  @override
  String ownerOverviewRevenueTodayByHourTotal(String amount) {
    return 'إجمالي اليوم: $amount';
  }

  @override
  String get ownerOverviewRevenueThisWeekTitle => 'إيرادات هذا الأسبوع';

  @override
  String get ownerOverviewRevenueThisWeekSubtitle =>
      'اتجاه الإيرادات للأسبوع الحالي';

  @override
  String get ownerOverviewRevenueThisWeekEmpty =>
      'لا توجد إيرادات هذا الأسبوع بعد';

  @override
  String ownerOverviewRevenueThisWeekTotal(String amount) {
    return 'إجمالي الأسبوع: $amount';
  }

  @override
  String get ownerOverviewTeamPerformanceTitle => 'أداء الفريق';

  @override
  String get ownerOverviewTeamPerformanceSubtitle =>
      'أعلى الإيرادات اليوم للحلاقين';

  @override
  String get ownerOverviewTeamPerformanceEmpty => 'لا خدمات مسجّلة اليوم بعد';

  @override
  String get ownerOverviewTeamPerformanceError => 'تعذّر تحميل أداء الفريق';

  @override
  String get ownerOverviewTeamPerformanceFallbackName => 'عضو الفريق';

  @override
  String ownerOverviewTeamPerformanceServicesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خدمة اليوم',
      many: '$count خدمة اليوم',
      few: '$count خدمات اليوم',
      two: 'خدمتان اليوم',
      one: 'خدمة واحدة اليوم',
      zero: '0 خدمات اليوم',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewKpiPendingRequests => 'طلبات معلّقة';

  @override
  String get ownerOverviewKpiPendingApprovals => 'موافقات معلّقة';

  @override
  String get ownerOverviewDashboardTagline =>
      'تابع الإيرادات والفريق والحجوزات من مكان واحد.';

  @override
  String get ownerOverviewTodayInsightTitle => 'رؤية اليوم';

  @override
  String get ownerOverviewTodayInsightNoActivity =>
      'لا يوجد نشاط اليوم بعد. ابدأ بإضافة بيع أو حجز.';

  @override
  String ownerOverviewTodayInsightRevenue(String amount) {
    return 'أداؤك جيد اليوم. الإيراد $amount.';
  }

  @override
  String ownerOverviewTodayInsightBookings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لديك $count حجز اليوم. حافظ على حركة التقويم.',
      many: 'لديك $count حجزًا اليوم. حافظ على حركة التقويم.',
      few: 'لديك $count حجوزات اليوم. حافظ على حركة التقويم.',
      two: 'لديك حجزان اليوم. حافظ على تنظيم التقويم.',
      one: 'لديك حجز واحد اليوم. اجعله زيارة سلسة.',
      zero: 'لا توجد حجوزات اليوم بعد.',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewTodayInsightPendingRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب يحتاج إلى مراجعة.',
      many: '$count طلبًا يحتاج إلى مراجعة.',
      few: '$count طلبات تحتاج إلى مراجعة.',
      two: 'طلبان يحتاجان إلى مراجعة.',
      one: 'طلب واحد يحتاج إلى مراجعة.',
      zero: 'لا توجد طلبات للمراجعة.',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewTodayInsightPendingApprovals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب حضور يحتاج إلى مراجعتك.',
      many: '$count طلب حضور يحتاج إلى مراجعتك.',
      few: '$count طلبات حضور تحتاج إلى مراجعتك.',
      two: 'طلبا حضور يحتاجان إلى مراجعتك.',
      one: 'طلب حضور واحد يحتاج إلى مراجعتك.',
      zero: 'لا توجد طلبات حضور للمراجعة.',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewRecentServicesTitle => 'أحدث الخدمات';

  @override
  String get ownerOverviewRecentServicesEmpty => 'لا توجد خدمات نشطة بعد.';

  @override
  String get ownerOverviewPerformanceNoData => 'لا توجد بيانات بعد';

  @override
  String ownerOverviewBestServiceSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أفضل خدمة هذا الأسبوع · $count عملية بيع',
      many: 'أفضل خدمة هذا الأسبوع · $count عملية بيع',
      few: 'أفضل خدمة هذا الأسبوع · $count مبيعات',
      two: 'أفضل خدمة هذا الأسبوع · عمليتا بيع',
      one: 'أفضل خدمة هذا الأسبوع · عملية بيع واحدة',
      zero: 'أفضل خدمة هذا الأسبوع · لا مبيعات',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewBestBarberSubtitle(String amount) {
    return 'أفضل عضو فريق اليوم · $amount';
  }

  @override
  String get ownerOverviewRecentActivityTitle => 'النشاط الأخير';

  @override
  String get ownerOverviewRecentActivityEmpty => 'لا يوجد نشاط حديث بعد';

  @override
  String ownerOverviewLatestSaleSubtitle(String service, String amount) {
    return 'آخر بيع: $service · $amount';
  }

  @override
  String get ownerOverviewLatestSaleFallbackService => 'عملية بيع';

  @override
  String get ownerOverviewViewTeam => 'عرض الفريق';

  @override
  String get ownerOverviewSmartCardServiceTitle => 'أضف خدمتك الأولى';

  @override
  String get ownerOverviewSmartCardServiceSubtitle =>
      'يحتاج العملاء إلى قائمة للحجز.';

  @override
  String get ownerOverviewSmartCardBarberTitle => 'أضف حلّاقك الأول';

  @override
  String get ownerOverviewSmartCardBarberSubtitle =>
      'يظهر الطاقم على الأرضية وفي الرواتب.';

  @override
  String get ownerOverviewSmartCardBookingTitle => 'أنشئ حجزك الأول';

  @override
  String get ownerOverviewSmartCardBookingSubtitle =>
      'املأ التقويم وتابع الإيرادات.';

  @override
  String ownerOverviewRevenueTodayLine(String amount) {
    return 'اليوم: $amount';
  }

  @override
  String ownerOverviewRevenueDeltaUp(String percent) {
    return '$percent مقارنةً بالشهر الماضي';
  }

  @override
  String ownerOverviewRevenueDeltaDown(String percent) {
    return '$percent مقارنةً بالشهر الماضي';
  }

  @override
  String get ownerOverviewStatRevenueToday => 'إيراد اليوم';

  @override
  String get ownerOverviewStatBookingsToday => 'حجوزات اليوم';

  @override
  String get ownerOverviewStatServicesToday => 'خدمات اليوم';

  @override
  String get ownerOverviewStatCompletedToday => 'المكتملة';

  @override
  String get ownerOverviewStatCheckedIn => 'الحضور';

  @override
  String get ownerOverviewStatWorkingNow => 'يعملون الآن';

  @override
  String get ownerOverviewQuickActionsTitle => 'إجراءات سريعة';

  @override
  String get ownerOverviewQuickAddSale => 'إضافة بيع';

  @override
  String get ownerOverviewQuickAddExpense => 'إضافة مصروف';

  @override
  String get ownerOverviewNeedsAttentionTitle => 'يحتاج إلى مراجعة';

  @override
  String get ownerOverviewNeedsAttentionNone =>
      'كل شيء تمام. لا يوجد ما يستدعي الانتباه الآن.';

  @override
  String get ownerOverviewFabLabel => 'إضافة سريعة';

  @override
  String get ownerOverviewRunPayroll => 'تشغيل الرواتب';

  @override
  String get ownerOverviewSmartSuggestionsTitle => 'اقتراحات ذكية';

  @override
  String get ownerOverviewSmartSuggestionsSubtitle =>
      'ابدأ بالأساسيات لضبط الحجوزات والمدفوعات.';

  @override
  String get ownerOverviewSmartAddBarber => 'إضافة حلاق';

  @override
  String get ownerOverviewSmartAddService => 'إضافة خدمة';

  @override
  String get ownerOverviewSmartCreateBooking => 'إنشاء حجز';

  @override
  String get ownerOverviewStatDeltaSameAsYesterday => 'مثل أمس';

  @override
  String ownerOverviewStatDeltaVsYesterday(String amount) {
    return '$amount مقارنةً بالأمس';
  }

  @override
  String get ownerOverviewKpiBadgeLive => 'نشط';

  @override
  String get ownerOverviewKpiBadgeQuiet => 'هادئ';

  @override
  String get ownerOverviewKpiBadgeBusy => 'مزدحم';

  @override
  String get ownerOverviewKpiBadgeDone => 'تم';

  @override
  String get ownerOverviewKpiBadgeNone => 'لا يوجد';

  @override
  String get ownerOverviewKpiBadgeOnFloor => 'على الأرض';

  @override
  String ownerOverviewRevenueLastMonthTotal(String amount) {
    return 'الشهر الماضي: $amount';
  }

  @override
  String get ownerOverviewRevenueNoPriorMonthCompare =>
      'لا مبيعات مكتملة الشهر الماضي للمقارنة';

  @override
  String get ownerOverviewRevenueDeltaFlatVsLastMonth =>
      'مستقر مقارنةً بالشهر الماضي';

  @override
  String ownerOverviewAttentionPendingBookings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حجز بانتظار التأكيد',
      many: '$count حجزًا بانتظار التأكيد',
      few: '$count حجوزات بانتظار التأكيد',
      two: 'حجزان بانتظار التأكيد',
      one: 'حجز واحد بانتظار التأكيد',
      zero: 'لا توجد حجوزات بانتظار التأكيد',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewAttentionPendingApprovals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب حضور للمراجعة',
      many: '$count طلب حضور للمراجعة',
      few: '$count طلبات حضور للمراجعة',
      two: 'طلبا حضور للمراجعة',
      one: 'طلب حضور واحد للمراجعة',
      zero: 'لا توجد طلبات حضور',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewAttentionPayrollPending =>
      'لم يتم تشغيل الرواتب لهذا الشهر بعد.';

  @override
  String get ownerOverviewAttentionNoServices =>
      'أضف خدمة واحدة على الأقل حتى يستطيع العملاء الحجز.';

  @override
  String get ownerOverviewReview => 'مراجعة';

  @override
  String get ownerOverviewSeeAll => 'عرض الكل';

  @override
  String get ownerOverviewTeamCardTitle => 'الفريق';

  @override
  String ownerOverviewTeamCardSubtitle(int active, int checkedIn) {
    return '$active نشط · $checkedIn حاضر اليوم';
  }

  @override
  String ownerOverviewTeamCardTopBarber(String name) {
    return 'أفضل عضو فريق اليوم: $name';
  }

  @override
  String ownerOverviewTeamCardInactive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو غير نشط',
      many: '$count عضوًا غير نشط',
      few: '$count أعضاء غير نشطين',
      two: 'عضوان غير نشطين',
      one: 'عضو غير نشط',
      zero: 'لا يوجد أعضاء غير نشطين',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewServicesCardTitle => 'الخدمات';

  @override
  String ownerOverviewServicesCardSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خدمة نشطة',
      many: '$count خدمة نشطة',
      few: '$count خدمات نشطة',
      two: 'خدمتان نشطتان',
      one: 'خدمة نشطة واحدة',
      zero: 'لا توجد خدمات نشطة بعد',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewServicesAveragePrice(String amount) {
    return 'متوسط السعر: $amount';
  }

  @override
  String ownerOverviewServicesTopToday(String name) {
    return 'الأعلى اليوم: $name';
  }

  @override
  String ownerOverviewServicesTopMonth(String name) {
    return 'الأكثر حجزًا هذا الشهر: $name';
  }

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String ownerOverviewAttentionInactiveEmployees(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو غير نشط بانتظار المراجعة',
      many: '$count عضوًا غير نشط بانتظار المراجعة',
      few: '$count أعضاء غير نشطين بانتظار المراجعة',
      two: 'عضوان غير نشطان بانتظار المراجعة',
      one: 'عضو فريق غير نشط بانتظار المراجعة',
      zero: 'لا يوجد أعضاء فريق غير نشطين',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewInsightsTitle => 'ملخّص الأداء';

  @override
  String ownerOverviewInsightRevenueUp(String percent) {
    return 'الإيرادات ارتفعت بنسبة $percent مقارنةً بالشهر الماضي.';
  }

  @override
  String ownerOverviewInsightRevenueDown(String percent) {
    return 'الإيرادات انخفضت بنسبة $percent مقارنةً بالشهر الماضي.';
  }

  @override
  String get ownerOverviewInsightRevenueFlat =>
      'لا تغيير يُذكر في الإيرادات مقارنةً بالشهر الماضي.';

  @override
  String get ownerOverviewInsightRevenueFresh =>
      'بداية جديدة لهذا الشهر — لا يوجد ما يُقارن به بعد.';

  @override
  String ownerOverviewInsightTopBarberContribution(
    String name,
    String percent,
  ) {
    return '$name حقّق $percent من إيرادات اليوم.';
  }

  @override
  String get ownerOverviewInsightTopBarberEmpty =>
      'لا يوجد نشاط لأي عضو فريق اليوم بعد.';

  @override
  String ownerOverviewInsightPopularService(String name) {
    return '$name هي الخدمة الأكثر طلبًا هذا الشهر.';
  }

  @override
  String get ownerOverviewAddExpenseTitle => 'إضافة مصروف';

  @override
  String get ownerOverviewAddExpenseSubtitle => 'سجّل مصروف الصالون بسرعة.';

  @override
  String get ownerOverviewAddExpenseTitleField => 'العنوان';

  @override
  String get ownerOverviewAddExpenseCategoryField => 'الفئة';

  @override
  String get ownerOverviewAddExpenseAmountField => 'المبلغ';

  @override
  String get ownerOverviewAddExpenseVendorField => 'المورد (اختياري)';

  @override
  String get ownerOverviewAddExpenseNotesField => 'ملاحظات (اختياري)';

  @override
  String get ownerOverviewAddExpenseSubmit => 'حفظ المصروف';

  @override
  String get ownerOverviewAddExpenseDateField => 'التاريخ';

  @override
  String get ownerOverviewAddExpenseSuggestedCategories => 'فئات مقترحة';

  @override
  String get ownerOverviewAddExpenseValidationError =>
      'يرجى إدخال العنوان والفئة ومبلغ موجب.';

  @override
  String get ownerOverviewExpenseCreated => 'تم تسجيل المصروف';

  @override
  String ownerOverviewSummaryEarnedFromSales(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بيعة مكتملة',
      many: '$count بيعة مكتملة',
      few: '$count مبيعات مكتملة',
      two: 'بيعتين مكتملتين',
      one: 'بيعة مكتملة واحدة',
      zero: 'لا مبيعات مكتملة',
    );
    return 'ربحت اليوم $amount من $_temp0.';
  }

  @override
  String ownerOverviewSummaryEarnedOnly(String amount) {
    return 'ربحت اليوم $amount.';
  }

  @override
  String get ownerOverviewSummaryNoSalesToday => 'لا مبيعات مكتملة اليوم بعد.';

  @override
  String ownerOverviewSummaryPendingSegment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حجز بانتظار التأكيد',
      many: '$count حجزًا بانتظار التأكيد',
      few: '$count حجوزات بانتظار التأكيد',
      two: 'حجزان بانتظار التأكيد',
      one: 'حجز واحد بانتظار التأكيد',
      zero: 'لا حجوزات بانتظار التأكيد',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewSummaryBarbersCheckedInSegment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو فريق سجّل حضورًا',
      many: '$count عضو فريق سجّلوا حضورًا',
      few: '$count أعضاء فريق سجّلوا حضورًا',
      two: 'عضوا فريق سجّلا حضورًا',
      one: 'عضو فريق واحد سجّل حضورًا',
      zero: 'لا أحد من أعضاء الفريق سجّل حضورًا',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewSummaryPayrollPendingSegment =>
      'الرواتب بانتظار التشغيل';

  @override
  String get ownerOverviewEmptyBookingsTodayTitle => 'لا حجوزات اليوم.';

  @override
  String get ownerOverviewEmptyCompletedTodayTitle =>
      'لا خدمات مكتملة اليوم بعد.';

  @override
  String get ownerOverviewEmptyCheckedInTitle => 'لم يسجّل أحد حضوره بعد.';

  @override
  String get ownerOverviewTeamMarkAttendance => 'تسجيل الحضور';

  @override
  String ownerOverviewTeamActiveBarbersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو فريق نشط',
      many: '$count عضو فريق نشطًا',
      few: '$count أعضاء فريق نشطون',
      two: 'عضوا فريق نشطان',
      one: 'عضو فريق نشط واحد',
      zero: 'لا أعضاء فريق بعد',
    );
    return '$_temp0';
  }

  @override
  String ownerOverviewTeamCheckedInShort(int count) {
    return '$count سجّلوا حضورهم';
  }

  @override
  String get ownerOverviewTeamEmptyTitle => 'لم تُضف أي عضو فريق بعد.';

  @override
  String get ownerOverviewTeamEmptyBody =>
      'أضف أول عضو فريق لتبدأ تتبّع الحضور والمبيعات.';

  @override
  String get ownerOverviewTeamStatusCheckedIn => 'حاضر';

  @override
  String get ownerOverviewTeamStatusNotCheckedIn => 'لم يُسجَّل الحضور';

  @override
  String get ownerOverviewTeamStatusOnService => 'في الخدمة';

  @override
  String get ownerOverviewTeamStatusLate => 'متأخر';

  @override
  String ownerOverviewInsightTopServiceWeek(String name) {
    return '$name هي الخدمة الأكثر طلبًا هذا الأسبوع.';
  }

  @override
  String ownerOverviewInsightBookingsUp(String percent) {
    return 'الحجوزات ارتفعت بنسبة $percent مقارنةً بالأمس.';
  }

  @override
  String ownerOverviewInsightBookingsDown(String percent) {
    return 'الحجوزات انخفضت بنسبة $percent مقارنةً بالأمس.';
  }

  @override
  String get ownerOverviewInsightNoBookingsToday =>
      'لا حجوزات اليوم — أهدأ من الأمس.';

  @override
  String get ownerOverviewInsightsGrowing =>
      'ستظهر الرؤى هنا مع نمو نشاط صالونك.';

  @override
  String ownerOverviewAttentionBarbersNotCheckedIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو فريق لم يُسجّل حضوره',
      many: '$count عضو فريق لم يُسجّلوا حضورهم',
      few: '$count أعضاء فريق لم يُسجّلوا حضورهم',
      two: 'عضوا فريق لم يُسجّلا حضورهما',
      one: 'عضو فريق واحد لم يُسجّل حضوره',
    );
    return '$_temp0';
  }

  @override
  String get ownerOverviewFabSheetTitle => 'إجراءات سريعة';

  @override
  String get ownerOverviewFabBookAppointment => 'حجز موعد';

  @override
  String get attendanceReviewTitle => 'طلبات الحضور';

  @override
  String get attendanceReviewEmptyTitle =>
      'لا توجد طلبات حضور بانتظار المراجعة';

  @override
  String get attendanceReviewEmptyMessage => 'كل شيء محدّث.';

  @override
  String get attendanceReviewErrorTitle => 'تعذّر تحميل الطلبات';

  @override
  String get attendanceReviewStatusPending => 'بانتظار المراجعة';

  @override
  String get attendanceReviewApprove => 'موافقة';

  @override
  String get attendanceReviewReject => 'رفض';

  @override
  String get attendanceReviewRejectDialogTitle => 'أضف ملاحظة رفض';

  @override
  String get attendanceReviewRejectDialogHint =>
      'اختياري — يساعد الموظف على الفهم.';

  @override
  String get attendanceReviewRejectConfirm => 'رفض';

  @override
  String attendanceReviewCheckInAt(String time) {
    return 'تم تسجيل الدخول في $time';
  }

  @override
  String attendanceReviewCheckOutAt(String time) {
    return 'تم تسجيل الخروج في $time';
  }

  @override
  String attendanceReviewSubmittedAt(String time) {
    return 'تم الإرسال في $time';
  }

  @override
  String get attendanceReviewUnknownEmployee => 'موظّف غير معروف';

  @override
  String get attendanceReviewTypePresent => 'طلب تعديل حضور';

  @override
  String get attendanceReviewTypeAbsent => 'طلب غياب';

  @override
  String get attendanceReviewTypeLeave => 'طلب إجازة';

  @override
  String get attendanceReviewTypeGeneric => 'طلب حضور';

  @override
  String get attendanceReviewApprovedSnackbar => 'تمت الموافقة على الحضور';

  @override
  String get attendanceReviewRejectedSnackbar => 'تم رفض الحضور';

  @override
  String attendanceReviewErrorSnackbar(String message) {
    return 'تعذّر التحديث: $message';
  }

  @override
  String get teamManagementTitle => 'الفريق';

  @override
  String get teamManagementSubtitle => 'إدارة أعضاء فريقك والمشرفين';

  @override
  String get teamSummaryTotalBarbers => 'إجمالي أعضاء الفريق';

  @override
  String get teamSummaryCheckedInToday => 'المسجّلون اليوم';

  @override
  String get teamSummarySalesToday => 'مبيعات اليوم';

  @override
  String get teamSummaryCommissionToday => 'عمولة اليوم';

  @override
  String get teamSummaryTotalMembers => 'إجمالي الأعضاء';

  @override
  String get teamSummaryTotalMembersHelper => 'قائمة الفريق';

  @override
  String get teamSummaryWorkingNow => 'يعملون الآن';

  @override
  String teamSummaryWorkingNowHelper(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'من $count أعضاء',
      one: 'من عضو واحد',
      zero: 'لا يوجد أعضاء بعد',
    );
    return '$_temp0';
  }

  @override
  String get teamSummaryAbsentToday => 'غائبون اليوم';

  @override
  String get teamSummaryAbsentTodayHelper => 'يحتاج متابعة';

  @override
  String get teamSummaryRevenueToday => 'إيراد اليوم';

  @override
  String get teamSummaryRevenueTodayHelper => 'مبيعات مباشرة';

  @override
  String get teamAnalyticsAction => 'تحليلات الفريق';

  @override
  String get teamAnalyticsComingSoon => 'ستتوفر تحليلات الفريق قريبًا.';

  @override
  String get teamAnalyticsActiveInactiveLabel => 'نشط / غير نشط';

  @override
  String get teamAnalyticsTopPerformerLabel => 'الأفضل أداءً';

  @override
  String get teamGuideDescription =>
      'يساعدك أعضاء الفريق على إدارة الحضور والخدمات والمبيعات والعمولات والرواتب من مكان واحد.';

  @override
  String get teamFilterAll => 'الكل';

  @override
  String get teamFilterActive => 'نشط';

  @override
  String get teamFilterCheckedIn => 'حاضر';

  @override
  String get teamFilterWorking => 'يعمل الآن';

  @override
  String get teamFilterInactive => 'غير نشط';

  @override
  String get teamFilterTopSellers => 'الأعلى مبيعًا';

  @override
  String get teamFilterTopPerformers => 'الأفضل أداءً';

  @override
  String get teamFilterTopServices => 'أعلى الخدمات';

  @override
  String get teamFilterTopPerformance => 'أعلى أداء';

  @override
  String get teamFilterOldest => 'الأقدم';

  @override
  String get teamFilterNewest => 'الأحدث';

  @override
  String get teamFilterNeedsAttention => 'يحتاج متابعة';

  @override
  String get teamAddBarberAction => 'إضافة عضو فريق';

  @override
  String get teamHeroSearchHint => 'ابحث عن عضو بالاسم أو الهاتف';

  @override
  String get teamSearchHint => 'ابحث عن عضو بالاسم أو الهاتف';

  @override
  String get teamMemberWhatsAppNoPhone => 'لا يوجد رقم هاتف لهذا العضو';

  @override
  String get teamFilterAction => 'تصفية الفريق';

  @override
  String get teamSortAction => 'ترتيب الفريق';

  @override
  String get teamSortSheetTitle => 'ترتيب حسب';

  @override
  String get teamSortNameAsc => 'الاسم أ–ي';

  @override
  String get teamSortNameDesc => 'الاسم ي–أ';

  @override
  String get teamSortRole => 'الدور';

  @override
  String get teamSortJoinedNewest => 'الأحدث تعيينًا';

  @override
  String get teamSortJoinedOldest => 'الأقدم تعيينًا';

  @override
  String get teamSortSalesToday => 'مبيعات اليوم';

  @override
  String get teamSortSalesMonth => 'مبيعات الشهر';

  @override
  String get teamEmptyTitle => 'لا يوجد أعضاء في الفريق بعد';

  @override
  String get teamEmptySubtitle =>
      'أضف أول عضو فريق لبدء تتبّع الحضور والمبيعات والرواتب.';

  @override
  String get teamEmptyBuildTitle => 'ابنِ فريقك';

  @override
  String get teamEmptyBuildSubtitle =>
      'أضف أول عضو فريق أو مشرف لبدء تتبّع الحضور والمبيعات والعمولات والرواتب.';

  @override
  String get teamEmptyNoMatchTitle => 'لا يوجد عضو فريق مطابق';

  @override
  String teamEmptyNoMatchSubtitle(String query) {
    return 'لم نجد أي نتيجة تطابق \"$query\". جرّب اسمًا أو هاتفًا أو رقم موظف أو دورًا آخر.';
  }

  @override
  String teamEmptyNoFilterResultTitle(String filter) {
    return 'لا يوجد أعضاء فريق بحالة $filter';
  }

  @override
  String teamEmptyNoFilterResultSubtitle(String filter) {
    return 'لا يوجد أعضاء فريق ضمن حالة $filter حاليًا. امسح الفلاتر أو اختر حالة مختلفة.';
  }

  @override
  String get teamEmptyPrimaryClearSearch => 'مسح البحث';

  @override
  String get teamEmptyPrimaryAddMember => 'إضافة عضو فريق';

  @override
  String get teamEmptySecondaryAddMember => 'إضافة عضو فريق';

  @override
  String get teamEmptySecondaryLearnHow => 'تعرّف كيف يعمل الفريق';

  @override
  String get teamLoadErrorTitle => 'تعذّر تحميل الفريق';

  @override
  String get teamStatusActive => 'نشط';

  @override
  String get teamStatusCheckedIn => 'حاضر';

  @override
  String get teamStatusLate => 'متأخر';

  @override
  String get teamStatusInactive => 'غير نشط';

  @override
  String get teamMemberMoreActions => 'إجراءات إضافية';

  @override
  String get teamMemberViewProfileAction => 'عرض الملف';

  @override
  String get teamMemberEditAction => 'تعديل العضو';

  @override
  String get teamMemberAttendanceAction => 'الحضور';

  @override
  String get teamMemberPayrollAction => 'الرواتب';

  @override
  String get teamMemberDeactivateAction => 'إيقاف';

  @override
  String get teamMemberActivateAction => 'تفعيل';

  @override
  String get teamMemberResetPasswordPlaceholder =>
      'إعادة تعيين كلمة المرور لاحقًا';

  @override
  String get teamMemberSalesToday => 'مبيعات اليوم';

  @override
  String get teamMemberServicesToday => 'خدمات اليوم';

  @override
  String get teamMemberServicesShort => 'الخدمات';

  @override
  String get teamMemberRevenueToday => 'الإيراد';

  @override
  String get teamMemberPerformance => 'الأداء';

  @override
  String teamMemberPerformancePercent(int percent) {
    return '$percent%';
  }

  @override
  String get teamMemberCommissionToday => 'عمولة اليوم';

  @override
  String get employeeDashboardFirestorePermissionBanner =>
      'تعذّر تحميل حضورك. اطلب من المشرف نشر أحدث صلاحيات قاعدة البيانات.';

  @override
  String get employeeDashboardAttendanceNotStartedYet => 'لم يبدأ بعد';

  @override
  String get teamMemberNoAttendanceToday => 'لا يوجد حضور اليوم بعد';

  @override
  String get teamMemberNotCheckedIn => 'لم يسجل الحضور';

  @override
  String get teamMemberInactiveStatus => 'غير نشط';

  @override
  String get teamCardAttendanceNotRequired => 'لا يُطلب تسجيل الحضور';

  @override
  String get teamCardAttendanceOnBreak => 'في استراحة';

  @override
  String get teamCardAccountFrozen => 'مجمّد';

  @override
  String teamMemberLateAt(String time) {
    return 'متأخر · $time';
  }

  @override
  String teamMemberCheckedOutAt(String time) {
    return 'تم تسجيل الخروج عند $time';
  }

  @override
  String teamMemberCheckedInAt(String time) {
    return 'تم تسجيل الحضور عند $time';
  }

  @override
  String get teamMemberAddSaleAction => 'إضافة بيع';

  @override
  String get teamMemberMarkAttendanceAction => 'تسجيل الحضور';

  @override
  String get teamMemberViewDetailsAction => 'عرض التفاصيل';

  @override
  String get teamFieldFullName => 'الاسم الكامل';

  @override
  String get teamFieldEmail => 'البريد الإلكتروني';

  @override
  String get teamFieldUsername => 'اسم المستخدم';

  @override
  String get teamFieldPhone => 'الهاتف';

  @override
  String get teamFieldHiringDate => 'تاريخ التعيين';

  @override
  String get teamFieldHiringDateHint =>
      'يُعدّل الراتب الأساسي الشهري في الرواتب وفق أيام الشهر اعتبارًا من هذا التاريخ.';

  @override
  String get teamFieldRole => 'الدور';

  @override
  String get teamRoleRequired => 'اختر الدور.';

  @override
  String get teamCommissionValueRequired => 'أدخل قيمة العمولة.';

  @override
  String get teamCommissionValueInvalid => 'أدخل قيمة عمولة صحيحة.';

  @override
  String get teamCommissionValueNegative => 'لا يمكن أن تكون العمولة سالبة.';

  @override
  String get teamSaveErrorGeneric => 'تعذّر حفظ بيانات عضو الفريق.';

  @override
  String teamAddBarberSuccess(String name) {
    return 'تمت إضافة $name إلى الفريق.';
  }

  @override
  String teamEditBarberSuccess(String name) {
    return 'تم تحديث $name.';
  }

  @override
  String get teamAddBarberSheetTitle => 'إضافة عضو فريق';

  @override
  String get teamEditBarberSheetTitle => 'تعديل عضو الفريق';

  @override
  String get teamAddBarberSheetSubtitle =>
      'اضبط الأساسيات الآن وأبقِ الملف جاهزًا للحضور والمبيعات والرواتب والحجوزات مستقبلًا.';

  @override
  String get teamPhotoPickerTitle => 'صورة الملف الشخصي';

  @override
  String get teamPhotoActionTake => 'التقاط صورة';

  @override
  String get teamPhotoActionGallery => 'اختيار من المعرض';

  @override
  String get teamPhotoActionRemove => 'إزالة الصورة';

  @override
  String get teamPhotoActionCancel => 'إلغاء';

  @override
  String get teamRolePickerTitle => 'اختر الدور';

  @override
  String get teamRolePickerSubtitle =>
      'حدّد ما يمكن لعضو الفريق الوصول إليه داخل الصالون.';

  @override
  String get teamRolePickerBarberTitle => 'عضو فريق';

  @override
  String get teamRolePickerBarberSubtitle =>
      'يمكنه تسجيل الخدمات وعرض حضوره ومبيعاته وكشوف رواتبه.';

  @override
  String get teamRolePickerBarberBadge => 'فريق الخدمة';

  @override
  String get teamRolePickerAdminTitle => 'مشرف';

  @override
  String get teamRolePickerAdminSubtitle =>
      'يمكنه إدارة العمليات اليومية حسب الصلاحيات التي يحددها المالك.';

  @override
  String get teamRolePickerAdminBadge => 'إدارة';

  @override
  String get teamCommissionPickerTitle => 'نوع العمولة';

  @override
  String get teamCommissionPickerSubtitle =>
      'اختر طريقة احتساب عمولة عضو الفريق.';

  @override
  String get teamCommissionPickerPercentageTitle => 'نسبة فقط';

  @override
  String get teamCommissionPickerPercentageSubtitle =>
      'تُحسب العمولة كنسبة من المبيعات.';

  @override
  String get teamCommissionPickerFixedTitle => 'مبلغ ثابت فقط';

  @override
  String get teamCommissionPickerFixedSubtitle =>
      'يحصل عضو الفريق على مبلغ ثابت لكل خدمة أو فترة.';

  @override
  String get teamCommissionPickerMixedTitle => 'نسبة + مبلغ ثابت';

  @override
  String get teamCommissionPickerMixedSubtitle =>
      'اجمع بين نسبة عمولة ومبلغ ثابت.';

  @override
  String get addBarberSheetHeroSubtitle =>
      'إنشاء حساب جديد لعضو الفريق وإعداد بياناته الأساسية.';

  @override
  String get addBarberSectionLoginPassword => 'الدخول وكلمة المرور';

  @override
  String get addBarberSectionCommissionWork => 'العمولة وإعدادات العمل';

  @override
  String get addBarberProfilePhotoTitle => 'صورة الملف الشخصي';

  @override
  String get addBarberProfilePhotoCaption => 'أضف صورة واضحة لعضو الفريق';

  @override
  String get addBarberProfilePhotoButton => 'أضف صورة';

  @override
  String get addBarberProfilePhotoAfterCreateSnack =>
      'يمكنك إضافة صورة الملف بعد إنشاء الحساب من ملف عضو الفريق.';

  @override
  String get addBarberMainTitle => 'تفاصيل حساب عضو الفريق';

  @override
  String get addBarberMainSubtitle =>
      'أنشئ بيانات تسجيل لعضو الفريق واضبط كلمة مرور أولية';

  @override
  String get addBarberSectionPersonalDetails => 'البيانات الشخصية';

  @override
  String get addBarberSectionAccountAccess => 'الوصول إلى الحساب';

  @override
  String get addBarberFieldFullName => 'الاسم الكامل';

  @override
  String get addBarberFieldEmailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get addBarberFieldUsername => 'اسم المستخدم';

  @override
  String get addBarberFieldPhoneNumber => 'رقم الجوال';

  @override
  String get addBarberFieldRole => 'الدور';

  @override
  String get addBarberFieldPassword => 'كلمة المرور';

  @override
  String get addBarberFieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get addBarberPlaceholderFullName => 'أدخل الاسم الكامل';

  @override
  String get addBarberPlaceholderEmail => 'أدخل عنوان البريد';

  @override
  String get addBarberHelperEmailLogin =>
      'يُستخدم هذا البريد لتسجيل الدخول مع كلمة المرور. يمكنهم أيضاً استخدام اسم المستخدم على شاشة «مستخدم».';

  @override
  String get addBarberPlaceholderUsername => 'مثال: jane.doe';

  @override
  String get addBarberPlaceholderPhone => 'أدخل رقم الجوال';

  @override
  String get addBarberPlaceholderPassword => 'أدخل كلمة المرور';

  @override
  String get addBarberPlaceholderConfirmPassword => 'أعد إدخال كلمة المرور';

  @override
  String get addBarberHelperPasswordShared =>
      'ستشارك كلمة المرور مع عضو الفريق بصفتك مالك الصالون';

  @override
  String get addBarberHelperMustChangePassword =>
      'سيُطلب من عضو الفريق تغيير كلمة المرور عند أول تسجيل دخول';

  @override
  String get addBarberPasswordRulesHint =>
      'استخدم 8 أحرف على الأقل تتضمّن أحرفًا كبيرة وصغيرة ورقمًا';

  @override
  String get addBarberValidationFullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get addBarberValidationEmailRequired =>
      'عنوان البريد الإلكتروني مطلوب';

  @override
  String get addBarberValidationEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get addBarberValidationEmailInternalNotAllowed =>
      'استخدم البريد الحقيقي لعضو الفريق، وليس عنوانًا داخليًا للتطبيق.';

  @override
  String get addBarberValidationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get addBarberValidationConfirmPasswordRequired =>
      'تأكيد كلمة المرور مطلوب';

  @override
  String get addBarberValidationPasswordMinLength =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get addBarberValidationPasswordComplexity =>
      'يجب أن تتضمّن كلمة المرور أحرفًا كبيرة وصغيرة ورقمًا';

  @override
  String get addBarberValidationPasswordsMismatch =>
      'كلمتا المرور غير متطابقتين';

  @override
  String get addBarberButtonCreate => 'إنشاء عضو فريق';

  @override
  String get addBarberButtonCreating => 'جارٍ إنشاء عضو فريق...';

  @override
  String get addBarberSuccessMessage => 'تم إنشاء عضو الفريق بنجاح';

  @override
  String get addBarberSuccessSubtext =>
      'اطلب منه تسجيل الدخول من شاشة «مستخدم» بهذا البريد أو اسم المستخدم وكلمة المرور التي ضبطتها، ثم التغيير عند أول دخول إن لزم';

  @override
  String get addBarberRequirePasswordChangeOnFirstLogin =>
      'طلب تغيير كلمة المرور عند أول تسجيل دخول';

  @override
  String get addBarberChecklistMinLength => '8 أحرف على الأقل';

  @override
  String get addBarberChecklistUppercase => 'تتضمّن حرفًا كبيرًا';

  @override
  String get addBarberChecklistLowercase => 'تتضمّن حرفًا صغيرًا';

  @override
  String get addBarberChecklistDigit => 'تتضمّن رقمًا';

  @override
  String get addBarberChecklistPasswordsMatch => 'كلمتا المرور متطابقتان';

  @override
  String get teamFieldCommissionType => 'نوع العمولة';

  @override
  String get teamCommissionTypePercentage => 'نسبة فقط';

  @override
  String get teamCommissionTypeFixed => 'مبلغ ثابت فقط';

  @override
  String get teamCommissionTypePercentagePlusFixed => 'نسبة + مبلغ ثابت';

  @override
  String get teamFieldCommissionPercentagePercent => 'نسبة العمولة (%)';

  @override
  String teamFieldCommissionFixedAmount(String currencyCode) {
    return 'مبلغ ثابت ($currencyCode)';
  }

  @override
  String get teamCommissionPercentInputHint => 'أدخل النسبة مثل 2 أو 10 أو 25';

  @override
  String get teamCommissionHelperPercentage =>
      'تحسب النسبة من إجمالي المبيعات والخدمات.';

  @override
  String get teamCommissionHelperFixed => 'يُضاف مبلغ ثابت لعمولة عضو الفريق.';

  @override
  String get teamCommissionHelperPercentagePlusFixed =>
      'تجمع بين نسبة من المبيعات ومبلغ ثابت.';

  @override
  String get teamCommissionPreviewLabel => 'قيمة العمولة التقديرية';

  @override
  String get teamCommissionPreviewDisclaimer => 'هذه القيمة للمعاينة فقط';

  @override
  String get teamCommissionPreviewSampleNote => 'مثال توضيحي فقط لحساب العمولة';

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
  String get teamCommissionPercentRequired => 'أدخل نسبة أكبر من 0.';

  @override
  String get teamCommissionPercentInvalidRange =>
      'يجب أن تكون النسبة بين 0 و100.';

  @override
  String get teamCommissionFixedInvalid => 'أدخل مبلغًا صحيحًا (0 أو أكثر).';

  @override
  String get teamCommissionCombinedInvalid =>
      'أدخل نسبة و/أو مبلغًا ثابتًا صالحًا.';

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
  String get teamFieldCommissionValue => 'قيمة العمولة';

  @override
  String get teamCommissionValueHelper =>
      'القيمة المستخدمة لحسابات المبيعات والرواتب.';

  @override
  String get teamFieldAttendanceRequired => 'الحضور مطلوب';

  @override
  String get teamFieldAttendanceRequiredHint => 'يقبل التعديل اليدوي للحضور';

  @override
  String get teamFieldBookable => 'قابل للحجز لاحقًا';

  @override
  String get teamFieldBookableHint =>
      'حضّر هذا الملف لتجربة حجز العملاء مستقبلًا.';

  @override
  String get teamFieldActiveStatus => 'حالة التفعيل';

  @override
  String get teamFieldActiveStatusHint =>
      'الأعضاء غير النشطين يُخفون من الإجراءات التشغيلية.';

  @override
  String get teamSaveBarberAction => 'حفظ عضو الفريق';

  @override
  String get teamSaveChangesAction => 'حفظ التغييرات';

  @override
  String get teamResetPasswordPlaceholderNotice =>
      'إعادة تعيين كلمة المرور ستُضاف في تحديث لاحق.';

  @override
  String teamMemberDeactivated(String name) {
    return 'تم إيقاف $name.';
  }

  @override
  String teamMemberActivated(String name) {
    return 'تم تفعيل $name.';
  }

  @override
  String get teamAttendanceMarkedSuccess => 'تم تسجيل الحضور.';

  @override
  String get teamAttendanceCheckoutSuccess => 'تم تسجيل الخروج.';

  @override
  String get teamAttendanceAlreadyCompleted => 'تم إكمال حضور اليوم بالفعل.';

  @override
  String get teamAttendanceMarkError => 'تعذّر تحديث الحضور.';

  @override
  String get teamMemberAttendanceAdminNoRecordTitle => 'لا يوجد حضور اليوم';

  @override
  String teamMemberAttendanceAdminNoRecordSubtitle(String name) {
    return 'لم يسجّل $name الحضور بعد.';
  }

  @override
  String get teamMemberAttendanceAdminCheckedInTitle => 'حاضر حالياً';

  @override
  String get teamMemberAttendanceAdminCheckedInSubtitle =>
      'تم تسجيل الدخول ولم يُسجَّل الخروج بعد.';

  @override
  String get teamMemberAttendanceAdminCompletedTitle => 'تم إكمال الحضور';

  @override
  String get teamMemberAttendanceAdminCompletedSubtitle =>
      'تم تسجيل الدخول والخروج لهذا اليوم.';

  @override
  String get teamMemberAttendanceStatusNone => 'بدون سجل';

  @override
  String get teamMemberAttendanceCheckInLabel => 'تسجيل حضور';

  @override
  String get teamMemberAttendanceCheckOutLabel => 'تسجيل انصراف';

  @override
  String get teamMemberAttendanceAddManual => 'إضافة حضور يدوي';

  @override
  String get teamMemberAttendanceEditManual => 'تعديل سجل الحضور';

  @override
  String get teamMemberAttendanceSummaryWeek => 'حضور هذا الأسبوع';

  @override
  String get teamMemberAttendanceSummaryLateMonth => 'عدد التأخير';

  @override
  String get teamMemberAttendanceSummaryLateMonthHint => 'هذا الشهر';

  @override
  String get teamMemberAttendanceSummaryMissingCheckout => 'نقص تسجيل الانصراف';

  @override
  String get teamMemberAttendanceSummaryMissingCheckoutHint => 'مرة';

  @override
  String get teamMemberAttendanceSummaryPendingRequests => 'طلبات معلقة';

  @override
  String get teamMemberAttendanceSummaryPendingRequestsHint => 'تعديل حضور';

  @override
  String get teamMemberAttendanceNoShiftAssigned =>
      'لا توجد وردية اليوم. افتح الورديات الأسبوعية لإسناد وردية.';

  @override
  String get teamMemberAttendanceSummaryDaysUnit => 'أيام';

  @override
  String get teamMemberAttendanceCorrectionsTitle => 'طلبات تعديل الحضور';

  @override
  String get teamMemberAttendanceCorrectionEmptyTitle =>
      'لا توجد طلبات تعديل حالياً';

  @override
  String get teamMemberAttendanceCorrectionEmptySubtitle =>
      'ستُعرض طلبات هذا الموظف هنا.';

  @override
  String get teamMemberAttendanceApprove => 'اعتماد';

  @override
  String get teamMemberAttendanceReject => 'رفض';

  @override
  String get teamMemberAttendanceRequestTypeMissingCheckIn =>
      'نسيان تسجيل الدخول';

  @override
  String get teamMemberAttendanceRequestTypeMissingCheckout =>
      'نسيان تسجيل الخروج';

  @override
  String get teamMemberAttendanceRequestTypeWrongCheckIn => 'تعديل وقت الدخول';

  @override
  String get teamMemberAttendanceRequestTypeWrongCheckOut => 'تعديل وقت الخروج';

  @override
  String get teamMemberAttendanceRequestTypeAbsence => 'تعديل غياب';

  @override
  String get teamMemberAttendanceRequestTypeGeneric => 'طلب تعديل حضور';

  @override
  String get teamMemberAttendanceStatusPending => 'معلق';

  @override
  String get teamMemberAttendanceStatusApproved => 'معتمد';

  @override
  String get teamMemberAttendanceStatusRejected => 'مرفوض';

  @override
  String get teamMemberAttendanceNoReason => 'لا يوجد سبب مذكور';

  @override
  String get teamMemberAttendanceHistoryTitle => 'سجل الحضور الأخير';

  @override
  String get teamMemberAttendanceFullHistoryTitle => 'كل سجلات الحضور';

  @override
  String get teamMemberAttendanceHistoryFilterTitle => 'نطاق التاريخ';

  @override
  String get teamMemberAttendanceHistoryFilterFrom => 'من';

  @override
  String get teamMemberAttendanceHistoryFilterTo => 'إلى';

  @override
  String get teamMemberAttendanceHistoryFilterApply => 'تطبيق';

  @override
  String get teamMemberAttendanceHistoryFilterClear => 'مسح';

  @override
  String get teamMemberAttendanceHistoryFilterSelectDate => 'اختر التاريخ';

  @override
  String get teamMemberAttendanceHistoryFilterNeedBothDates =>
      'اختر تاريخ البداية والنهاية.';

  @override
  String get teamMemberAttendanceHistoryFilterEmptyRange =>
      'لا يوجد حضور في هذا النطاق.';

  @override
  String get teamMemberAttendanceViewAll => 'عرض الكل';

  @override
  String get teamMemberAttendanceHistoryEmpty => 'لا توجد سجلات حضور بعد';

  @override
  String get teamMemberAttendanceRecordStatusCheckedIn => 'تم تسجيل الدخول';

  @override
  String get teamMemberAttendanceRecordStatusPresent => 'مكتمل';

  @override
  String get teamMemberAttendanceRecordStatusLate => 'متأخر';

  @override
  String get teamMemberAttendanceRecordStatusIncomplete => 'غير مكتمل';

  @override
  String get teamMemberAttendanceRecordStatusManual => 'يدوي';

  @override
  String get teamMemberAttendanceRecordStatusAbsent => 'غياب';

  @override
  String get teamMemberAttendanceRecordStatusOnBreak => 'في استراحة';

  @override
  String get teamMemberAttendanceManualSaved => 'تم حفظ سجل الحضور بنجاح';

  @override
  String get teamMemberAttendanceCorrectionApproved =>
      'تم اعتماد طلب تعديل الحضور';

  @override
  String get teamMemberAttendanceCorrectionRejected =>
      'تم رفض طلب تعديل الحضور';

  @override
  String get teamMemberAttendanceManualSheetTitle => 'حضور يدوي';

  @override
  String get teamMemberAttendanceSave => 'حفظ';

  @override
  String get teamMemberAttendanceDateLabel => 'التاريخ';

  @override
  String get teamMemberAttendanceStatusFieldLabel => 'الحالة';

  @override
  String get teamMemberAttendanceLateMinutes => 'دقائق التأخير';

  @override
  String get teamMemberAttendanceEarlyExitMinutes => 'دقائق الخروج المبكر';

  @override
  String get teamMemberAttendanceMissingCheckoutSwitch => 'نقص تسجيل الخروج';

  @override
  String get teamMemberAttendanceNotes => 'ملاحظات';

  @override
  String get teamMemberAttendanceReviewApproveTitle => 'اعتماد طلب التعديل';

  @override
  String get teamMemberAttendanceReviewRejectTitle => 'رفض طلب التعديل';

  @override
  String get teamMemberAttendanceReviewNoteLabel => 'ملاحظة المراجعة';

  @override
  String get teamMemberAttendanceReviewConfirmApprove => 'اعتماد';

  @override
  String get teamMemberAttendanceReviewConfirmReject => 'رفض';

  @override
  String get attendanceAdjustmentSheetTitle => 'تعديل الحضور';

  @override
  String get attendanceAdjustmentSheetSubtitle =>
      'تُحفظ التغييرات على الخادم وتُسجّل في سجل التعديلات. قد تُحدَّث ملخصات الرواتب لهذا الشهر.';

  @override
  String get attendanceAdjustmentShiftOffDay => 'يوم عطلة';

  @override
  String get attendanceAdjustmentDateLabel => 'التاريخ';

  @override
  String get attendanceAdjustmentShiftLabel => 'الوردية';

  @override
  String get attendanceAdjustmentStatusLabel => 'الحالة';

  @override
  String get attendanceAdjustmentStatusPresent => 'حاضر';

  @override
  String get attendanceAdjustmentStatusLateChips => 'متأخر';

  @override
  String get attendanceAdjustmentStatusAbsentChip => 'غائب';

  @override
  String get attendanceAdjustmentStatusDayOff => 'يوم راحة';

  @override
  String get attendanceAdjustmentNotSet => 'غير محدد';

  @override
  String get attendanceAdjustmentLateMinLabel => 'تأخير (د)';

  @override
  String get attendanceAdjustmentEarlyExitLabel => 'خروج مبكر (د)';

  @override
  String get attendanceAdjustmentMissingCheckoutLabelShort => 'بدون خروج';

  @override
  String attendanceAdjustmentMinutesValue(int minutes) {
    return '$minutes د';
  }

  @override
  String attendanceAdjustmentYesWithMinutes(int minutes) {
    return 'نعم (+$minutes عقوبة)';
  }

  @override
  String get attendanceAdjustmentNoAbbr => 'لا';

  @override
  String get attendanceAdjustmentErrorReasonRequired =>
      'يُرجى اختيار سبب هذا التعديل.';

  @override
  String get attendanceAdjustmentSaveSuccess => 'تم حفظ التصحيح بنجاح.';

  @override
  String attendanceAdjustmentCloudError(String code) {
    return 'تعذّر الحفظ: $code';
  }

  @override
  String get attendanceAdjustmentSaveFailed => 'تعذّر حفظ الحضور. حاول مجدداً.';

  @override
  String get attendanceAdjustmentTimesLabel => 'أوقات التسجيل';

  @override
  String get attendanceAdjustmentBreakOutLabel => 'بداية الاستراحة';

  @override
  String get attendanceAdjustmentBreakInLabel => 'نهاية الاستراحة';

  @override
  String get attendanceAdjustmentMissingCheckoutWarning =>
      'تسجيل الخروج مفقود. قد تُحتسب الدقائق وفقاً لعقوبة نقص تسجيل الخروج في إعدادات الصالون.';

  @override
  String get attendanceAdjustmentReasonLabel => 'السبب';

  @override
  String get attendanceAdjustmentReasonPlaceholder => 'اختر سبباً';

  @override
  String get attendanceAdjustmentReasonForgot => 'نسيان التسجيل';

  @override
  String get attendanceAdjustmentReasonGps => 'مشكلة GPS أو الجهاز';

  @override
  String get attendanceAdjustmentReasonSchedule => 'تصحيح الجدولة';

  @override
  String get attendanceAdjustmentReasonPayroll => 'مزامنة الرواتب';

  @override
  String get attendanceAdjustmentReasonOther => 'أخرى';

  @override
  String get attendanceAdjustmentManagerNoteLabel => 'ملاحظة داخلية (اختياري)';

  @override
  String get attendanceAdjustmentAuditFootnote =>
      'ينشئ هذا الإجراء سجل تعديل ويحدّث ملخصات الرواتب الشهرية عند الاقتضاء.';

  @override
  String get attendanceAdjustmentSaveCta => 'حفظ التصحيح';

  @override
  String get attendanceAdjustmentFirestoreDocLabel => 'مسار Firestore · ';

  @override
  String get attendanceAdjustmentSessionExpired =>
      'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';

  @override
  String get attendanceAdjustmentPermissionDeniedSave =>
      'ليس لديك صلاحية لحفظ هذا التصحيح';

  @override
  String get attendanceAdjustmentServerUnavailableSave =>
      'تعذر الاتصال بالخادم، حاول مرة أخرى';

  @override
  String get attendanceAdjustmentSaveFailedMapped =>
      'تعذر حفظ التصحيح، حاول مرة أخرى';

  @override
  String get attendanceAdjustmentLoadContextFailed =>
      'تعذّر تحميل هذه الشاشة. حاول مجدداً.';

  @override
  String get teamDetailsLoadErrorTitle => 'تعذّر تحميل تفاصيل عضو الفريق';

  @override
  String get teamDetailsTabOverview => 'نظرة عامة';

  @override
  String get teamDetailsTabSales => 'المبيعات';

  @override
  String get teamDetailsTabAttendance => 'الحضور';

  @override
  String get teamDetailsTabPayroll => 'الرواتب';

  @override
  String get teamDetailsTabServices => 'الخدمات';

  @override
  String get teamDetailsTabBookingPrep => 'تهيئة الحجز';

  @override
  String get teamDetailsStatusLabel => 'الحالة';

  @override
  String get teamDetailsJoinDate => 'تاريخ التعيين';

  @override
  String get teamDetailsCommissionRate => 'نسبة العمولة';

  @override
  String get teamDetailsBookableLater => 'قابل للحجز لاحقًا';

  @override
  String get teamProfileStatusFrozen => 'مجمّد';

  @override
  String get teamProfileJoinDateMissing => 'تاريخ التعيين غير متوفر';

  @override
  String get teamProfileSectionContact => 'جهة الاتصال';

  @override
  String get teamProfileSectionWorkSettings => 'إعدادات العمل';

  @override
  String get teamProfileTodaySalesLabel => 'مبيعات اليوم';

  @override
  String get teamProfileServicesLabel => 'الخدمات';

  @override
  String get teamProfileAttendanceLabel => 'الحضور';

  @override
  String get teamProfileActionCall => 'اتصال';

  @override
  String get teamProfileActionAddBooking => 'إضافة حجز';

  @override
  String get teamProfilePhoneMissingSnack => 'رقم الهاتف غير متوفر';

  @override
  String get teamProfileDialerErrorSnack => 'تعذّر فتح تطبيق الاتصال';

  @override
  String get teamProfileWhatsAppUnavailableSnack =>
      'واتساب غير متوفر على هذا الجهاز';

  @override
  String get teamProfileBookingUnavailableSnack =>
      'لا يمكن حجز هذا العضو حالياً';

  @override
  String get teamProfileAttendanceNotRequiredSummary => 'غير مطلوب';

  @override
  String get teamProfilePermissionDenied => 'ليست لديك صلاحية لعرض هذا العضو.';

  @override
  String get teamProfileLoadGenericError => 'حدث خطأ أثناء تحميل بيانات العضو.';

  @override
  String get teamProfileNotFound => 'لم يتم العثور على العضو.';

  @override
  String get teamValueNotAvailable => 'غير متاح';

  @override
  String get teamValueYes => 'نعم';

  @override
  String get teamValueNo => 'لا';

  @override
  String get teamValueEnabled => 'مفعّل';

  @override
  String get teamValueDisabled => 'معطّل';

  @override
  String get teamCardTeamMemberSubtitle => 'عضو الفريق';

  @override
  String get teamCardNameMissing => 'بدون اسم';

  @override
  String get teamMemberPerformanceUnrated => 'غير مقيّم';

  @override
  String teamCardEmployeeId(String id) {
    return 'المعرّف · $id';
  }

  @override
  String get teamCardChipLabelStatus => 'الحالة';

  @override
  String get teamCardChipLabelAttendToday => 'حضور اليوم';

  @override
  String get teamCardAttendWorking => 'يعمل الآن';

  @override
  String get teamCardAttendCompleted => 'مكتمل';

  @override
  String get teamCardAttendAbsent => 'غائب';

  @override
  String get teamCardAttendTodayOff => 'إجازة اليوم';

  @override
  String get teamCardAttendNoCheckIn => 'لم يسجّل الدخول';

  @override
  String get teamCardSwipeBrowseHint => 'اسحب لتصفح الفريق';

  @override
  String teamDeckFooterMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء في الفريق',
      one: 'عضو فريق واحد',
    );
    return '$_temp0';
  }

  @override
  String teamCommissionPercentValue(String value) {
    return '$value%';
  }

  @override
  String get teamNoSalesTodayTitle => 'لا توجد مبيعات مسجلة اليوم';

  @override
  String get teamNoSalesTodaySubtitle => 'سجّل أول عملية بيع لعضو الفريق هذا.';

  @override
  String get teamSalesRecentSalesTitle => 'المبيعات الأخيرة';

  @override
  String get teamSalesTopServicesTitle => 'أكثر الخدمات مبيعًا';

  @override
  String get teamTopServicesEmpty => 'لا يوجد أداء خدمات بعد.';

  @override
  String teamSalesTopServiceCount(int count) {
    return 'تم بيع $count';
  }

  @override
  String get teamSalesAverageTicketTitle => 'متوسط قيمة الفاتورة';

  @override
  String get teamPlaceholderLaterReady => 'عنصر جاهز للإضافة لاحقًا';

  @override
  String get teamSalesRevenueToday => 'إيراد اليوم';

  @override
  String get teamSalesRevenueWeek => 'إيراد هذا الأسبوع';

  @override
  String get teamSalesRevenueMonth => 'إيراد هذا الشهر';

  @override
  String get teamSalesServicesToday => 'خدمات اليوم';

  @override
  String get teamSalesServicesMonth => 'خدمات هذا الشهر';

  @override
  String teamSalesCommissionLabel(String value) {
    return 'العمولة $value';
  }

  @override
  String get teamMemberSalesHistoryTitle => 'سجل المبيعات';

  @override
  String get teamMemberSalesFilterThisMonth => 'هذا الشهر';

  @override
  String get teamMemberSalesFilterToday => 'اليوم';

  @override
  String get teamMemberSalesFilterThisWeek => 'هذا الأسبوع';

  @override
  String get teamMemberSalesFilterCustom => 'مخصص';

  @override
  String teamMemberSalesShowing(String filter) {
    return 'العرض: $filter';
  }

  @override
  String teamMemberSalesHistoryTotal(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String get teamMemberSalesLoadError => 'تعذّر تحميل المبيعات. حاول مرة أخرى.';

  @override
  String get teamMemberSalesPermissionDenied =>
      'ليست لديك صلاحية لعرض هذه المبيعات.';

  @override
  String get teamMemberSalesEmptyHistoryTitle => 'لا مبيعات في هذه الفترة';

  @override
  String get teamMemberSalesEmptyHistorySubtitle =>
      'جرّب نطاق تاريخ آخر أو سجّل عملية بيع جديدة.';

  @override
  String get teamMemberSalesWalkInCustomer => 'عميل بدون حجز';

  @override
  String get teamMemberSalesServiceSummaryFallback => 'الخدمات';

  @override
  String get teamMemberSalesSmartSummaryTitle => 'ملخص سريع';

  @override
  String get teamMemberSalesNotAvailableShort => '—';

  @override
  String get teamMemberSalesReceiptTapToEnlarge => 'صورة الإيصال، اضغط للتكبير';

  @override
  String get teamMemberSalesReceiptViewerTitle => 'الإيصال';

  @override
  String get teamNoAttendanceTodayTitle => 'لا يوجد حضور اليوم بعد';

  @override
  String get teamNoAttendanceTodaySubtitle => 'سجّل الحضور لبدء اليوم.';

  @override
  String get teamAttendanceTodayStatusTitle => 'حضور اليوم';

  @override
  String get teamAttendanceCheckedInLabel => 'وقت تسجيل الدخول';

  @override
  String get teamAttendanceCheckedOutLabel => 'وقت تسجيل الخروج';

  @override
  String get teamAttendanceStatusLabel => 'حالة الحضور';

  @override
  String get teamAttendanceWeeklySummary => 'حضور الأسبوع';

  @override
  String get teamAttendanceLateCount => 'عدد التأخير';

  @override
  String get teamAttendanceMissingCheckoutCount => 'مرات نقص تسجيل الخروج';

  @override
  String get teamAttendanceCorrectionRequestsTitle => 'طلبات تصحيح الحضور';

  @override
  String get teamPayrollCommissionPercentage => 'نسبة العمولة';

  @override
  String get teamPayrollCommissionToday => 'عمولة اليوم';

  @override
  String get teamPayrollCommissionMonth => 'عمولة هذا الشهر';

  @override
  String get teamPayrollBonusesTotal => 'إجمالي المكافآت';

  @override
  String get teamPayrollDeductionsTotal => 'إجمالي الخصومات';

  @override
  String get teamPayrollEstimatedPayout => 'الدفعة المتوقعة';

  @override
  String get teamPayrollHistoryEmptyTitle => 'لا يوجد سجل رواتب بعد';

  @override
  String get teamPayrollHistoryEmptySubtitle =>
      'سيظهر سجل الرواتب الشهري هنا عند إنشاء السجلات.';

  @override
  String get teamPayrollHistoryTitle => 'سجل الرواتب';

  @override
  String get teamServicesEditAssignmentsAction => 'تعديل ربط الخدمات';

  @override
  String get teamServicesEmptyTitle => 'لا توجد خدمات مخصصة بعد';

  @override
  String get teamServicesEmptySubtitle =>
      'خصّص خدمات لعضو الفريق هذا لتجهيزه للتشغيل وللحجز مستقبلًا.';

  @override
  String get teamServicesAssignedTitle => 'الخدمات المخصصة';

  @override
  String get teamServicesServiceActive => 'نشط';

  @override
  String get teamServicesServiceInactive => 'غير نشط';

  @override
  String get teamServicesEditAssignmentCardSubtitle =>
      'أدر الخدمات التي يمكن لمقدّم الخدمة تنفيذها.';

  @override
  String get teamServicesAssignedSectionSubtitle =>
      'الخدمات التي يقدّمها مقدّم الخدمة حاليًا.';

  @override
  String get teamServicesAssignServicesAction => 'تخصيص الخدمات';

  @override
  String get teamServicesAssignmentSelectAll => 'تحديد الكل';

  @override
  String get teamServicesAssignmentClearSelection => 'إلغاء التحديد';

  @override
  String get teamServicesRetryAction => 'إعادة المحاولة';

  @override
  String get teamServicesLoadErrorTitle => 'تعذّر تحميل التخصيصات';

  @override
  String get teamServicesUnnamedService => 'خدمة بدون اسم';

  @override
  String get teamBookingPrepPublicDisplayName => 'اسم العرض العام';

  @override
  String get teamBookingPrepPublicBio => 'النبذة العامة';

  @override
  String get teamBookingPrepWorkingHoursProfile => 'ملف ساعات العمل';

  @override
  String get teamBookingPrepSlotDuration => 'مدة فتحة الحجز';

  @override
  String get teamBookingPrepDisplayOrder => 'ترتيب العرض';

  @override
  String get teamBookingPrepProfileImage => 'صورة الملف';

  @override
  String get teamBookingPrepVisibleServicesTitle => 'الخدمات الظاهرة للعملاء';

  @override
  String get teamBookingPrepVisibleServicesEmpty =>
      'لا توجد خدمات ظاهرة للعملاء بعد.';

  @override
  String get moneyDashboardTitle => 'المالية';

  @override
  String get moneyDashboardSubtitle =>
      'إشارات مالية شهرية واتجاهات ورؤى تشغيلية واضحة.';

  @override
  String get moneyDashboardErrorTitle => 'تعذّر تحميل لوحة المالية';

  @override
  String get moneyDashboardErrorMessage => 'حاول مرة أخرى بعد قليل.';

  @override
  String get moneyDashboardRetry => 'إعادة المحاولة';

  @override
  String get moneyDashboardTrendTitle => 'المبيعات مقابل المصروفات';

  @override
  String get moneyDashboardTrendSubtitleDaily =>
      'تابع حركة الإيرادات والتكاليف يومًا بيوم خلال الشهر المحدد.';

  @override
  String get moneyDashboardTrendSubtitleWeekly =>
      'تابع حركة الإيرادات والتكاليف أسبوعيًا خلال الشهر المحدد.';

  @override
  String get moneyDashboardTrendSubtitleMonthly =>
      'تابع حركة الإيرادات والتكاليف عبر الأشهر الأخيرة.';

  @override
  String get moneyDashboardTrendSubtitleYearly =>
      'تابع حركة الإيرادات والتكاليف عبر السنوات الميلادية الأخيرة.';

  @override
  String get moneyDashboardSalesLegend => 'المبيعات';

  @override
  String get moneyDashboardExpensesLegend => 'المصروفات';

  @override
  String get moneyDashboardInsightsTitle => 'الرؤى';

  @override
  String get moneyDashboardInsightsEmpty =>
      'ستظهر رؤى أكثر كلما تراكمت المبيعات والرواتب والمصروفات.';

  @override
  String get moneyDashboardSalesNavSubtitle =>
      'افتح محرك المعاملات وسجّل مبيعات جديدة.';

  @override
  String get moneyDashboardExpensesNavSubtitle =>
      'راجع التكاليف والفئات وآخر المصروفات.';

  @override
  String get moneyDashboardSummaryHeadline => 'الملخص المالي';

  @override
  String get moneyDashboardSalesTotal => 'إجمالي المبيعات';

  @override
  String get moneyDashboardExpensesTotal => 'إجمالي المصروفات';

  @override
  String get moneyDashboardPayrollTotal => 'إجمالي الرواتب';

  @override
  String get moneyDashboardNetProfit => 'صافي الربح';

  @override
  String moneyDashboardInsightTopBarber(Object name, Object amount) {
    return '$name يتصدر هذا الشهر بمبيعات بلغت $amount.';
  }

  @override
  String moneyDashboardInsightTopService(Object service, Object amount) {
    return '$service هي الخدمة الأعلى دخلاً بقيمة $amount.';
  }

  @override
  String moneyDashboardInsightExpenseCategory(Object category, Object share) {
    return '$category تستحوذ على أكبر حصة من المصروفات بنسبة $share.';
  }

  @override
  String get moneyDashboardUncategorized => 'غير مصنّف';

  @override
  String get moneyDashboardNetLossWarning =>
      'صافي الربح سالب لهذا الشهر (المبيعات المكتملة ناقص المصروفات والرواتب في نفس الفترة). خفّف الإنفاق الاختياري، راجع التسعير، وتأكد من جداول الرواتب عند وجودها.';

  @override
  String moneyDashboardTrendPeakSalesSummary(Object day, Object amount) {
    return 'أعلى يوم مبيعات $day · $amount';
  }

  @override
  String moneyDashboardInsightActionTopBarber(Object name, Object amount) {
    return 'ركّز على $name ($amount مبيعات) — احمِ وقت الكرسي، انسخ ما ينجح في الاستشارات، وأعد توزيع الحجوزات الأقل ازدحامًا.';
  }

  @override
  String moneyDashboardInsightActionTopService(Object service, Object amount) {
    return 'اعرض $service ضمن الباقات والبيع الإضافي — حقق $amount هذا الشهر.';
  }

  @override
  String moneyDashboardInsightActionExpenseCategory(
    Object category,
    Object share,
  ) {
    return 'تركيز الإنفاق على $category ($share) — راجع الموردين والاشتراكات وقواعد الفئة قبل أن يتفاقم الأمر.';
  }

  @override
  String get moneyDashboardSearchHint => 'ابحث عن الفريق والإيرادات والطلبات';

  @override
  String get moneyDashboardChartGranularityDaily => 'يومي';

  @override
  String get moneyDashboardChartGranularityWeekly => 'أسبوعي';

  @override
  String get moneyDashboardChartGranularityMonthly => 'شهري';

  @override
  String get moneyDashboardChartGranularityYearly => 'سنوي';

  @override
  String get moneyDashboardChartGranularityPickerTitle => 'فترة المخطط';

  @override
  String get moneyDashboardKpiTrendNoData => '—';

  @override
  String get moneyDashboardKpiTrendNew => 'جديد';

  @override
  String moneyDashboardKpiTrendUpVsMonth(Object percent, Object month) {
    return '↗ $percent% مقارنة بـ $month';
  }

  @override
  String moneyDashboardKpiTrendDownVsMonth(Object percent, Object month) {
    return '↘ $percent% مقارنة بـ $month';
  }

  @override
  String moneyDashboardKpiTrendFlatVsMonth(Object percent, Object month) {
    return '→ $percent% مقارنة بـ $month';
  }

  @override
  String get moneyDashboardQuickPayrollSubtitle =>
      'راجع دورات الرواتب الشهرية وكشوف الدفع.';

  @override
  String get moneyDashboardQuickSalesBody =>
      'سجّل المعاملات وراقب إيرادات الخدمات.';

  @override
  String get moneyDashboardQuickExpensesBody =>
      'تابع التكاليف والفئات والإنفاق الأخير.';

  @override
  String get salesScreenTitle => 'المبيعات';

  @override
  String get salesScreenSubtitle => 'تابع الإيرادات والخدمات والأداء.';

  @override
  String get salesScreenAddSale => 'إضافة بيع';

  @override
  String get salesScreenErrorTitle => 'تعذّر تحميل المبيعات';

  @override
  String get salesScreenErrorMessage => 'سجل المعاملات غير متاح حالياً.';

  @override
  String get salesScreenSummaryTitle => 'الملخص الذكي';

  @override
  String get salesScreenTransactionCount => 'عدد العمليات';

  @override
  String get salesScreenAverageTicket => 'متوسط الفاتورة';

  @override
  String get salesScreenTopBarber => 'أفضل عضو فريق';

  @override
  String get salesScreenTopService => 'أفضل خدمة';

  @override
  String get salesScreenValuePending => '—';

  @override
  String salesScreenCustomRange(Object start, Object end) {
    return 'النطاق المخصص: $start - $end';
  }

  @override
  String get salesScreenBarberFilter => 'عضو الفريق';

  @override
  String get salesScreenAllBarbers => 'كل أعضاء الفريق';

  @override
  String get salesScreenEmptyTitle => 'لا توجد مبيعات بعد';

  @override
  String get salesScreenEmptyMessage =>
      'سجّل أول عملية بيع لبدء تتبع الإيرادات هنا.';

  @override
  String salesScreenDayTotal(Object amount) {
    return 'إجمالي اليوم $amount';
  }

  @override
  String get salesScreenUnknownService => 'خدمة';

  @override
  String get salesScreenAllPayments => 'كل طرق الدفع';

  @override
  String get salesScreenFiltersButton => 'عوامل التصفية';

  @override
  String get salesScreenFiltersSheetTitle => 'تصفية المبيعات';

  @override
  String get salesScreenTopServicesTitle => 'أعلى الخدمات حسب الإيراد';

  @override
  String get salesScreenBarberRankingTitle => 'أداء الفريق';

  @override
  String get salesScreenTopServicesEmpty =>
      'سيظهر مزيج الخدمات عند تضمين بنود في المبيعات.';

  @override
  String salesScreenPaymentSingleMethod(Object method) {
    return 'كل المبيعات عبر $method. فكّر بتشجيع البطاقة أو المحفظة لتقليل التعامل النقدي.';
  }

  @override
  String get salesDetailsTitle => 'تفاصيل البيع';

  @override
  String get salesDetailsNotFoundTitle => 'لم يتم العثور على عملية البيع';

  @override
  String get salesDetailsNotFoundMessage =>
      'لم تعد هذه العملية متاحة لهذا الصالون.';

  @override
  String get salesDetailsOverviewTitle => 'نظرة عامة';

  @override
  String get salesDetailsLineItemsTitle => 'بنود البيع';

  @override
  String get salesDetailsCustomerLabel => 'العميل';

  @override
  String get salesDetailsRecordedByLabel => 'تم التسجيل بواسطة';

  @override
  String get salesDetailsStatusLabel => 'الحالة';

  @override
  String get salesDetailsPaymentLabel => 'الدفع';

  @override
  String get salesDetailsSoldAtLabel => 'وقت البيع';

  @override
  String get salesDetailsSubtotalLabel => 'الإجمالي الفرعي';

  @override
  String get salesDetailsTaxLabel => 'الضريبة';

  @override
  String get salesDetailsDiscountLabel => 'الخصم';

  @override
  String get salesDetailsCommissionLabel => 'العمولة';

  @override
  String get salesStatusCompleted => 'مكتمل';

  @override
  String get salesStatusPending => 'قيد الانتظار';

  @override
  String get salesStatusRefunded => 'مسترد';

  @override
  String get salesStatusVoided => 'ملغى';

  @override
  String get salesDateToday => 'اليوم';

  @override
  String get salesDateThisWeek => 'هذا الأسبوع';

  @override
  String get salesDateThisMonth => 'هذا الشهر';

  @override
  String get salesDateCustom => 'مخصص';

  @override
  String get salesHeroTotalSalesLabel => 'إجمالي المبيعات';

  @override
  String get salesChartSalesVsExpenses => 'المبيعات مقابل المصروفات';

  @override
  String get salesChartLegendSales => 'المبيعات';

  @override
  String get salesChartLegendExpenses => 'المصروفات';

  @override
  String get salesInsightTopServicesSubtitle => 'حسب الإيراد';

  @override
  String get salesInsightBarberSubtitle => 'حسب الإيراد';

  @override
  String get salesInsightPaymentMixTitle => 'مزيج طرق الدفع';

  @override
  String get salesInsightPaymentSubtitle => 'حسب الطريقة';

  @override
  String get salesInsightHelperTopServices =>
      'سجّل المبيعات لمعرفة أكثر الخدمات ربحًا.';

  @override
  String get salesInsightHelperBarber =>
      'سجّل المبيعات لمعرفة أداء أعضاء الفريق.';

  @override
  String get salesInsightHelperPayment =>
      'سجّل المبيعات لمعرفة توزيع طرق الدفع.';

  @override
  String get salesInsightActionAddServices => 'إضافة خدمات';

  @override
  String get salesInsightActionAddSales => 'إضافة مبيعات';

  @override
  String get salesRecentCardTitle => 'أحدث المبيعات';

  @override
  String get salesRecentEmptyTitle => 'لا مبيعات بعد';

  @override
  String get salesRecentEmptyBody =>
      'ابدأ بإضافة المبيعات لعرض أحدث المعاملات هنا.';

  @override
  String get paymentMethodMixed => 'مختلط';

  @override
  String get addSaleSelectServicesTitle => 'اختر الخدمات';

  @override
  String get addSaleManageServices => 'إدارة الخدمات';

  @override
  String get addSaleSearchServicesHint => 'ابحث عن خدمة';

  @override
  String addSaleSelectedServicesTitle(int count) {
    return 'الخدمات المختارة ($count)';
  }

  @override
  String get addSaleAddAnotherService => 'إضافة خدمة أخرى';

  @override
  String get addSaleAllServicesSectionTitle => 'كل الخدمات';

  @override
  String get addSaleSelectedServiceLineSubtitle => 'في هذا البيع';

  @override
  String get addSaleClearSearchTooltip => 'مسح البحث';

  @override
  String get addSaleBarberLabel => 'مقدم الخدمة';

  @override
  String get addSaleWalkInCustomer => 'عميل زائر';

  @override
  String get addSaleAddNameLink => 'إضافة اسم';

  @override
  String get addSaleOrderSummaryTitle => 'ملخص الطلب';

  @override
  String get addSaleSubtotal => 'المجموع الفرعي';

  @override
  String get addSaleDiscountLink => 'إضافة خصم';

  @override
  String get addSaleDiscountTitle => 'الخصم';

  @override
  String get addSaleDiscountHint => 'المبلغ المخصوم من المجموع الفرعي';

  @override
  String get addSaleTotal => 'الإجمالي';

  @override
  String get addSaleRecordSale => 'تسجيل البيع';

  @override
  String get addSaleDiscountInvalid =>
      'لا يمكن أن يتجاوز الخصم المجموع الفرعي.';

  @override
  String get expensesScreenTitle => 'المصروفات';

  @override
  String get expensesScreenSubtitle =>
      'تابع مصروفات الصالون وأدرها من مكان واحد.';

  @override
  String get expensesScreenSalonMissing => 'لم يتم العثور على ملف الصالون.';

  @override
  String get expensesScreenRetry => 'إعادة المحاولة';

  @override
  String get expensesScreenTotalExpensesLabel => 'إجمالي المصروفات';

  @override
  String get expensesScreenTransactionsLabel => 'المعاملات';

  @override
  String expensesScreenTransactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة',
      many: '$count معاملة',
      few: '$count معاملات',
      two: 'معاملتان',
      one: 'معاملة واحدة',
      zero: 'لا معاملات',
    );
    return '$_temp0';
  }

  @override
  String get expensesScreenViewAll => 'عرض الكل';

  @override
  String get expensesScreenNoCategoriesTitle => 'لا فئات بعد';

  @override
  String get expensesScreenNoCategoriesMessage =>
      'أضف أول مصروف لرؤية توزيع الفئات.';

  @override
  String get expensesScreenRecentTitle => 'أحدث المصروفات';

  @override
  String get expensesScreenReportComingSoon => 'التقارير ستتوفر قريباً.';

  @override
  String get expensesScreenRecordedByLabel => 'سجّل بواسطة';

  @override
  String get expensesScreenAllCreators => 'الجميع';

  @override
  String get expensesScreenClearFilters => 'مسح عوامل التصفية';

  @override
  String get expensesScreenApplyFilters => 'تطبيق';

  @override
  String get expensesScreenAddExpense => 'إضافة مصروف';

  @override
  String get expensesScreenErrorTitle => 'تعذّر تحميل المصروفات';

  @override
  String get expensesScreenErrorMessage => 'سجل المصروفات غير متاح حالياً.';

  @override
  String get expensesScreenSummaryTitle => 'الملخص الذكي';

  @override
  String get expensesScreenCount => 'عدد المصروفات';

  @override
  String get expensesScreenTopCategory => 'أعلى فئة';

  @override
  String get expensesScreenValuePending => 'لا توجد بيانات كافية';

  @override
  String get expensesScreenAllCategories => 'كل الفئات';

  @override
  String get expensesScreenBreakdownTitle => 'توزيع الفئات';

  @override
  String get expensesScreenBreakdownEmpty =>
      'سيظهر التوزيع بعد تسجيل المصروفات.';

  @override
  String get expensesScreenEmptyTitle => 'لا توجد مصروفات بعد';

  @override
  String get expensesScreenEmptyMessage =>
      'أضف أول مصروف لبدء تتبع التكاليف هنا.';

  @override
  String expensesScreenDayTotal(Object amount) {
    return 'إجمالي اليوم $amount';
  }

  @override
  String get expensesScreenUnknownExpense => 'مصروف';

  @override
  String get expensesScreenFiltersButton => 'عوامل التصفية';

  @override
  String get expensesScreenFiltersSheetTitle => 'تصفية المصروفات';

  @override
  String get expensesScreenAverageExpense => 'متوسط / مصروف';

  @override
  String get expensesScreenHighestExpense => 'الأعلى';

  @override
  String get expensesScreenTrend => 'الاتجاه';

  @override
  String expensesScreenTrendVsPrior(Object percent) {
    return '$percent مقارنة بالفترة السابقة';
  }

  @override
  String get expenseScreenLinkedBarber => 'عضو الفريق المرتبط';

  @override
  String get addSalePaymentMethodField => 'طريقة الدفع';

  @override
  String get employeeAddSaleFab => 'إضافة بيع';

  @override
  String get employeeSectionPermissionDenied => 'لا تملك صلاحية عرض هذا القسم.';

  @override
  String get employeeTodayWorkspaceSubtitle => 'مساحة عملك اليوم';

  @override
  String get employeeTodayAttendanceTitle => 'حضور اليوم';

  @override
  String get employeeTodayAttendanceTagline => 'كن في الموعد، وكن متميزًا.';

  @override
  String get employeeTodayStatusNotCheckedIn => 'لم يتم تسجيل الدخول';

  @override
  String get employeeTodayStatusCheckedIn => 'تم تسجيل الحضور';

  @override
  String get employeeTodayStatusOnBreak => 'أنت في الاستراحة';

  @override
  String get employeeTodayStatusBackFromBreak => 'تم الرجوع من الاستراحة';

  @override
  String get employeeTodayStatusCheckedOut => 'تم إنهاء الدوام';

  @override
  String get employeeTodayStatusInvalidSequence => 'تسلسل بصمات غير صحيح';

  @override
  String get employeeTodayZoneInside => 'داخل نطاق الصالون';

  @override
  String get employeeTodayZoneOutside => 'خارج نطاق الصالون';

  @override
  String get employeeTodaySalonLabel => 'الصالون';

  @override
  String get employeeTodayAddressOnFile => 'العنوان المحفوظ';

  @override
  String employeeTodayDistanceMeters(int meters) {
    return 'حوالي $meters م من المركز';
  }

  @override
  String get employeeTodayAttendanceRequestTitle => 'طلب حضور';

  @override
  String get employeeTodayAttendanceRequestSubtitle =>
      'نسيت تسجيلًا؟ أرسل طلبًا لموافقة المشرف.';

  @override
  String get employeeTodayRequestCorrection => 'طلب تصحيح';

  @override
  String employeeTodayPendingCount(int count) {
    return 'قيد الانتظار: $count';
  }

  @override
  String get employeeTodayNoActivity => 'لا نشاط اليوم بعد.';

  @override
  String get employeeTodayPrivacyNote =>
      'يمكنك فقط عرض حضورك ومبيعاتك وطلباتك.';

  @override
  String get employeeTodayViewPolicy => 'عرض السياسة';

  @override
  String get employeeTodaySalonLocationMissing =>
      'لم يتم ضبط موقع حضور الصالون. تواصل مع المالك.';

  @override
  String get employeeTodayPunchIn => 'تسجيل دخول';

  @override
  String get employeeTodayPunchOut => 'تسجيل خروج';

  @override
  String get employeeTodayBreakOut => 'خروج للاستراحة';

  @override
  String get employeeTodayBreakIn => 'عودة من الاستراحة';

  @override
  String employeeTodayBreakCountdownRemaining(String time) {
    return 'الوقت المتبقي للاستراحة: $time';
  }

  @override
  String employeeTodayBreakCountdownExceeded(String time) {
    return 'تم تجاوز الاستراحة بمقدار $time';
  }

  @override
  String get employeeTodayBreakOutsideShift =>
      'يمكن بدء الاستراحة فقط خلال ساعات ورديتك المجدولة.';

  @override
  String get employeeTodayCompletedForToday => 'اكتمل اليوم';

  @override
  String employeeTodayHoursLabel(Object hours) {
    return '$hours س';
  }

  @override
  String employeeTodaySalesAmount(Object amount) {
    return 'مبيعات $amount';
  }

  @override
  String employeeTodayServicesCount(int count) {
    return '$count خدمات';
  }

  @override
  String get employeeTodayTeamMemberFallback => 'عضو الفريق';

  @override
  String employeeTodayPunchRecorded(Object action) {
    return 'تم تسجيل $action';
  }

  @override
  String get employeeTodayOfflinePunch => 'تحتاج إلى اتصال بالإنترنت للتسجيل.';

  @override
  String get employeeTodayPunchUnavailableAttendanceDisabled =>
      'تم إيقاف نظام الحضور لهذا الصالون.';

  @override
  String get employeeTodayPunchUnavailableMoveToZone =>
      'ادخل إلى نطاق الصالون لتسجيل الدخول أو الخروج.';

  @override
  String get employeeTodayPunchUnavailableShiftComplete =>
      'وصلت إلى الحد الأقصى لتسجيلات اليوم. إذا بدا الأمر خاطئًا، أرسل طلب تصحيح.';

  @override
  String get employeeTodayPunchUnavailableGeneric =>
      'لا تتوفر أي إجراءات تسجيل الآن.';

  @override
  String get employeeTodayPrimaryPunchInSubtitle => 'ابدأ جلسة العمل';

  @override
  String get employeeTodayPrimaryPunchOutSubtitle => 'أنهِ جلستك الحالية';

  @override
  String get employeeTodayPrimaryBreakOutSubtitle => 'ابدأ استراحة';

  @override
  String get employeeTodayPrimaryBreakInSubtitle => 'استأنف ورديتك';

  @override
  String get employeeTodayNoAction => 'لا يوجد إجراء';

  @override
  String get employeeTodayActionUnavailable => 'الإجراء غير متاح حالياً';

  @override
  String get employeeTodayPunchUnavailableMissingPunch =>
      'يرجى طلب تصحيح للبصمة الناقصة.';

  @override
  String get employeeTodayAttendanceLoadErrorTitle => 'تعذر تحميل الحضور';

  @override
  String get employeeTodayAttendanceStatusLabel => 'الحالة';

  @override
  String get employeeTodayLastPunchLabel => 'آخر بصمة';

  @override
  String get employeeTodayLocationContextLabel => 'الموقع';

  @override
  String get employeeTodayShiftLabel => 'الدوام';

  @override
  String get employeeTodayGpsVerified => 'تم التحقق من GPS';

  @override
  String get employeeTodayGpsLocating => 'جاري تحديد الموقع';

  @override
  String get employeeTodayPunchNotAllowedNow => 'هذه البصمة غير مسموح بها الآن';

  @override
  String get employeeQuickActionsTitle => 'إجراءات سريعة';

  @override
  String get employeeQuickActionAddSaleSubtitle => 'سجّل خدمة أو دفعة';

  @override
  String get employeeQuickActionRequestCorrectionTitle => 'طلب تصحيح';

  @override
  String get employeeQuickActionRequestCorrectionSubtitle =>
      'أصلح بصمة ناقصة أو خاطئة';

  @override
  String get employeeQuickActionViewPolicySubtitle => 'قواعد الحضور والمخالفات';

  @override
  String get employeeQuickActionPayrollTitle => 'الرواتب';

  @override
  String get employeeQuickActionPayrollSubtitle => 'قسائم الرواتب وسجل الرواتب';

  @override
  String get employeeTodaySectionLoadFailed => 'تعذر تحميل هذا القسم.';

  @override
  String get employeeTodayTryAgain => 'إعادة المحاولة';

  @override
  String get employeeTodayNoActivityTitle => 'لا تسجيلات بعد';

  @override
  String get employeeTodayNoActivityBody =>
      'سيظهر خط زمني لتسجيلاتك عند تسجيل الدخول والخروج.';

  @override
  String get employeeTodaySemanticNotifications => 'الإشعارات';

  @override
  String get employeeTodaySemanticSettings => 'الإعدادات';

  @override
  String get employeeActivityTimelineTitle => 'نشاط اليوم';

  @override
  String get employeeActivityTimelineLive => 'مباشر';

  @override
  String get employeeActivityTimelineEmpty => 'لا تسجيلات اليوم بعد.';

  @override
  String get employeeSalesTitle => 'مبيعاتي';

  @override
  String get employeeSalesSubtitle => 'تابع إيرادك وعمولتك';

  @override
  String get employeeSalesNotAllowedAdd =>
      'لا يمكنك تسجيل المبيعات. تواصل مع مالك الصالون.';

  @override
  String get employeeSaleRecordedSuccess => 'تم تسجيل البيع بنجاح.';

  @override
  String get employeeSalesEmptyPeriod => 'لا مبيعات في هذه الفترة بعد.';

  @override
  String get employeeSalesEmptyCta =>
      'اضغط «إضافة بيع» لتسجيل أول بيع لك اليوم.';

  @override
  String get employeeSalesRecentTitle => 'أحدث المبيعات';

  @override
  String get employeeSalesViewReceipts => 'عرض الإيصالات';

  @override
  String get employeeSalesViewReceiptsHint => 'مراجعة الإيصالات للمالك قريبًا.';

  @override
  String get employeeSalesTotalLabel => 'إجمالي المبيعات';

  @override
  String get employeeSalesHeroNoSales => 'لا مبيعات في هذه الفترة بعد.';

  @override
  String get employeeSalesKpiTotal => 'إجمالي المبيعات';

  @override
  String get employeeSalesKpiServices => 'الخدمات';

  @override
  String get employeeSalesKpiCommission => 'العمولة التقديرية';

  @override
  String get employeeSalesKpiAvgService => 'متوسط قيمة الخدمة';

  @override
  String get employeeSalesCommissionRate => 'نسبة العمولة';

  @override
  String get employeeSalesCommissionHint => 'نسبة عمولتك';

  @override
  String get employeeSalesEstimatedCommission => 'العمولة التقديرية';

  @override
  String employeeSalesFromSales(Object amount) {
    return 'من مبيعات بقيمة $amount';
  }

  @override
  String get employeeSalesCustomersLabel => 'العملاء';

  @override
  String employeeSalesServicesCustomersRow(Object services, Object customers) {
    return '$services خدمات · $customers عملاء';
  }

  @override
  String employeeSalesShowingLatest(int count) {
    return 'عرض أحدث $count عملية بيع';
  }

  @override
  String get addSaleReceiptSectionTitle => 'صورة الإيصال';

  @override
  String get addSaleReceiptSectionBody =>
      'التقط صورة لإيصال البطاقة أو النقد أو إثبات الدفع.';

  @override
  String get addSaleReceiptTakePhoto => 'التقاط صورة';

  @override
  String get addSaleReceiptRetake => 'إعادة التقاط';

  @override
  String get addSaleReceiptRemove => 'إزالة';

  @override
  String get addSaleReceiptRequiredCard =>
      'صورة الإيصال مطلوبة لمدفوعات البطاقة.';

  @override
  String get addSaleReceiptRequiredMixed =>
      'صورة الإيصال مطلوبة لأن البيع يشمل دفعًا بالبطاقة.';

  @override
  String get addSaleOptionalCashPhotoHint =>
      'اختياري: صورة للنقد المستلم أو إيصال يدوي.';

  @override
  String get addSaleCashCardSplitTitle => 'مبالغ النقد والبطاقة';

  @override
  String get addSaleCashAmountHint => 'نقدي';

  @override
  String get addSaleCardAmountHint => 'بطاقة';

  @override
  String get addSalePaymentSplitInvalid =>
      'يجب أن يساوي مجموع النقد والبطاقة إجمالي البيع.';

  @override
  String get ownerAddSaleAutoPrice => 'السعر المعبأ تلقائيًا';

  @override
  String get addSaleModeBookingCode => 'رمز الحجز';

  @override
  String get addSaleModeManual => 'بيع يدوي';

  @override
  String get addSaleDualSubtitle =>
      'أضف من رمز حجز الضيف أو سجّل بيعًا يدويًا.';

  @override
  String get addSaleBookingCodeFieldLabel => 'رمز الحجز';

  @override
  String get addSaleBookingCodeHint => 'أدخل رمز الحجز';

  @override
  String get addSaleBookingCodeExample => 'مثال: ZR-AB12CD';

  @override
  String get addSaleRetrieveBooking => 'استرجاع الحجز';

  @override
  String get addSaleCreateFromBooking => 'إنشاء البيع';

  @override
  String get addSaleBookingFound => 'تم العثور على الحجز';

  @override
  String get addSaleBookingSectionPayment => 'الدفع';

  @override
  String get addSaleBookingSectionAppointment => 'الموعد';

  @override
  String get addSaleBookingSectionServices => 'الخدمات';

  @override
  String get addSaleBookingSubtotal => 'المجموع الفرعي';

  @override
  String get addSaleBookingDiscount => 'الخصم';

  @override
  String get addSaleBookingTotal => 'الإجمالي';

  @override
  String get addSaleBookingStatus => 'حالة الحجز';

  @override
  String get addSalePaymentStatusPending => 'معلق';

  @override
  String get addSalePaymentStatusPaid => 'مدفوع';

  @override
  String get addSalePaymentStatusFailed => 'فشل';

  @override
  String get addSalePaymentStatusRefunded => 'مسترد';

  @override
  String get addSalePaymentMethodUnspecified => 'غير محدد';

  @override
  String get addSaleBookingErrorEmptyCode => 'يرجى إدخال رمز الحجز.';

  @override
  String get addSaleBookingErrorNotFound => 'رمز الحجز غير موجود.';

  @override
  String get addSaleBookingErrorWrongSalon => 'هذا الحجز لا يخص هذا الصالون.';

  @override
  String get addSaleBookingErrorCancelled => 'هذا الحجز ملغى.';

  @override
  String get addSaleBookingErrorSaleExists => 'تم إنشاء بيع لهذا الحجز مسبقًا.';

  @override
  String get addSaleBookingErrorNoServices => 'لا توجد خدمات في هذا الحجز.';

  @override
  String get addSaleBookingErrorZeroTotal =>
      'يجب أن يكون الإجمالي أكبر من صفر.';

  @override
  String get addSaleBookingErrorBarberMismatch => 'الحلاق في الحجز غير متطابق.';

  @override
  String get addSaleBookingErrorNotYourBooking =>
      'يمكنك استخدام الحجوزات المخصّصة لك فقط.';

  @override
  String get addSaleBookingErrorNoPreview => 'استرجِع الحجز أولًا.';

  @override
  String get addSaleBookingErrorNoSession => 'سجّل الدخول مرة أخرى للمتابعة.';

  @override
  String get addSaleBookingErrorBarberMissing => 'لم يُعثر على الحلاق المخصّص.';

  @override
  String get addSaleBookingErrorUnknown => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get addSaleBookingSaleCreated => 'تم إنشاء البيع';

  @override
  String get addSaleBookingSalon => 'الصالون';

  @override
  String get addSaleBookingCodeLabel => 'رمز الحجز';

  @override
  String get addSaleBookingCustomer => 'العميل';

  @override
  String get addSaleBookingBarber => 'الحلاق';

  @override
  String get addSalePaymentMethodWallet => 'المحفظة';

  @override
  String get addSaleBookingErrorManualNameRequired => 'اسم العميل مطلوب.';

  @override
  String get authV2WelcomeTitle => 'تشغيل أبسط.';

  @override
  String get authV2WelcomeSubtitle =>
      'أدر الحجوزات والفريق والرواتب والمال في مساحة عمل واحدة.';

  @override
  String get authV2WelcomeContinue => 'متابعة';

  @override
  String get authV2FieldLanguage => 'اللغة';

  @override
  String get authV2FieldCountry => 'الدولة';

  @override
  String get authV2RoleTitle => 'كيف تريد استخدام Zurano؟';

  @override
  String get authV2RoleOwnerTitle => 'أنشئ صالونًا';

  @override
  String get authV2RoleOwnerSubtitle => 'سجِّل عملك وفريقك وعملياتك.';

  @override
  String get authV2RoleCustomerTitle => 'المتابعة كمستخدم';

  @override
  String get authV2RoleCustomerSubtitle => 'اكتشف الصالونات واحجز المواعيد.';

  @override
  String get authV2OwnerLoginHeadline => 'مرحباً بعودتك';

  @override
  String get authV2OwnerLoginSubtitle => 'سجّل الدخول لإدارة صالونك.';

  @override
  String get authV2UserLoginHeadline => 'مرحباً بعودتك';

  @override
  String get authV2UserLoginSubtitle => 'سجّل الدخول للمتابعة.';

  @override
  String get authV2UserLoginIdentifierHelper =>
      'الموظفون يسجّلون باسم المستخدم. العملاء بالبريد الإلكتروني.';

  @override
  String get userLoginForgotPasswordNeedEmail =>
      'إعادة تعيين كلمة المرور تعمل مع البريد. أضف «@» إذا كنت تسجّل بالبريد.';

  @override
  String get authLoginErrorIncorrect =>
      'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get authLoginErrorDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get authLoginErrorInvalidEmail => 'صيغة البريد الإلكتروني غير صحيحة.';

  @override
  String get authLoginErrorTooManyRequests =>
      'تم إيقاف المحاولات مؤقتًا بسبب محاولات كثيرة. حاول لاحقًا أو أعد تعيين كلمة المرور.';

  @override
  String get authLoginErrorNetwork => 'تحقق من اتصال الإنترنت وحاول مرة أخرى.';

  @override
  String get authLoginErrorStaffUseUsername =>
      'موظفو الصالون يسجّلون بالبريد أو اسم المستخدم الذي أنشأه مالك الصالون. العملاء يستخدمون هذا الخيار ببريدهم الشخصي.';

  @override
  String get authLoginErrorGeneric => 'تعذر تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get authStaffLoginUserDocMissing =>
      'لم يتم العثور على حساب المستخدم. تواصل مع مالك الصالون.';

  @override
  String get authStaffLoginUserInactive =>
      'تم إيقاف هذا الحساب مؤقتًا. تواصل مع مالك الصالون.';

  @override
  String get authStaffLoginEmployeeDocMissing =>
      'حساب الموظف غير مرتبط بالصالون. تواصل مع مالك الصالون.';

  @override
  String get authStaffLoginEmployeeInactive =>
      'تم إيقاف حسابك من قبل مالك الصالون.';

  @override
  String get authStaffLoginWrongPortal =>
      'هذا الدخول مخصص لفريق الصالون. العملاء وملاك الصالون يستخدمون خيار تسجيل الدخول المناسب.';

  @override
  String get changeTemporaryPasswordFieldCurrent => 'كلمة المرور الحالية';

  @override
  String get changeTemporaryPasswordFieldNew => 'كلمة المرور الجديدة';

  @override
  String get changeTemporaryPasswordFieldConfirm => 'تأكيد كلمة المرور الجديدة';

  @override
  String get changeTemporaryPasswordTitle => 'إنشاء كلمة مرور جديدة';

  @override
  String get changeTemporaryPasswordSubtitle =>
      'مالك الصالون عيّن كلمة مرور مؤقتة. اختر كلمة مرور جديدة للمتابعة.';

  @override
  String get changeTemporaryPasswordSignOut => 'تسجيل الخروج';

  @override
  String get changeTemporaryPasswordSubmit => 'تحديث كلمة المرور';

  @override
  String get changeTemporaryPasswordSuccessSnack =>
      'تم تغيير كلمة المرور بنجاح';

  @override
  String get changeTemporaryPasswordErrorCurrentRequired =>
      'أدخل كلمة المرور الحالية.';

  @override
  String get changeTemporaryPasswordErrorNewMinLength =>
      'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل.';

  @override
  String get changeTemporaryPasswordErrorNewRequiresLetterAndNumber =>
      'يجب أن تتضمن كلمة المرور الجديدة حرفًا ورقمًا على الأقل.';

  @override
  String get changeTemporaryPasswordErrorConfirmMismatch =>
      'كلمتا المرور الجديدتان غير متطابقتين.';

  @override
  String get changeTemporaryPasswordErrorWrongPassword =>
      'كلمة المرور الحالية غير صحيحة.';

  @override
  String get changeTemporaryPasswordErrorWeakPassword =>
      'كلمة المرور ضعيفة. جرّب مزيجًا أطول من الأحرف والأرقام.';

  @override
  String get changeTemporaryPasswordErrorRequiresRecentLogin =>
      'يرجى تسجيل الخروج ثم الدخول مرة أخرى ثم أعد المحاولة.';

  @override
  String get changeTemporaryPasswordErrorNetwork =>
      'خطأ في الشبكة. تحقق من الاتصال ثم أعد المحاولة.';

  @override
  String get changeTemporaryPasswordErrorGeneric =>
      'تعذر تحديث كلمة المرور. حاول مرة أخرى.';

  @override
  String get changeTemporaryPasswordFirestorePartialFailure =>
      'تم تغيير كلمة المرور، لكن تعذر تحديث حالة الحساب. تواصل مع مالك الصالون.';

  @override
  String get authLoginErrorStaffNotFound =>
      'لا يوجد حساب موظف لهذا الاسم. تحقق من الإملاء أو راجع مالك الصالون.';

  @override
  String get authLoginErrorPermission => 'ليست لديك صلاحية لإتمام هذا الإجراء.';

  @override
  String get authV2LoginHeadline => 'تسجيل الدخول';

  @override
  String get authV2LoginSubtitle =>
      'استخدم بريدك المهني للوصول إلى مساحة العمل.';

  @override
  String get authV2SignupHeadline => 'إنشاء حساب';

  @override
  String get authV2SignupSubtitle =>
      'إعداد سريع — يمكنك إضافة التفاصيل لاحقًا.';

  @override
  String get authV2ForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authV2ForgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authV2ForgotPasswordDescription =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get authV2ForgotPasswordSent =>
      'تحقق من بريدك لتعليمات إعادة التعيين.';

  @override
  String get authV2SendResetLink => 'إرسال الرابط';

  @override
  String get authV2OrDivider => 'أو';

  @override
  String get guestAuthOrDivider => 'أو';

  @override
  String get guestAuthContinueAsGuest => 'متابعة كضيف';

  @override
  String get guestAuthGuestSubtitle =>
      'لا حاجة لحساب. اكتشف الصالونات واحجز بسرعة.';

  @override
  String guestAuthSignInFailed(String details) {
    return 'تعذر المتابعة كضيف: $details';
  }

  @override
  String get guestAuthSessionTimeout =>
      'استغرق تحميل ملفك وقتًا أطول من المتوقع. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get guestNicknameScreenTitle => 'كيف نناديك؟';

  @override
  String get guestNicknameScreenSubtitle =>
      'اختر اسمًا يظهر لفريق الصالون. سنجعله فريدًا.';

  @override
  String get guestNicknameFieldLabel => 'الاسم المستعار';

  @override
  String get guestNicknameSuggestedLabel => 'اسم العرض';

  @override
  String get guestNicknameContinue => 'متابعة';

  @override
  String get guestNicknameErrorTooShort => 'أدخل حرفين على الأقل.';

  @override
  String get guestNicknameErrorInvalid => 'استخدم أحرفًا وأرقامًا فقط.';

  @override
  String get guestNicknameErrorReserveFailed =>
      'تعذر حجز هذا الاسم. حاول مرة أخرى.';

  @override
  String get customerBookingReviewMissingGuestNickname =>
      'يرجى تعيين الاسم المستعار للضيف أولًا.';

  @override
  String get authV2ContinueGoogle => 'المتابعة مع Google';

  @override
  String get authV2ContinueApple => 'المتابعة مع Apple';

  @override
  String get authV2ContinueFacebook => 'المتابعة مع Facebook';

  @override
  String get authV2SignUpLink => 'إنشاء حساب';

  @override
  String get authV2SignInLink => 'تسجيل الدخول';

  @override
  String get authV2LoginSignupPrompt => 'جديد على Zurano؟';

  @override
  String get authV2SignupSigninPrompt => 'لديك حساب بالفعل؟';

  @override
  String get authV2PasswordHintRules => '8 أحرف على الأقل';

  @override
  String get authV2CreateSalonTitle => 'أضف تفاصيل صالونك';

  @override
  String get authV2CreateSalonSubtitle =>
      'اختر اسم الصالون والمدينة لبدء إدارة الحجوزات والفريق.';

  @override
  String get authV2CurrencyLabel => 'العملة';

  @override
  String get authV2OptionalAddressLabel => 'العنوان (اختياري)';

  @override
  String get authV2CreateSalonCta => 'إنشاء الصالون';

  @override
  String get createSalonCountryRequired =>
      'أكمل اختيار البلد في الإعداد قبل إنشاء الصالون.';

  @override
  String get createSalonCitiesLoading => 'جاري تحميل مدن بلدك…';

  @override
  String get createSalonNoCitiesForCountry =>
      'لا تتوفر قائمة مدن لهذا البلد. أدخل اسم المدينة يدويًا.';

  @override
  String get createSalonEnterCityManually => 'إدخال المدينة يدويًا';

  @override
  String get createSalonPickFromList => 'اختيار من القائمة';

  @override
  String get createSalonSelectCityHint => 'اضغط للبحث واختيار مدينة';

  @override
  String get bentoDashboardScreenTitle => 'مركز العمليات';

  @override
  String get firstTimeRoleEyebrow => 'مرحبًا';

  @override
  String get firstTimeRoleTitle => 'كيف ستستخدم Zurano؟';

  @override
  String get firstTimeRoleDescription => 'اختر دورك لإكمال إعداد الملف.';

  @override
  String get firstTimeRoleUserTitle => 'مستخدم';

  @override
  String get firstTimeRoleUserSubtitle =>
      'احجز الخدمات، استكشف الصالونات، وأدر مواعيدك.';

  @override
  String get firstTimeRoleOwnerTitle => 'صاحب صالون';

  @override
  String get firstTimeRoleOwnerSubtitle =>
      'أنشئ صالونك، وأدر الفريق والحجوزات والرواتب والعمليات.';

  @override
  String get firstTimeRoleContinue => 'متابعة';

  @override
  String get firstTimeRoleDifferentAccount => 'استخدام حساب آخر';

  @override
  String get firstTimeRoleError => 'تعذّر إكمال إعداد الملف. حاول مرة أخرى.';

  @override
  String get ownerTabCustomers => 'العملاء';

  @override
  String get ownerTabFinance => 'المالية';

  @override
  String get ownerDashboardSettingsTooltip => 'الإعدادات';

  @override
  String get ownerServicesWaitingForSalon => 'بانتظار ربط صالون بملفك…';

  @override
  String get onboardingSalonCreatedTitle => 'تم إنشاء الصالون';

  @override
  String get onboardingSalonCreatedSubtitle => 'جارٍ فتح لوحة التحكم…';

  @override
  String get splashBootstrapErrorMessage =>
      'تعذّر بدء التطبيق بسبب شبكة أو مشكلة في قاعدة البيانات. أعد المحاولة.';

  @override
  String get splashRetryStartup => 'إعادة المحاولة';

  @override
  String get customersScreenTitle => 'العملاء';

  @override
  String customersHeroGreeting(String greeting, String name) {
    return '$greeting، $name 👋';
  }

  @override
  String customersSalonOnlyBannerTitle(String salonName) {
    return 'عملاء $salonName فقط';
  }

  @override
  String get customersSalonOnlyBannerSubtitle =>
      'قائمة الصالون للزيارات والحجوزات والإنفاق.';

  @override
  String get customersGlobalSearchHint => 'ابحث عن الفريق والإيرادات والطلبات';

  @override
  String customersCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملاء',
      one: 'عميل واحد',
      zero: '0 عملاء',
    );
    return '$_temp0';
  }

  @override
  String get customersGoldenInfoTitle => 'العملاء الذهبيون';

  @override
  String get customersGoldenInfoSubtitle =>
      'تتبّع الزيارات والحجوزات والإنفاق.';

  @override
  String get customersGoldenInfoDismissSemantics => 'إخفاء التلميح';

  @override
  String get customersInsightsThisMonth => 'هذا الشهر';

  @override
  String get customersInsightsNewThisMonth => 'عملاء جدد';

  @override
  String get customersInsightsReturningThisMonth => 'عائدون';

  @override
  String get customersInsightsTotalCustomers => 'إجمالي النشطين';

  @override
  String get customersInsightsTotalSpent => 'إجمالي الإنفاق';

  @override
  String get customersInsightsLoadError => 'تعذّر تحميل الإحصاءات.';

  @override
  String customersLastServiceLine(String serviceName) {
    return 'آخر خدمة: $serviceName';
  }

  @override
  String get customersActionCall => 'اتصال بالعميل';

  @override
  String get customersActionMessage => 'مراسلة عبر واتساب';

  @override
  String get customersActionViewProfile => 'عرض الملف';

  @override
  String get customersActionCouldNotOpen => 'تعذّر فتح الرابط.';

  @override
  String get customersListFooterTitle => 'ابنِ قائمة عملائك';

  @override
  String get customersListFooterSubtitle =>
      'أضف زبائن الحضور، اربط الحجوزات، وتتبّع الولاء تلقائياً.';

  @override
  String get customersFilterEmptyTitle => 'لا نتائج';

  @override
  String get customersFilterEmptySubtitle =>
      'جرّب بحثاً آخر أو شريحة تصفية، أو امسح عوامل التصفية.';

  @override
  String get customersClearFilters => 'مسح عوامل التصفية';

  @override
  String get customersSearchEmptyTitle => 'لا نتائج للبحث';

  @override
  String get customersSearchEmptySubtitle =>
      'جرّب اسماً أو هاتفاً مختلفاً، أو امسح البحث.';

  @override
  String get customersClearSearch => 'مسح البحث';

  @override
  String get customersAddCustomerFab => 'إضافة عميل';

  @override
  String get customersPermissionErrorTitle =>
      'لا يمكنك الوصول إلى هؤلاء العملاء.';

  @override
  String get customersPermissionErrorSubtitle =>
      'تحقّق من عضوية الصالون أو الصلاحيات.';

  @override
  String get customersGenericLoadError => 'تعذّر تحميل العملاء. حاول مرة أخرى.';

  @override
  String get customersCategoryNewBadge => 'جديد';

  @override
  String get customersCategoryRegularBadge => 'منتظم';

  @override
  String get customersStatusActive => 'نشط';

  @override
  String get customersStatusInactive => 'غير نشط';

  @override
  String customersLastVisitShort(String date) {
    return 'آخر زيارة: $date';
  }

  @override
  String customersVisitsShort(int count) {
    return 'الزيارات: $count';
  }

  @override
  String customersSpentShort(String amount) {
    return 'الإنفاق: $amount';
  }

  @override
  String get customersSearchHint => 'ابحث بالاسم أو الهاتف';

  @override
  String get customersTagAll => 'الكل';

  @override
  String get customersTagNew => 'جديد';

  @override
  String get customersTagRegular => 'منتظم';

  @override
  String get customersTagVip => 'VIP';

  @override
  String get customersTagInactive => 'غير نشط';

  @override
  String get customersEmptyTitle => 'لا يوجد عملاء بعد';

  @override
  String get customersEmptyMessageCanCreate =>
      'أضف أول عميل لتتبّع الزيارات والإنفاق.';

  @override
  String get customersEmptyMessageNoAccess =>
      'لا يوجد عملاء متاحون لهذا الحساب.';

  @override
  String get customersAddFirstCta => 'إضافة أول عميل';

  @override
  String get customersLastVisitNever => 'لا زيارة بعد';

  @override
  String get customersPreferredBarberNone => 'لا يوجد عضو فريق مفضّل';

  @override
  String customersPreferredBarberLine(String phone, String barber) {
    return '$phone · $barber';
  }

  @override
  String customersPreferredBarberLabel(String name) {
    return 'عضو الفريق المفضّل: $name';
  }

  @override
  String customersLastVisitLine(String date, String relative) {
    return 'آخر زيارة: $date ($relative)';
  }

  @override
  String customersVisitsPointsLine(int visits, int points) {
    return 'الزيارات: $visits · النقاط: $points';
  }

  @override
  String customersTotalSpentLine(String amount) {
    return 'إجمالي الإنفاق: $amount';
  }

  @override
  String get customersVipBadge => 'VIP';

  @override
  String get customersTimeNever => 'لا يوجد';

  @override
  String get customersTimeJustNow => 'الآن';

  @override
  String customersTimeMinutesAgo(int n) {
    return 'منذ $n د';
  }

  @override
  String customersTimeHoursAgo(int n) {
    return 'منذ $n س';
  }

  @override
  String customersTimeDaysAgo(int n) {
    return 'منذ $n ي';
  }

  @override
  String customersTimeMonthsAgo(int n) {
    return 'منذ $n شهرًا';
  }

  @override
  String customersTimeYearsAgo(int n) {
    return 'منذ $n سنة';
  }

  @override
  String get customerNotFound => 'لم يُعثر على العميل';

  @override
  String get customerNotFoundSubtitle =>
      'ربما حُذف هذا العميل أو لا تملك صلاحية عرضه.';

  @override
  String get customerBackToCustomers => 'العودة إلى العملاء';

  @override
  String get customerDetailsCall => 'اتصال';

  @override
  String get customerDetailsWhatsApp => 'واتساب';

  @override
  String get customerDetailsEdit => 'تعديل';

  @override
  String get customerDetailsBook => 'حجز';

  @override
  String get customerDetailsAddService => 'إضافة عملية بيع';

  @override
  String get customerDetailsUpcomingSection => 'المواعيد القادمة';

  @override
  String get customerDetailsHistorySection => 'سجل الزيارات';

  @override
  String get customerDetailsBookSameServiceAgain => 'إعادة حجز نفس الخدمة';

  @override
  String customerDetailsSpendingSummary(String amount) {
    return 'ملخص الإنفاق: $amount';
  }

  @override
  String customerDetailsNotesWithValue(String notes) {
    return 'ملاحظات: $notes';
  }

  @override
  String get customerDetailsNotesEmpty => 'لا ملاحظات';

  @override
  String get customerDetailsServiceFallback => 'خدمة';

  @override
  String get customerInsightsTitle => 'رؤى العميل';

  @override
  String get customerProfileVipSubtitle => 'عميل VIP • مفعّل بواسطة المالك';

  @override
  String get customerInsightNoVisits => 'لا توجد زيارات سابقة';

  @override
  String customerInsightLastVisitDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days أيام',
      one: 'يوم واحد',
      zero: 'اليوم',
    );
    return 'آخر زيارة منذ $_temp0';
  }

  @override
  String customerInsightTotalVisitsLine(int count) {
    return 'إجمالي الزيارات: $count';
  }

  @override
  String customerInsightTotalSpentLine(String amount) {
    return 'إجمالي الإنفاق: $amount';
  }

  @override
  String get customerSuggestedActionVip => 'عميل عالي القيمة — يُفضّل عرض مخصص';

  @override
  String get customerSuggestedActionNew => 'عميل جديد — تابع بعرض ترحيبي';

  @override
  String get customerSuggestedActionRegular => 'عميل منتظم — حافظ على التواصل';

  @override
  String get customerSuggestedActionInactive => 'غير نشط — فكّر بعرض عودة';

  @override
  String get customerTypeSectionTitle => 'نوع العميل';

  @override
  String get customerTypeChipsHint =>
      'التصنيف يساعدك على العروض. VIP يحدده المالك فقط.';

  @override
  String get customerTypeVip => 'VIP';

  @override
  String get customerTypeNew => 'جديد';

  @override
  String get customerTypeRegular => 'منتظم';

  @override
  String get customerTypeInactive => 'غير نشط';

  @override
  String get customerDiscountBoxTitle => 'خصم العميل';

  @override
  String get customerDiscountBoxSubtitle =>
      'يُطبّق تلقائياً عند تسجيل عملية بيع';

  @override
  String get customerDiscountEditSheetTitle => 'تعديل الخصم';

  @override
  String get customerDiscountPercentLabel => 'نسبة الخصم %';

  @override
  String get customerDiscountInvalid => 'أدخل قيمة بين 0 و 100';

  @override
  String get customerSalesSectionTitle => 'سجل المعاملات';

  @override
  String customerSalesTotalSpentSummary(String amount) {
    return 'إجمالي ما أنفقه: $amount';
  }

  @override
  String customerSalesLastVisitSummary(String date) {
    return 'آخر زيارة: $date';
  }

  @override
  String get customerSalesEmptyTitle => 'لا توجد معاملات بعد';

  @override
  String get customerSalesEmptySubtitle => 'عند إضافة عملية بيع ستظهر هنا.';

  @override
  String get customerUpcomingSectionTitle => 'المواعيد القادمة';

  @override
  String get customerUpcomingEmptyTitle => 'لا مواعيد قادمة';

  @override
  String get customerNotesSectionTitle => 'ملاحظات';

  @override
  String get createBookingSearchCustomerLabel => 'ابحث عن عميل';

  @override
  String get createBookingAddNewCustomer => 'إضافة جديد';

  @override
  String createBookingDateWithValue(String date) {
    return 'التاريخ: $date';
  }

  @override
  String createBookingTimeWithValue(String time) {
    return 'الوقت: $time';
  }

  @override
  String get createBookingPickTime => 'اختر الوقت';

  @override
  String get createBookingValidationIncomplete =>
      'أكمل اختيار العميل والخدمة وعضو الفريق والتاريخ والوقت.';

  @override
  String get createBookingSuccessSnackbar => 'تم إنشاء الحجز بنجاح';

  @override
  String get createBookingSaveCta => 'حفظ الحجز';

  @override
  String get addCustomerTitle => 'إضافة عميل جديد';

  @override
  String get addCustomerSaveCustomer => 'حفظ العميل';

  @override
  String get addCustomerSaveAndBook => 'حفظ وحجز';

  @override
  String get addCustomerFieldFullName => 'الاسم الكامل';

  @override
  String get addCustomerFullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get addCustomerFieldPhone => 'رقم الهاتف';

  @override
  String get addCustomerFieldSource => 'المصدر (زائر، إنستغرام، إحالة…)';

  @override
  String get addCustomerFieldNotes => 'ملاحظات';

  @override
  String get addCustomerSavedWithPhone => 'تم حفظ العميل بنجاح.';

  @override
  String get addCustomerSavedNoPhone => 'تم حفظ العميل. لم يُضف رقم هاتف.';

  @override
  String get accountProfileRecoveryInlineError =>
      'تم إنشاء الحساب لكن إعداد الملف لم يكتمل. اضغط «إنشاء الملف» لاستكمال الحساب.';

  @override
  String get profileFieldFullName => 'الاسم الكامل';

  @override
  String get profileFieldMobile => 'الجوال';

  @override
  String get profileFieldCity => 'المدينة';

  @override
  String get authHintEmailExample => 'name@example.com';

  @override
  String get customerBookingMoreDays => 'مزيد من الأيام';

  @override
  String barberAttendanceInOutLine(String checkIn, String checkOut) {
    return 'دخول: $checkIn · خروج: $checkOut';
  }

  @override
  String get barberAttendanceStatusPresent => 'حاضر';

  @override
  String get barberAttendanceStatusAbsent => 'غائب';

  @override
  String get barberAttendanceStatusLate => 'متأخر';

  @override
  String get barberAttendanceStatusLeave => 'إجازة';

  @override
  String get preAuthLanguageEnglishHint => 'واجهة بالإنجليزية';

  @override
  String get preAuthLanguageArabicHint => 'واجهة بالعربية';

  @override
  String get semanticIllustrationSalonOwnerSignup =>
      'رسم توضيحي لتسجيل صاحب الصالون';

  @override
  String get semanticIllustrationCustomerSignup => 'رسم توضيحي لتسجيل العميل';

  @override
  String get semanticIllustrationEmptyServices => 'رسم توضيحي لعدم وجود خدمات';

  @override
  String get semanticIllustrationWelcomeOnboarding =>
      'رسم توضيحي لشاشة الترحيب';

  @override
  String get employeePayrollTitle => 'الرواتب';

  @override
  String get employeePayrollSubtitle => 'راتبك وكشف الراتب';

  @override
  String get employeePayrollSelectMonth => 'اختر الشهر';

  @override
  String get employeePayrollNetPay => 'صافي الراتب';

  @override
  String get employeePayrollEarnings => 'الاستحقاقات';

  @override
  String get employeePayrollDeductions => 'الخصومات';

  @override
  String get employeePayrollNetSalary => 'صافي الأجر';

  @override
  String get employeePayrollStatusPaid => 'مدفوع';

  @override
  String get employeePayrollStatusApproved => 'معتمد';

  @override
  String get employeePayrollServicesStat => 'الخدمات';

  @override
  String get employeePayrollThisMonth => 'هذا الشهر';

  @override
  String get employeePayrollCommissionStat => 'العمولة';

  @override
  String get employeePayrollOnServices => 'على الخدمات';

  @override
  String get employeePayrollAttendanceStat => 'الحضور';

  @override
  String get employeePayrollDaysPresent => 'أيام الحضور';

  @override
  String get employeePayrollViewFullPayslip => 'عرض كشف الراتب';

  @override
  String get employeePayrollDownloadPdf => 'تنزيل PDF';

  @override
  String get employeePayrollRecentTitle => 'كشوف سابقة';

  @override
  String get employeePayrollViewAll => 'عرض الكل';

  @override
  String get employeePayrollEmptyTitle =>
      'لم يتم إصدار كشف الراتب لهذا الشهر بعد';

  @override
  String get employeePayrollEmptyBody =>
      'سيظهر كشف الراتب هنا بعد أن يقوم صاحب الصالون بإصدار الرواتب لهذه الفترة.';

  @override
  String get employeeWorkspaceNotLinkedTitle => 'لم يتم ربط حسابك بملف موظف';

  @override
  String get employeeWorkspaceNotLinkedBody =>
      'لم يتم ربط حسابك بملف موظف بعد. اطلب من مالك الصالون إكمال إعداد حساب الموظف.';

  @override
  String get employeeStaffWorkspaceUnavailableTitle => 'مساحة الموظف غير متاحة';

  @override
  String get employeeStaffWorkspaceUnavailableBody =>
      'حسابك أو ملف الموظف غير نشط، أو تعذر تحميل بيانات الموظف. تواصل مع مالك الصالون لاستعادة الوصول.';

  @override
  String get employeeMapLocationPermissionRequired =>
      'يلزم إذن الموقع لعرض موقعك على الخريطة.';

  @override
  String get employeeMapUnavailableBody =>
      'تعذّر تحميل الخريطة. لا يزال بإمكانك التسجيل عبر GPS عند التفعيل.';

  @override
  String get employeePayrollErrorTitle => 'تعذر تحميل الرواتب';

  @override
  String get employeePayrollSalaryNotesTitle => 'ملاحظات الراتب';

  @override
  String get employeePayrollNoWorkspace => 'لا يوجد مساحة عمل';

  @override
  String get employeePayrollHistoryTitle => 'سجل كشوف الراتب';

  @override
  String get employeePayrollDetailsTitle => 'كشف الراتب';

  @override
  String get employeePayrollPdfShareSubject => 'كشف راتب';

  @override
  String get employeePayrollTotalEarnings => 'إجمالي الاستحقاقات';

  @override
  String get employeePayrollTotalDeductions => 'إجمالي الخصومات';

  @override
  String employeePayrollPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String get employeeTodayLocationUnknown => 'الموقع غير معروف';

  @override
  String get employeeTodayNoAddressSet => 'لم يُضبط عنوان';

  @override
  String get employeeAttendanceZoneNotConfiguredAdmin =>
      'منطقة الحضور غير مُعدّة بعد. يُرجى التواصل مع مسؤول الصالون.';

  @override
  String get employeeAttendanceNotRequiredOrDisabled =>
      'الحضور غير مطلوب أو معطّل.';

  @override
  String get employeeTodayCheckedOutForToday => 'لقد سجّلت خروجك لهذا اليوم.';

  @override
  String get employeeTodayCorrectionRequestsDisabled =>
      'طلبات التصحيح معطّلة لصالونك.';

  @override
  String get employeeTodayAwaitingApproval => 'بانتظار الموافقة';

  @override
  String get employeeTodayNoOpenRequests => 'لا توجد طلبات مفتوحة';

  @override
  String get employeeAttendanceSalonLocationTitle => 'موقع الصالون';

  @override
  String get employeeAttendanceLocating => 'جارٍ تحديد الموقع…';

  @override
  String employeeAttendanceGpsAccuracy(String accuracy) {
    return 'دقة GPS: $accuracy';
  }

  @override
  String get employeeAttendanceSalonLocationOwnerNote =>
      'لم يُضبط موقع الصالون. يُرجى التواصل مع المالك.';

  @override
  String get employeeAttendanceRetryLocation => 'إعادة محاولة الموقع';

  @override
  String get employeeAttendanceWithinRange => 'ضمن النطاق';

  @override
  String get employeeAttendanceOutsideRange => 'خارج النطاق';

  @override
  String get employeeAttendanceScreenTitle => 'الحضور';

  @override
  String get employeeAttendanceScreenSubtitle =>
      'تابع ساعات عملك والتزم بالمواعيد';

  @override
  String get employeeAttendanceGreetingMorning => 'صباح الخير،';

  @override
  String get employeeAttendanceGreetingAfternoon => 'مساء الخير،';

  @override
  String get employeeAttendanceGreetingEvening => 'مساء الخير،';

  @override
  String get employeeAttendanceProductiveDay => 'يومًا موفقًا! 👋';

  @override
  String get employeePunchNextAction => 'الإجراء التالي';

  @override
  String get employeePunchMissingDetectedWithCorrection =>
      'تم رصد بصمة ناقصة. أرسل طلبًا للموافقة.';

  @override
  String get employeePunchDoneForToday => 'أنهيت يومك.';

  @override
  String get employeePunchMustBeInZone =>
      'يجب أن تكون داخل نطاق الصالون لتسجيل الدخول.';

  @override
  String get employeePunchTapWhenArrive => 'اضغط عند وصولك إلى الصالون.';

  @override
  String employeePunchBreakLimitMinutes(int minutes) {
    return 'حد الاستراحة اليومي $minutes دقيقة إجمالًا.';
  }

  @override
  String get employeePunchReturnFromBreak => 'اضغط عند عودتك من الاستراحة.';

  @override
  String get employeePunchEndWorkingDay => 'أنهِ يوم العمل.';

  @override
  String get employeePunchSubmitCorrection => 'إرسال تصحيح';

  @override
  String get employeePunchMissingAskAdmin =>
      'تم رصد بصمة ناقصة. اطلب من المالك أو المسؤول تفعيل طلبات التصحيح.';

  @override
  String get employeePunchCompletedTodayTitle => 'اكتمل اليوم';

  @override
  String get employeeTimelineTodayTitle => 'الجدول الزمني لليوم';

  @override
  String get employeeTimelineBreakOutTitle => 'بداية الاستراحة';

  @override
  String get employeeTimelineBreakInTitle => 'نهاية الاستراحة';

  @override
  String get employeeTimelineWorkingHours => 'ساعات العمل';

  @override
  String get employeeTimelineShiftNotSet => 'لم تُضبط أوقات الوردية';

  @override
  String get employeeTodayStatusCardTitle => 'حالة اليوم';

  @override
  String get employeeAttendanceWorkedLabel => 'مدة العمل';

  @override
  String get employeeAttendanceExpectedCheckoutLabel => 'الخروج المتوقع';

  @override
  String get employeeAttendanceStatusMissingPunch => 'بصمة ناقصة';

  @override
  String get employeeAttendanceStatusIncomplete => 'غير مكتمل';

  @override
  String get employeeAttendanceStatusNotCheckedInTitle => 'لم يُسجّل الدخول';

  @override
  String get employeeRecentAttendanceTitle => 'الحضور الأخير';

  @override
  String get employeeAttendanceSeeAll => 'عرض الكل';

  @override
  String get employeeRecentAttendanceLoadError => 'تعذّر تحميل الأيام الأخيرة.';

  @override
  String get employeeRecentAttendanceEmpty =>
      'لا سجل حضور بعد.\nاضغط «تسجيل الدخول» عند وصولك إلى الصالون.';

  @override
  String get employeeAttendanceStatusOnTime => 'في الوقت';

  @override
  String get employeeAttendanceOverviewTitle => 'نظرة على الحضور (هذا الشهر)';

  @override
  String get employeeAttendanceViewCalendar => 'عرض التقويم';

  @override
  String get employeeAttendanceOverviewFootnote =>
      'يشمل الأيام بلا سجل قبل اليوم كغياب.';

  @override
  String get employeeAttendanceSummaryLoadError => 'تعذّر تحميل ملخص الحضور.';

  @override
  String get employeeAttendanceNoDataYet => 'لا بيانات بعد.';

  @override
  String get employeeAttendanceOverviewDays => 'أيام';

  @override
  String get employeeAttendanceLoadError => 'تعذّر تحميل الحضور.';

  @override
  String get employeeAttendanceCorrectionFlowTitle => 'تصحيح الحضور';

  @override
  String get employeeAttendanceCorrectionSubtitle =>
      'أرسل طلبًا لبصمة فاتتك لمراجعتها والموافقة.';

  @override
  String get employeeCorrectionSelectPunchType => 'يُرجى اختيار نوع البصمة.';

  @override
  String get employeeCorrectionSelectValidDate => 'يُرجى اختيار تاريخ صالح.';

  @override
  String get employeeCorrectionSelectValidTime => 'يُرجى اختيار وقت صالح.';

  @override
  String get employeeCorrectionFutureNotAllowed =>
      'لا يمكن أن يكون تاريخ الطلب في المستقبل.';

  @override
  String get employeeCorrectionTooOld =>
      'هذا الطلب أقدم من فترة التصحيح المسموح بها.';

  @override
  String get employeeCorrectionReasonRequired => 'يُرجى إدخال السبب.';

  @override
  String get employeeCorrectionReasonMinLength =>
      'يجب أن يكون السبب 10 أحرف على الأقل.';

  @override
  String get employeeCorrectionReasonMaxLength =>
      'لا يمكن أن يتجاوز السبب 250 حرفًا.';

  @override
  String get employeeCorrectionSubmittedSnackbar => 'تم إرسال الطلب بنجاح';

  @override
  String get employeeCorrectionDetailsTitle => 'تفاصيل التصحيح';

  @override
  String get employeeCorrectionRequestedPunchLabel => 'البصمة المطلوبة';

  @override
  String get employeeCorrectionSelectPlaceholder => 'اختر';

  @override
  String get employeeAttendanceReasonLabel => 'السبب';

  @override
  String get employeeCorrectionAdminReviewNote => 'سيراجع المسؤول طلبك.';

  @override
  String get employeeCorrectionSubmitCta => 'إرسال الطلب';

  @override
  String get employeeCorrectionRecentTitle => 'الطلبات الأخيرة';

  @override
  String get employeePolicyTitle => 'سياسة الحضور';

  @override
  String get employeePolicySubtitle => 'قواعد بسيطة ليوم عملك';

  @override
  String get employeePolicySummaryTitle => 'ملخص السياسة';

  @override
  String employeePolicyGpsSummary(int maxBreaks) {
    return 'يستخدم صالونك حضورًا بالـGPS عند التفعيل. تسجيل دخول وتسجيل خروج مرة واحدة يوميًا؛ حتى $maxBreaks استراحات.';
  }

  @override
  String get employeePolicyRulePunchSession =>
      '«تسجيل الدخول» يبدأ جلسة العمل؛ «تسجيل الخروج» ينهيها.';

  @override
  String get employeePolicyRuleBreakPair =>
      'يجب استخدام «بداية الاستراحة» و«نهاية الاستراحة» كزوج.';

  @override
  String get employeePolicyRuleGpsZone =>
      'قد يُطلب GPS عند البصمة — ابقَ داخل نطاق الصالون.';

  @override
  String get employeePolicyUpdatedSnackbar => 'تم تحديث السياسة';

  @override
  String get employeePolicyRegenerateCta => 'إعادة إنشاء السياسة';

  @override
  String get employeePolicyPunchRules => 'قواعد البصمات';

  @override
  String get employeePolicyLateEarly => 'التأخير والخروج المبكر';

  @override
  String get employeePolicyCorrectionSection => 'طلبات التصحيح';

  @override
  String get employeePolicyDefaultTitle => 'سياسة الحضور';

  @override
  String get employeeTodaySubmitCorrection => 'إرسال تصحيح';

  @override
  String get employeeTodayStatusMissingPunch => 'بصمة ناقصة';

  @override
  String get employeeTodayStatusCheckedInSubtitle => 'أنت الآن داخل الدوام';

  @override
  String get employeeTodayStatusOnBreakSubtitle =>
      'اضغط رجوع عند انتهاء الاستراحة';

  @override
  String get employeeTodayStatusBackFromBreakSubtitle =>
      'يمكنك إنهاء الدوام لاحقاً';

  @override
  String get employeeTodayStatusCheckedOutSubtitle => 'شكراً لك';

  @override
  String get employeeTodayStatusMissingPunchSubtitle =>
      'يرجى إرسال طلب تصحيح للبصمة الناقصة';

  @override
  String get employeeTodayStatusInvalidSequenceSubtitle =>
      'يرجى إرسال طلب تصحيح';

  @override
  String employeeTodayLastPunchAt(String time) {
    return 'آخر بصمة: $time';
  }

  @override
  String get employeeMapOpenInMaps => 'فتح في الخرائط';

  @override
  String get employeePolicySummaryStatic =>
      'هذه القواعد تعكس إعدادات حضور الصالون. يمكن لمالك الصالون تعديلها في أي وقت.';

  @override
  String get employeePolicyDeductionsSection => 'الخصومات';

  @override
  String get employeePolicyRuleWorkPunchesOneLine =>
      'كل يوم تسجّل دخولًا وخروجًا مرة واحدة؛ الاستراحات منفصلة عنهما.';

  @override
  String employeePolicyRuleMaxBreakMinutesOneLine(int minutes) {
    return 'مدة الاستراحات الإجمالية محدودة بـ $minutes دقيقة يوميًا (مجموع الاستراحات).';
  }

  @override
  String get employeePolicyRuleBreakOrderOneLine =>
      'يجب أن تلي «بدء الاستراحة» دائمًا «نهاية الاستراحة» قبل بصمات أخرى.';

  @override
  String employeePolicyRuleGpsRequiredOneLine(int radius) {
    return 'الحضور يتطلب موقع هاتفك. ابقَ ضمن $radius م من مركز الصالون عند البصمة.';
  }

  @override
  String get employeePolicyRuleGpsOptionalOneLine =>
      'قد يُستخدم GPS للتحقق من البصمات. ابقَ داخل نطاق الصالون عندما يطلب المالك ذلك.';

  @override
  String get employeePolicyRuleCorrectionForgotOneLine =>
      'إذا فاتتك بصمة، أرسل طلب تصحيح حضور لموافقة المسؤول.';

  @override
  String get employeePolicyRuleCorrectionApprovedOneLine =>
      'التصحيحات الموافق عليها تُضاف بأمان إلى سجل بصماتك.';

  @override
  String employeePolicyRuleLateGraceOneLine(int grace) {
    return 'يُحتسب التأخير فقط بعد فترة سماح $grace دقيقة.';
  }

  @override
  String employeePolicyRuleLateMonthlyOneLine(int count) {
    return 'يُسمح بما يصل إلى $count حالات تأخير شهريًا بعد السماح قبل مراجعة إضافية.';
  }

  @override
  String employeePolicyRuleEarlyGraceOneLine(int grace) {
    return 'يُحتسب الخروج المبكر فقط بعد فترة سماح $grace دقيقة.';
  }

  @override
  String employeePolicyRuleEarlyMonthlyOneLine(int count) {
    return 'يُسمح بما يصل إلى $count حالات خروج مبكر شهريًا بعد السماح قبل مراجعة إضافية.';
  }

  @override
  String get employeePolicyDeductionNone => 'لا يوجد';

  @override
  String employeePolicyDeductionPercentValue(int percent) {
    return '$percent٪';
  }

  @override
  String get employeePolicyDeductionMissingCheckoutTitle => 'تسجيل خروج ناقص';

  @override
  String get employeePolicyDeductionMissingCheckoutSubtitle =>
      'الخصم المُعدّ عند غياب تسجيل الخروج.';

  @override
  String get employeePolicyDeductionAbsenceTitle => 'الغياب';

  @override
  String get employeePolicyDeductionAbsenceSubtitle =>
      'الخصم المُعدّ لأيام الغياب غير المبررة.';

  @override
  String get employeeCalendarLoadError => 'تعذّر تحميل التقويم';

  @override
  String get employeeAttendanceDayTitle => 'يوم الحضور';

  @override
  String get employeeAttendanceDayNoRecord => 'لا سجل لهذا اليوم.';

  @override
  String employeeAttendanceDayStatusLine(String status) {
    return 'الحالة: $status';
  }

  @override
  String employeeAttendanceDayWorkedBreakLine(int worked, int breakMin) {
    return 'العمل: $worked د · الاستراحة: $breakMin د';
  }

  @override
  String get employeeAttendanceDayPunchesTitle => 'البصمات';

  @override
  String get employeeHistoryTitle => 'سجل الحضور';

  @override
  String get employeeHistoryRequestCta => 'طلب';

  @override
  String get employeeHistoryEmpty => 'لا أيام حضور بعد.';

  @override
  String get employeeAttendanceRequestAddReason => 'يُرجى إضافة سبب.';

  @override
  String get employeeAttendanceRequestFutureTime =>
      'لا يمكن أن يكون الوقت المطلوب في المستقبل.';

  @override
  String get employeeAttendanceRequestDuplicatePending =>
      'لديك بالفعل طلب معلّق لهذا.';

  @override
  String get employeeAttendanceRequestSubmitted => 'تم إرسال الطلب';

  @override
  String get employeeRequestFailed => 'فشل الطلب';

  @override
  String get employeeAttendanceRequestScreenTitle => 'تصحيح الحضور';

  @override
  String get employeeAttendanceRequestPunchLabel => 'البصمة المطلوبة';

  @override
  String get employeeAttendanceRequestSubmitCta => 'إرسال الطلب';

  @override
  String get employeeMapPreviewMobileOnly =>
      'معاينة الخريطة متاحة في تطبيق الجوال.';

  @override
  String get employeeMapZoneNotConfigured => 'النطاق غير مُعدّ';

  @override
  String get employeeMapMarkerSalonZone => 'نطاق الصالون';

  @override
  String get employeeMapMarkerYourLocation => 'موقعك';

  @override
  String get employeeTodayStatsTitle => 'يومي';

  @override
  String get employeeTodayStatsSalesLabel => 'المبيعات';

  @override
  String get employeeTodayStatsHoursLabel => 'الساعات';

  @override
  String get employeeTodayDistanceUnknown => 'المسافة —';

  @override
  String get employeeBottomNavToday => 'اليوم';

  @override
  String get employeeBottomNavSales => 'المبيعات';

  @override
  String get employeeBottomNavAttendance => 'الحضور';

  @override
  String get employeeBottomNavPayroll => 'الرواتب';

  @override
  String get employeeBottomNavProfile => 'الملف';

  @override
  String get employeeProfileTabOverview => 'نظرة عامة';

  @override
  String get employeeProfileTabAccountInfo => 'معلومات الحساب';

  @override
  String get employeeProfilePhotoTitle => 'الصورة الشخصية';

  @override
  String get employeeProfilePhotoUpdateAction => 'تحديث الصورة';

  @override
  String get employeeProfileResetPasswordHint =>
      'إرسال رابط إعادة التعيين إلى بريد حسابك.';

  @override
  String get employeeProfileResetPasswordAction => 'إرسال رابط إعادة التعيين';

  @override
  String get employeeProfileUsernameLabel => 'اسم المستخدم';

  @override
  String get employeeProfileRoleLabel => 'الدور';

  @override
  String get employeeProfileAccountStatusLabel => 'حالة الحساب';

  @override
  String get employeeSettingsHeaderSubtitle =>
      'إدارة الملف الشخصي والأمان وتفضيلات التطبيق.';

  @override
  String get employeeProfileSummarySubtitle => 'حافظ على تحديث ملفك المهني.';

  @override
  String get employeeProfileUpdateShort => 'تحديث';

  @override
  String get employeeNoData => 'غير متوفر';

  @override
  String get ownerCustomerBookingTileTitle => 'حجز العملاء';

  @override
  String get ownerCustomerBookingTileSubtitle =>
      'التحكم بالحجز عبر الإنترنت والتوفر والظهور العام';

  @override
  String get ownerCustomerBookingTitle => 'حجز العملاء';

  @override
  String get ownerCustomerBookingSubtitle =>
      'تحكّم في ظهور صالونك للعملاء والحجز عبر الإنترنت وساعات العمل.';

  @override
  String get ownerCustomerBookingSectionPublic => 'الظهور العام';

  @override
  String get ownerCustomerBookingSectionPublicHint => 'القائمة والاستكشاف';

  @override
  String get ownerCustomerBookingShowSalon => 'إظهار الصالون للعملاء';

  @override
  String get ownerCustomerBookingShowSalonHint =>
      'عند الإيقاف، لن يظهر صالونك في استكشاف العملاء.';

  @override
  String get ownerCustomerBookingSectionAvailability => 'توفر الحجز';

  @override
  String get ownerCustomerBookingEnableBooking => 'تفعيل حجز العملاء';

  @override
  String get ownerCustomerBookingAutoConfirm => 'تأكيد الحجوزات تلقائياً';

  @override
  String get ownerCustomerBookingAnySpecialist => 'السماح بأي أخصائي متاح';

  @override
  String get ownerCustomerBookingRequireCode => 'طلب رمز الحجز للاستعلام';

  @override
  String get ownerCustomerBookingShowPrices => 'إظهار الأسعار للعملاء';

  @override
  String get ownerCustomerBookingAllowNotes => 'السماح بملاحظات العميل';

  @override
  String get ownerCustomerBookingAllowFeedback => 'السماح بتقييم العميل';

  @override
  String get ownerCustomerBookingSectionRules => 'قواعد الحجز';

  @override
  String get ownerCustomerBookingSlotInterval => 'فترة الموعد';

  @override
  String get ownerCustomerBookingMaxAdvance => 'أقصى أيام مسبقاً للحجز';

  @override
  String get ownerCustomerBookingCancelCutoff => 'مهلة الإلغاء';

  @override
  String get ownerCustomerBookingRescheduleCutoff => 'مهلة إعادة الجدولة';

  @override
  String get ownerCustomerBookingSectionContact => 'بيانات التواصل العامة';

  @override
  String get ownerCustomerBookingPublicArea => 'المنطقة الظاهرة';

  @override
  String get ownerCustomerBookingPublicPhone => 'الهاتف العام';

  @override
  String get ownerCustomerBookingPublicWhatsapp => 'واتساب العام';

  @override
  String get ownerCustomerBookingGenderTarget => 'الفئة';

  @override
  String get ownerCustomerBookingGenderMen => 'رجال';

  @override
  String get ownerCustomerBookingGenderLadies => 'سيدات';

  @override
  String get ownerCustomerBookingGenderUnisex => 'للجميع';

  @override
  String get ownerCustomerBookingWorkingHours => 'ساعات العمل';

  @override
  String get ownerCustomerBookingCopyMonday =>
      'نسخ الإثنين إلى الثلاثاء–الخميس';

  @override
  String get ownerCustomerBookingCloseAll => 'إغلاق الكل';

  @override
  String get ownerCustomerBookingOpenAll => 'فتح الكل';

  @override
  String get ownerCustomerBookingSave => 'حفظ الإعدادات';

  @override
  String get ownerCustomerBookingSaved => 'تم حفظ إعدادات حجز العملاء';

  @override
  String get ownerCustomerBookingValidationTimeOrder =>
      'يجب أن يكون وقت البداية قبل وقت النهاية في الأيام المفتوحة.';

  @override
  String get ownerCustomerBookingValidationWorkingDay =>
      'يُشترط يوم عمل واحد على الأقل عند تفعيل الظهور العام والحجز.';

  @override
  String get ownerCustomerBookingPublicAreaRequired =>
      'المنطقة العامة مطلوبة عندما يكون الصالون عاماً والحجز مفعّلاً.';

  @override
  String get ownerCustomerBookingValidationSlotInterval =>
      'اختر فترة موعد صالحة (15 أو 20 أو 30 أو 45 أو 60 دقيقة).';

  @override
  String get ownerCustomerBookingValidationMaxAdvance =>
      'أقصى أيام مسبقاً يجب أن يكون بين 1 و90.';

  @override
  String get ownerCustomerBookingValidationCutoff =>
      'المهلة يجب أن تكون بين 0 و10080 دقيقة.';

  @override
  String get ownerCustomerBookingValidationPhone =>
      'أدخل رقم هاتف صالح أو اترك الحقل فارغاً.';

  @override
  String get ownerCustomerBookingDayOpen => 'مفتوح';

  @override
  String get ownerCustomerBookingDayClosed => 'مغلق';

  @override
  String get ownerCustomerBookingSettingsSubtitle =>
      'تحكّم في كيفية حجز العملاء للمواعيد';

  @override
  String get ownerCustomerBookingStatusEnabled => 'مفعّل';

  @override
  String get ownerCustomerBookingStatusDisabled => 'معطّل';

  @override
  String get ownerCustomerBookingSameDay => 'السماح بالحجز في نفس اليوم';

  @override
  String get ownerCustomerBookingRequirePhone => 'إلزام رقم هاتف العميل';

  @override
  String get ownerCustomerBookingRequireName => 'إلزام اسم العميل';

  @override
  String get ownerCustomerBookingTimeRulesTitle => 'قواعد الوقت';

  @override
  String get ownerCustomerBookingMinNotice => 'أقل مهلة قبل الحجز';

  @override
  String get ownerCustomerBookingMaxDaysAhead => 'أقصى عدد أيام للأمام';

  @override
  String get ownerCustomerBookingSlotDuration => 'مدة الفترة';

  @override
  String get ownerCustomerBookingBuffer => 'فاصل بين الحجوزات';

  @override
  String get ownerCustomerBookingCancellationTitle => 'قواعد الإلغاء';

  @override
  String get ownerCustomerBookingAllowCancel => 'السماح للعميل بإلغاء الحجز';

  @override
  String get ownerCustomerBookingCancelNotice => 'أقل مهلة قبل الإلغاء';

  @override
  String get ownerCustomerBookingPublicMessageTitle => 'رسالة الحجز العامة';

  @override
  String get ownerCustomerBookingPublicMessageHint =>
      'تظهر للعملاء عندما يكون الحجز مفتوحاً.';

  @override
  String get ownerCustomerBookingSaveCta => 'حفظ';

  @override
  String get ownerCustomerBookingSaveSuccess => 'تم تحديث إعدادات الحجز';

  @override
  String get ownerCustomerBookingSaveError => 'تعذّر حفظ الإعدادات';

  @override
  String get ownerCustomerBookingLoadError => 'تعذّر تحميل إعدادات الحجز';

  @override
  String get ownerCustomerBookingValidationMinNotice =>
      'لا يمكن أن تكون أقل المهلة سالبة.';

  @override
  String get ownerCustomerBookingValidationMaxDays =>
      'أقصى عدد أيام للأمام يجب أن يكون أكبر من 0.';

  @override
  String get ownerCustomerBookingValidationSlot =>
      'مدة الفترة يجب أن تكون أكبر من 0.';

  @override
  String get ownerCustomerBookingValidationBuffer =>
      'لا يمكن أن يكون الفاصل سالباً.';

  @override
  String get ownerCustomerBookingValidationCancelHours =>
      'مهلة الإلغاء يجب أن تكون أكبر من 0 عند السماح بالإلغاء.';

  @override
  String get ownerCustomerBookingValidationMessage =>
      'لا يمكن أن تتجاوز الرسالة 250 حرفاً.';

  @override
  String ownerCustomerBookingMinutesShort(int n) {
    return '$n د';
  }

  @override
  String ownerCustomerBookingHoursShort(int n) {
    return '$n س';
  }

  @override
  String get ownerCustomerBookingMinutesDay => '24 س';

  @override
  String get customerBookingClosedTitle => 'الحجز عبر الإنترنت مغلق';

  @override
  String get customerBookingClosedMessage =>
      'هذا الصالون لا يقبل حجوزات جديدة عبر الإنترنت حالياً.';

  @override
  String get addSaleSelectAtLeastOneService =>
      'اختر خدمة واحدة على الأقل للمتابعة.';

  @override
  String get addSaleSelectStaffMember => 'اختر مقدّم الخدمة لهذا البيع.';

  @override
  String get addSaleTotalMustBePositive => 'يجب أن يكون الإجمالي أكبر من صفر.';

  @override
  String get addSaleMixedPaymentMustEqualTotal =>
      'يجب أن يساوي مجموع النقد والبطاقة الإجمالي.';

  @override
  String get addSaleNoActiveServicesYet => 'لا توجد خدمات نشطة بعد';

  @override
  String get addSaleCreateServicesFirst =>
      'أضف خدمات أولاً لتتمكن من تسجيل المبيعات.';

  @override
  String get addSaleUnableToLoadServices => 'تعذّر تحميل الخدمات';

  @override
  String get ownerShiftsTileTitle => 'الورديات وجدول الفريق';

  @override
  String get ownerShiftsTileSubtitle => 'إدارة القوالب والجدول الأسبوعي';

  @override
  String get ownerShiftsTitle => 'الورديات';

  @override
  String get ownerShiftsSubtitle => 'إنشاء وإدارة قوالب الورديات';

  @override
  String get ownerShiftsRetry => 'إعادة المحاولة';

  @override
  String get ownerShiftsLoadError => 'تعذّر تحميل قوالب الورديات';

  @override
  String get ownerShiftsSummaryTotalShifts => 'إجمالي الورديات';

  @override
  String get ownerShiftsSummaryAssignedStaff => 'الموظفون المعيّنون';

  @override
  String get ownerShiftsSummaryOffDayRules => 'قواعد أيام الإجازة';

  @override
  String get ownerShiftsSummaryTemplates => 'قوالب';

  @override
  String get ownerShiftsSummaryEmployees => 'موظفون';

  @override
  String get ownerShiftsSummaryRuleSet => 'مجموعة قواعد';

  @override
  String get ownerShiftsTemplatesSectionTitle => 'قوالب الورديات';

  @override
  String get ownerShiftsEmptyStateTitle => 'لا توجد قوالب ورديات بعد';

  @override
  String get ownerShiftsEmptyStateSubtitle =>
      'أنشئ أول قالب وردية للبدء في الجدولة الأسبوعية.';

  @override
  String get ownerShiftsEmptyStateHelper =>
      'الموصى به: وردية نهارية، وردية ليلية، ويوم إجازة.';

  @override
  String get ownerShiftsDuration => 'المدة';

  @override
  String get ownerShiftsBreak => 'الاستراحة';

  @override
  String get ownerShiftsEmployees => 'الموظفون';

  @override
  String get ownerShiftsOvernightBadge => 'ليلية';

  @override
  String get ownerShiftsOffDay => 'إجازة';

  @override
  String get ownerShiftsOpenWeeklyRosterTitle => 'فتح الجدول الأسبوعي';

  @override
  String get ownerShiftsOpenWeeklyRosterSubtitle =>
      'عرض وإدارة ورديات الفريق خلال الأسبوع';

  @override
  String get ownerShiftsCreateTemplateCta => 'إنشاء قالب وردية';

  @override
  String get ownerShiftsDeactivateError => 'تعذّر تعطيل هذه الوردية';

  @override
  String get ownerShiftsDeleteConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف قالب الوردية هذا؟';

  @override
  String get ownerShiftsCreateTemplatePlaceholder =>
      'شاشة إنشاء قالب الوردية ستتوفر لاحقاً';

  @override
  String get ownerShiftsEditTemplatePlaceholder =>
      'شاشة تعديل قالب الوردية ستتوفر لاحقاً';

  @override
  String get ownerShiftsWeeklyPlaceholder =>
      'شاشة الورديات الأسبوعية ستتوفر لاحقاً';

  @override
  String get ownerShiftsApplyPlaceholder => 'شاشة تطبيق الجدول ستتوفر لاحقاً';

  @override
  String get ownerShiftCreateTitle => 'إنشاء وردية';

  @override
  String get ownerShiftEditTitle => 'تعديل وردية';

  @override
  String get ownerShiftCreateSubtitle => 'حدد ساعات العمل للموظفين';

  @override
  String get ownerShiftEditSubtitle => 'حدّث ساعات العمل للموظفين';

  @override
  String get ownerShiftNameLabel => 'اسم الوردية';

  @override
  String get ownerShiftNameHint => 'وردية نهارية';

  @override
  String get ownerShiftTypeLabel => 'نوع الوردية';

  @override
  String get ownerShiftTypeWorking => 'وردية عمل';

  @override
  String get ownerShiftTypeOff => 'يوم إجازة';

  @override
  String get ownerShiftStartTimeLabel => 'وقت البداية';

  @override
  String get ownerShiftEndTimeLabel => 'وقت النهاية';

  @override
  String get ownerShiftBreakMinutesLabel => 'مدة الاستراحة (دقائق)';

  @override
  String get ownerShiftBreakMinutesHint => '30';

  @override
  String get ownerShiftNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get ownerShiftNotesHint => 'أضف ملاحظات لهذه الوردية...';

  @override
  String get ownerShiftColorLabel => 'اللون';

  @override
  String get ownerShiftDefaultLabel => 'الوردية الافتراضية';

  @override
  String get ownerShiftDefaultHint =>
      'سيتم تعيين هذه الوردية تلقائياً لأي موظف جديد.';

  @override
  String get ownerShiftCancelCta => 'إلغاء';

  @override
  String get ownerShiftSaveCta => 'حفظ الوردية';

  @override
  String get ownerShiftSaveSuccess => 'تم حفظ الوردية بنجاح';

  @override
  String get ownerShiftSaveError => 'تعذّر حفظ الوردية';

  @override
  String get ownerShiftPreviewTitleFallback => 'معاينة الوردية';

  @override
  String get ownerShiftValidationNameRequired => 'اسم الوردية مطلوب.';

  @override
  String get ownerShiftValidationNameLength =>
      'يجب ألا يتجاوز اسم الوردية 30 حرفاً.';

  @override
  String get ownerShiftValidationTimeRequired =>
      'وقت البداية والنهاية مطلوبان لوردية العمل.';

  @override
  String get ownerShiftValidationDurationPositive =>
      'يجب أن تكون مدة الوردية أكبر من صفر.';

  @override
  String get ownerShiftValidationDurationMax =>
      'يجب ألا تتجاوز مدة الوردية 16 ساعة.';

  @override
  String get ownerShiftValidationBreakMin =>
      'لا يمكن أن تكون دقائق الاستراحة سالبة.';

  @override
  String get ownerShiftValidationBreakMax =>
      'يجب أن تكون دقائق الاستراحة أقل من مدة الوردية.';

  @override
  String get ownerShiftValidationDefaultRequired =>
      'يجب تحديد قالب وردية افتراضي واحد على الأقل.';

  @override
  String get ownerWeeklyShiftsTitle => 'الورديات الأسبوعية';

  @override
  String get ownerWeeklyShiftsSubtitle => 'إدارة جدول الفريق';

  @override
  String get ownerWeeklyShiftsThisWeek => 'هذا الأسبوع';

  @override
  String get ownerWeeklyShiftsNextWeek => 'الأسبوع القادم';

  @override
  String get ownerWeeklyShiftsApplyToMonth => 'تطبيق على الشهر';

  @override
  String get ownerWeeklyShiftsTemplatesStripTitle => 'اسحب وردية إلى اليوم';

  @override
  String get ownerWeeklyShiftsDragStripBody => 'اسحب وردية\nإلى اليوم';

  @override
  String get ownerWeeklyShiftsTipCardBody =>
      'اضغط على خلية لوضع علامة عطلة، أو تغيير الوردية، أو إزالة التعيين الحالي.';

  @override
  String get ownerShiftsTemplatesReorder => 'إعادة ترتيب';

  @override
  String get ownerWeeklyShiftsNoTemplates => 'أنشئ قوالب الورديات أولاً';

  @override
  String get ownerWeeklyShiftsNoEmployees => 'أضف موظفين أولاً';

  @override
  String get ownerWeeklyShiftsLoadError => 'تعذّر تحميل بيانات الجدول الأسبوعي';

  @override
  String get ownerWeeklyShiftsEmptyCell => '+';

  @override
  String get ownerWeeklyShiftsEmployeesHeader => 'الموظفون';

  @override
  String get ownerWeeklyShiftsMarkOffAction => 'تحديد إجازة';

  @override
  String get ownerWeeklyShiftsRemoveAssignmentAction => 'إزالة التعيين';

  @override
  String get ownerWeeklyShiftsAssignAction => 'تعيين';

  @override
  String get ownerApplyScheduleSectionTarget => 'طبّق هذه الخطة على';

  @override
  String get ownerApplyScheduleTitle => 'تطبيق الجدول';

  @override
  String get ownerApplyScheduleSubtitle => 'تكرار هذه الخطة الأسبوعية';

  @override
  String get ownerApplyScheduleOptionThisWeek => 'هذا الأسبوع فقط';

  @override
  String get ownerApplyScheduleOptionRemainingMonth =>
      'الأسابيع المتبقية من هذا الشهر';

  @override
  String get ownerApplyScheduleOptionRemainingMonthSubtitle =>
      'تطبيق من هذا الأسبوع حتى نهاية الشهر';

  @override
  String get ownerApplyScheduleOptionCustomRange => 'نطاق تاريخ مخصص';

  @override
  String get ownerApplyScheduleSelectCustomRange =>
      'اختر تاريخ البداية والنهاية';

  @override
  String get ownerApplyScheduleCalendarPreview => 'معاينة التقويم';

  @override
  String get ownerApplyScheduleRepeatEveryWeek => 'التكرار كل أسبوع';

  @override
  String get ownerApplyScheduleSkipExistingAssignments =>
      'تخطي التعيينات الموجودة';

  @override
  String get ownerApplyScheduleIncludeOffDays => 'تضمين أيام الإجازة';

  @override
  String get ownerApplyScheduleInfoCard =>
      'تطبيق هذا الجدول سيحدّث جدول الموظفين للتواريخ المحددة.';

  @override
  String get ownerApplyScheduleCta => 'تطبيق الجدول';

  @override
  String get ownerApplyScheduleSuccessTitle => 'تم تطبيق الجدول بنجاح';

  @override
  String ownerApplyScheduleSuccessBody(int writes, int skipped) {
    return 'تم إنشاء/تحديث $writes جداول. تم تخطي $skipped جداول موجودة.';
  }

  @override
  String get ownerApplyScheduleOk => 'حسنًا';

  @override
  String ownerApplySchedulePreviewSummary(int assignments, int offDays) {
    return 'التعيينات: $assignments • أيام الإجازة: $offDays';
  }

  @override
  String get zuranoDiscoverGuestName => 'زائر';

  @override
  String get zuranoHomeHeadlineLine1 => 'حيث العناية الذاتية';

  @override
  String get zuranoHomeHeadlineLine2Prefix => 'تلتقي ';

  @override
  String get zuranoHomeHeadlineHighlight => 'الأناقة';

  @override
  String get zuranoHomeLocationLoading => 'جاري تحديد الموقع…';

  @override
  String get zuranoHomeLocationUnavailable => 'الموقع غير متاح';

  @override
  String get zuranoHomeLocationNearYou => 'بالقرب منك';

  @override
  String zuranoHomeLocationCityCountry(String city, String country) {
    return '$city، $country';
  }

  @override
  String get zuranoDiscoverSomethingWrong => 'حدث خطأ ما';

  @override
  String get zuranoDiscoverRecommendedTitle => 'موصى بها لك';

  @override
  String get zuranoDiscoverSeeAll => 'عرض الكل';

  @override
  String get zuranoDiscoverExploreAll => 'استكشف الكل';

  @override
  String get zuranoDiscoverFiltersLabel => 'التصفيات';

  @override
  String get zuranoDiscoverFiltersComingSoon =>
      'حفظ عوامل التصفية سيُضاف لاحقًا.';

  @override
  String get zuranoDiscoverSearchHint =>
      'ابحث عن الصالونات أو الخدمات أو المناطق...';

  @override
  String get zuranoRewardsBannerTitle => 'تألّق أكثر وتدفع أقل ✨';

  @override
  String get zuranoRewardsBannerSubtitle =>
      'اكسب نقاطًا مع كل حجز وافتح مكافآت حصرية.';

  @override
  String get zuranoRewardsBannerCta => 'عرض العروض';

  @override
  String get zuranoTrendingServicesTitle => 'خدمات رائجة الآن';

  @override
  String get zuranoNearbyTitle => 'صالونات قريبة';

  @override
  String get zuranoNearbyViewMap => 'عرض الخريطة';

  @override
  String get zuranoNearbyMapSnack => 'عرض الخريطة سيُضاف لاحقًا.';

  @override
  String get zuranoNearbyBookNow => 'احجز الآن';

  @override
  String zuranoNearbyLocationLineKm(String cityCountry, String kmFormatted) {
    return '$cityCountry • $kmFormatted كم';
  }

  @override
  String zuranoNearbyKilometersOnly(String kmFormatted) {
    return '$kmFormatted كم';
  }

  @override
  String zuranoNearbyLocationTwoParts(String first, String second) {
    return '$first • $second';
  }

  @override
  String get zuranoBottomNavHome => 'الرئيسية';

  @override
  String get zuranoBottomNavBookings => 'الحجوزات';

  @override
  String get zuranoBottomNavRewards => 'المكافآت';

  @override
  String get zuranoBottomNavProfile => 'الملف';

  @override
  String get zuranoDiscoverFallbackCategoryAll => 'الكل';

  @override
  String get zuranoDiscoverFallbackCategoryHair => 'الشعر';

  @override
  String get zuranoDiscoverFallbackCategoryNails => 'الأظافر';

  @override
  String get zuranoDiscoverFallbackCategoryBeauty => 'التجميل';

  @override
  String get zuranoDiscoverFallbackCategoryBarbers => 'الحلاقة';

  @override
  String get zuranoDiscoverFallbackCategorySpa => 'السبا';

  @override
  String get zuranoDiscoverFallbackCategoryMakeup => 'المكياج';

  @override
  String get zuranoDiscoverIndexBuildingMessage =>
      'نعمل على تجهيز بيانات الصالونات. يرجى المحاولة قريبًا.';

  @override
  String get zuranoDiscoverSectionLoadFailed =>
      'تعذّر تحميل هذا القسم. يرجى المحاولة لاحقًا.';

  @override
  String get zuranoDiscoverRecommendedEmpty => 'لا توجد صالونات موصى بها بعد';

  @override
  String get zuranoDiscoverTrendingServicesEmpty => 'لا توجد خدمات رائجة بعد';

  @override
  String zuranoDiscoverNearbyEmptyInCountry(String countryName) {
    return 'لا توجد صالونات في $countryName بعد';
  }

  @override
  String get estimatedPayout => 'الدفعة المتوقعة';

  @override
  String get commission => 'العمولة';

  @override
  String get services => 'الخدمات';

  @override
  String get addBonus => 'إضافة مكافأة';

  @override
  String get addDeduction => 'إضافة خصم';

  @override
  String get generatePayslip => 'إنشاء قسيمة راتب';

  @override
  String get reverseLastPayrollMonth => 'عكس شهر الرواتب الأخير';

  @override
  String get fixedCommissionAmount => 'قيمة العمولة الثابتة';

  @override
  String get earningsBreakdown => 'تفصيل الأرباح';

  @override
  String get servicesRevenue => 'إيراد الخدمات';

  @override
  String get commissionToday => 'عمولة اليوم';

  @override
  String get commissionThisMonth => 'عمولة هذا الشهر';

  @override
  String get bonuses => 'المكافآت';

  @override
  String get deductions => 'الخصومات';

  @override
  String get payrollFormula => 'معادلة الرواتب';

  @override
  String get payrollHistory => 'سجل الرواتب';

  @override
  String get noPayrollRecordsYet => 'لا توجد سجلات رواتب بعد';

  @override
  String get generatedPayslipsWillAppearHere =>
      'ستظهر قسائم الرواتب المُنشأة هنا.';

  @override
  String get generateFirstPayslip => 'أنشئ أول قسيمة راتب';

  @override
  String get payrollLocked => 'الراتب مقفل';

  @override
  String get payrollPaidLockedMessage =>
      'تم دفع هذا الراتب بالفعل ولا يمكن تعديله.';

  @override
  String get payrollPayslipGeneratedLockedMessage =>
      'تم إنشاء قسيمة راتب لهذا الشهر. استخدم «عكس شهر الرواتب الأخير» لتعديل أو حذف التعديلات، ثم أنشئ القسيمة من جديد عند الحاجة.';

  @override
  String get employeeInactivePayrollMessage =>
      'الموظف غير نشط/مجمّد، لذلك تم تعطيل إجراءات الرواتب.';

  @override
  String get addPayrollAdjustment => 'إضافة تعديل راتب';

  @override
  String get amount => 'المبلغ';

  @override
  String get elementName => 'اسم العنصر';

  @override
  String get notRecurring => 'غير متكرر';

  @override
  String get recurringOneYear => 'متكرر (حتى الإزالة)';

  @override
  String get deletePayrollElementTitle => 'حذف عنصر الرواتب؟';

  @override
  String deletePayrollElementMessage(String name) {
    return 'هل تريد إزالة \"$name\" من عناصر الرواتب؟ سيتم إيقاف العناصر المتكررة للأشهر القادمة.';
  }

  @override
  String get keepElement => 'إبقاء';

  @override
  String get deleteElement => 'حذف';

  @override
  String get payrollElementDeleted => 'تم حذف عنصر الرواتب.';

  @override
  String get payrollAdjustmentDeleteNoneMatched =>
      'تعذّر إزالة هذا التعديل (لم يُعثر على سجل مطابق). اسحب للتحديث ثم أعد المحاولة.';

  @override
  String get reverseLastPayrollMonthTitle => 'عكس شهر الرواتب الأخير؟';

  @override
  String get reverseLastPayrollMonthMessage =>
      'سيتم تعليم أحدث شهر رواتب كمعكوس. يمكنك إنشاءه مرة أخرى عند الحاجة.';

  @override
  String get reversePayrollMonthSuccess => 'تم عكس شهر الرواتب الأخير بنجاح.';

  @override
  String get reason => 'السبب';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get bonusAddedSuccessfully => 'تمت إضافة المكافأة بنجاح.';

  @override
  String get deductionAddedSuccessfully => 'تمت إضافة الخصم بنجاح.';

  @override
  String get payslipGeneratedSuccessfully => 'تم إنشاء قسيمة الراتب بنجاح.';

  @override
  String get payrollLoadFailed => 'تعذّر تحميل بيانات الرواتب.';

  @override
  String get payrollHistoryLoadFailed => 'تعذّر تحميل سجل الرواتب.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get updatePayrollAdjustment => 'تحديث تعديل الراتب';

  @override
  String get payrollElementUpdated => 'تم تحديث عنصر الرواتب.';

  @override
  String get update => 'تحديث';
}
