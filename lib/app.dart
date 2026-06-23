import 'package:barberflow/core/constants/app_constants.dart';
import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/core/theme/app_theme.dart';
import 'package:barberflow/core/theme/dynamic_theme.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/client/providers/client_appointments_provider.dart';
import 'package:barberflow/presentation/client/providers/client_booking_provider.dart';
import 'package:barberflow/presentation/manager/providers/barbeiro_crud_provider.dart';
import 'package:barberflow/presentation/manager/providers/barber_dashboard_provider.dart';
import 'package:barberflow/presentation/manager/providers/manual_booking_provider.dart';
import 'package:barberflow/presentation/manager/providers/mensalista_provider.dart';
import 'package:barberflow/presentation/manager/providers/servico_crud_provider.dart';
import 'package:barberflow/presentation/routes/app_routes.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarberFlowApp extends StatelessWidget {
  const BarberFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EstabelecimentoProvider()),
        ChangeNotifierProvider(create: (_) => ClientBookingProvider()),
        ChangeNotifierProvider(create: (_) => ClientAppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => BarberDashboardProvider()),
        ChangeNotifierProvider(create: (_) => ManualBookingProvider()),
        ChangeNotifierProvider(create: (_) => MensalistaProvider()),
        ChangeNotifierProvider(create: (_) => ServicoCrudProvider()),
        ChangeNotifierProvider(create: (_) => BarbeiroCrudProvider()),
      ],
      child: Consumer<EstabelecimentoProvider>(
        builder: (context, estabelecimentoProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: DynamicTheme.fromEstabelecimento(
              estabelecimentoProvider.estabelecimento,
            ),
            darkTheme: AppTheme.light(),
            routes: AppRoutes.routes,
            initialRoute: RouteNames.splash,
            home: null,
          );
        },
      ),
    );
  }
}
