import 'package:barberflow/core/utils/date_utils.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/manager/providers/manual_booking_provider.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManualBookingScreen extends StatefulWidget {
  const ManualBookingScreen({super.key});

  @override
  State<ManualBookingScreen> createState() => _ManualBookingScreenState();
}

class _ManualBookingScreenState extends State<ManualBookingScreen> {
  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuario = context.read<AuthProvider>().usuario!;
      context.read<ManualBookingProvider>().init(
            usuario.idEstabelecimento,
            usuario.uid,
          );
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final provider = context.read<ManualBookingProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.data ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked == null || !context.mounted) return;

    provider.selectData(picked);

    final estab = context.read<EstabelecimentoProvider>().estabelecimento;
    await provider.carregarSlots(
      abertura: estab?.abertura ?? '09:00',
      fechamento: estab?.fechamento ?? '19:00',
    );
  }

  Future<void> _confirmar() async {
    final usuario = context.read<AuthProvider>().usuario!;
    final provider = context.read<ManualBookingProvider>();

    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do cliente.')),
      );
      return;
    }
    provider.setNomeCliente(_nomeController.text);

    final ok = await provider.confirmar(usuario.idEstabelecimento);

    if (!mounted) return;

    if (ok) {
      _nomeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento realizado com sucesso!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erro ao agendar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManualBookingProvider>();
    final usuario = context.read<AuthProvider>().usuario!;
    final isDono = usuario.tipo == TipoUsuario.dono;

    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento manual')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Nome do cliente ──────────────────────────────────────────
            Text('Cliente', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do cliente',
                hintText: 'Ex: João Silva',
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: provider.setNomeCliente,
            ),

            const SizedBox(height: 20),

            // ── Serviços ─────────────────────────────────────────────────
            Text('Serviços', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            provider.servicos.isEmpty
                ? const Text('Nenhum serviço disponível.')
                : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: provider.servicos.map((s) {
                      final sel = provider.servicosSelecionadosIds.contains(s.id);
                      return FilterChip(
                        label:
                            Text('${s.nome} · ${s.duracaoMinutos}min'),
                        selected: sel,
                        onSelected: (_) => provider.toggleServico(s),
                      );
                    }).toList(),
                  ),
            if (provider.servicosSelecionados.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Duração total: ${provider.duracaoTotal} min  ·  '
                'R\$ ${provider.servicosSelecionados.fold(0.0, (s, v) => s + v.preco).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            const SizedBox(height: 20),

            // ── Profissional (somente dono) ──────────────────────────────
            if (isDono) ...[
              Text('Profissional',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              provider.barbeiros.isEmpty
                  ? const Text('Nenhum profissional disponível.')
                  : DropdownButtonFormField<String>(
                      value: provider.idBarbeiro,
                      decoration:
                          const InputDecoration(labelText: 'Barbeiro'),
                      items: provider.barbeiros
                          .map((b) => DropdownMenuItem(
                                value: b.uid,
                                child: Text(b.nome),
                              ))
                          .toList(),
                      onChanged: (uid) {
                        if (uid != null) provider.selectBarbeiro(uid);
                      },
                    ),
              const SizedBox(height: 20),
            ],

            // ── Data ─────────────────────────────────────────────────────
            Text('Data', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                provider.data != null
                    ? AppDateUtils.formatDate(provider.data!)
                    : 'Selecionar data',
              ),
              onPressed: provider.servicosIds.isNotEmpty
                  ? () => _selecionarData(context)
                  : null,
            ),
            if (provider.servicosIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Selecione ao menos um serviço primeiro.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),

            const SizedBox(height: 20),

            // ── Horário ──────────────────────────────────────────────────
            if (provider.data != null) ...[
              Text('Horário',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.slotsDisponiveis.isEmpty
                      ? const Text(
                          'Nenhum horário disponível para este dia.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.slotsDisponiveis.map((slot) {
                            return ChoiceChip(
                              label: Text(slot),
                              selected: provider.horario == slot,
                              onSelected: (_) =>
                                  provider.selectHorario(slot),
                            );
                          }).toList(),
                        ),
              const SizedBox(height: 20),
            ],

            // ── Botão confirmar ──────────────────────────────────────────
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (provider.podeSalvar && !provider.isSaving)
                    ? _confirmar
                    : null,
                child: provider.isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar agendamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
