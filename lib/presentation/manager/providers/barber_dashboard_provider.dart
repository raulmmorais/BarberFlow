import 'dart:async';

import 'package:barberflow/core/constants/app_constants.dart';
import 'package:barberflow/data/repositories/agendamento_repository.dart';
import 'package:barberflow/data/repositories/servico_repository.dart';
import 'package:barberflow/data/repositories/usuario_repository.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/domain/entities/servico.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:flutter/foundation.dart';

class BarberDashboardProvider extends ChangeNotifier {
  BarberDashboardProvider({
    AgendamentoRepository? agendamentoRepository,
    UsuarioRepository? usuarioRepository,
    ServicoRepository? servicoRepository,
  })  : _agendamentoRepo = agendamentoRepository ?? AgendamentoRepository(),
        _usuarioRepo = usuarioRepository ?? UsuarioRepository(),
        _servicoRepo = servicoRepository ?? ServicoRepository();

  final AgendamentoRepository _agendamentoRepo;
  final UsuarioRepository _usuarioRepo;
  final ServicoRepository _servicoRepo;

  StreamSubscription<List<Agendamento>>? _agendaSub;

  String? _idBarbeiro;
  DateTime _dataSelecionada = DateTime.now();
  List<Agendamento> _agendamentos = [];
  Map<String, String> _clienteNomes = {};
  Map<String, Servico> _servicosMap = {};
  bool _isLoading = false;
  bool _isActing = false;
  String? _error;

  DateTime get dataSelecionada => _dataSelecionada;
  List<Agendamento> get agendamentos => _agendamentos;
  bool get isLoading => _isLoading;
  bool get isActing => _isActing;
  String? get error => _error;

  void init(String idBarbeiro, String idEstabelecimento) {
    _idBarbeiro = idBarbeiro;
    _servicoRepo.watchByEstabelecimento(idEstabelecimento).listen((list) {
      _servicosMap = {for (final s in list) s.id: s};
      notifyListeners();
    });
    _watchAgenda();
  }

  void _watchAgenda() {
    if (_idBarbeiro == null) return;
    _isLoading = true;
    notifyListeners();
    _agendaSub?.cancel();
    _agendaSub = _agendamentoRepo
        .watchByBarbeiro(_idBarbeiro!, _dataSelecionada)
        .listen(
      (list) {
        _agendamentos = list;
        _isLoading = false;
        _resolverNomesClientes(list);
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _resolverNomesClientes(List<Agendamento> lista) async {
    for (final a in lista) {
      if (a.idCliente == AppConstants.manualClienteId) continue;
      if (_clienteNomes.containsKey(a.idCliente)) continue;
      final usuario = await _usuarioRepo.getById(a.idCliente);
      if (usuario != null) _clienteNomes[a.idCliente] = usuario.nome;
    }
    notifyListeners();
  }

  String nomeCliente(Agendamento a) {
    if (a.idCliente == AppConstants.manualClienteId) {
      return a.nomeClienteManual ?? 'Cliente manual';
    }
    return _clienteNomes[a.idCliente] ?? 'Cliente';
  }

  String nomesServicos(Agendamento a) {
    if (a.servicosIds.isEmpty) return 'Sem serviços';
    return a.servicosIds
        .map((id) => _servicosMap[id]?.nome ?? '...')
        .join(', ');
  }

  bool temConflito(Agendamento a) {
    if (a.status == AgendamentoStatus.recusado ||
        a.status == AgendamentoStatus.concluido) return false;
    final ativos = _agendamentos.where((ag) =>
        ag.id != a.id &&
        ag.status != AgendamentoStatus.recusado &&
        ag.status != AgendamentoStatus.concluido);
    final aInicio = a.dataHora.hour * 60 + a.dataHora.minute;
    final aFim = aInicio + a.duracaoTotalMinutos;
    return ativos.any((other) {
      final oInicio = other.dataHora.hour * 60 + other.dataHora.minute;
      final oFim = oInicio + other.duracaoTotalMinutos;
      return aInicio < oFim && aFim > oInicio;
    });
  }

  void avancarDia() {
    _dataSelecionada = _dataSelecionada.add(const Duration(days: 1));
    _agendamentos = [];
    _watchAgenda();
  }

  void voltarDia() {
    _dataSelecionada = _dataSelecionada.subtract(const Duration(days: 1));
    _agendamentos = [];
    _watchAgenda();
  }

  void irParaDia(DateTime date) {
    _dataSelecionada =
        DateTime(date.year, date.month, date.day);
    _agendamentos = [];
    _watchAgenda();
  }

  Future<bool> confirmar(String id) => _atualizarStatus(id, AgendamentoStatus.confirmado);
  Future<bool> recusar(String id) => _atualizarStatus(id, AgendamentoStatus.recusado);

  Future<bool> _atualizarStatus(String id, AgendamentoStatus status) async {
    _isActing = true;
    _error = null;
    notifyListeners();
    try {
      await _agendamentoRepo.updateStatus(id, status);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _agendaSub?.cancel();
    super.dispose();
  }
}
