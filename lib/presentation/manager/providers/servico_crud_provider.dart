import 'package:barberflow/data/models/servico_model.dart';
import 'package:barberflow/data/repositories/servico_repository.dart';
import 'package:barberflow/domain/entities/servico.dart';
import 'package:flutter/foundation.dart';

class ServicoCrudProvider extends ChangeNotifier {
  ServicoCrudProvider({ServicoRepository? repository})
      : _repository = repository ?? ServicoRepository();

  final ServicoRepository _repository;

  List<Servico> _servicos = [];
  bool _isLoading = false;
  String? _error;

  List<Servico> get servicos => _servicos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void watch(String idEstabelecimento) {
    _isLoading = true;
    notifyListeners();
    _repository.watchByEstabelecimento(idEstabelecimento).listen(
      (list) {
        _servicos = list;
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

  Future<bool> create({
    required String idEstabelecimento,
    required String nome,
    required double preco,
    required int duracaoMinutos,
  }) async {
    try {
      await _repository.create(
        idEstabelecimento,
        ServicoModel(
          id: '',
          idEstabelecimento: idEstabelecimento,
          nome: nome,
          preco: preco,
          duracaoMinutos: duracaoMinutos,
        ),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required Servico servico,
    required String nome,
    required double preco,
    required int duracaoMinutos,
  }) async {
    try {
      await _repository.update(
        ServicoModel(
          id: servico.id,
          idEstabelecimento: servico.idEstabelecimento,
          nome: nome,
          preco: preco,
          duracaoMinutos: duracaoMinutos,
        ),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(Servico servico) async {
    try {
      await _repository.delete(
        ServicoModel(
          id: servico.id,
          idEstabelecimento: servico.idEstabelecimento,
          nome: servico.nome,
          preco: servico.preco,
          duracaoMinutos: servico.duracaoMinutos,
        ),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
