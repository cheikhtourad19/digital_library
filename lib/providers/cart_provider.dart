import 'package:flutter/material.dart';
import 'package:digital_library/core/di/injection.dart';
import 'package:digital_library/models/livre_model.dart';
import 'package:digital_library/service/commande_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';

class CartItem {
  final Livre livre;

  CartItem({required this.livre});
}

class CartProvider extends ChangeNotifier with WidgetsBindingObserver {
  final List<CartItem> _items = [];
  final Set<String> _ownedLivreIds = <String>{};
  final CommandeService _commandeService = getIt<CommandeService>();

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.length;

  bool contains(String livreId) =>
      _items.any((item) => item.livre.id == livreId);

  bool isOwned(String livreId) => _ownedLivreIds.contains(livreId);

  bool addLivre(Livre livre) {
    if (isOwned(livre.id) || contains(livre.id)) {
      return false;
    }
    if (!contains(livre.id)) {
      _items.add(CartItem(livre: livre));
      _saveCart();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeLivre(String livreId) {
    _items.removeWhere((item) => item.livre.id == livreId);
    _saveCart();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.livre.prix);

  SharedPreferences? _prefs;

  CartProvider() {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveCart();
    }
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCart();
    await refreshOwnedBooks();
  }

  void _loadCart() {
    if (_prefs == null) return;
    List<String>? cartData = _prefs!.getStringList('cart');
    if (cartData != null) {
      _items.clear();
      for (String json in cartData) {
        Map<String, dynamic> livreData = jsonDecode(json);
        Livre livre = Livre.fromJson(livreData);
        _items.add(CartItem(livre: livre));
      }
      notifyListeners();
    }
  }

  Future<void> refreshOwnedBooks() async {
    try {
      final result = await _commandeService.getMyBooks();
      _ownedLivreIds
        ..clear()
        ..addAll(result.livres.map((item) => item.id));
      _removeOwnedBooksFromCart();
      notifyListeners();
    } catch (_) {
      // Keep local cart behavior if request fails.
    }
  }

  void _removeOwnedBooksFromCart() {
    final before = _items.length;
    _items.removeWhere((item) => _ownedLivreIds.contains(item.livre.id));
    if (_items.length != before) {
      _saveCart();
    }
  }

  Future<void> _saveCart() async {
    if (_prefs == null) return;
    List<String> cartData = _items.map((item) {
      return jsonEncode(item.livre.toJson());
    }).toList();
    await _prefs!.setStringList('cart', cartData);
  }
}
