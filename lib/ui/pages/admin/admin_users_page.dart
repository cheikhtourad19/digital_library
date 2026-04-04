import 'package:digital_library/service/user_service.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/utils/app_colors.dart';
import '../../../models/user_model.dart';
import '../../components/table/app_table.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final UserService _userService = UserService();
  List<User> _users = [];
  Future<void> loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.fetchAllUsers();

      setState(() {
        _users = users;
      });
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }
  // Mock data for testing

  List<User> get _filtered => _searchQuery.isEmpty
      ? _users
      : _users
            .where(
              (u) =>
                  u.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

  void _viewUser(User user) {
    Navigator.of(
      context,
    ).pushNamed(AppRouter.adminUserDetailPage, arguments: user);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header ──────────────────────────────────
            _buildPageHeader(),
            const SizedBox(height: 20),

            // ── Table ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: AppTable<User>(
                  title: 'All Users',
                  trailing: _buildSearchBar(),
                  columns: const ['User', 'Email', 'Role', 'Actions'],
                  rows: _filtered,
                  isLoading: _isLoading,
                  emptyMessage: 'No users found',
                  rowBuilder: (user) => [
                    AppTableCell.avatar(user.nom, subtitle: user.email),
                    AppTableCell.text(user.email),
                    AppTableCell.badge(
                      user.isAdmin ? 'Admin' : 'Client',
                      color: user.isAdmin
                          ? AppColors.accent
                          : AppColors.secondary,
                    ),
                    // replace with user.isActive
                    AppTableCell.action(onTap: () => _viewUser(user)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_users.length} total users',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 200,
      height: 36,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
