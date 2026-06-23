import 'package:flutter/material.dart';

class BarbersCrudScreen extends StatelessWidget {
  const BarbersCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profissionais')),
      body: const Center(
        child: Text('CRUD de barbeiros — Sprint 2'),
      ),
    );
  }
}
