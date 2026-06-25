import 'package:barberflow/core/constants/app_constants.dart';
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

class ManualBookingProvider extends ChangeNotifier {
  ManualBookingProvider({
    ServicoRepository? servicoRepository,
    UsuarioRepository? usuarioRepository,
    AgendamentoRepository? agendamentoRepository,
  })  : _servicoRepo = servicoRepository ?? ServicoRepository(),
        _usuarioRepo = usuarioRepository ?? UsuarioRepository(),
        _agendamentoRepo = agendamentoRepository ?? AgendamentoRepository();

  final ServicoRepository _servicoRepo;
  final UsuarioRepository _usuarioRepo;
  final AgendamentoRepository _agendamentoRepo;

  List<Servico> _servicos = [];
  List<Usuario> _barbeiros = [];
  final Set<String> _servicosIds = {};
  String _nomeCliente = '';
  String? _idBarbeiro;
  DateTime? _data;
  String? _horario;
  List<String> _slotsDisponiveis = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<Servico> get servicos => _servicos;
  List<Usuario> get barbeiros => _barbeiros;
  Set<String> get servicosSelecionadosIds => _servicosIds;
  List<Servico> get servicosSelecionados =>
      _servicos.where((s) => _servicosIds.contains(s.id)).toList();
  String get nomeCliente => _nomeCliente;
  String? get idBarbeiro => _idBarbeiro;
  DateTime? get data => _data;
  String? get horario => _horario;
  List<String> get slotsDisponiveis => _slotsDisponiveis;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  int get duracaoTotal =>
      servicosSelecionados.fold(0, (sum, s) => sum + s.duracaoMinutos);

  bool get podeSalvar =>
      _nomeCliente.trim().isNotEmpty &&
      _servicosIds.isNotEmpty &&
      _idBarbeiro != null &&
      _data != null &&
      _horario != null;

  void init(String idEstabelecimento, String meuUid) {
    _idBarbeiro = meuUid;
    _servicoRepo.watchByEstabelecimento(idEstabelecimento).listen((list) {
      _servicos = list;
      notifyListeners();
    });
    _usuarioRepo.watchBarbeiros(idEstabelecimento).listen((list) {
      _barbeiros = list;
      notifyListeners();
    });
  }

  void setNomeCliente(String nome) {
    _nomeCliente = nome;
    notifyListeners();
  }

  void toggleServico(Servico s) {
    if (_servicosIds.contains(s.id)) {
      _servicosIds.remove(s.id);
    } else {
      _servicosIds.add(s.id);
    }
    _horario = null;
    _slotsDisponiveis = [];
    notifyListeners();
  }

  void selectBarbeiro(String uid) {
    _idBarbeiro = uid;
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

  Future<void> carregarSlots({
    required String abertura,
    required String fechamento,
  }) async {
    if (_idBarbeiro == null || _data == null) return;
    _isLoading = true;
    _slotsDisponiveis = [];
    notifyListeners();
    try {
      final ocupados = await _agendamentoRepo
          .watchByBarbeiro(_idBarbeiro!, _data!)
          .first;
      _slotsDisponiveis = _calcularSlots(
        abertura: abertura,
        fechamento: fechamento,
        duracao: duracaoTotal,
        ocupados: ocupados
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
    final abMin = _toMin(abertura);
    final feMin = _toMin(fechamento);
    final slots = <String>[];
    for (var m = abMin; m + duracao <= feMin; m += 30) {
      final fim = m + duracao;
      final conflito = ocupados.any((a) {
        final i = a.dataHora.hour * 60 + a.dataHora.minute;
        return m < i + a.duracaoTotalMinutos && fim > i;
      });
      if (!conflito) slots.add(_fromMin(m));
    }
    return slots;
  }

  int _toMin(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String _fromMin(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  Future<bool> confirmar(String idEstabelecimento) async {
    if (!podeSalvar) return false;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final dataHora = AppDateUtils.combineDateAndTime(_data!, _horario!);
      await _agendamentoRepo.create(
        AgendamentoModel(
          id: '',
          idEstabelecimento: idEstabelecimento,
          idCliente: AppConstants.manualClienteId,
          nomeClienteManual: _nomeCliente.trim(),
          idBarbeiro: _idBarbeiro!,
          servicosIds: _servicosIds.toList(),
          dataHora: dataHora,
          duracaoTotalMinutos: duracaoTotal,
          status: AgendamentoStatus.confirmado,
        ),
      );
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
    _nomeCliente = '';
    _servicosIds.clear();
    _data = null;
    _horario = null;
    _slotsDisponiveis = [];
    _error = null;
    notifyListeners();
  }
}
