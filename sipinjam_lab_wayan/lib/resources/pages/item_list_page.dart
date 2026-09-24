import '/app/controllers/item_list_controller.dart';
import '/app/models/item.dart';
import '/app/models/user.dart' as app;
import '/app/helpers/loan_status_message.dart';
import '/resources/pages/item_detail_page.dart';
import '/resources/widgets/student_bottom_nav.dart';
import '/resources/widgets/bottom_sheet_modals/bottom_sheet_modals.dart';
import '/app/events/logout_event.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

const List<String> kCategories = [
  "Semua",
  "Jaringan",
  "Multimedia",
  "Elektronika",
];

class ItemListPage extends NyStatefulWidget<ItemListController> {
  static RouteView path = ("/items", (_) => ItemListPage());

  ItemListPage({super.key}) : super(child: () => _ItemListPageState());
}

class _ItemListPageState extends NyPage<ItemListPage> {
  List<Item> _items = [];
  String _selectedCategory = "Semua";
  String _search = "";
  RealtimeChannel? _loanChannel;

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();

  @override
  get init => () async {
    await _fetch();
    _subscribeLoanUpdates();
  };

  @override
  void dispose() {
    if (_loanChannel != null) {
      widget.controller.unsubscribeLoanUpdates(_loanChannel!);
    }
    super.dispose();
  }

  void _subscribeLoanUpdates() {
    app.User? user = Nylo.user<app.User>();
    if (user?.id == null) return;

    _loanChannel = widget.controller.subscribeLoanUpdates(
      userId: user!.id!,
      onChange: (payload) {
        String? message = loanStatusChangeMessage(payload.newRecord['status']);
        if (message == null) return;
        showToastInfo(description: message);
        LocalNotification.sendNotification(
          title: "Status Peminjaman",
          body: message,
        );
      },
    );
  }

  Future<void> _fetch() async {
    List<Item> items = await widget.controller.load(
      category: _selectedCategory,
      search: _search,
    );
    if (!mounted) return;
    setState(() => _items = items);
  }

  Color _badgeColor(Item item) {
    if (!item.isReady) return Colors.grey;
    return item.isAvailable ? Colors.green : Colors.red;
  }

  String _badgeLabel(Item item) {
    if (!item.isReady) return "Diperbaiki";
    return "${item.availableQty}/${item.totalQty}";
  }

  @override
  Widget view(BuildContext context) {
    app.User? user = Nylo.user<app.User>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Alat"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                BottomSheetModal.showLogout(
                  context,
                  onLogoutPressed: () => event<LogoutEvent>(),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(enabled: false, child: Text(user?.name ?? "")),
              const PopupMenuItem(value: 'logout', child: Text("Keluar")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari alat...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                _search = value;
                _fetch();
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                String category = kCategories[index];
                bool selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    _selectedCategory = category;
                    _fetch();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Pullable(
              onRefresh: () async => _fetch(),
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: Text("Tidak ada alat ditemukan"),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        Item item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imageUrl != null
                                  ? Image.network(
                                      item.imageUrl!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      color: const Color.fromARGB(
                                        255,
                                        112,
                                        103,
                                        103,
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                      ),
                                    ),
                            ),
                            title: Text(item.name ?? ""),
                            subtitle: Text("${item.code} • ${item.category}"),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _badgeColor(
                                  item,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _badgeLabel(item),
                                style: TextStyle(
                                  color: _badgeColor(item),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () =>
                                routeTo(ItemDetailPage.path, data: item),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StudentBottomNav(currentIndex: 0),
    );
  }
}
