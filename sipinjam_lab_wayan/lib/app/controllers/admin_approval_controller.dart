import '/app/models/loan.dart';
import '/app/services/loan_service.dart';
import 'controller.dart';

class AdminApprovalController extends Controller {
  final LoanService loanService = LoanService();

  Future<List<Loan>> load() => loanService.pending();

  Future<void> approve(String loanId) => loanService.approve(loanId);

  Future<void> reject(String loanId) => loanService.reject(loanId);
}
