import 'package:barberflow/domain/entities/agendamento.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoModel extends Agendamento {
  const AgendamentoModel({
    required super.id,
    required super.idEstabelecimento,
    required super.idCliente,
    required super.idBarbeiro,
    required super.servicosIds,
    required super.dataHora,
    required super.duracaoTotalMinutos,
    required super.status,
    super.nomeClienteManual,
    super.comentarioPosCorte,
    super.fotoLocalPath,
  });

  factory AgendamentoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AgendamentoModel(
      id: doc.id,
      idEstabelecimento: data['id_estabelecimento'] as String? ?? '',
      idCliente: data['id_cliente'] as String? ?? '',
      nomeClienteManual: data['nome_cliente_manual'] as String?,
      idBarbeiro: data['id_barbeiro'] as String? ?? '',
      servicosIds: List<String>.from(data['servicos_ids'] as List? ?? []),
      dataHora: (data['data_hora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duracaoTotalMinutos: data['duracao_total_minutos'] as int? ?? 30,
      status: AgendamentoStatus.fromString(
        data['status'] as String? ?? 'pendente',
      ),
      comentarioPosCorte: data['comentario_pos_corte'] as String?,
      fotoLocalPath: data['foto_local_path'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id_estabelecimento': idEstabelecimento,
        'id_cliente': idCliente,
        if (nomeClienteManual != null) 'nome_cliente_manual': nomeClienteManual,
        'id_barbeiro': idBarbeiro,
        'servicos_ids': servicosIds,
        'data_hora': Timestamp.fromDate(dataHora),
        'duracao_total_minutos': duracaoTotalMinutos,
        'status': status.value,
        if (comentarioPosCorte != null) 'comentario_pos_corte': comentarioPosCorte,
        if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      };
}
