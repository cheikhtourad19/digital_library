import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final int? pageIndex;
  final bool isLogout;

  const MenuItem({
    required this.label,
    required this.icon,
    this.pageIndex,
    this.isLogout = false,
  });
}

class MenuSection {
  final String title;
  final List<MenuItem> items;

  const MenuSection({required this.title, required this.items});
}

class MenuConfig {
  static List<MenuSection> getClientMenus() {
    return [
      MenuSection(
        title: 'Main',
        items: [
          MenuItem(label: 'Home', icon: Icons.home, pageIndex: 0),
          MenuItem(label: 'Books', icon: Icons.library_books, pageIndex: 1),
          MenuItem(label: 'Favorites', icon: Icons.favorite, pageIndex: 2),
        ],
      ),
      MenuSection(
        title: 'Account',
        items: [
          MenuItem(label: 'Profile', icon: Icons.person, pageIndex: 3),
          MenuItem(label: 'Logout', icon: Icons.logout, isLogout: true),
        ],
      ),
    ];
  }

  static List<MenuSection> getAdminMenus() {
    return [
      MenuSection(
        title: 'Dashboard',
        items: [
          MenuItem(label: 'Home', icon: Icons.dashboard, pageIndex: 0),
          MenuItem(label: 'Analytics', icon: Icons.analytics, pageIndex: 1),
        ],
      ),
      MenuSection(
        title: 'Management',
        items: [
          MenuItem(label: 'Books', icon: Icons.library_books, pageIndex: 2),
          MenuItem(label: 'Users', icon: Icons.people, pageIndex: 3),
        ],
      ),
      MenuSection(
        title: 'Account',
        items: [
          MenuItem(label: 'Profile', icon: Icons.person, pageIndex: 4),
          MenuItem(label: 'Logout', icon: Icons.logout, isLogout: true),
        ],
      ),
    ];
  }
}
