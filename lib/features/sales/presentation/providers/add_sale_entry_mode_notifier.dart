import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/add_sale_entry_mode.dart';

class AddSaleEntryModeNotifier extends Notifier<AddSaleEntryMode> {
  @override
  AddSaleEntryMode build() => AddSaleEntryMode.owner;

  void setMode(AddSaleEntryMode mode) => state = mode;
}

/// Not autoDispose: [AddSaleScreen] sets mode via [read] / post-frame callbacks
/// without [watch], so an autoDispose provider would reset to [owner] and break
/// employee POS submit ([recordSale], [syncBarberWithLoggedInEmployee]).
final addSaleEntryModeProvider =
    NotifierProvider<AddSaleEntryModeNotifier, AddSaleEntryMode>(
      AddSaleEntryModeNotifier.new,
    );
