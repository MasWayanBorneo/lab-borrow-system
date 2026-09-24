import '/app/controllers/my_loans_controller.dart';
import '/app/models/loan.dart';
import '/app/models/user.dart' as app;
import '/app/helpers/loan_status_message.dart';
import '/resources/widgets/student_bottom_nav.dart';
import '/resources/widgets/loan_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class MyLoansPage extends NyStatefulWidget<MyLoansController> {
  static RouteView path = ("/my-loans", (_) => MyLoansPage());

  MyLoansPage({super.key}) : super(child: () => _MyLoansPageState());
}

class _MyLoansPageState extends NyPage<MyLoansPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Loan> _loans = [];
  RealtimeChannel? _loanChannel;

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();

  @override
  get init => () async {
    _tabController = TabController(length: 2, vsync: this);
    await _fetch();
    _subscribeLoanUpdates();
  };

  void _subscribeLoanUpdates() {
    app.User? user = Nylo.user<app.User>();
    if (user?.id == null) return;

    _loanChannel = widget.controller.subscribeLoanUpdates(
      userId: user!.id!,
      onChange: (payload) {
        String? message = loanStatusChangeMessage(payload.newRecord['status']);
        if (message != null) {
          showToastInfo(description: message);
          LocalNotification.sendNotification(
            title: "Status Peminjaman",
            body: message,
          );
        }
        _fetch();
      },
    );
  }

  Future<void> _fetch() async {
    app.User? user = Nylo.user<app.User>();
    if (user?.id == null) return;

    List<Loan> loans = await widget.controller.load(user!.id!);
    if (!mounted) return;
    setState(() => _loans = loans);
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_loanChannel != null) {
      widget.controller.unsubscribeLoanUpdates(_loanChannel!);
    }
    super.dispose();
  }

  List<Loan> get _ongoing =>
      _loans.where((l) => ['pending', 'approved'].contains(l.status)).toList();

  List<Loan> get _history =>
      _loans.where((l) => ['rejected', 'returned'].contains(l.status)).toList();

  Widget _list(List<Loan> loans) {
    if (loans.isEmpty) {
      return const Center(child: Text("Belum ada data"));
    }
    return Pullable(
      onRefresh: () async => _fetch(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          Loan loan = loans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(loan.item?.name ?? "Alat"),
              subtitle: Text(
                "Jumlah: ${loan.qty}\n"
                "${loan.borrowDate?.toLocal().toString().split(' ').first} "
                "s/d ${loan.returnDatePlanned?.toLocal().toString().split(' ').first}",
              ),
              isThreeLine: true,
              trailing: LoanStatusBadge(status: loan.status ?? ''),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peminjaman Saya"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Berjalan"),
            Tab(text: "Riwayat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _list(_ongoing),
          _list(_history),
        ],
      ),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
    );
  }
}
