import 'package:flutter/material.dart';
import 'package:digital_library/core/di/injection.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/menu_model.dart';
import '../../../service/auth_service.dart';
import '../../components/navigation/app_sidebar.dart';
import 'admin_analytics_page.dart';
import 'admin_books_page.dart';
import 'admin_home_page.dart';
import 'admin_settings_page.dart';
import 'admin_users_page.dart';

class AdminLayout extends StatefulWidget {
  final int initialIndex;

  const AdminLayout({super.key, this.initialIndex = 0});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  late int _selectedIndex;
  final _authService = getIt<AuthService>();

  final List<Widget> _pages = const [
    AdminHomePage(),
    AdminAnalyticsPage(),
    AdminBooksPage(),
    AdminUsersPage(),
    AdminSettingsPage(),
  ];

  final List<String> _titles = const [
    'Admin Dashboard',
    'Analytics',
    'Books',
    'Users',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onMenuTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _onLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: AppSidebar(
        menus: MenuConfig.getAdminMenus(),
        selectedIndex: _selectedIndex,
        onMenuTap: _onMenuTap,
        onLogout: _onLogout,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
