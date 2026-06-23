import 'package:flutter/material.dart';

class MensalidadeScreen extends StatelessWidget {
  const MensalidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensalidade')),
      body: const Center(
        child: Text('Status da mensalidade — Sprint 6'),
      ),
    );
  }
}
