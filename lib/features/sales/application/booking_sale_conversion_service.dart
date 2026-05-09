import '../../customer/data/models/customer_booking_details_model.dart';

class BookingSaleConversionPayload {
  const BookingSaleConversionPayload({
    required this.bookingId,
    required this.salonId,
    required this.customerId,
    required this.employeeId,
    required this.services,
    required this.totalAmount,
    required this.paymentStatus,
  });

  final String bookingId;
  final String salonId;
  final String customerId;
  final String employeeId;
  final List<CustomerBookingDetailsServiceItem> services;
  final double totalAmount;
  final String paymentStatus;
}

/// TODO: Booking → Sale conversion will be implemented in owner POS flow.
///
/// For now this provides a safe boundary and payload shape so downstream code can
/// be wired without leaking booking-model details everywhere.
class BookingSaleConversionService {
  const BookingSaleConversionService._();

  static BookingSaleConversionPayload buildPayload(
    CustomerBookingDetailsModel booking,
  ) {
    return BookingSaleConversionPayload(
      bookingId: booking.id,
      salonId: booking.salonId,
      customerId: booking.customerId ?? '',
      employeeId: booking.employeeId,
      services: booking.services,
      totalAmount: booking.totalAmount,
      paymentStatus: booking.paymentStatus,
    );
  }
}

