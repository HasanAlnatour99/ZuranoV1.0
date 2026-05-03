import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/user_roles.dart';
import '../../../../core/firestore/report_period.dart';
import '../../../../core/utils/firebase_error_message.dart';
import '../../../../features/customers/data/models/customer.dart';
import '../../../../features/employees/data/models/employee.dart';
import '../../../../features/sales/data/models/sale.dart';
import '../../../../features/sales/data/models/salon_sales_settings.dart';
import '../../../../features/sales/data/sales_ai_analysis_service.dart';
import '../../../../features/services/data/models/service.dart';
import '../../../../shared/services/service_category_icon_resolver.dart';
import '../../../../features/users/data/models/app_user.dart';
import '../../../../providers/app_settings_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../domain/add_sale_entry_mode.dart';
import '../../domain/payment_method.dart';
import 'add_sale_entry_mode_notifier.dart';
import 'salon_sales_settings_provider.dart';

final addSaleControllerProvider =
    NotifierProvider.autoDispose<AddSaleController, AddSaleState>(
      AddSaleController.new,
    );

final _salesAiAnalysisServiceProvider = Provider<SalesAiAnalysisService>(
  (ref) => const SalesAiAnalysisService(),
);

class CartLine {
  const CartLine({
    required this.serviceId,
    required this.serviceName,
    this.categoryKey,
    this.iconKey,
    required this.unitPrice,
    this.quantity = 1,
  });

