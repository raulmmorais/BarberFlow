import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus agendamentos')),
      body: const Center(
        child: Text('Lista de agendamentos — Sprint 3'),
      ),
    );
  }
}
