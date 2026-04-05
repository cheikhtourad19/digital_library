import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/ui/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/menu_model.dart';
import '../../../service/auth_service.dart';
import '../../components/navigation/app_sidebar.dart';
import 'client_books_page.dart';
import 'client_favorites_page.dart';
import 'client_home_page.dart';

class ClientLayout extends StatefulWidget {
  final int initialIndex;

  const ClientLayout({super.key, this.initialIndex = 0});

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  late int _selectedIndex;
  final _authService = getIt<AuthService>();

  final List<Widget> _pages = const [
    ClientHomePage(),
    ClientBooksPage(),
    ClientFavoritesPage(),
    ProfilePage(),
  ];

  final List<String> _titles = const [
    'Digital Library',
    'Books',
    'Favorites',
    'Profile',
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
        menus: MenuConfig.getClientMenus(),
        selectedIndex: _selectedIndex,
        onMenuTap: _onMenuTap,
        onLogout: _onLogout,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
