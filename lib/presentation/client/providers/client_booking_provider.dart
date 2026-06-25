import 'package:barberflow/core/utils/date_utils.dart';
import 'package:barberflow/data/models/agendamento_model.dart';
import 'package:barberflow/data/repositories/agendamento_repository.dart';
import 'package:barberflow/data/repositories/servico_repository.dart';
import 'package:barberflow/data/repositories/usuario_repository.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/domain/entities/servico.dart';
import 'package:barberflow/domain/entities/usuario.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:flutter/foundation.dart';

class ClientBookingProvider extends ChangeNotifier {
  ClientBookingProvider({
    ServicoRepository? servicoRepository,
    UsuarioRepository? usuarioRepository,
    AgendamentoRepository? agendamentoRepository,
  })  : _servicoRepo = servicoRepository ?? ServicoRepository(),
        _usuarioRepo = usuarioRepository ?? UsuarioRepository(),
        _agendamentoRepo = agendamentoRepository ?? AgendamentoRepository();

  final ServicoRepository _servicoRepo;
  final UsuarioRepository _usuarioRepo;
  final AgendamentoRepository _agendamentoRepo;

  // Dados disponíveis
  List<Servico> _servicosDisponiveis = [];
  List<Usuario> _barbeirosDisponiveis = [];

  // Seleções do usuário
  final Set<String> _servicosIds = {};
  Usuario? _barbeiro;
  DateTime? _data;
  String? _horario; // "HH:mm"

  // Slots calculados
  List<String> _slotsDisponiveis = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  bool _sucesso = false;

  List<Servico> get servicosDisponiveis => _servicosDisponiveis;
  List<Usuario> get barbeirosDisponiveis => _barbeirosDisponiveis;
  Set<String> get servicosSelecionadosIds => _servicosIds;
  List<Servico> get servicosSelecionados =>
      _servicosDisponiveis.where((s) => _servicosIds.contains(s.id)).toList();
  Usuario? get barbeiro => _barbeiro;
  DateTime? get data => _data;
  String? get horario => _horario;
  List<String> get slotsDisponiveis => _slotsDisponiveis;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get sucesso => _sucesso;

  int get duracaoTotal =>
      servicosSelecionados.fold(0, (sum, s) => sum + s.duracaoMinutos);

  bool get podeAvancarServicos => _servicosIds.isNotEmpty;
  bool get podeAvancarBarbeiro => _barbeiro != null;
  bool get podeAvancarData => _data != null;
  bool get podeConfirmar => _horario != null;

  void init(String idEstabelecimento) {
    _servicoRepo.watchByEstabelecimento(idEstabelecimento).listen((list) {
      _servicosDisponiveis = list;
      notifyListeners();
    });
    _usuarioRepo.watchBarbeiros(idEstabelecimento).listen((list) {
      _barbeirosDisponiveis = list;
      notifyListeners();
    });
  }

  void toggleServico(Servico servico) {
    if (_servicosIds.contains(servico.id)) {
      _servicosIds.remove(servico.id);
    } else {
      _servicosIds.add(servico.id);
    }
    // Reset passos seguintes ao alterar seleção
    _horario = null;
    _slotsDisponiveis = [];
    notifyListeners();
  }

  void selectBarbeiro(Usuario barbeiro) {
    _barbeiro = barbeiro;
    _data = null;
    _horario = null;
    _slotsDisponiveis = [];
    notifyListeners();
  }

  void selectData(DateTime data) {
    _data = data;
    _horario = null;
    _slotsDisponiveis = [];
    notifyListeners();
  }

  void selectHorario(String horario) {
    _horario = horario;
    notifyListeners();
  }

  // Calcula horários disponíveis com base na agenda do barbeiro no dia.
  Future<void> carregarSlots({
    required String abertura,
    required String fechamento,
  }) async {
    if (_barbeiro == null || _data == null) return;

    _isLoading = true;
    _slotsDisponiveis = [];
    notifyListeners();

    try {
      final agendamentosExistentes = await _agendamentoRepo
          .watchByBarbeiro(_barbeiro!.uid, _data!)
          .first;

      _slotsDisponiveis = _calcularSlots(
        abertura: abertura,
        fechamento: fechamento,
        duracao: duracaoTotal,
        ocupados: agendamentosExistentes
            .where((a) =>
                a.status != AgendamentoStatus.recusado &&
                a.status != AgendamentoStatus.concluido)
            .toList(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _calcularSlots({
    required String abertura,
    required String fechamento,
    required int duracao,
    required List<Agendamento> ocupados,
  }) {
    if (duracao <= 0) return [];

    final aberturaMin = _toMinutes(abertura);
    final fechamentoMin = _toMinutes(fechamento);
    final slots = <String>[];

    for (var min = aberturaMin; min + duracao <= fechamentoMin; min += 30) {
      final slotFim = min + duracao;
      final conflito = ocupados.any((a) {
        final inicio = a.dataHora.hour * 60 + a.dataHora.minute;
        final fim = inicio + a.duracaoTotalMinutos;
        return min < fim && slotFim > inicio;
      });
      if (!conflito) slots.add(_fromMinutes(min));
    }
    return slots;
  }

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _fromMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<bool> confirmar({
    required String idCliente,
    required String idEstabelecimento,
  }) async {
    if (_barbeiro == null || _data == null || _horario == null) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final dataHora = AppDateUtils.combineDateAndTime(_data!, _horario!);
      final model = AgendamentoModel(
        id: '',
        idEstabelecimento: idEstabelecimento,
        idCliente: idCliente,
        idBarbeiro: _barbeiro!.uid,
        servicosIds: _servicosIds.toList(),
        dataHora: dataHora,
        duracaoTotalMinutos: duracaoTotal,
        status: AgendamentoStatus.pendente,
      );
      await _agendamentoRepo.create(model);
      _sucesso = true;
      resetar();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void resetar() {
    _servicosIds.clear();
    _barbeiro = null;
    _data = null;
    _horario = null;
    _slotsDisponiveis = [];
    _sucesso = false;
    _error = null;
    notifyListeners();
  }
}
