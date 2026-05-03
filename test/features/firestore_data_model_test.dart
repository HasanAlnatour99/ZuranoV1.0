import 'package:barber_shop_app/core/constants/attendance_approval.dart';
import 'package:barber_shop_app/core/constants/booking_statuses.dart';
import 'package:barber_shop_app/core/constants/payroll_statuses.dart';
import 'package:barber_shop_app/core/constants/sale_reporting.dart';
import 'package:barber_shop_app/core/constants/user_roles.dart';
import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/features/bookings/data/models/booking.dart';
import 'package:barber_shop_app/features/sales/data/models/sale.dart';
import 'package:barber_shop_app/features/salon/data/models/salon.dart';
import 'package:barber_shop_app/features/services/data/models/service.dart';
import 'package:barber_shop_app/features/onboarding/domain/value_objects/user_phone.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser', () {
    test('serializes and deserializes user membership fields', () {
      final user = AppUser(
        uid: 'user-1',
        name: 'Hasan',
        email: 'owner@salon.com',
        role: 'owner',
        salonId: 'salon-1',
        employeeId: 'employee-1',
        phone: const UserPhone(
          countryIsoCode: 'JO',
          dialCode: '+962',
          nationalNumber: '700000000',
          e164: '+962700000000',
        ),
      );

      final json = user.toJson();
      final decoded = AppUser.fromJson(json);

      expect(decoded.uid, 'user-1');
      expect(decoded.name, 'Hasan');
      expect(decoded.salonId, 'salon-1');
      expect(decoded.employeeId, 'employee-1');
      expect(decoded.phone?.e164, '+962700000000');
    });
  });

  group('Salon', () {
    test('persists salonId aligned with id', () {
      final salon = Salon(
        id: 'salon-1',
        salonId: 'salon-1',
        name: 'Main St',
        phone: '+1',
        address: '1 St',
        ownerUid: 'owner-1',
        ownerName: 'Owner',
        ownerEmail: 'o@example.com',
      );

      final json = salon.toJson();
      expect(json['salonId'], 'salon-1');
      final decoded = Salon.fromJson(json);
      expect(decoded.salonId, decoded.id);
    });

    test('fromJson falls back when salonId missing', () {
      final decoded = Salon.fromJson({
        'id': 'salon-legacy',
        'name': 'Legacy',
        'phone': '1',
        'address': 'a',
        'ownerUid': 'u',
        'ownerName': 'n',
        'ownerEmail': 'e',
      });
      expect(decoded.salonId, 'salon-legacy');
    });
  });

  group('SalonService', () {
    test('serviceName mirrors name when omitted in json', () {
      final s = SalonService.fromJson({
        'id': 's1',
        'salonId': 'salon-1',
        'name': 'Cut',
        'durationMinutes': 30,
        'price': 20,
      });
      expect(s.serviceName, 'Cut');
      expect(s.toJson()['serviceName'], 'Cut');
    });

    test('serviceName can differ from name', () {
      final s = SalonService(
        id: 's1',
        salonId: 'salon-1',
        name: 'Cut',
        serviceName: 'Premium Cut',
        durationMinutes: 30,
        price: 20,
      );
      expect(s.name, 'Cut');
      expect(s.serviceName, 'Premium Cut');
    });

    test('nameAr defaults empty when omitted in json', () {
      final s = SalonService.fromJson({
        'id': 's1',
        'salonId': 'salon-1',
        'name': 'Cut',
        'durationMinutes': 30,
        'price': 20,
      });
      expect(s.nameAr, '');
    });

    test('nameAr roundtrips and localizedTitle prefers Arabic', () {
      final s = SalonService.fromJson({
        'id': 's1',
        'salonId': 'salon-1',
        'name': 'Cut',
        'serviceName': 'Cut',
        'nameAr': 'قص',
        'durationMinutes': 30,
        'price': 20,
      });
      expect(s.nameAr, 'قص');
      expect(s.toJson()['nameAr'], 'قص');
      expect(s.localizedTitleForLanguageCode('ar'), 'قص');
      expect(s.localizedTitleForLanguageCode('en'), 'Cut');
    });
  });

  group('UserRoles', () {
    test('allowsMissingSalon for customer and pending', () {
      expect(UserRoles.allowsMissingSalon(UserRoles.customer), isFalse);
      expect(UserRoles.allowsMissingSalon(UserRoles.pending), isTrue);
      expect(UserRoles.allowsMissingSalon(UserRoles.owner), isTrue);
    });
  });

  group('Booking', () {
    test('includes salonId barberId customerId and report fields', () {
      final start = DateTime.utc(2026, 4, 18, 10);
      final booking = Booking(
        id: 'b1',
        salonId: 'salon-1',
        barberId: 'emp-1',
        customerId: 'cust-uid',
        startAt: start,
        endAt: DateTime.utc(2026, 4, 18, 11),
        status: BookingStatuses.confirmed,
        reportYear: 2026,
        reportMonth: 4,
      );

      final json = booking.toJson();
      expect(json['salonId'], 'salon-1');
      expect(json['barberId'], 'emp-1');
      expect(json['customerId'], 'cust-uid');
      expect(json['reportYear'], 2026);
      expect(json['reportMonth'], 4);
      expect(booking.reportPeriodKey, '2026-04');

      final decoded = Booking.fromJson(json);
      expect(decoded.barberId, 'emp-1');
      expect(decoded.customerId, 'cust-uid');
      expect(decoded.reportPeriodKey, '2026-04');
    });

    test('fromJson maps legacy scheduled to pending', () {
      final start = DateTime.utc(2026, 4, 18, 10);
      final decoded = Booking.fromJson({
        'id': 'b1',
        'salonId': 'salon-1',
        'barberId': 'emp-1',
        'customerId': 'c1',
        'startAt': start,
        'endAt': DateTime.utc(2026, 4, 18, 11),
        'status': 'scheduled',
      });
      expect(decoded.status, BookingStatuses.pending);
    });

    test('fromJson preserves reschedule and cancel audit fields', () {
      final start = DateTime.utc(2026, 4, 18, 10);
      final cancelledAt = DateTime.utc(2026, 4, 17, 12);
      final decoded = Booking.fromJson({
        'id': 'b1',
        'salonId': 'salon-1',
        'barberId': 'emp-1',
        'customerId': 'c1',
        'startAt': start,
        'endAt': DateTime.utc(2026, 4, 18, 11),
        'status': BookingStatuses.rescheduled,
        'rescheduledToBookingId': 'b2',
        'cancelledAt': cancelledAt,
        'cancelledByRole': 'customer',
        'cancelledByUserId': 'c1',
        'rescheduledFromBookingId': 'b0',
      });
      expect(decoded.status, BookingStatuses.rescheduled);
      expect(decoded.rescheduledToBookingId, 'b2');
      expect(decoded.rescheduledFromBookingId, 'b0');
      expect(decoded.cancelledByRole, 'customer');
      expect(decoded.cancelledByUserId, 'c1');
      expect(decoded.cancelledAt, cancelledAt);
    });
  });

  group('Sale', () {
    test('preserves denormalized names and reporting fields', () {
      final soldAt = DateTime.utc(2026, 4, 18);
      final sale = Sale(
        id: 'sale-1',
        salonId: 'salon-1',
        employeeId: 'employee-1',
        employeeName: 'Ahmad',
        lineItems: const [
          SaleLineItem(
            serviceId: 'service-1',
            serviceName: 'Haircut',
            employeeId: 'employee-1',
            employeeName: 'Ahmad',
            quantity: 1,
            unitPrice: 25,
            total: 25,
          ),
        ],
        serviceNames: const ['Haircut'],
        subtotal: 25,
        tax: 0,
        discount: 0,
        total: 25,
        paymentMethod: SalePaymentMethods.cash,
        status: SaleStatuses.completed,
        soldAt: soldAt,
        customerId: 'customer-uid',
        customerName: 'Walk-in',
        createdByUid: 'user-1',
        createdByName: 'Hasan',
      );

      final json = sale.toJson();
      final decoded = Sale.fromJson(json);

      expect(json['employeeName'], 'Ahmad');
      expect(json['paymentMethod'], SalePaymentMethods.cash);
      expect(json['status'], SaleStatuses.completed);
      expect(json['barberId'], 'employee-1');
      expect(json['customerId'], 'customer-uid');
      expect(json['reportPeriodKey'], '2026-04');
      expect(decoded.lineItems.single.serviceName, 'Haircut');
      expect(decoded.employeeName, 'Ahmad');
      expect(decoded.barberId, 'employee-1');
    });

    test('fromJson fills barberId from employeeId when missing', () {
      final decoded = Sale.fromJson({
        'id': 's',
        'salonId': 'salon-1',
        'employeeId': 'e1',
        'employeeName': 'X',
        'lineItems': <dynamic>[],
        'serviceNames': <String>[],
        'subtotal': 0.0,
        'tax': 0.0,
        'discount': 0.0,
        'total': 0.0,
        'soldAt': DateTime.utc(2026, 1, 5).toIso8601String(),
      });
      expect(decoded.barberId, 'e1');
      expect(decoded.reportYear, 2026);
      expect(decoded.reportMonth, 1);
    });

    test('fromJson and toJson preserve receipt photo fields', () {
      final soldAt = DateTime.utc(2026, 5, 2);
      final decoded = Sale.fromJson({
        'id': 's1',
        'salonId': 'salon-1',
        'employeeId': 'e1',
        'employeeName': 'X',
        'lineItems': <dynamic>[],
        'serviceNames': <String>[],
        'subtotal': 10.0,
        'tax': 0.0,
        'discount': 0.0,
        'total': 10.0,
        'paymentMethod': SalePaymentMethods.cash,
        'status': SaleStatuses.completed,
        'soldAt': soldAt.toIso8601String(),
        'receiptPhotoUrl': 'https://example.com/r.jpg',
        'receiptStoragePath': 'salons/s1/sales/s1/receipts/1.jpg',
      });
      expect(decoded.receiptPhotoUrl, 'https://example.com/r.jpg');
      expect(decoded.receiptStoragePath, 'salons/s1/sales/s1/receipts/1.jpg');

      final out = decoded.toJson();
      expect(out['receiptPhotoUrl'], 'https://example.com/r.jpg');
      expect(out['receiptStoragePath'], 'salons/s1/sales/s1/receipts/1.jpg');

      final round = Sale.fromJson(out);
      expect(round.receiptPhotoUrl, decoded.receiptPhotoUrl);
      expect(round.receiptStoragePath, decoded.receiptStoragePath);
    });

    test('Sale.create derives subtotal, total, and serviceNames', () {
      final soldAt = DateTime.utc(2026, 4, 18);
      final sale = Sale.create(
        salonId: 'salon-1',
        employeeId: 'e1',
        employeeName: 'Sam',
        tax: 2,
        discount: 5,
        soldAt: soldAt,
        lineItems: [
          SaleLineItem.withComputedTotal(
            serviceId: 's1',
            serviceName: 'Cut',
            employeeId: 'e1',
            employeeName: 'Sam',
            quantity: 2,
            unitPrice: 10,
          ),
          SaleLineItem.withComputedTotal(
            serviceId: 's2',
            serviceName: 'Shave',
            employeeId: 'e1',
            employeeName: 'Sam',
            quantity: 1,
            unitPrice: 15,
          ),
        ],
      );

      expect(sale.subtotal, 35);
      expect(sale.total, 32);
      expect(sale.serviceNames, ['Cut', 'Shave']);
      expect(sale.employeeName, 'Sam');
      expect(sale.lineItems.first.serviceName, 'Cut');
      expect(sale.lineItems.first.total, 20);
    });
  });

  group('PayrollStatuses', () {
    test('draft is default-friendly', () {
      expect(PayrollStatuses.draft, 'draft');
      expect(PayrollStatuses.paid, 'paid');
    });
  });

  group('AttendanceApprovalStatuses', () {
    test('pending default matches model default', () {
      expect(AttendanceApprovalStatuses.pending, 'pending');
    });
  });

  group('FirestorePaths', () {
    test('builds nested salon collection paths', () {
      expect(FirestorePaths.user('user-1'), 'users/user-1');
      expect(
        FirestorePaths.salonEmployee('salon-1', 'employee-1'),
        'salons/salon-1/employees/employee-1',
      );
      expect(
        FirestorePaths.salonSale('salon-1', 'sale-1'),
        'salons/salon-1/sales/sale-1',
      );
      expect(
        FirestorePaths.salonPayrollRecord('salon-1', 'payroll-1'),
        'salons/salon-1/payroll/payroll-1',
      );
      expect(
        FirestorePaths.salonBooking('salon-1', 'booking-1'),
        'salons/salon-1/bookings/booking-1',
      );
    });
  });
}
