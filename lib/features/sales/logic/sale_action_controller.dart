import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sale.dart';
import '../data/sales_repository.dart';
import '../../../core/constants/sale_reporting.dart';
import '../../../providers/repository_providers.dart';

final saleActionControllerProvider = Provider<SaleActionController>((ref) {
  return SaleActionController(
    salesRepository: ref.watch(salesRepositoryProvider),
  );
});

class SaleActionController {
  SaleActionController({required SalesRepository salesRepository})
    : _salesRepository = salesRepository;

  final SalesRepository _salesRepository;

  /// Voids a sale. Usually done for mistakes on the same day.
  /// Sets commission to 0 as the sale never happened.
  Future<void> voidSale(String salonId, String saleId) async {
    final sale = await _salesRepository.getSale(salonId, saleId);
    if (sale == null) throw StateError('Sale not found');
    if (sale.status == SaleStatuses.voided) return;

    final updatedSale = Sale(
      id: sale.id,
      salonId: sale.salonId,
      employeeId: sale.employeeId,
      employeeName: sale.employeeName,
      lineItems: sale.lineItems,
      serviceNames: sale.serviceNames,
      subtotal: sale.subtotal,
      tax: sale.tax,
      discount: sale.discount,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
      status: SaleStatuses.voided,
      soldAt: sale.soldAt,
      customerId: sale.customerId,
      reportYear: sale.reportYear,
      reportMonth: sale.reportMonth,
      commissionRateUsed: sale.commissionRateUsed,
      commissionAmount: 0, // No commission for voided sales
      receiptPhotoUrl: sale.receiptPhotoUrl,
      receiptStoragePath: sale.receiptStoragePath,
      updatedAt: DateTime.now(),
    );

    await _salesRepository.updateSale(salonId, updatedSale);
  }

  /// Refunds a sale.
  /// Commission is usually reversed or set to 0 depending on salon policy.
  /// Here we set it to 0 to be safe for payroll.
  Future<void> refundSale(String salonId, String saleId) async {
    final sale = await _salesRepository.getSale(salonId, saleId);
    if (sale == null) throw StateError('Sale not found');
    if (sale.status == SaleStatuses.refunded) return;

    final updatedSale = Sale(
      id: sale.id,
      salonId: sale.salonId,
      employeeId: sale.employeeId,
      employeeName: sale.employeeName,
      lineItems: sale.lineItems,
      serviceNames: sale.serviceNames,
      subtotal: sale.subtotal,
      tax: sale.tax,
      discount: sale.discount,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
      status: SaleStatuses.refunded,
      soldAt: sale.soldAt,
      customerId: sale.customerId,
      reportYear: sale.reportYear,
      reportMonth: sale.reportMonth,
      commissionRateUsed: sale.commissionRateUsed,
      commissionAmount: 0, // Commission is nullified on refund
      receiptPhotoUrl: sale.receiptPhotoUrl,
      receiptStoragePath: sale.receiptStoragePath,
      updatedAt: DateTime.now(),
    );

    await _salesRepository.updateSale(salonId, updatedSale);
  }
}
