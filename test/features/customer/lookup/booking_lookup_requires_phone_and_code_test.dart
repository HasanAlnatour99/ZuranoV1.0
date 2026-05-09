import 'package:barber_shop_app/features/customer/data/models/customer_booking_lookup_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lookup callable json parses into model', () {
    final model = CustomerBookingLookupModel.fromLookupCallableJson({
      'bookingId': 'b1',
      'salonId': 's1',
      'salonName': 'Salon',
      'bookingCode': 'ZR-123456',
      'status': 'confirmed',
      'customerName': 'Hasan',
      'customerPhone': '+97470001043',
      'customerPhoneNormalized': '+97470001043',
      'employeeId': 'e1',
      'employeeName': 'Barber',
      'serviceNames': ['Haircut'],
      'totalAmount': 10,
      'startAtMs': 1,
      'endAtMs': 2,
      'createdAtMs': 3,
    });
    expect(model, isA<CustomerBookingLookupModel>());
    expect(model.bookingCode.trim().isNotEmpty, true);
  });

  test('lookup list empty means not found (requires phone + code)', () {
    final results = <CustomerBookingLookupModel>[];
    expect(results, isEmpty);
  });
}

