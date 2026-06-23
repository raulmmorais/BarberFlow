import 'package:flutter/material.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      body: const Center(
        child: Text('Configuração de lembretes — Sprint 6'),
      ),
    );
  }
}
