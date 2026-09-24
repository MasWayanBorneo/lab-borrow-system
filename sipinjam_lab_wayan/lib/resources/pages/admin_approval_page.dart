import '/app/controllers/admin_approval_controller.dart';
import '/app/models/loan.dart';
import '/app/services/auth_service.dart';
import '/resources/widgets/admin_bottom_nav.dart';
import '/resources/widgets/bottom_sheet_modals/bottom_sheet_modals.dart';
import '/app/events/logout_event.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalPage extends NyStatefulWidget<AdminApprovalController> {
  static RouteView path = ("/admin/approvals", (_) => AdminApprovalPage());

  AdminApprovalPage({super.key}) : super(child: () => _AdminApprovalPageState());
}

class _AdminApprovalPageState extends NyPage<AdminApprovalPage> {
  List<Loan> _loans = [];
  final AuthService _authService = AuthService();

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

  Future<void> _viewKtm(Loan loan) async {
    String? path = loan.borrowerKtmPath;
    if (path == null) {
      showToastDanger(description: "Mahasiswa belum mengunggah KTM");
      return;
    }

    try {
      String url = await _authService.signedKtmUrl(path);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("KTM ${loan.borrowerName ?? ''}",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      showToastDanger(description: "Gagal memuat foto KTM");
    }
  }

  Future<bool> _confirm(String title, String message) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return result ?? false;
  }

  Future<void> _approve(Loan loan) async {
    bool confirmed = await _confirm(
      "Setujui Peminjaman",
      "Setujui peminjaman ${loan.item?.name} oleh ${loan.borrowerName}?",
    );
    if (!confirmed) return;

    try {
      await widget.controller.approve(loan.id!);
      showToastSuccess(description: "Peminjaman disetujui");
      await _fetch();
    } catch (e) {
      String reason = "stok tidak mencukupi";
      if (e is PostgrestException && e.message.contains("not ready")) {
        reason = "alat sedang rusak / dalam perbaikan";
      }
      showToastDanger(description: "Gagal menyetujui: $reason");
    }
  }

  Future<void> _reject(Loan loan) async {
    bool confirmed = await _confirm(
      "Tolak Peminjaman",
      "Tolak peminjaman ${loan.item?.name} oleh ${loan.borrowerName}?",
    );
    if (!confirmed) return;

    await widget.controller.reject(loan.id!);
    showToastSuccess(description: "Peminjaman ditolak");
    await _fetch();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Persetujuan Peminjaman"),
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
          ? const Center(child: Text("Tidak ada pengajuan menunggu"))
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
                          Text(loan.item?.name ?? "Alat",
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text("${loan.borrowerName ?? '-'} (${loan.borrowerNim ?? '-'})"),
                          Text("Jumlah: ${loan.qty}"),
                          Text(
                            "Tanggal Pinjam: ${loan.borrowDate?.toLocal().toString().split(' ').first}",
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => _viewKtm(loan),
                              icon: const Icon(Icons.badge_outlined, size: 18),
                              label: const Text("Lihat KTM"),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _reject(loan),
                                  child: const Text("Tolak"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _approve(loan),
                                  child: const Text("Setujui"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }
}
