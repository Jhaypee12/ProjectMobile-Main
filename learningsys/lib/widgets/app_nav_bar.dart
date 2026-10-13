import 'package:flutter/material.dart';

import '../theme.dart';

class NavItem {
  const NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Bottom navigation bar used by every role.
/// RoleShell decides which items to pass in.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: NavigationBar(
        height: 66,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.ice,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final item in items)
            NavigationDestination(
              label: item.label,
              icon: Icon(item.icon, color: AppColors.muted),
              selectedIcon: Icon(item.icon, color: AppColors.purple),
            ),
        ],
      ),
    );
  }
}