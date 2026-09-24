import '/resources/pages/admin_approval_page.dart';
import '/resources/pages/admin_returns_page.dart';
import '/resources/pages/admin_items_page.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Shared bottom navigation for the admin-facing pages.
class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        RouteView path = switch (index) {
          0 => AdminApprovalPage.path,
          1 => AdminReturnsPage.path,
          _ => AdminItemsPage.path,
        };
        routeTo(path,
            navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: (route) => false);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check),
          label: "Persetujuan",
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_return_outlined),
          selectedIcon: Icon(Icons.assignment_return),
          label: "Pengembalian",
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: "Kelola Alat",
        ),
      ],
    );
  }
}
