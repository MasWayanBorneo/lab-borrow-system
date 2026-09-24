import '/app/models/loan.dart';
import '/app/services/loan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'controller.dart';

class MyLoansController extends Controller {
  final LoanService loanService = LoanService();

  Future<List<Loan>> load(String userId) {
    return loanService.myLoans(userId);
  }

  RealtimeChannel subscribeLoanUpdates({
    required String userId,
    required void Function(PostgresChangePayload payload) onChange,
  }) {
    return loanService.subscribeToUserLoanUpdates(
      userId: userId,
      channelName: 'loans-updates-my-loans-$userId',
      onChange: onChange,
    );
  }

  void unsubscribeLoanUpdates(RealtimeChannel channel) {
    loanService.unsubscribe(channel);
  }
}
