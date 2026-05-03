/// High-level POS entry on [AddSaleScreen].
enum AddSalePosTab {
  /// Convert a `guestBookings/{code}` row into a salon sale.
  fromBookingCode,

  /// Classic cart-based sale (existing flow).
  manual,
}
