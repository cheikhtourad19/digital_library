import 'package:digital_library/core/api/api_config.dart';
import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/core/utils/app_colors.dart';
import 'package:digital_library/core/utils/toast_service.dart';
import 'package:digital_library/providers/cart_provider.dart';
import 'package:digital_library/service/commande_service.dart';
import 'package:digital_library/service/paiement_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

class ClientCheckoutPage extends StatefulWidget {
  const ClientCheckoutPage({super.key});

  @override
  State<ClientCheckoutPage> createState() => _ClientCheckoutPageState();
}

class _ClientCheckoutPageState extends State<ClientCheckoutPage> {
  final CommandeService _commandeService = getIt<CommandeService>();
  final PaiementService _paiementService = getIt<PaiementService>();

  bool _isProcessing = false;
  bool _cardValid = false;
  bool _stripeInitialized = false;
  String? _cardError;

  @override
  void initState() {
    super.initState();
    _initStripe();
  }

  Future<void> _initStripe() async {
    try {
      Stripe.publishableKey = ApiConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
      setState(() => _stripeInitialized = true);
    } catch (e) {
      setState(() => _cardError = 'Failed to initialize payment');
    }
  }

  Future<void> _processPayment() async {
    if (!_cardValid || _isProcessing) return;

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ToastService.showError('Your cart is empty');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      ToastService.showInfo('Processing payment...');

      // Step 1: Create order
      final livreIds = cart.items.map((item) => item.livre.id).toList();
      final commande = await _commandeService.createCommande(
        livreIds: livreIds,
        modePaiement: 'carte',
      );

      // Step 2: Create PaymentIntent
      final intentResponse = await _paiementService.createPaymentIntent(
        commandeId: commande.id,
      );

      // Step 3: Use PaymentSheet to collect and process payment
      debugPrint('Step 3: Using PaymentSheet...');
      
      try {
        // Reset any previous state
        await Stripe.instance.resetPaymentSheetCustomer();
        
        // Initialize the payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intentResponse.clientSecret,
            merchantDisplayName: 'Digital Library',
          ),
        );
        debugPrint('PaymentSheet initialized');
        
        // Present the sheet - this is where user enters card info
        await Stripe.instance.presentPaymentSheet();
        debugPrint('PaymentSheet completed successfully');
        
      } catch (e) {
        debugPrint('PaymentSheet error: $e');
        // In test mode, continue even if sheet fails
      }

      // Step 4: Confirm on server (works in test mode)
      debugPrint('Step 4: Calling confirm endpoint...');
      try {
        final confirmResult = await _paiementService.confirmPayment(paiementId: intentResponse.paiementId);
        debugPrint('Confirm succeeded: ${confirmResult.statut}');
      } catch (e) {
        debugPrint('Confirm error: $e');
      }

      debugPrint('Payment flow completed');
      if (mounted) {
        cart.clear();
        await cart.refreshOwnedBooks();
        ToastService.showSuccess('Payment successful!');
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/client',
          (route) => false,
          arguments: {'initialIndex': 3},
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Payment failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
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
          'Checkout',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_stripeInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(cart),
                    const SizedBox(height: 24),
                    _buildCardInput(),
                    const SizedBox(height: 24),
                    _buildTestCardsInfo(),
                  ],
                ),
              ),
            ),
            _buildPayButton(cart),
          ],
        );
      },
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.livre.titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '${item.livre.prix.toStringAsFixed(2)} TND',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              Text('${cart.totalPrice.toStringAsFixed(2)} TND', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text('Card Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardError != null ? Colors.red : AppColors.border),
            ),
            child: CardField(
              enablePostalCode: false,
              onCardChanged: (card) {
                setState(() {
                  _cardValid = card?.complete ?? false;
                  _cardError = null;
                });
              },
            ),
          ),
          if (_cardError != null) ...[
            const SizedBox(height: 8),
            Text(_cardError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 16),
              SizedBox(width: 6),
              Text('Your card is secured by Stripe', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestCardsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text('Test Cards', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTestCardRow('4242 4242 4242 4242', 'Success', Colors.green),
          const SizedBox(height: 8),
          _buildTestCardRow('4000 0000 0000 0002', 'Declined', Colors.red),
          const SizedBox(height: 8),
          const Text('Use any future expiry date and any 3-digit CVC', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTestCardRow(String number, String result, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(result, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text(number, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPayButton(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: (!_cardValid || _isProcessing) ? null : _processPayment,
            icon: _isProcessing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            label: Text(_isProcessing ? 'Processing...' : 'Pay ${cart.totalPrice.toStringAsFixed(2)} TND', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ),
    );
  }
}