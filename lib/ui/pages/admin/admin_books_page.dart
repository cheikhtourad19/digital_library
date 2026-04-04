import 'package:flutter/material.dart';

class AdminBooksPage extends StatelessWidget {
  const AdminBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Admin Books Management',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
