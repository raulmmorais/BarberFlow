import 'package:barberflow/domain/enums/agendamento_status.dart';

class Agendamento {
  const Agendamento({
    required this.id,
    required this.idEstabelecimento,
    required this.idCliente,
    required this.idBarbeiro,
    required this.servicosIds,
    required this.dataHora,
    required this.duracaoTotalMinutos,
    required this.status,
    this.nomeClienteManual,
    this.comentarioPosCorte,
    this.fotoLocalPath,
  });

  final String id;
  final String idEstabelecimento;
  final String idCliente;
  final String? nomeClienteManual;
  final String idBarbeiro;
  final List<String> servicosIds;
  final DateTime dataHora;
  final int duracaoTotalMinutos;
  final AgendamentoStatus status;
  final String? comentarioPosCorte;
  final String? fotoLocalPath;

  bool get isManual => idCliente == 'manual';
}
