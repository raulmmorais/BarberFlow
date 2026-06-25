import 'package:barberflow/core/utils/date_utils.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/client/providers/client_booking_provider.dart';
import 'package:barberflow/presentation/client/widgets/barber_card.dart';
import 'package:barberflow/presentation/client/widgets/service_card.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingDateTimeScreen extends StatefulWidget {
  const BookingDateTimeScreen({super.key});

  @override
  State<BookingDateTimeScreen> createState() => _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends State<BookingDateTimeScreen> {
  int _step = 0;

  void _irPara(int step) => setState(() => _step = step);

  Future<void> _confirmar() async {
    final auth = context.read<AuthProvider>();
    final booking = context.read<ClientBookingProvider>();
    final idEstab = auth.usuario!.idEstabelecimento;

    final ok = await booking.confirmar(
      idCliente: auth.usuario!.uid,
      idEstabelecimento: idEstab,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Agendamento enviado! Aguarde a confirmação.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(booking.error ?? 'Erro ao agendar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<ClientBookingProvider>();
    final estab = context.watch<EstabelecimentoProvider>().estabelecimento;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo agendamento')),
      body: Stepper(
        currentStep: _step,
        onStepTapped: (i) {
          // Permite voltar para passos anteriores
          if (i < _step) _irPara(i);
        },
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          // ── Passo 1: Serviços ─────────────────────────────────────────────
          Step(
            title: const Text('Serviços'),
            subtitle: booking.servicosSelecionados.isEmpty
                ? null
                : Text(
                    '${booking.servicosSelecionados.length} selecionado(s) · ${booking.duracaoTotal} min',
                  ),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                if (booking.servicosDisponiveis.isEmpty)
                  const Text('Nenhum serviço disponível.')
                else
                  ...booking.servicosDisponiveis.map(
                    (s) => ServiceCard(
                      servico: s,
                      isSelected:
                          booking.servicosSelecionadosIds.contains(s.id),
                      onTap: () => booking.toggleServico(s),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: booking.podeAvancarServicos
                        ? () => _irPara(1)
                        : null,
                    child: const Text('Próximo'),
                  ),
                ),
              ],
            ),
          ),

          // ── Passo 2: Profissional ─────────────────────────────────────────
          Step(
            title: const Text('Profissional'),
            subtitle:
                booking.barbeiro != null ? Text(booking.barbeiro!.nome) : null,
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                if (booking.barbeirosDisponiveis.isEmpty)
                  const Text('Nenhum profissional disponível.')
                else
                  ...booking.barbeirosDisponiveis.map(
                    (b) => BarberCard(
                      barbeiro: b,
                      isSelected: booking.barbeiro?.uid == b.uid,
                      onTap: () => booking.selectBarbeiro(b),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: booking.podeAvancarBarbeiro
                        ? () => _irPara(2)
                        : null,
                    child: const Text('Próximo'),
                  ),
                ),
              ],
            ),
          ),

          // ── Passo 3: Data ─────────────────────────────────────────────────
          Step(
            title: const Text('Data'),
            subtitle: booking.data != null
                ? Text(AppDateUtils.formatDate(booking.data!))
                : null,
            isActive: _step >= 2,
            state: _step > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                CalendarDatePicker(
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  onDateChanged: (date) {
                    final diasUteis = estab?.diasUteis ?? [1, 2, 3, 4, 5, 6];
                    // weekday: 1=Seg...7=Dom (Dart)
                    if (!diasUteis.contains(date.weekday)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Este dia não é um dia de funcionamento.')),
                      );
                      return;
                    }
                    booking.selectData(date);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: booking.podeAvancarData
                        ? () async {
                            await booking.carregarSlots(
                              abertura: estab?.abertura ?? '09:00',
                              fechamento: estab?.fechamento ?? '19:00',
                            );
                            if (mounted) _irPara(3);
                          }
                        : null,
                    child: const Text('Próximo'),
                  ),
                ),
              ],
            ),
          ),

          // ── Passo 4: Horário + Confirmação ────────────────────────────────
          Step(
            title: const Text('Horário'),
            subtitle: booking.horario != null ? Text(booking.horario!) : null,
            isActive: _step >= 3,
            state: StepState.indexed,
            content: booking.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (booking.slotsDisponiveis.isEmpty)
                        const Text(
                          'Nenhum horário disponível para este dia. Tente outra data.',
                        )
                      else ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: booking.slotsDisponiveis.map((slot) {
                            final selected = booking.horario == slot;
                            return ChoiceChip(
                              label: Text(slot),
                              selected: selected,
                              onSelected: (_) => booking.selectHorario(slot),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        if (booking.horario != null) ...[
                          const Divider(),
                          _ResumoAgendamento(booking: booking),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: booking.isSaving ? null : _confirmar,
                              child: booking.isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Confirmar agendamento'),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResumoAgendamento extends StatelessWidget {
  const _ResumoAgendamento({required this.booking});

  final ClientBookingProvider booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumo',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
            'Serviços: ${booking.servicosSelecionados.map((s) => s.nome).join(', ')}'),
        Text('Profissional: ${booking.barbeiro?.nome ?? ''}'),
        Text('Data: ${AppDateUtils.formatDate(booking.data!)}'),
        Text('Horário: ${booking.horario}'),
        Text('Duração total: ${booking.duracaoTotal} min'),
        Text(
          'Valor estimado: R\$ ${booking.servicosSelecionados.fold(0.0, (sum, s) => sum + s.preco).toStringAsFixed(2)}',
        ),
      ],
    );
  }
}
