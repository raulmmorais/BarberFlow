import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:barberflow/presentation/shared/widgets/dynamic_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario!;
    final estabelecimento = context.watch<EstabelecimentoProvider>().estabelecimento;

    return Scaffold(
      appBar: DynamicAppBar(
        title: estabelecimento?.nomeComercial ?? 'BarberFlow',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () =>
                Navigator.of(context).pushNamed(RouteNames.myAppointments),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Olá, ${usuario.nome}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Serviços e profissionais serão carregados do Firestore.'),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.content_cut),
            title: const Text('Agendar serviços'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.bookingDateTime),
          ),
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
    );
  }
}
