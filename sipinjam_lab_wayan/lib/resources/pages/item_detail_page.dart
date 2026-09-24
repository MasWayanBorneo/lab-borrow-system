import '/app/controllers/item_detail_controller.dart';
import '/app/models/item.dart';
import '/app/models/user.dart' as app;
import '/resources/pages/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ItemDetailPage extends NyStatefulWidget<ItemDetailController> {
  static RouteView path = ("/items/detail", (_) => ItemDetailPage());

  ItemDetailPage({super.key}) : super(child: () => _ItemDetailPageState());
}

class _ItemDetailPageState extends NyPage<ItemDetailPage> {
  late Item _item;
  int _qty = 1;
  DateTime _borrowDate = DateTime.now();
  DateTime _returnDate = DateTime.now().add(const Duration(days: 1));
  bool _submitting = false;

  @override
  get init => () {
    _item = data<Item>()!;
  };

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();

  Future<void> _pickDate({required bool isBorrowDate}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBorrowDate ? _borrowDate : _returnDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() {
      if (isBorrowDate) {
        _borrowDate = picked;
        if (_returnDate.isBefore(_borrowDate)) {
          _returnDate = _borrowDate.add(const Duration(days: 1));
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    app.User? user = Nylo.user<app.User>();
    if (user?.id == null) return;

    setState(() => _submitting = true);
    try {
      await widget.controller.submitLoan(
        userId: user!.id!,
        itemId: _item.id!,
        qty: _qty,
        borrowDate: _borrowDate,
        returnDatePlanned: _returnDate,
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Pengajuan Terkirim"),
          content: const Text(
            "Pengajuan peminjaman Anda telah dikirim dan menunggu persetujuan admin.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      if (mounted) {
        routeTo(
          ItemListPage.path,
          navigationType: NavigationType.pushAndRemoveUntil,
          removeUntilPredicate: (route) => false,
        );
      }
    } catch (e) {
      showToastDanger(description: "Gagal mengajukan peminjaman");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    int maxQty = _item.isReady ? (_item.availableQty ?? 0) : 0;

    return Scaffold(
      appBar: AppBar(title: Text(_item.name ?? "")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _item.imageUrl != null
                    ? Image.network(
                        _item.imageUrl!,
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 220,
                        color: const Color.fromARGB(255, 248, 43, 43),
                        child: const Icon(Icons.inventory_2_outlined, size: 64),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                _item.name ?? "",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text("Kode: ${_item.code}"),
              Text("Kategori: ${_item.category}"),
              if (_item.isReady)
                Text("Tersedia: $maxQty dari ${_item.totalQty}")
              else
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.build_circle_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tidak tersedia — alat sedang rusak / dalam perbaikan",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 32),
              Text(
                "Jumlah Pinjam",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("$_qty", style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    onPressed: _qty < maxQty
                        ? () => setState(() => _qty++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Tanggal Pinjam"),
                subtitle: Text("${_borrowDate.toLocal()}".split(' ').first),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(isBorrowDate: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Rencana Tanggal Kembali"),
                subtitle: Text("${_returnDate.toLocal()}".split(' ').first),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(isBorrowDate: false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (maxQty > 0 && !_submitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        !_item.isReady
                            ? "Tidak Tersedia"
                            : (maxQty > 0 ? "Ajukan Peminjaman" : "Stok Habis"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
