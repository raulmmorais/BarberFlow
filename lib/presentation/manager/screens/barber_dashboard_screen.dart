import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/core/utils/date_utils.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/manager/providers/barber_dashboard_provider.dart';
import 'package:barberflow/presentation/manager/widgets/day_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BarberDashboardScreen extends StatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  State<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuario = context.read<AuthProvider>().usuario!;
      context.read<BarberDashboardProvider>().init(
            usuario.uid,
            usuario.idEstabelecimento,
          );
    });
  }

  Future<void> _dialogConcluir(
      BuildContext context, String agendamentoId) async {
    final comentarioController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Concluir atendimento'),
        content: TextField(
          controller: comentarioController,
          decoration: const InputDecoration(
            labelText: 'Observação interna (opcional)',
            hintText: 'Ex: cliente satisfeito, próxima visita em 3 semanas',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<BarberDashboardProvider>();
    final ok = await provider.concluir(
      agendamentoId,
      comentario: comentarioController.text.trim().isEmpty
          ? null
          : comentarioController.text.trim(),
    );

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erro ao concluir.')),
      );
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final provider = context.read<BarberDashboardProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.dataSelecionada,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && context.mounted) {
      provider.irParaDia(picked);
    }
  }

  void _mostrarMenuGestao(BuildContext context) {
    final usuario = context.read<AuthProvider>().usuario!;
    final isDono = usuario.tipo == TipoUsuario.dono;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Mensalistas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(RouteNames.mensalistas);
              },
            ),
            if (isDono) ...[
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Estabelecimento'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed(RouteNames.ownerEstablishment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.design_services),
                title: const Text('Serviços'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(RouteNames.servicesCrud);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Profissionais'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(RouteNames.barbersCrud);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario!;
    final provider = context.watch<BarberDashboardProvider>();
    final dataFormatada = DateFormat('EEE, d MMM', 'pt_BR')
        .format(provider.dataSelecionada);
    final isHoje = AppDateUtils.isSameDay(
        provider.dataSelecionada, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Gerenciar',
            onPressed: () => _mostrarMenuGestao(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Navegação de data ────────────────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: provider.voltarDia,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selecionarData(context),
                    child: Column(
                      children: [
                        Text(
                          dataFormatada,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        if (isHoje)
                          Text(
                            'Hoje',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: provider.avancarDia,
                ),
              ],
            ),
          ),

          // ── Lista de agendamentos ────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.agendamentos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_available,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum agendamento\npara este dia.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.agendamentos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final a = provider.agendamentos[index];
                          return DayScheduleCard(
                            horario: AppDateUtils.formatTime(a.dataHora),
                            clienteNome: provider.nomeCliente(a),
                            servicos: provider.nomesServicos(a),
                            duracaoMinutos: a.duracaoTotalMinutos,
                            status: a.status,
                            hasConflict: provider.temConflito(a),
                            isActing: provider.isActing,
                            onConcluir: () =>
                                _dialogConcluir(context, a.id),
                            onConfirm: () async {
                              final ok =
                                  await provider.confirmar(a.id);
                              if (!context.mounted) return;
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(provider.error ??
                                          'Erro ao confirmar.')),
                                );
                              }
                            },
                            onReject: () async {
                              final ok =
                                  await provider.recusar(a.id);
                              if (!context.mounted) return;
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(provider.error ??
                                          'Erro ao recusar.')),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),

          // ── Boas vindas ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Olá, ${usuario.nome}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(RouteNames.manualBooking),
        icon: const Icon(Icons.person_add),
        label: const Text('Ag. manual'),
      ),
    );
  }
}
