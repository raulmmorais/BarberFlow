import 'dart:io';

import 'package:barberflow/core/services/local_storage_service.dart';
import 'package:barberflow/core/utils/date_utils.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/presentation/auth/providers/auth_provider.dart';
import 'package:barberflow/presentation/client/providers/client_appointments_provider.dart';
import 'package:barberflow/presentation/client/providers/client_booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().usuario!.uid;
      context.read<ClientAppointmentsProvider>().watch(uid);
    });
  }

  String _resolverServicos(Agendamento a, ClientBookingProvider booking) {
    if (booking.servicosDisponiveis.isEmpty) {
      return '${a.servicosIds.length} serviço(s)';
    }
    final nomes = a.servicosIds
        .map((id) =>
            booking.servicosDisponiveis
                .where((s) => s.id == id)
                .firstOrNull
                ?.nome ??
            id)
        .toList();
    return nomes.isEmpty ? 'Sem serviços' : nomes.join(', ');
  }

  Future<void> _adicionarFoto(BuildContext context, Agendamento a,
      ImageSource source) async {
    final path = await _storage.savePhoto(a.id, source: source);
    if (path == null || !context.mounted) return;

    final ok = await context.read<ClientAppointmentsProvider>().atualizarMidia(
          id: a.id,
          fotoLocalPath: path,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(ok ? 'Foto salva!' : 'Erro ao salvar foto.')),
    );
  }

  Future<void> _adicionarComentario(
      BuildContext context, Agendamento a) async {
    final controller =
        TextEditingController(text: a.comentarioPosCorte ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comentário do corte'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Como ficou? O que você achou?',
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final texto = controller.text.trim();
    if (texto.isEmpty) return;

    final ok = await context.read<ClientAppointmentsProvider>().atualizarMidia(
          id: a.id,
          comentario: texto,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(ok ? 'Comentário salvo!' : 'Erro ao salvar comentário.')),
    );
  }

  void _mostrarOpcoesFoto(BuildContext context, Agendamento a) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto agora'),
              onTap: () {
                Navigator.pop(context);
                _adicionarFoto(context, a, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _adicionarFoto(context, a, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<ClientAppointmentsProvider>();
    final booking = context.watch<ClientBookingProvider>();
    final historico = appointments.historico;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: appointments.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historico.isEmpty
              ? const Center(
                  child: Text('Nenhum atendimento concluído ainda.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: historico.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final a = historico[index];
                    return _HistoricoCard(
                      agendamento: a,
                      servicosNomes: _resolverServicos(a, booking),
                      onAdicionarFoto: () =>
                          _mostrarOpcoesFoto(context, a),
                      onAdicionarComentario: () =>
                          _adicionarComentario(context, a),
                    );
                  },
                ),
    );
  }
}

// ── Card de histórico ───────────────────────────────────────────────────────

class _HistoricoCard extends StatelessWidget {
  const _HistoricoCard({
    required this.agendamento,
    required this.servicosNomes,
    required this.onAdicionarFoto,
    required this.onAdicionarComentario,
  });

  final Agendamento agendamento;
  final String servicosNomes;
  final VoidCallback onAdicionarFoto;
  final VoidCallback onAdicionarComentario;

  @override
  Widget build(BuildContext context) {
    final a = agendamento;
    final temFoto = a.fotoLocalPath != null &&
        File(a.fotoLocalPath!).existsSync();
    final temComentario =
        a.comentarioPosCorte != null && a.comentarioPosCorte!.isNotEmpty;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Foto (se existir) ───────────────────────────────────────────
          if (temFoto)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(a.fotoLocalPath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Data e serviços ───────────────────────────────────────
                Text(
                  AppDateUtils.formatDateTime(a.dataHora),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(servicosNomes,
                    style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '${a.duracaoTotalMinutos} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // ── Comentário ────────────────────────────────────────────
                if (temComentario) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${a.comentarioPosCorte}"',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Botões de ação ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          temFoto ? Icons.edit : Icons.camera_alt,
                          size: 18,
                        ),
                        label: Text(temFoto ? 'Trocar foto' : 'Adicionar foto'),
                        onPressed: onAdicionarFoto,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          temComentario ? Icons.edit_note : Icons.comment_outlined,
                          size: 18,
                        ),
                        label: Text(
                            temComentario ? 'Editar nota' : 'Adicionar nota'),
                        onPressed: onAdicionarComentario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
