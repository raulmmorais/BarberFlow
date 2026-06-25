import 'package:barberflow/data/repositories/agendamento_repository.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:flutter/foundation.dart';

class ClientAppointmentsProvider extends ChangeNotifier {
  ClientAppointmentsProvider({AgendamentoRepository? repository})
      : _repository = repository ?? AgendamentoRepository();

  final AgendamentoRepository _repository;

  List<Agendamento> _agendamentos = [];
  bool _isLoading = false;
  String? _error;

  List<Agendamento> get agendamentos => _agendamentos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Agendamento> get historico => _agendamentos
      .where((a) => a.status == AgendamentoStatus.concluido)
      .toList();

  Future<bool> atualizarMidia({
    required String id,
    String? comentario,
    String? fotoLocalPath,
  }) async {
    try {
      await _repository.atualizarMidia(
        id: id,
        comentario: comentario,
        fotoLocalPath: fotoLocalPath,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void watch(String idCliente) {
    _isLoading = true;
    notifyListeners();
    _repository.watchByCliente(idCliente).listen(
      (list) {
        _agendamentos = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
