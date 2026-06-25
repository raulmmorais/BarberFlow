import 'package:barberflow/core/constants/firestore_collections.dart';
import 'package:barberflow/core/errors/app_exception.dart';
import 'package:barberflow/data/models/estabelecimento_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstabelecimentoRemoteDatasource {
  EstabelecimentoRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<EstabelecimentoModel?> getById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.estabelecimentos)
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return EstabelecimentoModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao buscar estabelecimento.');
    }
  }

  Stream<EstabelecimentoModel?> watchById(String id) {
    return _firestore
        .collection(FirestoreCollections.estabelecimentos)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return EstabelecimentoModel.fromFirestore(doc);
    });
  }

  Future<void> save(EstabelecimentoModel estabelecimento) async {
    try {
      await _firestore
          .collection(FirestoreCollections.estabelecimentos)
          .doc(estabelecimento.id)
          .set(estabelecimento.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao salvar estabelecimento.');
    }
  }

  Future<bool> validateCodigoConvite(String estabId, String code) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.estabelecimentos)
          .doc(estabId)
          .get();
      if (!doc.exists) return false;
      final stored = doc.data()?['codigo_convite'] as String?;
      return stored != null && stored.isNotEmpty && stored == code;
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao validar código de convite.');
    }
  }
}
