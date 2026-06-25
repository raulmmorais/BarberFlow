import 'package:barberflow/core/constants/firestore_collections.dart';
import 'package:barberflow/core/errors/app_exception.dart';
import 'package:barberflow/data/models/agendamento_model.dart';
import 'package:barberflow/domain/enums/agendamento_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoRemoteDatasource {
  AgendamentoRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.agendamentos);

  Stream<List<AgendamentoModel>> watchByCliente(String idCliente) {
    return _collection
        .where('id_cliente', isEqualTo: idCliente)
        .orderBy('data_hora', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AgendamentoModel.fromFirestore).toList());
  }

  Stream<List<AgendamentoModel>> watchByBarbeiro(
    String idBarbeiro,
    DateTime day,
  ) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _collection
        .where('id_barbeiro', isEqualTo: idBarbeiro)
        .where('data_hora', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data_hora', isLessThan: Timestamp.fromDate(end))
        .orderBy('data_hora')
        .snapshots()
        .map((s) => s.docs.map(AgendamentoModel.fromFirestore).toList());
  }

  Future<String> create(AgendamentoModel agendamento) async {
    try {
      final doc = await _collection.add(agendamento.toFirestore());
      return doc.id;
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao criar agendamento.');
    }
  }

  Future<void> updateStatus(String id, AgendamentoStatus status) async {
    try {
      await _collection.doc(id).update({'status': status.value});
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao atualizar agendamento.');
    }
  }

  Future<void> concluirAtendimento({
    required String id,
    String? comentario,
    String? fotoLocalPath,
  }) async {
    try {
      await _collection.doc(id).update({
        'status': AgendamentoStatus.concluido.value,
        if (comentario != null) 'comentario_pos_corte': comentario,
        if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao concluir atendimento.');
    }
  }
}
