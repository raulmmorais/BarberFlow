import 'package:barberflow/data/datasources/remote/auth_remote_datasource.dart';
import 'package:barberflow/data/datasources/remote/usuario_remote_datasource.dart';
import 'package:barberflow/data/models/usuario_model.dart';
import 'package:barberflow/domain/entities/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({
    AuthRemoteDatasource? authDatasource,
    UsuarioRemoteDatasource? usuarioDatasource,
  })  : _authDatasource = authDatasource ?? AuthRemoteDatasource(),
        _usuarioDatasource = usuarioDatasource ?? UsuarioRemoteDatasource();

  final AuthRemoteDatasource _authDatasource;
  final UsuarioRemoteDatasource _usuarioDatasource;

  Stream<User?> get authStateChanges => _authDatasource.authStateChanges;

  User? get currentUser => _authDatasource.currentUser;

  Future<void> signIn(String email, String password) {
    return _authDatasource.signIn(email, password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required UsuarioModel usuario,
  }) {
    return _authDatasource.signUp(
      email: email,
      password: password,
      usuario: usuario,
    );
  }

  Future<bool> signInWithGoogle() => _authDatasource.signInWithGoogle();

  Future<void> saveUsuarioProfile(UsuarioModel usuario) {
    return _authDatasource.saveUsuarioProfile(usuario);
  }

  Future<bool> hasUsuarioProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return false;
    return _authDatasource.hasUsuarioProfile(uid);
  }

  Future<void> signOut() => _authDatasource.signOut();

  Future<Usuario?> getCurrentUsuario() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return _usuarioDatasource.getById(uid);
  }

  Stream<Usuario?> watchCurrentUsuario() {
    final uid = currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _usuarioDatasource.watchById(uid);
  }
}
