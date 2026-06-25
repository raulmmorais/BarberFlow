import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/client/providers/client_booking_provider.dart';
import 'package:barberflow/presentation/client/widgets/barber_card.dart';
import 'package:barberflow/presentation/client/widgets/service_card.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:barberflow/presentation/shared/widgets/dynamic_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idEstab =
          context.read<AuthProvider>().usuario!.idEstabelecimento;
      context.read<ClientBookingProvider>().init(idEstab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario!;
    final estab =
        context.watch<EstabelecimentoProvider>().estabelecimento;
    final booking = context.watch<ClientBookingProvider>();

    return Scaffold(
      appBar: DynamicAppBar(
        title: estab?.nomeComercial ?? 'BarberFlow',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Meus agendamentos',
            onPressed: () =>
                Navigator.of(context).pushNamed(RouteNames.myAppointments),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Olá, ${usuario.nome}!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            estab != null
                ? 'Funcionamento: ${estab.abertura} às ${estab.fechamento}'
                : '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          // ── Serviços ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Serviços',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Agendar'),
                onPressed: () => Navigator.of(context)
                    .pushNamed(RouteNames.bookingDateTime),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (booking.servicosDisponiveis.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Nenhum serviço disponível no momento.'),
            )
          else
            ...booking.servicosDisponiveis.map(
              (s) => ServiceCard(
                servico: s,
                isSelected: false,
                onTap: () =>
                    Navigator.of(context).pushNamed(RouteNames.bookingDateTime),
              ),
            ),

          const SizedBox(height: 24),

          // ── Profissionais ─────────────────────────────────────────────────
          Text('Profissionais',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (booking.barbeirosDisponiveis.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Nenhum profissional disponível.'),
            )
          else
            ...booking.barbeirosDisponiveis.map(
              (b) => BarberCard(
                barbeiro: b,
                isSelected: false,
                onTap: () =>
                    Navigator.of(context).pushNamed(RouteNames.bookingDateTime),
              ),
            ),

          const SizedBox(height: 24),

          // ── Atalhos ───────────────────────────────────────────────────────
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico'),
            onTap: () => Navigator.of(context).pushNamed(RouteNames.history),
          ),
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('Mensalidade'),
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.mensalidade),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Lembretes de retorno'),
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.reminderSettings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(RouteNames.bookingDateTime),
        icon: const Icon(Icons.add),
        label: const Text('Agendar'),
      ),
    );
  }
}
