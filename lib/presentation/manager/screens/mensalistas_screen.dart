import 'package:flutter/material.dart';

class MensalistasScreen extends StatelessWidget {
  const MensalistasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensalistas')),
      body: const Center(
        child: Text('Controle de mensalistas — Sprint 6'),
      ),
    );
  }
}
