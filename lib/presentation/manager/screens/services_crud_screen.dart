import 'package:barberflow/domain/entities/servico.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/manager/providers/servico_crud_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServicesCrudScreen extends StatefulWidget {
  const ServicesCrudScreen({super.key});

  @override
  State<ServicesCrudScreen> createState() => _ServicesCrudScreenState();
}

class _ServicesCrudScreenState extends State<ServicesCrudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idEstab =
          context.read<AuthProvider>().usuario!.idEstabelecimento;
      context.read<ServicoCrudProvider>().watch(idEstab);
    });
  }

  void _abrirFormulario(BuildContext context, {Servico? servico}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ServicoFormSheet(servico: servico),
    );
  }

  Future<void> _confirmarExclusao(
      BuildContext context, Servico servico) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir serviço'),
        content: Text('Deseja excluir "${servico.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final ok = await context.read<ServicoCrudProvider>().delete(servico);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir serviço.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicoCrudProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.servicos.isEmpty
              ? const Center(
                  child: Text('Nenhum serviço cadastrado.\nToque em + para adicionar.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.servicos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final servico = provider.servicos[index];
                    return ListTile(
                      title: Text(servico.nome),
                      subtitle: Text(
                        '${servico.duracaoMinutos} min  •  R\$ ${servico.preco.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _abrirFormulario(context, servico: servico),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _confirmarExclusao(context, servico),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Bottom sheet de formulário ──────────────────────────────────────────────

class _ServicoFormSheet extends StatefulWidget {
  const _ServicoFormSheet({this.servico});

  final Servico? servico;

  @override
  State<_ServicoFormSheet> createState() => _ServicoFormSheetState();
}

class _ServicoFormSheetState extends State<_ServicoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _duracaoController;
  bool _isSaving = false;

  bool get _isEditing => widget.servico != null;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.servico?.nome ?? '');
    _precoController = TextEditingController(
        text: widget.servico != null
            ? widget.servico!.preco.toStringAsFixed(2)
            : '');
    _duracaoController = TextEditingController(
        text: widget.servico?.duracaoMinutos.toString() ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _duracaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ServicoCrudProvider>();
    final idEstab =
        context.read<AuthProvider>().usuario!.idEstabelecimento;
    final nome = _nomeController.text.trim();
    final preco = double.parse(_precoController.text.trim().replaceAll(',', '.'));
    final duracao = int.parse(_duracaoController.text.trim());

    bool ok;
    if (_isEditing) {
      ok = await provider.update(
        servico: widget.servico!,
        nome: nome,
        preco: preco,
        duracaoMinutos: duracao,
      );
    } else {
      ok = await provider.create(
        idEstabelecimento: idEstab,
        nome: nome,
        preco: preco,
        duracaoMinutos: duracao,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar serviço.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Editar serviço' : 'Novo serviço',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do serviço'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório.' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precoController,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$)',
                      hintText: '0.00',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório.';
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed < 0) return 'Valor inválido.';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _duracaoController,
                    decoration:
                        const InputDecoration(labelText: 'Duração (min)'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório.';
                      final parsed = int.tryParse(v);
                      if (parsed == null || parsed <= 0) return 'Valor inválido.';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _salvar,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Salvar alterações' : 'Adicionar serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
