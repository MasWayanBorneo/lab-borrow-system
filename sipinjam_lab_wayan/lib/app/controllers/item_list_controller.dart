import '/app/models/item.dart';
import '/app/services/item_service.dart';
import '/app/services/loan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'controller.dart';

class ItemListController extends Controller {
  final ItemService itemService = ItemService();
  final LoanService loanService = LoanService();

  Future<List<Item>> load({String? category, String? search}) {
    return itemService.all(category: category, search: search);
  }

  RealtimeChannel subscribeLoanUpdates({
    required String userId,
    required void Function(PostgresChangePayload payload) onChange,
  }) {
    return loanService.subscribeToUserLoanUpdates(
      userId: userId,
      channelName: 'loans-updates-item-list-$userId',
      onChange: onChange,
    );
  }

  void unsubscribeLoanUpdates(RealtimeChannel channel) {
    loanService.unsubscribe(channel);
  }
}
