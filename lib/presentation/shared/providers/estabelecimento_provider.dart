import 'package:barberflow/data/models/estabelecimento_model.dart';
import 'package:barberflow/data/repositories/estabelecimento_repository.dart';
import 'package:barberflow/domain/entities/estabelecimento.dart';
import 'package:flutter/foundation.dart';

class EstabelecimentoProvider extends ChangeNotifier {
  EstabelecimentoProvider({EstabelecimentoRepository? repository})
      : _repository = repository ?? EstabelecimentoRepository();

  final EstabelecimentoRepository _repository;

  Estabelecimento? _estabelecimento;
  bool _isLoading = false;

  Estabelecimento? get estabelecimento => _estabelecimento;
  bool get isLoading => _isLoading;

  Future<bool> save(EstabelecimentoModel model) async {
    try {
      await _repository.save(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  void watch(String idEstabelecimento) {
    _isLoading = true;
    notifyListeners();

    _repository.watchById(idEstabelecimento).listen((data) {
      _estabelecimento = data;
      _isLoading = false;
      notifyListeners();
    });
  }
}
