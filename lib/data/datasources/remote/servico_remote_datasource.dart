import 'package:barberflow/core/constants/firestore_collections.dart';
import 'package:barberflow/core/errors/app_exception.dart';
import 'package:barberflow/data/models/servico_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicoRemoteDatasource {
  ServicoRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String idEstabelecimento) {
    return _firestore
        .collection(FirestoreCollections.estabelecimentos)
        .doc(idEstabelecimento)
        .collection(FirestoreCollections.servicos);
  }

  Stream<List<ServicoModel>> watchByEstabelecimento(String idEstabelecimento) {
    return _collection(idEstabelecimento).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ServicoModel.fromFirestore(doc, idEstabelecimento))
              .toList(),
        );
  }

  Future<void> create(String idEstabelecimento, ServicoModel servico) async {
    try {
      await _collection(idEstabelecimento).add(servico.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao criar serviço.');
    }
  }

  Future<void> update(ServicoModel servico) async {
    try {
      await _collection(servico.idEstabelecimento)
          .doc(servico.id)
          .update(servico.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao atualizar serviço.');
    }
  }

  Future<void> delete(ServicoModel servico) async {
    try {
      await _collection(servico.idEstabelecimento).doc(servico.id).delete();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao remover serviço.');
    }
  }
}
