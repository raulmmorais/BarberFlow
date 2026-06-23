import 'package:barberflow/data/datasources/remote/servico_remote_datasource.dart';
import 'package:barberflow/data/models/servico_model.dart';
import 'package:barberflow/domain/entities/servico.dart';

class ServicoRepository {
  ServicoRepository({ServicoRemoteDatasource? datasource})
      : _datasource = datasource ?? ServicoRemoteDatasource();

  final ServicoRemoteDatasource _datasource;

  Stream<List<Servico>> watchByEstabelecimento(String idEstabelecimento) =>
      _datasource.watchByEstabelecimento(idEstabelecimento);

  Future<void> create(String idEstabelecimento, ServicoModel servico) =>
      _datasource.create(idEstabelecimento, servico);

  Future<void> update(ServicoModel servico) => _datasource.update(servico);

  Future<void> delete(ServicoModel servico) => _datasource.delete(servico);
}
