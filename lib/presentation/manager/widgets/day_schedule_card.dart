import 'package:flutter/material.dart';

class DayScheduleCard extends StatelessWidget {
  const DayScheduleCard({
    super.key,
    required this.horario,
    required this.clienteNome,
    required this.servicos,
    this.hasConflict = false,
  });

  final String horario;
  final String clienteNome;
  final String servicos;
  final bool hasConflict;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: hasConflict
          ? Theme.of(context).colorScheme.errorContainer
          : null,
      child: ListTile(
        title: Text('$horario — $clienteNome'),
        subtitle: Text(servicos),
        trailing: hasConflict ? const Icon(Icons.warning_amber) : null,
      ),
    );
  }
}
