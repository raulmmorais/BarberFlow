import 'package:barberflow/data/datasources/remote/usuario_remote_datasource.dart';
import 'package:barberflow/domain/entities/usuario.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';

class UsuarioRepository {
  UsuarioRepository({UsuarioRemoteDatasource? datasource})
      : _datasource = datasource ?? UsuarioRemoteDatasource();

  final UsuarioRemoteDatasource _datasource;

  Future<Usuario?> getById(String uid) => _datasource.getById(uid);

  Stream<Usuario?> watchById(String uid) => _datasource.watchById(uid);

  Stream<List<Usuario>> watchBarbeiros(String idEstabelecimento) =>
      _datasource.watchBarbeiros(idEstabelecimento);

  Future<void> updateTipo(String uid, TipoUsuario tipo) =>
      _datasource.updateTipo(uid, tipo);

  Future<void> updateMensalista(String uid, MensalistaUpdate data) =>
      _datasource.updateMensalista(uid, data);
}
