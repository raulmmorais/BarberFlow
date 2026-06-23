import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/core/widgets/app_loading.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/auth/screens/complete_profile_screen.dart';
import 'package:barberflow/presentation/client/screens/client_home_screen.dart';
import 'package:barberflow/presentation/manager/screens/barber_dashboard_screen.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String? _estabelecimentoCarregado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadCurrentUsuario();
    });
  }

  void _loadEstabelecimento(String idEstabelecimento) {
    if (_estabelecimentoCarregado == idEstabelecimento) return;
    _estabelecimentoCarregado = idEstabelecimento;
    context.read<EstabelecimentoProvider>().watch(idEstabelecimento);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        }
      });
      return const AppLoading(message: 'Redirecionando...');
    }

    if (auth.isLoading) {
      return const AppLoading(message: 'Carregando perfil...');
    }

    if (auth.needsProfileCompletion) {
      return const CompleteProfileScreen();
    }

    if (auth.usuario == null) {
      return const AppLoading(message: 'Carregando perfil...');
    }

    _loadEstabelecimento(auth.usuario!.idEstabelecimento);

    final tipo = auth.usuario!.tipo;
    if (tipo == TipoUsuario.barbeiro || tipo == TipoUsuario.dono) {
      return const BarberDashboardScreen();
    }

    return const ClientHomeScreen();
  }
}
