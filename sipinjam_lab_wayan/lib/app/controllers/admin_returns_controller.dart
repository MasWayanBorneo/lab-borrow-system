import '/app/models/loan.dart';
import '/app/services/loan_service.dart';
import 'controller.dart';

class AdminReturnsController extends Controller {
  final LoanService loanService = LoanService();

  Future<List<Loan>> load() => loanService.activeApproved();

  Future<void> markReturned(String loanId) => loanService.markReturned(loanId);
}
