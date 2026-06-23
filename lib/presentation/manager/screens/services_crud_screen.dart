import 'package:flutter/material.dart';

class ServicesCrudScreen extends StatelessWidget {
  const ServicesCrudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      body: const Center(
        child: Text('CRUD de serviços — Sprint 2'),
      ),
    );
  }
}
