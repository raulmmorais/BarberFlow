import 'package:flutter/material.dart';

class ManualBookingScreen extends StatelessWidget {
  const ManualBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento manual')),
      body: const Center(
        child: Text('Agendamento para clientes sem app — Sprint 4'),
      ),
    );
  }
}
