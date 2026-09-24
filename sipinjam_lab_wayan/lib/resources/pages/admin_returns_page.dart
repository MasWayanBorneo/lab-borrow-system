import '/app/controllers/admin_returns_controller.dart';
import '/app/models/loan.dart';
import '/resources/widgets/admin_bottom_nav.dart';
import '/resources/widgets/bottom_sheet_modals/bottom_sheet_modals.dart';
import '/app/events/logout_event.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AdminReturnsPage extends NyStatefulWidget<AdminReturnsController> {
  static RouteView path = ("/admin/returns", (_) => AdminReturnsPage());

  AdminReturnsPage({super.key}) : super(child: () => _AdminReturnsPageState());
}

class _AdminReturnsPageState extends NyPage<AdminReturnsPage> {
  List<Loan> _loans = [];

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();

  @override
  get init => () async {
    await _fetch();
  };

  Future<void> _fetch() async {
    List<Loan> loans = await widget.controller.load();
    if (!mounted) return;
    setState(() => _loans = loans);
  }

  Future<void> _markReturned(Loan loan) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tandai Dikembalikan"),
        content: Text("Konfirmasi ${loan.item?.name} telah dikembalikan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.controller.markReturned(loan.id!);
    showToastSuccess(description: "Alat ditandai sudah dikembalikan");
    await _fetch();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengembalian Alat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => BottomSheetModal.showLogout(
              context,
              onLogoutPressed: () => event<LogoutEvent>(),
            ),
          ),
        ],
      ),
      body: _loans.isEmpty
          ? const Center(child: Text("Tidak ada peminjaman aktif"))
          : Pullable(
              onRefresh: () async => _fetch(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _loans.length,
                itemBuilder: (context, index) {
                  Loan loan = _loans[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(loan.item?.name ?? "Alat",
                                    style: Theme.of(context).textTheme.titleMedium),
                              ),
                              if (loan.isLate)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Terlambat",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("${loan.borrowerName ?? '-'} (${loan.borrowerNim ?? '-'})"),
                          Text("Jumlah: ${loan.qty}"),
                          Text(
                            "Rencana Kembali: ${loan.returnDatePlanned?.toLocal().toString().split(' ').first}",
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _markReturned(loan),
                              child: const Text("Tandai Dikembalikan"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}
