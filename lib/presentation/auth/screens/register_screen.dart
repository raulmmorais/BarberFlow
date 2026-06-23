import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/core/errors/error_handler.dart';
import 'package:barberflow/core/utils/validators.dart';
import 'package:barberflow/core/widgets/app_button.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _estabelecimentoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _estabelecimentoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      idEstabelecimento: _estabelecimentoController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(RouteNames.root);
    } else if (auth.error != null) {
      ErrorHandler.show(context, auth.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _nomeController,
                  label: 'Nome completo',
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _telefoneController,
                  label: 'Telefone',
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  validator: Validators.password,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _estabelecimentoController,
                  label: 'ID do estabelecimento',
                  validator: (value) =>
                      Validators.required(value, field: 'ID do estabelecimento'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Peça o ID ao salão onde você deseja agendar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Criar conta',
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
