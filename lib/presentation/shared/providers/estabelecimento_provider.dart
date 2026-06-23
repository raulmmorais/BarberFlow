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
