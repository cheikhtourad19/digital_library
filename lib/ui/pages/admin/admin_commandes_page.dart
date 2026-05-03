import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/models/commande_model.dart';
import 'package:digital_library/service/commande_service.dart';
import 'package:flutter/material.dart';

class AdminCommandesPage extends StatefulWidget {
  const AdminCommandesPage({super.key});

  @override
  State<AdminCommandesPage> createState() => _AdminCommandesPageState();
}

class _AdminCommandesPageState extends State<AdminCommandesPage> {
  final CommandeService _commandeService = getIt<CommandeService>();
  final TextEditingController _clientIdCtrl = TextEditingController();
  bool _isLoading = true;
  List<Commande> _commandes = const <Commande>[];
  int _page = 1;
  int _pages = 1;
  int _total = 0;
  final int _limite = 20;
  String? _selectedStatut;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch({int? targetPage}) async {
    setState(() {
      _isLoading = true;
      if (targetPage != null) {
        _page = targetPage;
      }
    });
    try {
      final result = await _commandeService.getAllCommandes(
        page: _page,
        limite: _limite,
        statut: _selectedStatut,
        clientId: _clientIdCtrl.text.trim().isEmpty ? null : _clientIdCtrl.text.trim(),
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
        ToastService.showError('Failed to load orders');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeStatus(Commande commande, String statut) async {
    try {
      final updated = await _commandeService.updateCommandeStatus(
        id: commande.id,
        statut: statut,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        final idx = _commandes.indexWhere((item) => item.id == updated.id);
        if (idx >= 0) {
          _commandes[idx] = updated;
        }
      });
      ToastService.showSuccess('Order status updated');
    } catch (_) {
      if (mounted) {
        ToastService.showError('Failed to update order status');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(onRefresh: () => _fetch(targetPage: 1), child: _buildBody()),
          ),
          if (!_isLoading) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _clientIdCtrl,
            decoration: InputDecoration(
              hintText: 'Filter by client ID',
              isDense: true,
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
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatut,
                  decoration: InputDecoration(
                    hintText: 'Status',
                    isDense: true,
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
                  ),
                  items: const [
                    DropdownMenuItem<String>(value: null, child: Text('All status')),
                    DropdownMenuItem<String>(value: 'en_attente', child: Text('en_attente')),
                    DropdownMenuItem<String>(value: 'confirmée', child: Text('confirmée')),
                    DropdownMenuItem<String>(value: 'échouée', child: Text('échouée')),
                    DropdownMenuItem<String>(value: 'remboursée', child: Text('remboursée')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatut = value),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _fetch(targetPage: 1),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$_total orders',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
                      '#${commande.id.substring(0, commande.id.length.clamp(0, 8))} • ${commande.clientNom ?? commande.client}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${commande.montantTotal.toStringAsFixed(2)} TND',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${commande.livres.length} book(s) • ${commande.modePaiement}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: CommandeStatutMapper.toJson(commande.statut),
                      decoration: InputDecoration(
                        isDense: true,
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
                      ),
                      items: const [
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
                      onChanged: (value) {
                        if (value != null) {
                          _changeStatus(commande, value);
                        }
                      },
                    ),
                  ),
                ],
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
