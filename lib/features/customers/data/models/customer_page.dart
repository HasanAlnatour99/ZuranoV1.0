import 'package:cloud_firestore/cloud_firestore.dart';

import 'customer.dart';

class CustomerPage {
  const CustomerPage({
    required this.customers,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<Customer> customers;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  static const empty = CustomerPage(
    customers: <Customer>[],
    lastDocument: null,
    hasMore: false,
  );
}

