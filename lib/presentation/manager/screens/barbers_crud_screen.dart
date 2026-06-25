import 'package:barberflow/domain/entities/usuario.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/manager/providers/barbeiro_crud_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarbersCrudScreen extends StatefulWidget {
  const BarbersCrudScreen({super.key});

  @override
  State<BarbersCrudScreen> createState() => _BarbersCrudScreenState();
}

class _BarbersCrudScreenState extends State<BarbersCrudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idEstab =
          context.read<AuthProvider>().usuario!.idEstabelecimento;
      context.read<BarbeiroCrudProvider>().watch(idEstab);
    });
  }

  Future<void> _promoverUsuario() async {
    final uidController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promover usuário a barbeiro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite o UID do usuário (visível no perfil do app ou no Firebase Console).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(
                labelText: 'UID do usuário',
                hintText: 'Ex: abc123xyz...',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Promover'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final uid = uidController.text.trim();
    if (uid.isEmpty) return;

    final idEstab =
        context.read<AuthProvider>().usuario!.idEstabelecimento;
    final erro = await context
        .read<BarbeiroCrudProvider>()
        .promover(uid: uid, idEstabelecimento: idEstab);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro ?? 'Usuário promovido a barbeiro com sucesso!'),
      ),
    );
  }

  Future<void> _demoverBarbeiro(Usuario barbeiro) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover barbeiro'),
        content: Text(
          '${barbeiro.nome} voltará a ser cliente. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final erro = await context
        .read<BarbeiroCrudProvider>()
        .demover(barbeiro.uid);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro ?? '${barbeiro.nome} removido da equipe.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarbeiroCrudProvider>();
    final meuUid = context.read<AuthProvider>().usuario!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Profissionais')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.barbeiros.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum profissional vinculado.\nToque em + para adicionar.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.barbeiros.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final barbeiro = provider.barbeiros[index];
                    final isDono = barbeiro.tipo == TipoUsuario.dono;
                    final isMe = barbeiro.uid == meuUid;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          barbeiro.nome.isNotEmpty
                              ? barbeiro.nome[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(barbeiro.nome),
                      subtitle: Text(
                        isDono ? 'Dono' : 'Barbeiro',
                      ),
                      trailing: (!isDono && !isMe)
                          ? IconButton(
                              icon: const Icon(Icons.person_remove_outlined),
                              tooltip: 'Remover da equipe',
                              onPressed: () => _demoverBarbeiro(barbeiro),
                            )
                          : null,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promoverUsuario,
        tooltip: 'Adicionar barbeiro',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
