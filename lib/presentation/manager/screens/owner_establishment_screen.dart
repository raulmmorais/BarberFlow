import 'package:barberflow/data/models/estabelecimento_model.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/shared/providers/estabelecimento_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnerEstablishmentScreen extends StatefulWidget {
  const OwnerEstablishmentScreen({super.key});

  @override
  State<OwnerEstablishmentScreen> createState() =>
      _OwnerEstablishmentScreenState();
}

class _OwnerEstablishmentScreenState extends State<OwnerEstablishmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _logoController = TextEditingController();
  final _corPrimariaController = TextEditingController();
  final _corSecundariaController = TextEditingController();

  final Map<int, String> _diasLabel = {
    1: 'Seg',
    2: 'Ter',
    3: 'Qua',
    4: 'Qui',
    5: 'Sex',
    6: 'Sáb',
    7: 'Dom',
  };

  Set<int> _diasSelecionados = {1, 2, 3, 4, 5, 6};
  TimeOfDay _abertura = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _fechamento = const TimeOfDay(hour: 19, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preencherFormulario());
  }

  void _preencherFormulario() {
    final estab =
        context.read<EstabelecimentoProvider>().estabelecimento;
    if (estab == null) return;

    _nomeController.text = estab.nomeComercial;
    _logoController.text = estab.logoUrl;
    _corPrimariaController.text = estab.corPrimaria;
    _corSecundariaController.text = estab.corSecundaria;
    setState(() {
      _diasSelecionados = Set<int>.from(estab.diasUteis);
      _abertura = _parseTime(estab.abertura);
      _fechamento = _parseTime(estab.fechamento);
    });
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool isAbertura}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isAbertura ? _abertura : _fechamento,
    );
    if (picked == null) return;
    setState(() {
      if (isAbertura) {
        _abertura = picked;
      } else {
        _fechamento = picked;
      }
    });
  }

  String? _validateHex(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório.';
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6 || int.tryParse(hex, radix: 16) == null) {
      return 'Informe um código hex válido (ex: #1A1A2E).';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um dia de funcionamento.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final idEstab =
        context.read<AuthProvider>().usuario!.idEstabelecimento;

    final model = EstabelecimentoModel(
      id: idEstab,
      nomeComercial: _nomeController.text.trim(),
      logoUrl: _logoController.text.trim(),
      corPrimaria: _corPrimariaController.text.trim(),
      corSecundaria: _corSecundariaController.text.trim(),
      diasUteis: _diasSelecionados.toList()..sort(),
      abertura: _formatTime(_abertura),
      fechamento: _formatTime(_fechamento),
    );

    final ok =
        await context.read<EstabelecimentoProvider>().save(model);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Estabelecimento atualizado com sucesso!'
            : 'Erro ao salvar. Tente novamente.'),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _logoController.dispose();
    _corPrimariaController.dispose();
    _corSecundariaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estabelecimento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Informações gerais ──────────────────────────────────────
                Text('Informações gerais',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeController,
                  decoration:
                      const InputDecoration(labelText: 'Nome comercial'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Campo obrigatório.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _logoController,
                  decoration: const InputDecoration(
                    labelText: 'URL da logo (opcional)',
                    hintText: 'https://...',
                  ),
                ),

                const SizedBox(height: 24),

                // ── Tema de cores ───────────────────────────────────────────
                Text('Cores do tema',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Use códigos hex, ex: #1A1A2E',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _corPrimariaController,
                        decoration: const InputDecoration(
                            labelText: 'Cor primária'),
                        validator: _validateHex,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ColorPreview(
                        hexColor: _corPrimariaController.text),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _corSecundariaController,
                        decoration: const InputDecoration(
                            labelText: 'Cor secundária'),
                        validator: _validateHex,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ColorPreview(
                        hexColor: _corSecundariaController.text),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Horário de funcionamento ────────────────────────────────
                Text('Horário de funcionamento',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _diasLabel.entries.map((e) {
                    final selecionado =
                        _diasSelecionados.contains(e.key);
                    return FilterChip(
                      label: Text(e.value),
                      selected: selecionado,
                      onSelected: (val) => setState(() {
                        if (val) {
                          _diasSelecionados.add(e.key);
                        } else {
                          _diasSelecionados.remove(e.key);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimeTile(
                        label: 'Abertura',
                        time: _formatTime(_abertura),
                        onTap: () => _pickTime(isAbertura: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeTile(
                        label: 'Fechamento',
                        time: _formatTime(_fechamento),
                        onTap: () => _pickTime(isAbertura: false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _salvar,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar alterações'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.hexColor});

  final String hexColor;

  @override
  Widget build(BuildContext context) {
    Color? color;
    try {
      final hex = hexColor.replaceFirst('#', '');
      if (hex.length == 6) {
        color = Color(int.parse('ff$hex', radix: 16));
      }
    } catch (_) {}

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(time,
            style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
