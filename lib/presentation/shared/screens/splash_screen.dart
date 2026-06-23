import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/core/widgets/app_loading.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    final auth = context.read<AuthProvider>();
    if (!mounted) return;

    final route = auth.isAuthenticated ? RouteNames.root : RouteNames.login;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoading(message: 'BarberFlow'),
    );
  }
}
