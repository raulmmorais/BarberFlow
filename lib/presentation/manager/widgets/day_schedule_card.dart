import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:flutter/material.dart';

class DayScheduleCard extends StatelessWidget {
  const DayScheduleCard({
    super.key,
    required this.horario,
    required this.clienteNome,
    required this.servicos,
    required this.duracaoMinutos,
    required this.status,
    this.hasConflict = false,
    this.onConfirm,
    this.onReject,
    this.isActing = false,
  });

  final String horario;
  final String clienteNome;
  final String servicos;
  final int duracaoMinutos;
  final AgendamentoStatus status;
  final bool hasConflict;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool isActing;

  Color _corStatus(BuildContext context) => switch (status) {
        AgendamentoStatus.pendente => Colors.orange,
        AgendamentoStatus.confirmado => Colors.green,
        AgendamentoStatus.concluido => Theme.of(context).colorScheme.primary,
        AgendamentoStatus.recusado => Colors.red,
      };

  String _labelStatus() => switch (status) {
        AgendamentoStatus.pendente => 'Pendente',
        AgendamentoStatus.confirmado => 'Confirmado',
        AgendamentoStatus.concluido => 'Concluído',
        AgendamentoStatus.recusado => 'Recusado',
      };

  @override
  Widget build(BuildContext context) {
    final cor = _corStatus(context);
    final isPendente = status == AgendamentoStatus.pendente;

    return Card(
      color: hasConflict ? Theme.of(context).colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho ──────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  horario,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  clienteNome,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (hasConflict)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.warning_amber, color: Colors.deepOrange),
                  ),
                Chip(
                  label: Text(
                    _labelStatus(),
                    style: TextStyle(
                        color: cor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  side: BorderSide(color: cor),
                  backgroundColor: cor.withOpacity(0.08),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),

            // ── Detalhes ───────────────────────────────────────────────────
            const SizedBox(height: 4),
            Text(servicos,
                style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '$duracaoMinutos min',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            // ── Botões de ação (somente pendentes) ──────────────────────────
            if (isPendente) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        onPressed: isActing ? null : onConfirm,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Recusar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.error,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                        ),
                        onPressed: isActing ? null : onReject,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
