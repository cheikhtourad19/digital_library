import 'package:flutter/material.dart';

class ClientFavoritesPage extends StatelessWidget {
  const ClientFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Client Favorites',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
