import 'package:barberflow/data/models/usuario_model.dart';
import 'package:barberflow/data/repositories/auth_repository.dart';
import 'package:barberflow/data/repositories/estabelecimento_repository.dart';
import 'package:barberflow/domain/entities/usuario.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthRepository? repository,
    EstabelecimentoRepository? estabRepository,
  })  : _repository = repository ?? AuthRepository(),
        _estabRepository = estabRepository ?? EstabelecimentoRepository() {
    _repository.authStateChanges.listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  final EstabelecimentoRepository _estabRepository;

  User? _firebaseUser;
  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;
  bool _needsProfileCompletion = false;

  User? get firebaseUser => _firebaseUser;
  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get needsProfileCompletion => _needsProfileCompletion;

  Future<void> loadCurrentUsuario() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasProfile = await _repository.hasUsuarioProfile();
      _needsProfileCompletion = isAuthenticated && !hasProfile;
      _usuario = hasProfile ? await _repository.getCurrentUsuario() : null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    return _runAuthAction(() async {
      await _repository.signIn(email, password);
      await loadCurrentUsuario();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nome,
    required String telefone,
    required String idEstabelecimento,
    TipoUsuario tipo = TipoUsuario.cliente,
  }) async {
    return _runAuthAction(() async {
      await _repository.signUp(
        email: email,
        password: password,
        usuario: UsuarioModel(
          uid: '',
          nome: nome,
          telefone: telefone,
          tipo: tipo,
          idEstabelecimento: idEstabelecimento,
        ),
      );
      await loadCurrentUsuario();
    });
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final signedIn = await _repository.signInWithGoogle();
      if (!signedIn) return false;
      await loadCurrentUsuario();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeProfile({
    required String nome,
    required String telefone,
    required String idEstabelecimento,
    TipoUsuario tipo = TipoUsuario.cliente,
  }) async {
    return _runAuthAction(() async {
      await _repository.saveUsuarioProfile(
        UsuarioModel(
          uid: _firebaseUser!.uid,
          nome: nome,
          telefone: telefone,
          tipo: tipo,
          idEstabelecimento: idEstabelecimento,
        ),
      );
      _needsProfileCompletion = false;
      _usuario = await _repository.getCurrentUsuario();
    });
  }

  Future<bool> validateInviteCode(String estabId, String code) async {
    try {
      return await _estabRepository.validateCodigoConvite(estabId, code);
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _usuario = null;
    _needsProfileCompletion = false;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
