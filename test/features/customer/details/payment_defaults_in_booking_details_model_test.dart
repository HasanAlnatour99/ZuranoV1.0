import 'package:barber_shop_app/features/customer/data/models/customer_booking_details_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('booking details defaults payment fields when missing', () {
    final model = CustomerBookingDetailsModel.fromCallablePayload(
      bookingId: 'b1',
      bookingData: {
        'salonId': 's1',
        'salonName': 'Salon',
        'salonArea': 'Area',
        'bookingNumber': 'ZR-123456',
        'status': 'confirmed',
        'customerName': 'Hasan',
        'customerPhone': '+97470001043',
        'customerPhoneNormalized': '+97470001043',
        'employeeId': 'e1',
        'employeeName': 'Barber',
        'services': [
          {
            'serviceId': 'svc',
            'serviceName': 'Haircut',
            'price': 10,
            'durationMinutes': 30,
            'category': 'hair',
          },
        ],
        'subtotal': 10,
        'discountAmount': 0,
        'totalAmount': 10,
        'durationMinutes': 30,
        'startAt': '2026-05-08T10:00:00.000Z',
        'endAt': '2026-05-08T10:30:00.000Z',
        'source': 'customer_app',
        'customerNote': '',
      },
      publicSalon: {
        'id': 's1',
        'name': 'Salon',
        'area': 'Area',
        'currencyCode': 'USD',
        'phone': '',
        'whatsapp': '',
        'customerBookingSettings': {},
      },
    );

    expect(model.paymentStatus, 'unpaid');
    expect(model.paymentMethod, 'not_selected');
    expect(model.depositRequired, false);
    expect(model.depositAmount, 0);
    expect(model.paidAmount, 0);
    expect(model.balanceAmount, 10);
  });
}

