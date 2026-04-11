import 'package:flutter/material.dart';

class ClientCartPage extends StatefulWidget {
  const ClientCartPage({super.key});

  @override
  State<ClientCartPage> createState() => _ClientCartPageState();
}

class _ClientCartPageState extends State<ClientCartPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(
        child: Text(
          'Panier 1!!!!!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
