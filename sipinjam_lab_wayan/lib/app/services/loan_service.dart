import '/app/models/loan.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class LoanService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Loan>> myLoans(String userId) async {
    final data = await _client
        .from('loans')
        .select('*, items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List.from(data).map((json) => Loan.fromJson(json)).toList();
  }

  Future<void> create({
    required String userId,
    required String itemId,
    required int qty,
    required DateTime borrowDate,
    required DateTime returnDatePlanned,
  }) async {
    await _client.from('loans').insert({
      "user_id": userId,
      "item_id": itemId,
      "qty": qty,
      "borrow_date": borrowDate.toIso8601String().split('T').first,
      "return_date_planned":
          returnDatePlanned.toIso8601String().split('T').first,
      "status": "pending",
    });
  }

  Future<List<Loan>> pending() async {
    final data = await _client
        .from('loans')
        .select('*, items(*), profiles(*)')
        .eq('status', 'pending')
        .order('created_at');

    return List.from(data).map((json) => Loan.fromJson(json)).toList();
  }

  Future<List<Loan>> activeApproved() async {
    final data = await _client
        .from('loans')
        .select('*, items(*), profiles(*)')
        .eq('status', 'approved')
        .order('return_date_planned');

    return List.from(data).map((json) => Loan.fromJson(json)).toList();
  }

  Future<void> approve(String loanId) async {
    await _client.rpc('approve_loan', params: {"p_loan_id": loanId});
  }

  Future<void> reject(String loanId) async {
    await _client.from('loans').update({"status": "rejected"}).eq(
        'id', loanId);
  }

  Future<void> markReturned(String loanId) async {
    await _client.rpc('return_loan', params: {"p_loan_id": loanId});
  }

  /// Listens for status changes (approved/rejected/returned) on the given
  /// user's own loans. [channelName] must be unique per subscriber.
  RealtimeChannel subscribeToUserLoanUpdates({
    required String userId,
    required String channelName,
    required void Function(PostgresChangePayload payload) onChange,
  }) {
    return _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'loans',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: onChange,
        )
        .subscribe();
  }

  void unsubscribe(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }
}
