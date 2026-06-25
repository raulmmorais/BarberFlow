import 'package:barberflow/core/constants/firestore_collections.dart';
import 'package:barberflow/core/errors/app_exception.dart';
import 'package:barberflow/data/models/usuario_model.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioRemoteDatasource {
  UsuarioRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UsuarioModel?> getById(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.usuarios)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UsuarioModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao buscar usuário.');
    }
  }

  Stream<UsuarioModel?> watchById(String uid) {
    return _firestore
        .collection(FirestoreCollections.usuarios)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UsuarioModel.fromFirestore(doc);
    });
  }

  Stream<List<UsuarioModel>> watchBarbeiros(String idEstabelecimento) {
    return _firestore
        .collection(FirestoreCollections.usuarios)
        .where('id_estabelecimento', isEqualTo: idEstabelecimento)
        .where('tipo', whereIn: [TipoUsuario.barbeiro.value, TipoUsuario.dono.value])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(UsuarioModel.fromFirestore).toList());
  }

  Future<void> updateTipo(String uid, TipoUsuario tipo) async {
    try {
      await _firestore
          .collection(FirestoreCollections.usuarios)
          .doc(uid)
          .update({'tipo': tipo.value});
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao atualizar tipo de usuário.');
    }
  }

  Future<void> updateMensalista(String uid, MensalistaUpdate data) async {
    try {
      await _firestore.collection(FirestoreCollections.usuarios).doc(uid).update({
        'mensalista': {
          'is_mensalista': data.isMensalista,
          'pago': data.pago,
          'dia_vencimento': data.diaVencimento,
        },
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao atualizar mensalista.');
    }
  }
}

class MensalistaUpdate {
  const MensalistaUpdate({
    required this.isMensalista,
    required this.pago,
    required this.diaVencimento,
  });

  final bool isMensalista;
  final bool pago;
  final int diaVencimento;
}
