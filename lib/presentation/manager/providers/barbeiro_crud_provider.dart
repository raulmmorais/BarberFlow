import 'package:barberflow/data/repositories/usuario_repository.dart';
import 'package:barberflow/domain/entities/usuario.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:flutter/foundation.dart';

class BarbeiroCrudProvider extends ChangeNotifier {
  BarbeiroCrudProvider({UsuarioRepository? repository})
      : _repository = repository ?? UsuarioRepository();

  final UsuarioRepository _repository;

  List<Usuario> _barbeiros = [];
  bool _isLoading = false;
  String? _error;

  List<Usuario> get barbeiros => _barbeiros;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void watch(String idEstabelecimento) {
    _isLoading = true;
    notifyListeners();
    _repository.watchBarbeiros(idEstabelecimento).listen(
      (list) {
        _barbeiros = list;
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

  // Promove um usuário cliente (por UID) a barbeiro, verificando se pertence ao mesmo estabelecimento.
  Future<String?> promover({
    required String uid,
    required String idEstabelecimento,
  }) async {
    try {
      final usuario = await _repository.getById(uid);
      if (usuario == null) return 'Usuário não encontrado.';
      if (usuario.idEstabelecimento != idEstabelecimento) {
        return 'Este usuário não pertence ao seu estabelecimento.';
      }
      if (usuario.tipo == TipoUsuario.barbeiro ||
          usuario.tipo == TipoUsuario.dono) {
        return 'Usuário já é barbeiro ou dono.';
      }
      await _repository.updateTipo(uid, TipoUsuario.barbeiro);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> demover(String uid) async {
    try {
      await _repository.updateTipo(uid, TipoUsuario.cliente);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
