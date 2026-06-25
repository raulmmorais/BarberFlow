import 'package:barberflow/data/datasources/local/image_local_datasource.dart';
import 'package:barberflow/data/datasources/remote/agendamento_remote_datasource.dart';
import 'package:barberflow/data/models/agendamento_model.dart';
import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';

class AgendamentoRepository {
  AgendamentoRepository({
    AgendamentoRemoteDatasource? remoteDatasource,
    ImageLocalDatasource? localDatasource,
  })  : _remoteDatasource = remoteDatasource ?? AgendamentoRemoteDatasource(),
        _localDatasource = localDatasource ?? ImageLocalDatasource();

  final AgendamentoRemoteDatasource _remoteDatasource;
  final ImageLocalDatasource _localDatasource;

  Stream<List<Agendamento>> watchByCliente(String idCliente) =>
      _remoteDatasource.watchByCliente(idCliente);

  Stream<List<Agendamento>> watchByBarbeiro(String idBarbeiro, DateTime day) =>
      _remoteDatasource.watchByBarbeiro(idBarbeiro, day);

  Future<String> create(AgendamentoModel agendamento) =>
      _remoteDatasource.create(agendamento);

  Future<void> updateStatus(String id, AgendamentoStatus status) =>
      _remoteDatasource.updateStatus(id, status);

  Future<void> atualizarMidia({
    required String id,
    String? comentario,
    String? fotoLocalPath,
  }) =>
      _remoteDatasource.atualizarMidia(
        id: id,
        comentario: comentario,
        fotoLocalPath: fotoLocalPath,
      );

  Future<void> concluirAtendimento({
    required String id,
    String? comentario,
    bool capturarFoto = false,
  }) async {
    String? fotoPath;
    if (capturarFoto) {
      fotoPath = await _localDatasource.capturePhoto(id);
    }
    await _remoteDatasource.concluirAtendimento(
      id: id,
      comentario: comentario,
      fotoLocalPath: fotoPath,
    );
  }
}
