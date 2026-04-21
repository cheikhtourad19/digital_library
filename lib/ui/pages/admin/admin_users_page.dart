import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/service/user_service.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/utils/app_colors.dart';
import '../../../models/user_model.dart';
import '../../components/table/app_table.dart';

enum _UserRoleFilter { all, admin, client }

enum _UserSortOption { newest, oldest, nameAsc, nameDesc }

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _UserRoleFilter _roleFilter = _UserRoleFilter.all;
  _UserSortOption _sortOption = _UserSortOption.newest;
  bool _recentOnly = false;
  final UserService _userService = getIt<UserService>();
  List<User> _users = [];

  // ── Pagination ──────────────────────────────────────────────
  int _currentPage = 1;
  static const int _pageSize = 10;

  int get _totalPages => (_filtered.length / _pageSize).ceil().clamp(1, 999999);

  List<User> get _paginatedUsers {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() => _currentPage = page);
  }

  void _resetPage() => _currentPage = 1;
  // ────────────────────────────────────────────────────────────

  Future<void> loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.fetchAllUsers();
      setState(() {
        _users = users;
        _resetPage();
      });
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  List<User> get _filtered {
    final now = DateTime.now();
    final recentThreshold = now.subtract(const Duration(days: 30));
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _users.where((u) {
      final matchesSearch =
          query.isEmpty ||
          u.nom.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);

      final matchesRole = switch (_roleFilter) {
        _UserRoleFilter.all => true,
        _UserRoleFilter.admin => u.isAdmin,
        _UserRoleFilter.client => !u.isAdmin,
      };

      final matchesRecent =
          !_recentOnly ||
          (u.dateCreation != null && u.dateCreation!.isAfter(recentThreshold));

      return matchesSearch && matchesRole && matchesRecent;
    }).toList();

    filtered.sort((a, b) {
      final aName = a.nom.toLowerCase();
      final bName = b.nom.toLowerCase();
      final aDate = a.dateCreation;
      final bDate = b.dateCreation;

      return switch (_sortOption) {
        _UserSortOption.newest => _compareDateDesc(aDate, bDate),
        _UserSortOption.oldest => _compareDateAsc(aDate, bDate),
        _UserSortOption.nameAsc => aName.compareTo(bName),
        _UserSortOption.nameDesc => bName.compareTo(aName),
      };
    });

    return filtered;
  }

  int _compareDateDesc(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  int _compareDateAsc(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _roleFilter = _UserRoleFilter.all;
      _sortOption = _UserSortOption.newest;
      _recentOnly = false;
      _resetPage();
    });
  }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(20), child: _buildPageHeader()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildFiltersPanel(),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    AppTable<User>(
                      title: 'All Users',
                      trailing: _buildSearchBar(),
                      columns: const ['User', 'Role', 'Actions'],
                      rows: _paginatedUsers,
                      isLoading: _isLoading,
                      emptyMessage: 'No users found',
                      rowBuilder: (user) => [
                        AppTableCell.avatar(user.nom, subtitle: user.email),
                        AppTableCell.badge(
                          user.isAdmin ? 'Admin' : 'Client',
                          color: user.isAdmin
                              ? AppColors.accent
                              : AppColors.secondary,
                        ),
                        AppTableCell.action(onTap: () => _viewUser(user)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPaginationBar(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
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
              '${_filtered.length} shown / ${_users.length} total',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildRoleChip(_UserRoleFilter.all, 'All'),
          _buildRoleChip(_UserRoleFilter.admin, 'Admins'),
          _buildRoleChip(_UserRoleFilter.client, 'Clients'),
          FilterChip(
            label: const Text('Recent 30d'),
            selected: _recentOnly,
            onSelected: (selected) => setState(() {
              _recentOnly = selected;
              _resetPage();
            }),
            selectedColor: AppColors.secondary.withOpacity(0.14),
            checkmarkColor: AppColors.secondary,
            side: BorderSide(color: AppColors.border),
            labelStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          PopupMenuButton<_UserSortOption>(
            initialValue: _sortOption,
            tooltip: 'Sort',
            onSelected: (value) => setState(() {
              _sortOption = value;
              _resetPage();
            }),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _UserSortOption.newest,
                child: Text('Newest first'),
              ),
              PopupMenuItem(
                value: _UserSortOption.oldest,
                child: Text('Oldest first'),
              ),
              PopupMenuItem(
                value: _UserSortOption.nameAsc,
                child: Text('Name A-Z'),
              ),
              PopupMenuItem(
                value: _UserSortOption.nameDesc,
                child: Text('Name Z-A'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(_sortOption),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(_UserRoleFilter value, String label) {
    final selected = _roleFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() {
        _roleFilter = value;
        _resetPage();
      }),
      selectedColor: AppColors.secondary.withOpacity(0.14),
      side: BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.secondary : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  String _sortLabel(_UserSortOption option) {
    return switch (option) {
      _UserSortOption.newest => 'Newest',
      _UserSortOption.oldest => 'Oldest',
      _UserSortOption.nameAsc => 'Name A-Z',
      _UserSortOption.nameDesc => 'Name Z-A',
    };
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 200,
      height: 36,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _resetPage();
        }),
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

  Widget _buildPaginationBar() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    // Build the list of page numbers to show (with ellipsis logic)
    final pages = <int?>[];
    if (_totalPages <= 7) {
      for (int i = 1; i <= _totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.add(1);
      if (_currentPage > 3) pages.add(null); // leading ellipsis
      for (
        int i = (_currentPage - 1).clamp(2, _totalPages - 1);
        i <= (_currentPage + 1).clamp(2, _totalPages - 1);
        i++
      ) {
        pages.add(i);
      }
      if (_currentPage < _totalPages - 2) pages.add(null); // trailing ellipsis
      pages.add(_totalPages);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prev button
        _PaginationButton(
          icon: Icons.chevron_left_rounded,
          onTap: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
        ),
        const SizedBox(width: 4),

        // Page number buttons
        for (final page in pages)
          page == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '…',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _PaginationButton(
                    label: '$page',
                    isActive: page == _currentPage,
                    onTap: () => _goToPage(page),
                  ),
                ),

        const SizedBox(width: 4),
        // Next button
        _PaginationButton(
          icon: Icons.chevron_right_rounded,
          onTap: _currentPage < _totalPages
              ? () => _goToPage(_currentPage + 1)
              : null,
        ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    this.label,
    this.icon,
    this.onTap,
    this.isActive = false,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary
              : disabled
              ? AppColors.background
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: 16,
                  color: disabled ? AppColors.textMuted : AppColors.textPrimary,
                )
              : Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
