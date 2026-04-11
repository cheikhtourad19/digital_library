import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:digital_library/service/livre_service.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:digital_library/ui/components/cards/book_info_card.dart';
import 'package:digital_library/ui/components/cards/pdf_preview_card.dart';
import 'package:digital_library/ui/components/modals/app_modal.dart';
import 'package:flutter/material.dart';

class AdminBookDetailPage extends StatefulWidget {
  final String livreId;

  const AdminBookDetailPage({super.key, required this.livreId});

  @override
  State<AdminBookDetailPage> createState() => _AdminBookDetailPageState();
}

class _AdminBookDetailPageState extends State<AdminBookDetailPage> {
  final LivreService _livreService = getIt<LivreService>();

  Livre? _livre;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchLivre();
  }

  Future<void> _fetchLivre() async {
    setState(() => _isLoading = true);
    try {
      final livre = await _livreService.fetchLivreById(widget.livreId);
      if (!mounted) {
        return;
      }
      setState(() => _livre = livre);
    } catch (_) {
      ToastService.showError('Failed to load book details');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    showAppModal(
      context: context,
      title: 'Delete book',
      subtitle: 'This action cannot be undone',
      content: const Text('Do you want to permanently delete this book?'),
      actions: [
        AppButton.secondary(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.danger(
          label: 'Delete',
          icon: Icons.delete_rounded,
          onPressed: _isDeleting ? null : _deleteBook,
        ),
      ],
    );
  }

  Future<void> _deleteBook() async {
    setState(() => _isDeleting = true);
    try {
      await _livreService.supprimerLivre(widget.livreId);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.showSuccess('Book deleted successfully');
      Navigator.of(context).pop(true);
    } catch (_) {
      ToastService.showError('Failed to delete book');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
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
          'Book details',
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
                BookInfoCard(livre: _livre!),
                const SizedBox(height: 14),
                AppButton.danger(
                  label: 'Delete book',
                  icon: Icons.delete_rounded,
                  expand: true,
                  onPressed: _confirmDelete,
                ),
                const SizedBox(height: 14),
                PdfPreviewCard(livreId: widget.livreId),
              ],
            ),
    );
  }
}
