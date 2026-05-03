import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/navigation/app_router.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/commande_model.dart';
import 'package:digital_library/models/lecture_model.dart';
import 'package:digital_library/service/commande_service.dart';
import 'package:digital_library/service/lecture_service.dart';
import 'package:flutter/material.dart';

class ClientOrderHistoryPage extends StatefulWidget {
  const ClientOrderHistoryPage({super.key});

  @override
  State<ClientOrderHistoryPage> createState() => _ClientOrderHistoryPageState();
}

class _ClientOrderHistoryPageState extends State<ClientOrderHistoryPage> {
  final CommandeService _commandeService = getIt<CommandeService>();
  final LectureService _lectureService = getIt<LectureService>();
  bool _isLoading = true;
  bool _isLoadingLectures = true;
  List<Commande> _commandes = const <Commande>[];
  List<Lecture> _latestLectures = const <Lecture>[];
  int _page = 1;
  int _pages = 1;
  int _total = 0;
  final int _limite = 10;
  String? _selectedStatut;

  @override
  void initState() {
    super.initState();
    _fetch();
    _fetchLatestLectures();
  }

  Future<void> _fetchLatestLectures() async {
    try {
      final lectures = await _lectureService.getLatestLectures();
      if (!mounted) return;
      setState(() => _latestLectures = lectures);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingLectures = false);
      }
    }
  }

  Future<void> _openBook(String livreId) async {
    final lecture = await _lectureService.getLectureByLivre(livreId);
    final startPage = lecture?.dernierePage ?? 0;
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppRouter.clientReadBookPage,
      arguments: {'livreId': livreId, 'startPage': startPage},
    );
  }

  Future<void> _fetch({int? targetPage}) async {
    setState(() {
      _isLoading = true;
      if (targetPage != null) {
        _page = targetPage;
      }
    });

    try {
      final result = await _commandeService.getMyCommandes(
        page: _page,
        limite: _limite,
        statut: _selectedStatut,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _commandes = result.commandes;
        _page = result.page;
        _pages = result.pages;
        _total = result.total;
      });
    } catch (_) {
      if (mounted) {
        ToastService.showError('Failed to load order history');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          if (!_isLoadingLectures && _latestLectures.isNotEmpty)
            _buildContinueReadingSection(),
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetch(targetPage: 1),
              child: _buildBody(),
            ),
          ),
          if (!_isLoading) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Continue Reading',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
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
                return _LectureCard(
                  lecture: lecture,
                  onTap: () => _openBook(lecture.livre),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatut,
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Filter by status',
              ),
              items: const [
                DropdownMenuItem<String>(value: null, child: Text('All status')),
                ...[
                  DropdownMenuItem<String>(
                    value: 'en_attente',
                    child: Text('en_attente'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'confirmée',
                    child: Text('confirmée'),
                  ),
                  DropdownMenuItem<String>(value: 'échouée', child: Text('échouée')),
                  DropdownMenuItem<String>(
                    value: 'remboursée',
                    child: Text('remboursée'),
                  ),
                ],
              ],
              onChanged: (value) {
                setState(() => _selectedStatut = value);
                _fetch(targetPage: 1);
              },
            ),
          ),
          Text(
            '$_total orders',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    if (_commandes.isEmpty) {
      return const Center(
        child: Text(
          'No orders found',
          style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: _commandes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final commande = _commandes[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${commande.id.substring(0, commande.id.length.clamp(0, 8))}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatutChip(statut: CommandeStatutMapper.toJson(commande.statut)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${commande.livres.length} book(s) • ${commande.modePaiement}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                '${commande.montantTotal.toStringAsFixed(2)} TND',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Page $_page / $_pages',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: _page > 1 ? () => _fetch(targetPage: _page - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: _page < _pages ? () => _fetch(targetPage: _page + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatutChip extends StatelessWidget {
  final String statut;
  const _StatutChip({required this.statut});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (statut) {
      case 'confirmée':
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green.shade700;
        break;
      case 'échouée':
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red.shade700;
        break;
      case 'remboursée':
        bg = Colors.deepPurple.withOpacity(0.12);
        fg = Colors.deepPurple.shade700;
        break;
      default:
        bg = Colors.orange.withOpacity(0.12);
        fg = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        statut,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
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
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
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
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (lecture.livreAuteur.isNotEmpty)
                        Text(
                          lecture.livreAuteur.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
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
              lecture.termine
                  ? 'Completed'
                  : 'Page ${page + 1} / $total',
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
