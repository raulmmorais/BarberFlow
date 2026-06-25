import 'package:barberflow/data/datasources/remote/estabelecimento_remote_datasource.dart';
import 'package:barberflow/data/models/estabelecimento_model.dart';
import 'package:barberflow/domain/entities/estabelecimento.dart';

class EstabelecimentoRepository {
  EstabelecimentoRepository({EstabelecimentoRemoteDatasource? datasource})
      : _datasource = datasource ?? EstabelecimentoRemoteDatasource();

  final EstabelecimentoRemoteDatasource _datasource;

  Future<Estabelecimento?> getById(String id) => _datasource.getById(id);

  Stream<Estabelecimento?> watchById(String id) => _datasource.watchById(id);

  Future<void> save(EstabelecimentoModel estabelecimento) =>
      _datasource.save(estabelecimento);

  Future<bool> validateCodigoConvite(String estabId, String code) =>
      _datasource.validateCodigoConvite(estabId, code);
}
