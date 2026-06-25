import 'package:barberflow/data/repositories/agendamento_repository.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
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
