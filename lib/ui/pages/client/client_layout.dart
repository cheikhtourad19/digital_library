import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../models/menu_model.dart';
import '../../../service/auth_service.dart';
import '../../components/navigation/app_sidebar.dart';
import 'client_books_page.dart';
import 'client_favorites_page.dart';
import 'client_home_page.dart';
import 'client_profile_page.dart';

class ClientLayout extends StatefulWidget {
  final int initialIndex;

  const ClientLayout({super.key, this.initialIndex = 0});

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    ClientHomePage(),
    ClientBooksPage(),
    ClientFavoritesPage(),
    ClientProfilePage(),
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
    await AuthService().logout();
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
