import 'package:barberflow/domain/entities/usuario.dart';
import 'package:flutter/material.dart';

class BarberCard extends StatelessWidget {
  const BarberCard({
    super.key,
    required this.barbeiro,
    required this.isSelected,
    required this.onTap,
  });

  final Usuario barbeiro;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            barbeiro.nome.isNotEmpty ? barbeiro.nome[0].toUpperCase() : '?',
          ),
        ),
        title: Text(barbeiro.nome),
        subtitle: Text(barbeiro.telefone),
        trailing: isSelected ? const Icon(Icons.check_circle) : null,
        onTap: onTap,
      ),
    );
  }
}
