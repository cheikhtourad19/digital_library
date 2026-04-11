import 'dart:io';

import 'package:dio/dio.dart';
import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/service/livre_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfPreviewCard extends StatefulWidget {
  final String livreId;

  const PdfPreviewCard({super.key, required this.livreId});

  @override
  State<PdfPreviewCard> createState() => _PdfPreviewCardState();
}

class _PdfPreviewCardState extends State<PdfPreviewCard> {
  final LivreService _livreService = getIt<LivreService>();
  final TransformationController _transformationController =
      TransformationController();

  PDFViewController? _pdfController;
  bool _isLoading = true;
  String? _localPdfPath;
  String? _pdfTitle;
  String? _error;
  double _zoomLevel = 1.0;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdfPreview();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfPreview() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pdfController = null;
      _currentPage = 0;
      _totalPages = 0;
    });

    try {
      final lireResult = await _livreService.getLivrePdfUrl(widget.livreId);
      final response = await Dio().get<List<int>>(
        lireResult.url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Empty PDF content');
      }

      final file = File(
        '${Directory.systemTemp.path}/preview_${widget.livreId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) {
        return;
      }

      setState(() {
        _localPdfPath = file.path;
        _pdfTitle = lireResult.titre;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Unable to load PDF preview';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _zoomIn() {
    final next = (_zoomLevel + 0.2).clamp(1.0, 3.0);
    _applyZoom(next);
  }

  void _zoomOut() {
    final next = (_zoomLevel - 0.2).clamp(1.0, 3.0);
    _applyZoom(next);
  }

  void _resetZoom() {
    _applyZoom(1.0);
  }

  void _applyZoom(double zoom) {
    setState(() => _zoomLevel = zoom);
    _transformationController.value = Matrix4.identity()..scale(zoom);
  }

  Future<void> _goToPreviousPage() async {
    if (_pdfController == null || _currentPage <= 0) {
      return;
    }
    await _pdfController!.setPage(_currentPage - 1);
  }

  Future<void> _goToNextPage() async {
    if (_pdfController == null || _currentPage >= _totalPages - 1) {
      return;
    }
    await _pdfController!.setPage(_currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pdfTitle ?? 'PDF Preview',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadPdfPreview,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Reload preview',
                ),
                IconButton(
                  onPressed: _isLoading ? null : _zoomOut,
                  icon: const Icon(Icons.zoom_out_rounded),
                  tooltip: 'Zoom out',
                ),
                IconButton(
                  onPressed: _isLoading ? null : _zoomIn,
                  icon: const Icon(Icons.zoom_in_rounded),
                  tooltip: 'Zoom in',
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: _previewHeight(context), child: _buildContent()),
        ],
      ),
    );
  }

  double _previewHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicHeight = screenHeight * 0.68;
    return dynamicHeight.clamp(460.0, 720.0);
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_localPdfPath == null) {
      return const Center(
        child: Text(
          'No preview available',
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1,
            maxScale: 3,
            panEnabled: true,
            scaleEnabled: true,
            child: PDFView(
              filePath: _localPdfPath!,
              autoSpacing: true,
              enableSwipe: true,
              swipeHorizontal: false,
              onViewCreated: (controller) {
                _pdfController = controller;
              },
              onRender: (pages) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _totalPages = pages ?? 0;
                  _currentPage = 0;
                });
              },
              onPageChanged: (page, total) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _currentPage = page ?? 0;
                  _totalPages = total ?? _totalPages;
                });
              },
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: _resetZoom,
              child: Text(
                '${(_zoomLevel * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        if (_totalPages > 0)
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.85),
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.surface,
                    ),
                    tooltip: 'Previous page',
                  ),
                  Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? _goToNextPage
                        : null,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.surface,
                    ),
                    tooltip: 'Next page',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
