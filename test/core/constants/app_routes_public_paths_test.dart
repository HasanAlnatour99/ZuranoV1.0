import 'package:barber_shop_app/core/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes.isPublicCustomerExperiencePath', () {
    test('allows the guest nearby map route', () {
      expect(
        AppRoutes.isPublicCustomerExperiencePath(AppRoutes.customerNearbyMap),
        isTrue,
      );
    });

    test('keeps signed-in customer home subroutes private by default', () {
      expect(
        AppRoutes.isPublicCustomerExperiencePath(AppRoutes.customerMyBookings),
        isFalse,
      );
      expect(
        AppRoutes.isPublicCustomerExperiencePath(
          AppRoutes.customerSalonBook('salon-1'),
        ),
        isFalse,
      );
    });
  });
}
