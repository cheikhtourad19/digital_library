import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/avis_model.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:digital_library/providers/cart_provider.dart';
import 'package:digital_library/service/avis_service.dart';
import 'package:digital_library/service/livre_service.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:digital_library/ui/components/cards/book_info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetailPage extends StatefulWidget {
  final String livreId;

  const BookDetailPage({super.key, required this.livreId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final LivreService _livreService = getIt<LivreService>();
  final AvisService _avisService = getIt<AvisService>();
  final TextEditingController _commentController = TextEditingController();

  Livre? _livre;
  List<Avis> _avis = const <Avis>[];
  bool _isLoading = true;
  bool _isLoadingAvis = true;
  bool _isUpdatingRating = false;
  bool _isSubmittingComment = false;
  bool _isDeletingReview = false;
  int _avisPage = 1;
  int _avisPages = 1;
  int _selectedRating = 0;
  double _noteMoyenne = 0;
  int _nombreAvis = 0;
  Avis? _myAvis;

  @override
  void initState() {
    super.initState();
    _fetchLivre();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchLivre() async {
    setState(() => _isLoading = true);
    try {
      final livre = await _livreService.fetchLivreById(widget.livreId);
      final reviewsResult = await _avisService.getBookReviews(
        livreId: widget.livreId,
        page: 1,
        limite: 10,
      );
      final myReview = await _avisService.getMyReview(widget.livreId);

      if (!mounted) return;
      setState(() {
        _livre = livre;
        _avis = reviewsResult.avis;
        _avisPage = reviewsResult.page;
        _avisPages = reviewsResult.pages;
        _noteMoyenne = reviewsResult.noteMoyenne;
        _nombreAvis = reviewsResult.totalAvis;
        _myAvis = myReview;
        _selectedRating = myReview?.note ?? 0;
        _commentController.text = myReview?.commentaire ?? '';
        _isLoadingAvis = false;
      });
    } catch (_) {
      ToastService.showError('Failed to load book details');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvisPage(int targetPage) async {
    setState(() => _isLoadingAvis = true);
    try {
      final reviewsResult = await _avisService.getBookReviews(
        livreId: widget.livreId,
        page: targetPage,
        limite: 10,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _avis = reviewsResult.avis;
        _avisPage = reviewsResult.page;
        _avisPages = reviewsResult.pages;
        _noteMoyenne = reviewsResult.noteMoyenne;
        _nombreAvis = reviewsResult.totalAvis;
      });
    } catch (_) {
      if (mounted) {
        ToastService.showError('Failed to load reviews');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAvis = false);
      }
    }
  }

  Future<void> _onRatingChanged(int rating) async {
    if (_isUpdatingRating) {
      return;
    }
    setState(() => _isUpdatingRating = true);
    try {
      final result = await _avisService.rateBook(
        livreId: widget.livreId,
        note: rating,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedRating = result.note;
        _noteMoyenne = result.noteMoyenne;
        _nombreAvis = result.nombreAvis;
      });
      _myAvis = await _avisService.getMyReview(widget.livreId);
      if (mounted) {
        _commentController.text = _myAvis?.commentaire ?? _commentController.text;
      }
      await _loadAvisPage(1);
      ToastService.showSuccess('Rating saved');
    } catch (_) {
      ToastService.showError('Unable to save rating');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingRating = false);
      }
    }
  }

  Future<void> _submitComment() async {
    if (_isSubmittingComment) {
      return;
    }
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ToastService.showError('Please write a comment before submitting.');
      return;
    }
    setState(() => _isSubmittingComment = true);
    try {
      final result = await _avisService.commentBook(
        livreId: widget.livreId,
        commentaire: text,
        note: _selectedRating > 0 ? _selectedRating : null,
      );
      if (!mounted) {
        return;
      }
      _noteMoyenne = result.noteMoyenne;
      _nombreAvis = result.nombreAvis;
      _myAvis = await _avisService.getMyReview(widget.livreId);
      if (mounted) {
        setState(() {
          _selectedRating = _myAvis?.note ?? _selectedRating;
          _commentController.text = _myAvis?.commentaire ?? text;
        });
      }
      await _loadAvisPage(1);
      FocusScope.of(context).unfocus();
      ToastService.showSuccess('Comment saved');
    } catch (_) {
      ToastService.showError('Unable to save comment');
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  Future<void> _deleteMyReview() async {
    if (_isDeletingReview) {
      return;
    }
    setState(() => _isDeletingReview = true);
    try {
      final result = await _avisService.deleteMyReview(widget.livreId);
      if (!mounted) {
        return;
      }
      setState(() {
        _myAvis = null;
        _selectedRating = 0;
        _commentController.clear();
        _noteMoyenne = result.noteMoyenne;
        _nombreAvis = result.nombreAvis;
      });
      await _loadAvisPage(1);
      ToastService.showSuccess('Review deleted');
    } catch (_) {
      ToastService.showError('Unable to delete review');
    } finally {
      if (mounted) {
        setState(() => _isDeletingReview = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Book Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : _livre == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Book not found',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton.secondary(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    onPressed: _fetchLivre,
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Book info ──────────────────────────────
                BookInfoCard(livre: _livre!),
                const SizedBox(height: 16),

                // ── Add to Cart ────────────────────────────
                _AddToCartSection(livre: _livre!),
                const SizedBox(height: 28),

                // ── Reader reviews ─────────────────────────
                const _SectionDivider(label: 'Reader reviews'),
                const SizedBox(height: 12),
                _AvisListSection(
                  avis: _avis,
                  noteMoyenne: _noteMoyenne,
                  nombreAvis: _nombreAvis,
                  isLoading: _isLoadingAvis,
                  page: _avisPage,
                  pages: _avisPages,
                  onPrevPage: _avisPage > 1 ? () => _loadAvisPage(_avisPage - 1) : null,
                  onNextPage: _avisPage < _avisPages
                      ? () => _loadAvisPage(_avisPage + 1)
                      : null,
                ),
                const SizedBox(height: 28),

                // ── Rate this book ─────────────────────────
                const _SectionDivider(label: 'Rate this book'),
                const SizedBox(height: 12),
                _StarRatingSection(
                  selectedRating: _selectedRating,
                  isSubmitting: _isUpdatingRating,
                  onRatingChanged: _onRatingChanged,
                ),
                const SizedBox(height: 24),

                // ── Leave a review ─────────────────────────
                const _SectionDivider(label: 'Leave a review'),
                const SizedBox(height: 12),
                _CommentSection(
                  controller: _commentController,
                  isSubmitting: _isSubmittingComment,
                  isDeleting: _isDeletingReview,
                  hasExistingReview: _myAvis != null,
                  onSubmit: _submitComment,
                  onDelete: _myAvis != null ? _deleteMyReview : null,
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Add to Cart Section
// ─────────────────────────────────────────────────────────────────
class _AddToCartSection extends StatelessWidget {
  final Livre livre;
  const _AddToCartSection({required this.livre});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.contains(livre.id);
    final isOwned = cart.isOwned(livre.id);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOwned
          ? const _OwnedBookBanner(key: ValueKey('owned'))
          : inCart
          ? _RemoveFromCartButton(livreId: livre.id, key: const ValueKey('in'))
          : _AddButton(livre: livre, key: const ValueKey('out')),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Livre livre;
  const _AddButton({required this.livre, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Price display ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              Text(
                '${livre.prix.toStringAsFixed(2)} TND',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ── Add button ─────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final added = context.read<CartProvider>().addLivre(livre);
              if (added) {
                ToastService.showSuccess('Added to cart!');
              } else {
                ToastService.showWarning('You already own this book');
              }
            },
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Add to Cart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnedBookBanner extends StatelessWidget {
  const _OwnedBookBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You already purchased this book',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveFromCartButton extends StatelessWidget {
  final String livreId;
  const _RemoveFromCartButton({required this.livreId, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Added to cart',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.read<CartProvider>().removeLivre(livreId),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Reader Reviews Section
// ─────────────────────────────────────────────────────────────────
class _AvisListSection extends StatelessWidget {
  final List<Avis> avis;
  final double noteMoyenne;
  final int nombreAvis;
  final bool isLoading;
  final int page;
  final int pages;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;

  const _AvisListSection({
    required this.avis,
    required this.noteMoyenne,
    required this.nombreAvis,
    required this.isLoading,
    required this.page,
    required this.pages,
    this.onPrevPage,
    this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Average score summary ──────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              // Big numeric score
              Column(
                children: [
                  Text(
                    noteMoyenne.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/5',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Stars + review count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      final fill = noteMoyenne - i;
                      return Icon(
                        fill >= 1
                            ? Icons.star_rounded
                            : fill >= 0.5
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFFFC107),
                        size: 22,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$nombreAvis ${nombreAvis == 1 ? 'review' : 'reviews'}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Individual avis ────────────────────────────────
        if (isLoading) ...[
          const SizedBox(height: 16),
          const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
        ] else if (avis.isEmpty) ...[
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No reviews yet. Be the first!',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          ...avis.map((a) => _AvisCard(avis: a)),
          if (pages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onPrevPage,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Page $page / $pages',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onNextPage,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _AvisCard extends StatelessWidget {
  final Avis avis;
  const _AvisCard({required this.avis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + date + stars ───────────
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  (avis.clientNom?.isNotEmpty == true
                          ? avis.clientNom![0]
                          : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avis.clientNom ?? 'Anonymous',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (avis.createdAt != null)
                      Text(
                        _formatDate(avis.createdAt!),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              // Star rating chips
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < avis.note
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFC107),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          // ── Comment body ───────────────────────────────────
          if (avis.commentaire.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              avis.commentaire,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────
// Star Rating Section
// ─────────────────────────────────────────────────────────────────
class _StarRatingSection extends StatelessWidget {
  final int selectedRating;
  final bool isSubmitting;
  final ValueChanged<int> onRatingChanged;

  const _StarRatingSection({
    required this.selectedRating,
    required this.isSubmitting,
    required this.onRatingChanged,
  });

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: isSubmitting ? null : () => onRatingChanged(star),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  star <= selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  key: ValueKey('$star-${star <= selectedRating}'),
                  color: star <= selectedRating
                      ? const Color(0xFFFFC107)
                      : AppColors.textMuted,
                  size: 42,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        if (isSubmitting)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selectedRating == 0
                ? const Text(
                    'Tap a star to rate',
                    key: ValueKey('none'),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  )
                : Text(
                    _labels[selectedRating],
                    key: ValueKey(selectedRating),
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Comment / Avis Section
// ─────────────────────────────────────────────────────────────────
class _CommentSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final bool isDeleting;
  final bool hasExistingReview;
  final Future<void> Function() onSubmit;
  final Future<void> Function()? onDelete;

  const _CommentSection({
    required this.controller,
    required this.isSubmitting,
    required this.isDeleting,
    required this.hasExistingReview,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 500,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Share your thoughts about this book…',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.surface,
            counterStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textMuted.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textMuted.withOpacity(0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                label: Text(
                  hasExistingReview ? 'Update Review' : 'Submit Review',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Reusable section divider
// ─────────────────────────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textMuted.withOpacity(0.25),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textMuted.withOpacity(0.25),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
