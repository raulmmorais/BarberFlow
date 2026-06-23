import 'package:barberflow/domain/entities/servico.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.servico,
    required this.isSelected,
    required this.onTap,
  });

  final Servico servico;
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
        title: Text(servico.nome),
        subtitle: Text(
          'R\$ ${servico.preco.toStringAsFixed(2)} · ${servico.duracaoMinutos} min',
        ),
        trailing: isSelected ? const Icon(Icons.check_circle) : null,
        onTap: onTap,
      ),
    );
  }
}
