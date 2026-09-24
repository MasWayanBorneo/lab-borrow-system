import '/app/controllers/admin_items_controller.dart';
import '/app/models/item.dart';
import '/resources/widgets/admin_bottom_nav.dart';
import '/resources/widgets/item_form_sheet.dart';
import '/resources/widgets/bottom_sheet_modals/bottom_sheet_modals.dart';
import '/app/events/logout_event.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AdminItemsPage extends NyStatefulWidget<AdminItemsController> {
  static RouteView path = ("/admin/items", (_) => AdminItemsPage());

  AdminItemsPage({super.key}) : super(child: () => _AdminItemsPageState());
}

class _AdminItemsPageState extends NyPage<AdminItemsPage> {
  List<Item> _items = [];

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();

  @override
  get init => () async {
    await _fetch();
  };

  Future<void> _fetch() async {
    List<Item> items = await widget.controller.load();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<bool> _confirmDelete(Item item) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Alat"),
        content: Text("Hapus \"${item.name}\" dari daftar alat?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _delete(Item item) async {
    try {
      await widget.controller.delete(item.id!);
      if (!mounted) return;
      setState(() => _items.removeWhere((i) => i.id == item.id));
      showToastSuccess(description: "Alat berhasil dihapus");
    } catch (e) {
      showToastDanger(description: "Gagal menghapus alat");
      await _fetch();
    }
  }

  Future<void> _toggleReady(Item item, bool value) async {
    bool previous = item.isReady;
    setState(() => item.isReady = value);
    try {
      await widget.controller.setReady(item.id!, value);
      showToastSuccess(
        description: value
            ? "\"${item.name}\" ditandai siap dipinjam"
            : "\"${item.name}\" ditandai rusak / diperbaiki",
      );
    } catch (e) {
      setState(() => item.isReady = previous);
      showToastDanger(description: "Gagal memperbarui status alat");
    }
  }

  Future<void> _openForm({Item? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemFormSheet(
        existing: existing,
        uploadImage: widget.controller.uploadImage,
        onSave: (item) async {
          if (existing == null) {
            await widget.controller.create(item);
          } else {
            await widget.controller.update(item);
          }
          showToastSuccess(description: "Data alat disimpan");
          await _fetch();
        },
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Data Alat"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _items.isEmpty
          ? const Center(child: Text("Belum ada data alat"))
          : Pullable(
              onRefresh: () async => _fetch(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  Item item = _items[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(item),
                    onDismissed: (_) => _delete(item),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrl != null
                              ? Image.network(item.imageUrl!,
                                  width: 48, height: 48, fit: BoxFit.cover)
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.inventory_2_outlined),
                                ),
                        ),
                        title: Text(item.name ?? ""),
                        subtitle: Text(
                          "${item.code} • ${item.category} • ${item.availableQty}/${item.totalQty}\n"
                          "${item.isReady ? "Siap dipinjam" : "Rusak / diperbaiki"}",
                          style: TextStyle(
                            color: item.isReady ? Colors.green : Colors.red,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: item.isReady,
                              onChanged: (value) =>
                                  _toggleReady(item, value ?? true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(existing: item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
