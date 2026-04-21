import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/categorie_model.dart';
import 'package:digital_library/service/categorie_service.dart';
import 'package:digital_library/service/livre_service.dart';
import 'package:digital_library/ui/components/buttons/app_button.dart';
import 'package:digital_library/ui/components/modals/app_modal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminCreateBookPage extends StatefulWidget {
  const AdminCreateBookPage({super.key});

  @override
  State<AdminCreateBookPage> createState() => _AdminCreateBookPageState();
}

class _AdminCreateBookPageState extends State<AdminCreateBookPage> {
  final LivreService _livreService = getIt<LivreService>();
  final CategorieService _categorieService = getIt<CategorieService>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titreCtrl = TextEditingController();
  final TextEditingController _auteursCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _prixCtrl = TextEditingController();
  final TextEditingController _newCategorieNomCtrl = TextEditingController();
  final TextEditingController _newCategorieDescCtrl = TextEditingController();

  List<Categorie> _categories = const <Categorie>[];
  String? _selectedCategorieId;
  bool _isLoadingCategories = true;
  bool _isCreatingCategorie = false;

  String? _selectedLanguage;
  DateTime? _selectedPublicationDate;

  List<int>? _pdfBytes;
  String? _pdfFileName;
  List<int>? _coverBytes;
  String? _coverFileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _auteursCtrl.dispose();
    _descriptionCtrl.dispose();
    _prixCtrl.dispose();
    _newCategorieNomCtrl.dispose();
    _newCategorieDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _categorieService.fetchCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = categories;
        if (_selectedCategorieId == null && categories.isNotEmpty) {
          _selectedCategorieId = categories.first.id;
        }
      });
    } catch (_) {
      ToastService.showError('Failed to load categories');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _openCreateCategorieModal() {
    _newCategorieNomCtrl.clear();
    _newCategorieDescCtrl.clear();

    showAppModal(
      context: context,
      title: 'Create Category',
      subtitle: 'Admin only action',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _newCategorieNomCtrl,
            decoration: const InputDecoration(labelText: 'Name *'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newCategorieDescCtrl,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        AppButton.secondary(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: 'Create',
          icon: Icons.add_rounded,
          isLoading: _isCreatingCategorie,
          onPressed: _isCreatingCategorie ? null : _createCategorie,
        ),
      ],
    );
  }

  Future<void> _createCategorie() async {
    final nom = _newCategorieNomCtrl.text.trim();
    if (nom.isEmpty) {
      ToastService.showWarning('Category name is required');
      return;
    }

    setState(() => _isCreatingCategorie = true);
    try {
      final created = await _categorieService.createCategorie(
        nom: nom,
        description: _newCategorieDescCtrl.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ToastService.showSuccess('Category created');

      await _fetchCategories();
      if (!mounted) {
        return;
      }
      setState(() => _selectedCategorieId = created.id);
    } catch (_) {
      ToastService.showError('Failed to create category');
    } finally {
      if (mounted) {
        setState(() => _isCreatingCategorie = false);
      }
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    if (file.bytes == null) {
      ToastService.showError('Unable to read selected PDF');
      return;
    }

    setState(() {
      _pdfBytes = file.bytes;
      _pdfFileName = file.name;
    });
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    if (file.bytes == null) {
      ToastService.showError('Unable to read selected image');
      return;
    }

    setState(() {
      _coverBytes = file.bytes;
      _coverFileName = file.name;
    });
  }

  Future<void> _pickPublicationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPublicationDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedPublicationDate = picked);
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ToastService.showWarning('Please complete required fields');
      return;
    }

    if (_pdfBytes == null || _pdfFileName == null) {
      ToastService.showWarning('Please choose a PDF file');
      return;
    }

    if (_coverBytes == null || _coverFileName == null) {
      ToastService.showWarning('Please choose a cover image');
      return;
    }

    final prix = double.tryParse(_prixCtrl.text.trim());

    if (prix == null) {
      ToastService.showWarning('Price must be a valid number');
      return;
    }

    if (_selectedCategorieId == null || _selectedCategorieId!.isEmpty) {
      ToastService.showWarning('Please select a category');
      return;
    }

    final auteurs = _auteursCtrl.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (auteurs.isEmpty) {
      ToastService.showWarning('At least one author is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _livreService.creerLivre(
        titre: _titreCtrl.text.trim(),
        auteur: auteurs,
        description: _descriptionCtrl.text.trim(),
        categorie: _selectedCategorieId!,
        prix: prix,
        langue: _selectedLanguage ?? '',
        datePublication: _selectedPublicationDate,
        pdfBytes: _pdfBytes!,
        pdfFileName: _pdfFileName!,
        couvertureBytes: _coverBytes!,
        couvertureFileName: _coverFileName!,
      );

      if (!mounted) {
        return;
      }
      ToastService.showSuccess('Book created successfully');
      Navigator.of(context).pop(true);
    } catch (_) {
      ToastService.showError('Failed to create book');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Create Book',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_titreCtrl, 'Title *'),
            const SizedBox(height: 10),
            _field(
              _auteursCtrl,
              'Authors * (comma separated)',
              hint: 'Author 1, Author 2',
            ),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 10),
            _buildLanguageSelector(),
            const SizedBox(height: 10),
            _field(
              _prixCtrl,
              'Price *',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 10),
            _buildPublicationDatePicker(),
            const SizedBox(height: 10),
            _field(_descriptionCtrl, 'Description *', maxLines: 5),
            const SizedBox(height: 14),
            _filePickerCard(
              label: 'PDF file *',
              fileName: _pdfFileName,
              icon: Icons.picture_as_pdf_rounded,
              onPick: _pickPdf,
            ),
            const SizedBox(height: 10),
            _filePickerCard(
              label: 'Cover image *',
              fileName: _coverFileName,
              icon: Icons.image_rounded,
              onPick: _pickCover,
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'Create Book',
              icon: Icons.save_rounded,
              expand: true,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (label.contains('*') && (value == null || value.trim().isEmpty)) {
          return 'Required field';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _filePickerCard({
    required String label,
    required String? fileName,
    required IconData icon,
    required Future<void> Function() onPick,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName ?? label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fileName == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppButton.secondary(label: 'Choose', onPressed: () => onPick()),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_isLoadingCategories) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCategorieId,
            isExpanded: true,
            hint: const Text('Select a category'),
            items: _categories
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.nom),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedCategorieId = value),
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AppButton.secondary(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onPressed: _fetchCategories,
              ),
              const SizedBox(width: 10),
              AppButton.primary(
                label: 'New category',
                icon: Icons.add_rounded,
                onPressed: _openCreateCategorieModal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final languages = [
      'English',
      'French',
      'Spanish',
      'Arabic',
      'German',
      'Chinese',
      'Japanese',
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Language *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            isExpanded: true,
            hint: const Text('Select a language'),
            items: languages
                .map(
                  (lang) =>
                      DropdownMenuItem<String>(value: lang, child: Text(lang)),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedLanguage = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Language is required';
              }
              return null;
            },
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicationDatePicker() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Publication Date',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickPublicationDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedPublicationDate != null
                        ? '${_selectedPublicationDate!.year}-${_selectedPublicationDate!.month.toString().padLeft(2, '0')}-${_selectedPublicationDate!.day.toString().padLeft(2, '0')}'
                        : 'Select a date',
                    style: TextStyle(
                      color: _selectedPublicationDate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
