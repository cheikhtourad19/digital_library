import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/models/lecture_model.dart';
import 'package:digital_library/service/lecture_service.dart';
import 'package:digital_library/ui/components/cards/pdf_preview_card.dart';
import 'package:flutter/material.dart';

class ClientReadBookPage extends StatefulWidget {
  final String livreId;
  final int startPage;

  const ClientReadBookPage({super.key, required this.livreId, this.startPage = 0});

  @override
  State<ClientReadBookPage> createState() => _ClientReadBookPageState();
}

class _ClientReadBookPageState extends State<ClientReadBookPage> {
  final LectureService _lectureService = getIt<LectureService>();
  
  int _initialPage = 0;
  bool _isLoading = true;
  int _lastSavedPage = -1;
  Lecture? _lecture;

  @override
  void initState() {
    super.initState();
    _loadLecture();
  }

  Future<void> _loadLecture() async {
    try {
      final lecture = await _lectureService.getLectureByLivre(widget.livreId);
      if (mounted) {
        setState(() {
          _lecture = lecture;
          _initialPage = lecture?.dernierePage != null ? lecture!.dernierePage - 1 : widget.startPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialPage = widget.startPage;
          _isLoading = false;
        });
      }
    }
  }

  void _onPageChanged(int page) {
    if (page == 0 || page == _lastSavedPage) {
      return;
    }
    _lastSavedPage = page;
    _lectureService.updateLecture(
      livreId: widget.livreId,
      dermierePage: page + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          _lecture?.livreTitre ?? 'Read Book',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_added_rounded),
            tooltip: 'Mark as finished',
            onPressed: () async {
              try {
                await _lectureService.updateLecture(livreId: widget.livreId, termine: true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book marked as finished')),
                  );
                }
              } catch (_) {}
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PdfPreviewCard(
                  livreId: widget.livreId,
                  initialPage: _initialPage,
                  onPageChanged: _onPageChanged,
                ),
              ],
            ),
    );
  }
}