  final String serviceId;
  final String serviceName;
  final String? categoryKey;
  final String? iconKey;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(
      serviceId: serviceId,
      serviceName: serviceName,
      categoryKey: categoryKey,
      iconKey: iconKey,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class AddSaleState {
  const AddSaleState({
    this.lines = const [],
    this.searchQuery = '',
    this.selectedBarberId,
    this.paymentMethod = PosPaymentMethod.cash,
    this.customerName = '',
    this.linkedCustomerId,
    this.linkedCustomerDiscountPercent = 0,
    this.discountAmount = 0,
    this.splitCashAmount = 0,
    this.splitCardAmount = 0,
    this.receiptImage,
    this.submitError,
    this.isSubmitting = false,
    this.suppressStaffExtraDiscount = false,
  });

  final List<CartLine> lines;
  final String searchQuery;
  final String? selectedBarberId;
  final PosPaymentMethod paymentMethod;
  final String customerName;

  final String? linkedCustomerId;
  final double linkedCustomerDiscountPercent;

  final double discountAmount;
  final double splitCashAmount;
  final double splitCardAmount;
  final XFile? receiptImage;
  final String? submitError;
  final bool isSubmitting;

  /// When true (employee entry + salon policy), linked % and manual discounts
  /// are ignored for totals and persistence.
  final bool suppressStaffExtraDiscount;

  double get subtotal =>
      lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  double get customerPercentDiscountAmount {
    if (suppressStaffExtraDiscount) {
      return 0;
    }
    if (linkedCustomerId == null || linkedCustomerId!.trim().isEmpty) {
      return 0;
    }
    final p = linkedCustomerDiscountPercent;
    if (p <= 0) return 0;
    final raw = subtotal * (p / 100);
    return raw.clamp(0, subtotal);
  }

  double get appliedManualDiscount =>
      suppressStaffExtraDiscount ? 0 : discountAmount.clamp(0, subtotal);

  double get totalDiscountAmount =>
      (customerPercentDiscountAmount + appliedManualDiscount).clamp(
        0,
        subtotal,
      );

  double get totalAmount =>
      (subtotal - totalDiscountAmount).clamp(0, double.infinity);

  ({double cash, double card}) paymentAmounts(double total) {
    switch (paymentMethod) {
      case PosPaymentMethod.cash:
        return (cash: total, card: 0.0);
      case PosPaymentMethod.card:
        return (cash: 0.0, card: total);
      case PosPaymentMethod.mixed:
        return (cash: splitCashAmount, card: splitCardAmount);
    }
  }

  static const _eps = 0.009;

  bool paymentStructureValid(double total) {
    if (total <= 0) return false;
    final p = paymentAmounts(total);
    if (paymentMethod == PosPaymentMethod.cash) {
      return (p.cash - total).abs() <= _eps && p.card.abs() <= _eps;
    }
    if (paymentMethod == PosPaymentMethod.card) {
      return (p.card - total).abs() <= _eps && p.cash.abs() <= _eps;
    }
    return p.cash > _eps &&
        p.card > _eps &&
        (p.cash + p.card - total).abs() <= _eps;
  }

  bool receiptRequirementMet({
    required SalonSalesSettings settings,
    required AddSaleEntryMode mode,
  }) {
    final total = totalAmount;
    if (total <= 0) return true;
    final p = paymentAmounts(total);
    final cardPart = paymentMethod == PosPaymentMethod.card
        ? total
        : (paymentMethod == PosPaymentMethod.mixed ? p.card : 0);
    final needsCardPhoto = settings.requireCardReceiptPhoto && cardPart > _eps;
    final needsCashPhoto =
        settings.requireCashReceiptPhoto &&
        paymentMethod == PosPaymentMethod.cash;
    if (needsCardPhoto || needsCashPhoto) {
      return receiptImage != null;
    }
    return true;
  }

  bool get canSubmit =>
      lines.isNotEmpty &&
      (selectedBarberId != null && selectedBarberId!.trim().isNotEmpty) &&
      totalAmount > 0.001 &&
      paymentStructureValid(totalAmount);

  AddSaleState copyWith({
    List<CartLine>? lines,
    String? searchQuery,
    String? selectedBarberId,
    PosPaymentMethod? paymentMethod,
    String? customerName,
    String? linkedCustomerId,
    double? linkedCustomerDiscountPercent,
    bool clearLinkedCustomer = false,
    double? discountAmount,
    double? splitCashAmount,
    double? splitCardAmount,
    XFile? receiptImage,
    bool clearReceipt = false,
    String? submitError,
    bool clearSubmitError = false,
    bool? isSubmitting,
    bool? suppressStaffExtraDiscount,
  }) {
    return AddSaleState(
      lines: lines ?? this.lines,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBarberId: selectedBarberId ?? this.selectedBarberId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      linkedCustomerId: clearLinkedCustomer
          ? null
          : (linkedCustomerId ?? this.linkedCustomerId),
      linkedCustomerDiscountPercent: clearLinkedCustomer
          ? 0
          : (linkedCustomerDiscountPercent ??
                this.linkedCustomerDiscountPercent),
      discountAmount: discountAmount ?? this.discountAmount,
      splitCashAmount: splitCashAmount ?? this.splitCashAmount,
      splitCardAmount: splitCardAmount ?? this.splitCardAmount,
      receiptImage: clearReceipt ? null : (receiptImage ?? this.receiptImage),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      suppressStaffExtraDiscount:
          suppressStaffExtraDiscount ?? this.suppressStaffExtraDiscount,
    );
  }
}

class AddSaleController extends Notifier<AddSaleState> {
  @override
  AddSaleState build() => const AddSaleState();

  void initialize({
    String? serviceId,
    String? barberId,
    String? paymentMethodRaw,
    String? linkedCustomerId,
    String? linkedCustomerName,
    double? linkedCustomerDiscountPercent,
  }) {
    PosPaymentMethod? pm;
    if (paymentMethodRaw != null && paymentMethodRaw.trim().isNotEmpty) {
      pm = posPaymentMethodFromFirestore(paymentMethodRaw.trim());
    }
    final cid = linkedCustomerId?.trim();
    var next = state.copyWith(
      selectedBarberId: barberId?.trim().isEmpty ?? true
          ? state.selectedBarberId
          : barberId?.trim(),
      paymentMethod: pm ?? state.paymentMethod,
      clearSubmitError: true,
    );
    if (cid != null && cid.isNotEmpty) {
      next = next.copyWith(
        customerName: (linkedCustomerName?.trim().isNotEmpty ?? false)
            ? linkedCustomerName!.trim()
            : next.customerName,
        linkedCustomerId: cid,
        linkedCustomerDiscountPercent: linkedCustomerDiscountPercent ?? 0,
      );
    }
    state = next;
    final sid = serviceId?.trim();
    if (sid == null || sid.isEmpty) return;
    final services = ref.read(servicesStreamProvider).asData?.value;
    if (services == null) return;
    SalonService? found;
    for (final s in services) {
      if (s.id == sid) {
        found = s;
        break;
      }
    }
    if (found != null && found.isActive) {
      addOrIncrementService(found);
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q, clearSubmitError: true);
  }

  void addOrIncrementService(SalonService service) {
    final id = service.id;
    final lang = ref.read(appLocalePreferenceProvider).languageCode;
    final next = List<CartLine>.from(state.lines);
    final idx = next.indexWhere((e) => e.serviceId == id);
    if (idx >= 0) {
      final line = next[idx];
      next[idx] = line.copyWith(quantity: line.quantity + 1);
    } else {
      next.add(
        CartLine(
          serviceId: service.id,
          serviceName: service.localizedTitleForLanguageCode(lang),
          categoryKey: service.categoryKey,
          iconKey: service.iconKey,
          unitPrice: service.price,
        ),
      );
    }
    state = state.copyWith(lines: next, clearSubmitError: true);
  }

  void removeLine(String serviceId) {
    state = state.copyWith(
      lines: state.lines.where((e) => e.serviceId != serviceId).toList(),
      clearSubmitError: true,
    );
  }

  void decrementLine(String serviceId) {
    final next = <CartLine>[];
    for (final line in state.lines) {
      if (line.serviceId != serviceId) {
        next.add(line);
        continue;
      }
      if (line.quantity > 1) {
        next.add(line.copyWith(quantity: line.quantity - 1));
      }
    }
    state = state.copyWith(lines: next, clearSubmitError: true);
  }

  void selectBarber(String? employeeId) {
    final mode = ref.read(addSaleEntryModeProvider);
    final user = ref.read(sessionUserProvider).asData?.value;
    if (mode == AddSaleEntryMode.employee && user != null) {
      final self = user.employeeId?.trim();
      if (self != null && self.isNotEmpty) {
        state = state.copyWith(selectedBarberId: self, clearSubmitError: true);
        return;
      }
    }
    state = state.copyWith(
      selectedBarberId: employeeId,
      clearSubmitError: true,
    );
  }

  void updateCustomerName(String value) {
    state = state.copyWith(
      customerName: value,
      clearLinkedCustomer: true,
      clearSubmitError: true,
    );
  }

  void applyLinkedCustomer(Customer customer) {
    state = state.copyWith(
      customerName: customer.visibleDisplayName.trim(),
      linkedCustomerId: customer.id.trim(),
      linkedCustomerDiscountPercent: customer.discountPercentage,
      clearSubmitError: true,
    );
  }

  void clearLinkedCustomer() {
    state = state.copyWith(clearLinkedCustomer: true, clearSubmitError: true);
  }

  void setPaymentMethod(PosPaymentMethod method) {
    final total = state.totalAmount;
    var next = state.copyWith(paymentMethod: method, clearSubmitError: true);
    if (method == PosPaymentMethod.mixed) {
      if (total <= 0) {
        next = next.copyWith(splitCashAmount: 0, splitCardAmount: 0);
      } else {
        final half = total / 2;
        next = next.copyWith(
          splitCashAmount: half,
          splitCardAmount: total - half,
        );
      }
    } else {
      next = next.copyWith(splitCashAmount: 0, splitCardAmount: 0);
    }
    state = next;
  }

  void setSplitCashAmount(double value) {
    state = state.copyWith(
      splitCashAmount: value < 0 ? 0 : value,
      clearSubmitError: true,
    );
  }

  void setSplitCardAmount(double value) {
    state = state.copyWith(
      splitCardAmount: value < 0 ? 0 : value,
      clearSubmitError: true,
    );
  }

  void setReceiptImage(XFile? file) {
    state = state.copyWith(receiptImage: file, clearSubmitError: true);
  }

  void clearReceiptImage() {
    state = state.copyWith(clearReceipt: true, clearSubmitError: true);
  }

  void setDiscount(double amount) {
    final v = amount < 0 ? 0.0 : amount;
    state = state.copyWith(discountAmount: v, clearSubmitError: true);
  }

  void syncEmployeeSalePolicy(
    SalonSalesSettings settings,
    AddSaleEntryMode mode,
  ) {
    if (mode != AddSaleEntryMode.employee) {
      if (state.suppressStaffExtraDiscount) {
        state = state.copyWith(suppressStaffExtraDiscount: false);
      }
      return;
    }
    state = state.copyWith(
      suppressStaffExtraDiscount: !settings.allowEmployeeDiscount,
    );
    if (!settings.allowMixedPayment &&
        state.paymentMethod == PosPaymentMethod.mixed) {
      setPaymentMethod(PosPaymentMethod.cash);
    }
  }

  void applyDefaultBarberIfNeeded(AppUser user, List<Employee> employees) {
    if (state.selectedBarberId != null &&
        state.selectedBarberId!.trim().isNotEmpty) {
      return;
    }
    final active = employees.where((e) => e.isActive).toList();
    if (active.isEmpty) {
      return;
    }
    if (user.role == UserRoles.barber || user.role == UserRoles.employee) {
      final byUid = active.where((e) => e.uid == user.uid).toList();
      if (byUid.isNotEmpty) {
        state = state.copyWith(selectedBarberId: byUid.first.id);
      }
      final eid = user.employeeId?.trim();
      if (eid != null && eid.isNotEmpty) {
        final byDoc = active.where((e) => e.id == eid).toList();
        if (byDoc.isNotEmpty) {
          state = state.copyWith(selectedBarberId: byDoc.first.id);
        }
      }
      return;
    }
    if (active.length == 1) {
      state = state.copyWith(selectedBarberId: active.first.id);
    }
  }

  Future<bool> recordSale() async {
    state = state.copyWith(clearSubmitError: true, submitError: null);
    final mode = ref.read(addSaleEntryModeProvider);
    final settings =
        ref.read(salonSalesSettingsStreamProvider).asData?.value ??
        SalonSalesSettings.defaults();

    if (!state.canSubmit) {
      return false;
    }
    if (!state.receiptRequirementMet(settings: settings, mode: mode)) {
      state = state.copyWith(
        submitError: 'Receipt photo is required for this payment.',
      );
      return false;
    }

    final sessionAsync = ref.read(sessionUserProvider);
    final user = sessionAsync.asData?.value;
    final salonId = user?.salonId?.trim();
    if (user == null || salonId == null || salonId.isEmpty) {
      return false;
    }

    if (mode == AddSaleEntryMode.employee) {
      if (!settings.allowEmployeeAddSale) {
        state = state.copyWith(
          submitError: 'Sales entry is disabled for staff.',
        );
        return false;
      }
      final eid = user.employeeId?.trim();
      if (eid == null || eid.isEmpty) {
        state = state.copyWith(submitError: 'Staff profile mismatch for sale.');
        return false;
      }
      if (!settings.allowMixedPayment &&
          state.paymentMethod == PosPaymentMethod.mixed) {
        state = state.copyWith(
          submitError: 'Mixed payment is not allowed for your salon.',
        );
        return false;
      }
    }

    if (mode != AddSaleEntryMode.employee) {
      if (state.selectedBarberId == null ||
          state.selectedBarberId!.trim().isEmpty) {
        return false;
      }
    }

    final targetBarberId = mode == AddSaleEntryMode.employee
        ? user.employeeId!.trim()
        : state.selectedBarberId!.trim();

    Employee? barber;
    if (mode == AddSaleEntryMode.employee) {
      barber = await ref
          .read(employeeRepositoryProvider)
          .getEmployee(salonId, targetBarberId);
    } else {
      final employees = ref.read(employeesStreamProvider).asData?.value;
      if (employees == null) {
        return false;
      }
      for (final e in employees) {
        if (e.id == targetBarberId) {
          barber = e;
          break;
        }
      }
      barber ??= await ref
          .read(employeeRepositoryProvider)
          .getEmployee(salonId, targetBarberId);
    }
    if (barber == null || !barber.isActive) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);

    final customerLabel = state.customerName.trim();
    final linkedId = state.linkedCustomerId?.trim();
    final subtotal = state.subtotal;
    final customerDiscAmt = state.customerPercentDiscountAmount;
    final manualDisc = state.appliedManualDiscount;
    final totalDisc = state.totalDiscountAmount.clamp(0.0, subtotal).toDouble();
    final totalAfter = state.totalAmount;
    final pay = state.paymentAmounts(totalAfter);

    final lineItems = <SaleLineItem>[
      for (final line in state.lines)
        SaleLineItem.withComputedTotal(
          serviceId: line.serviceId,
          serviceName: line.serviceName,
          serviceIcon: ServiceCategoryIconResolver.persistedIconKey(
            iconKey: line.iconKey,
            categoryKey: line.categoryKey,
          ),
          employeeId: barber.id,
          employeeName: barber.name,
          quantity: line.quantity,
          unitPrice: line.unitPrice,
        ),
    ];

    final rate = barber.effectiveCommissionRate ?? barber.commissionRate;
    final soldAt = DateTime.now();
    String? phoneSnap;
    if (linkedId != null && linkedId.isNotEmpty) {
      final c = await ref
          .read(customerRepositoryProvider)
          .getCustomerById(salonId, linkedId);
      final p = c?.phone.trim() ?? '';
      if (p.isNotEmpty) {
        phoneSnap = p;
      }
    }

    final repo = ref.read(salesRepositoryProvider);
    final saleId = repo.allocateSaleDocumentId(salonId);

    String? receiptUrl;
    String? receiptPath;
    if (state.receiptImage != null) {
      try {
        final up = await repo.uploadReceiptPhoto(
          salonId: salonId,
          saleId: saleId,
          image: state.receiptImage!,
        );
        receiptUrl = up.downloadUrl;
        receiptPath = up.storagePath;
      } on Object catch (e) {
        state = state.copyWith(
          isSubmitting: false,
          submitError: FirebaseErrorMessage.fromException(e),
        );
        return false;
      }
    }

    final sale = Sale.create(
      id: saleId,
      salonId: salonId,
      employeeId: barber.id,
      employeeName: barber.name,
      lineItems: lineItems,
      tax: 0,
      discount: totalDisc,
      paymentMethod: state.paymentMethod.firestoreValue,
      soldAt: soldAt,
      customerId: linkedId?.isNotEmpty == true ? linkedId : null,
      customerPhoneSnapshot: phoneSnap,
      customerDiscountPercentageSnapshot:
          linkedId?.isNotEmpty == true && !state.suppressStaffExtraDiscount
          ? state.linkedCustomerDiscountPercent.clamp(0.0, 100.0)
          : 0,
      customerName: customerLabel.isEmpty ? null : customerLabel,
      barberImageUrl: barber.avatarUrl,
      createdByUid: user.uid,
      createdByName: user.name,
      commissionRateUsed: rate,
    );

    final approvalStatus =
        mode == AddSaleEntryMode.employee && settings.saleNeedsApproval
        ? 'pending'
        : 'approved';

    try {
      final additionalFields = <String, dynamic>{
        'barberId': barber.id,
        'barberName': barber.name,
        if (barber.avatarUrl != null && barber.avatarUrl!.trim().isNotEmpty)
          'barberImageUrl': barber.avatarUrl,
        'commissionPercentage': rate,
        'createdBy': user.uid,
        'updatedBy': user.uid,
        'employeeUid': user.uid,
        'createdByRole': user.role.trim(),
        'subtotalAmount': subtotal,
        'discountAmount': totalDisc,
        'customerDiscountFromPercent': customerDiscAmt,
        'manualDiscountAmount': manualDisc,
        'totalAmountAfterDiscount': sale.total,
        'cashAmount': pay.cash,
        'cardAmount': pay.card,
        'approvalStatus': approvalStatus,
        'dateKey': _saleDateKeyUtc(soldAt),
        'monthKey': ReportPeriod.periodKey(
          ReportPeriod.yearFrom(soldAt),
          ReportPeriod.monthFrom(soldAt),
        ),
        'receiptPhotoUrl': ?receiptUrl,
        'receiptStoragePath': ?receiptPath,
      };

      if (linkedId != null && linkedId.isNotEmpty) {
        await repo.createSaleWithLinkedCustomerStats(
          salonId: salonId,
          sale: sale,
          additionalFields: additionalFields,
          linkedCustomerId: linkedId,
          presetSaleId: saleId,
        );
      } else {
        await repo.createSale(
          salonId,
          sale,
          additionalFields: additionalFields,
        );
      }

      unawaited(
        ref
            .read(_salesAiAnalysisServiceProvider)
            .maybeWriteInternalSummary(
              salonId: salonId,
              saleId: saleId,
              sale: sale,
            ),
      );

      state = state.copyWith(isSubmitting: false, clearSubmitError: true);
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: FirebaseErrorMessage.fromException(e),
      );
      return false;
    }
  }
}

String _saleDateKeyUtc(DateTime soldAt) {
  final u = soldAt.toUtc();
  final y = u.year.toString().padLeft(4, '0');
  final m = u.month.toString().padLeft(2, '0');
  final day = u.day.toString().padLeft(2, '0');
  return '$y$m$day';
}
