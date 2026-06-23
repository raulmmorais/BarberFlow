import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/manager/widgets/appointment_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarberDashboardScreen extends StatelessWidget {
  const BarberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario!;
    final isDono = usuario.tipo == TipoUsuario.dono;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda do dia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Bem-vindo, ${usuario.nome}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text('Agenda do dia será carregada do Firestore.'),
          const SizedBox(height: 24),
          const AppointmentActionButtons(
            onConfirm: null,
            onReject: null,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Agendamento manual'),
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.manualBooking),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Mensalistas'),
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.mensalistas),
          ),
          if (isDono) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Estabelecimento'),
              onTap: () => Navigator.of(context)
                  .pushNamed(RouteNames.ownerEstablishment),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('Serviços'),
              onTap: () =>
                  Navigator.of(context).pushNamed(RouteNames.servicesCrud),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Profissionais'),
              onTap: () =>
                  Navigator.of(context).pushNamed(RouteNames.barbersCrud),
            ),
          ],
        ],
      ),
    );
  }
}
