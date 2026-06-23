import 'package:flutter/material.dart';

class BookingDateTimeScreen extends StatelessWidget {
  const BookingDateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data e horário')),
      body: const Center(
        child: Text('Seleção de data/horário — Sprint 3'),
      ),
    );
  }
}
