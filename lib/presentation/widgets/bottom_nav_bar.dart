import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDeveloper;
  final bool isAdmin;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDeveloper = false,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Search'),
      const BottomNavigationBarItem(icon: Icon(Icons.download_outlined), activeIcon: Icon(Icons.download), label: 'Downloads'),
      if (isDeveloper)
        const BottomNavigationBarItem(icon: Icon(Icons.code_outlined), activeIcon: Icon(Icons.code), label: 'Dev'),
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          elevation: 0,
        ),
      ),
    );
  }
}
