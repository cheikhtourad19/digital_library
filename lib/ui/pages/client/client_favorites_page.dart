import 'package:digital_library/core/api/api_config.dart';
import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:digital_library/models/lecture_model.dart';
import 'package:digital_library/service/commande_service.dart';
import 'package:digital_library/service/lecture_service.dart';
import 'package:flutter/material.dart';

class ClientFavoritesPage extends StatefulWidget {
  const ClientFavoritesPage({super.key});

  @override
  State<ClientFavoritesPage> createState() => _ClientFavoritesPageState();
}

class _ClientFavoritesPageState extends State<ClientFavoritesPage> {
  final CommandeService _commandeService = getIt<CommandeService>();
  final LectureService _lectureService = getIt<LectureService>();
  bool _isLoading = true;
  bool _isLoadingLectures = true;
  List<Livre> _livres = const <Livre>[];
  List<Lecture> _latestLectures = const <Lecture>[];

  @override
  void initState() {
    super.initState();
    _fetch();
    _fetchLatestLectures();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final result = await _commandeService.getMyBooks();
      if (!mounted) return;
      setState(() => _livres = result.livres);
    } catch (_) {
      if (mounted) ToastService.showError('Failed to load purchased books');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchLatestLectures() async {
    try {
      final lectures = await _lectureService.getLatestLectures();
      if (!mounted) return;
      setState(() => _latestLectures = lectures);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingLectures = false);
    }
  }

  Future<void> _openBook(String livreId) async {
    await Navigator.of(context).pushNamed(
      AppRouter.clientReadBookPage,
      arguments: livreId,
    );
    _fetch();
    _fetchLatestLectures();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: CustomScrollView(
        slivers: [
          if (!_isLoadingLectures && _latestLectures.isNotEmpty)
            SliverToBoxAdapter(child: _buildContinueReadingSection()),
          if (_livres.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No purchased books yet',
                  style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final livre = _livres[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRouter.clientReadBookPage,
                        arguments: livre.id,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: SizedBox(width: double.infinity, child: _buildCover(livre)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    livre.titre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    livre.auteur.isEmpty ? 'Auteur inconnu' : livre.auteur.join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _livres.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Continue Reading',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _latestLectures.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final lecture = _latestLectures[index];
                return _LectureCard(lecture: lecture, onTap: () => _openBook(lecture.livre));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(Livre livre) {
    final raw = (livre.couvertureUrl?.trim().isNotEmpty == true) ? livre.couvertureUrl!.trim() : livre.couverture.trim();
    if (raw.isEmpty) return _placeholder();
    final url = raw.startsWith('http://') || raw.startsWith('https://') ? raw : raw.startsWith('/') ? '${ApiConfig.minioUrl}$raw' : '${ApiConfig.minioUrl}/$raw';
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.textMuted, size: 28)),
    );
  }
}

class _LectureCard extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback onTap;

  const _LectureCard({required this.lecture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final page = lecture.dernierePage;
    final total = lecture.nombrePages ?? 1;
    final progress = total > 0 ? (page / total).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture.livreTitre ?? 'Book',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      if (lecture.livreAuteur.isNotEmpty)
                        Text(
                          lecture.livreAuteur.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 6),
            Text(
              lecture.termine ? 'Completed' : 'Page ${page + 1} / $total',
              style: TextStyle(
                color: lecture.termine ? Colors.green : AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}