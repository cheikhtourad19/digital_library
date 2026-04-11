import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/categorie_model.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:digital_library/service/categorie_service.dart';
import 'package:digital_library/service/livre_service.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:digital_library/ui/components/cards/admin_book_grid_card.dart';
import 'package:flutter/material.dart';

class AdminBooksPage extends StatefulWidget {
  const AdminBooksPage({super.key});

  @override
  State<AdminBooksPage> createState() => _AdminBooksPageState();
}

class _AdminBooksPageState extends State<AdminBooksPage> {
  final LivreService _livreService = getIt<LivreService>();
  final CategorieService _categorieService = getIt<CategorieService>();

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _langueCtrl = TextEditingController();
  final TextEditingController _minPrixCtrl = TextEditingController();
  final TextEditingController _maxPrixCtrl = TextEditingController();

  List<Livre> _livres = const <Livre>[];
  List<Categorie> _categories = const <Categorie>[];
  String? _selectedCategorieId;
  bool _isLoading = true;
  bool _isLoadingCategories = false;
  bool _showFilters = false;
  int _page = 1;
  int _limite = 12;
  int _pages = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchLivres();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _langueCtrl.dispose();
    _minPrixCtrl.dispose();
    _maxPrixCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _categorieService.fetchCategories();
      if (!mounted) {
        return;
      }
      setState(() => _categories = categories);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ToastService.showError('Failed to load categories');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _fetchLivres({int? targetPage}) async {
    setState(() {
      _isLoading = true;
      if (targetPage != null) {
        _page = targetPage;
      }
    });

    try {
      final result = await _livreService.fetchLivres(
        categorie: _selectedCategorieId,
        minPrix: _optionalDouble(_minPrixCtrl),
        maxPrix: _optionalDouble(_maxPrixCtrl),
        langue: _optionalText(_langueCtrl),
        search: _optionalText(_searchCtrl),
        page: _page,
        limite: _limite,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _livres = result.livres;
        _total = result.total;
        _page = result.page;
        _limite = result.limite;
        _pages = result.pages;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ToastService.showError('Failed to load books');
      setState(() {
        _livres = const <Livre>[];
        _total = 0;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreatePage() async {
    final created = await Navigator.of(
      context,
    ).pushNamed(AppRouter.adminCreateBookPage);

    if (created == true) {
      await _fetchLivres(targetPage: 1);
    }
  }

  Future<void> _openDetailsPage(Livre livre) async {
    final changed = await Navigator.of(
      context,
    ).pushNamed(AppRouter.adminBookDetailPage, arguments: livre.id);

    if (changed == true) {
      await _fetchLivres();
    }
  }

  void _resetFilters() {
    _searchCtrl.clear();
    _selectedCategorieId = null;
    _langueCtrl.clear();
    _minPrixCtrl.clear();
    _maxPrixCtrl.clear();
    _fetchLivres(targetPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Column(
        children: [
          _buildHeader(),
          if (_showFilters) _buildFiltersPanel(),
          Expanded(child: _buildBody()),
          if (!_isLoading) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Books ($_total)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          AppButton.primary(
            label: 'Create Book',
            icon: Icons.add_rounded,
            onPressed: _openCreatePage,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: _inputDecoration('Search by title...'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildCategorieSelect()),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _langueCtrl,
                  decoration: _inputDecoration('Language (ex: fr)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPrixCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration('Min price'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _maxPrixCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration('Max price'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Reset',
                  icon: Icons.restart_alt_rounded,
                  expand: true,
                  onPressed: _resetFilters,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.primary(
                  label: 'Apply Filters',
                  icon: Icons.search_rounded,
                  expand: true,
                  onPressed: () => _fetchLivres(targetPage: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorieSelect() {
    if (_isLoadingCategories) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategorieId,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All categories'),
        ),
        ..._categories.map(
          (item) =>
              DropdownMenuItem<String>(value: item.id, child: Text(item.nom)),
        ),
      ],
      onChanged: (value) => setState(() => _selectedCategorieId = value),
      decoration: _inputDecoration('Category'),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (_livres.isEmpty) {
      return const Center(
        child: Text(
          'No books found',
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 170).floor().clamp(2, 6);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
          itemCount: _livres.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, index) => AdminBookGridCard(
            livre: _livres[index],
            onTap: () => _openDetailsPage(_livres[index]),
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Page $_page of $_pages',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppButton.secondary(
            label: 'Prev',
            icon: Icons.chevron_left_rounded,
            onPressed: _page > 1
                ? () => _fetchLivres(targetPage: _page - 1)
                : null,
          ),
          const SizedBox(width: 8),
          AppButton.primary(
            label: 'Next',
            icon: Icons.chevron_right_rounded,
            onPressed: _page < _pages
                ? () => _fetchLivres(targetPage: _page + 1)
                : null,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  double? _optionalDouble(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return null;
    }
    return double.tryParse(value);
  }
}
