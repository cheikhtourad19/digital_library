import 'package:flutter/material.dart';

class ClientBooksPage extends StatelessWidget {
  const ClientBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Client Books',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
