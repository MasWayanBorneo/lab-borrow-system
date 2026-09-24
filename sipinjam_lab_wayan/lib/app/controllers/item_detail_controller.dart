import '/app/services/loan_service.dart';
import 'controller.dart';

class ItemDetailController extends Controller {
  final LoanService loanService = LoanService();

  Future<void> submitLoan({
    required String userId,
    required String itemId,
    required int qty,
    required DateTime borrowDate,
    required DateTime returnDatePlanned,
  }) {
    return loanService.create(
      userId: userId,
      itemId: itemId,
      qty: qty,
      borrowDate: borrowDate,
      returnDatePlanned: returnDatePlanned,
    );
  }
}
