import '/resources/pages/item_list_page.dart';
import '/resources/pages/my_loans_page.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Shared bottom navigation for the student-facing pages.
class StudentBottomNav extends StatelessWidget {
  const StudentBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          routeTo(ItemListPage.path,
              navigationType: NavigationType.pushAndRemoveUntil,
              removeUntilPredicate: (route) => false);
        } else {
          routeTo(MyLoansPage.path,
              navigationType: NavigationType.pushAndRemoveUntil,
              removeUntilPredicate: (route) => false);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: "Daftar Alat",
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: "Peminjaman Saya",
        ),
      ],
    );
  }
}
