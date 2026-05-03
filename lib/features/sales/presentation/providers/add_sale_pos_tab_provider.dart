import 'package:riverpod/legacy.dart' show StateProvider;

import '../../domain/add_sale_pos_tab.dart';

final addSalePosTabProvider = StateProvider.autoDispose<AddSalePosTab>(
  (ref) => AddSalePosTab.fromBookingCode,
);
