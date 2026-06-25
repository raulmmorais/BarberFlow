import 'package:barberflow/core/utils/date_utils.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/client/providers/client_appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().usuario!.uid;
      context.read<ClientAppointmentsProvider>().watch(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientAppointmentsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus agendamentos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.agendamentos.isEmpty
              ? const Center(
                  child: Text('Você ainda não possui agendamentos.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.agendamentos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _AgendamentoCard(
                        agendamento: provider.agendamentos[index]);
                  },
                ),
    );
  }
}

class _AgendamentoCard extends StatelessWidget {
  const _AgendamentoCard({required this.agendamento});

  final Agendamento agendamento;

  Color _corStatus(BuildContext context) {
    return switch (agendamento.status) {
      AgendamentoStatus.pendente => Colors.orange,
      AgendamentoStatus.confirmado => Colors.green,
      AgendamentoStatus.concluido =>
        Theme.of(context).colorScheme.primary,
      AgendamentoStatus.recusado => Colors.red,
    };
  }

  String _labelStatus() {
    return switch (agendamento.status) {
      AgendamentoStatus.pendente => 'Pendente',
      AgendamentoStatus.confirmado => 'Confirmado',
      AgendamentoStatus.concluido => 'Concluído',
      AgendamentoStatus.recusado => 'Recusado',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corStatus(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppDateUtils.formatDateTime(agendamento.dataHora),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(
                    _labelStatus(),
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                  ),
                  side: BorderSide(color: cor),
                  backgroundColor: cor.withOpacity(0.08),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Duração: ${agendamento.duracaoTotalMinutos} min'),
            if (agendamento.status == AgendamentoStatus.concluido &&
                agendamento.comentarioPosCorte != null) ...[
              const SizedBox(height: 4),
              Text(
                '"${agendamento.comentarioPosCorte}"',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
