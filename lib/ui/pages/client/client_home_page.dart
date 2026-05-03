import 'package:digital_library/core/api/api_config.dart';
import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:digital_library/models/recommendation_model.dart';
import 'package:digital_library/service/recommendation_service.dart';
import 'package:flutter/material.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final RecommendationService _recommendationService =
      getIt<RecommendationService>();

  bool _isLoading = true;
  List<RecommendedBook> _ageRecommendations = const <RecommendedBook>[];
  List<RecommendedBook> _trendingBooks = const <RecommendedBook>[];
  List<RecommendedBook> _newBooks = const <RecommendedBook>[];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _openDetailsPage(RecommendedBook book) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRouter.clientBookDetailPage, arguments: book.id);
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);

    final results =
        await Future.wait<({List<RecommendedBook> data, bool hasError})>([
          _safeLoadRecommendations(_recommendationService.getRecommendedByAge),
          _safeLoadRecommendations(_recommendationService.getTrendingBooks),
          _safeLoadRecommendations(
            () => _recommendationService.getNewBooks(limit: 12),
          ),
        ]);

    if (!mounted) return;

    setState(() {
      _ageRecommendations = results[0].data;
      _trendingBooks = results[1].data;
      _newBooks = results[2].data;
      _isLoading = false;
    });

    final failedCount = results.where((item) => item.hasError).length;
    if (failedCount == results.length) {
      ToastService.showError('Failed to load recommendations');
    } else if (failedCount > 0) {
      ToastService.showWarning('Some recommendation sections are unavailable');
    }
  }

  Future<({List<RecommendedBook> data, bool hasError})>
  _safeLoadRecommendations(
    Future<List<RecommendedBook>> Function() request,
  ) async {
    try {
      return (data: await request(), hasError: false);
    } catch (_) {
      return (data: const <RecommendedBook>[], hasError: true);
    }
  }

  void _goToBooksPage() {
    Navigator.of(
      context,
    ).pushReplacementNamed(AppRouter.client, arguments: {'initialIndex': 1});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: _loadRecommendations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            _HomeHero(onVoirPlus: _goToBooksPage),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 42),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              )
            else ...[
              _RecommendationSection(
                title: 'Pour Votre Age',
                subtitle: 'Suggestions basees sur les lecteurs de votre groupe',
                books: _ageRecommendations,
                onVoirPlus: _goToBooksPage,
                onBookTap: _openDetailsPage,
              ),
              const SizedBox(height: 12),
              _RecommendationSection(
                title: 'Tendances',
                subtitle: 'Les livres les plus commandes ces 3 derniers mois',
                books: _trendingBooks,
                onVoirPlus: _goToBooksPage,
                onBookTap: _openDetailsPage,
              ),
              const SizedBox(height: 12),
              _RecommendationSection(
                title: 'Nouveautes',
                subtitle: 'Les derniers livres ajoutes au catalogue',
                books: _newBooks,
                onVoirPlus: _goToBooksPage,
                onBookTap: _openDetailsPage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final VoidCallback onVoirPlus;

  const _HomeHero({required this.onVoirPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Votre espace decouverte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Retrouvez vos recommandations personnalisees, les tendances du moment et les derniers ajouts.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onVoirPlus,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Voir plus'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<RecommendedBook> books;
  final VoidCallback onVoirPlus;
  final void Function(RecommendedBook) onBookTap;

  const _RecommendationSection({
    required this.title,
    required this.subtitle,
    required this.books,
    required this.onVoirPlus,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onVoirPlus,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Voir plus'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (books.isEmpty)
            Container(
              height: 128,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Aucune recommandation pour le moment',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SizedBox(
              height: 235,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _RecommendedBookCard(
                    book: books[index],
                    onTap: () => onBookTap(books[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendedBookCard extends StatelessWidget {
  final RecommendedBook book;
  final VoidCallback? onTap;

  const _RecommendedBookCard({required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final coverUrl = _normalizeCoverUrl(book.couverture);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 114,
                width: double.infinity,
                child: coverUrl == null
                    ? _BookCoverPlaceholder(title: book.titre)
                    : Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _BookCoverPlaceholder(title: book.titre),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book.auteur.isEmpty
                          ? 'Auteur inconnu'
                          : book.auteur.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    if (book.categorieNom.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          book.categorieNom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Text(
                          '${book.prix.toStringAsFixed(2)} TND',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          book.noteMoyenne.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _normalizeCoverUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '${ApiConfig.minioUrl}$trimmed';
    }
    return '${ApiConfig.minioUrl}/$trimmed';
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  final String title;

  const _BookCoverPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFECE8E1)),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: AppColors.textMuted,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
