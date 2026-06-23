import 'package:barberflow/data/models/mensalista_model.dart';
import 'package:barberflow/domain/entities/usuario.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.uid,
    required super.nome,
    required super.telefone,
    required super.tipo,
    required super.idEstabelecimento,
    super.isMensalista,
    super.mensalidadePaga,
    super.diaVencimento,
  });

  factory UsuarioModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final mensalista = MensalistaModel.fromMap(
      Map<String, dynamic>.from(data['mensalista'] as Map? ?? {}),
    );

    return UsuarioModel(
      uid: data['uid'] as String? ?? doc.id,
      nome: data['nome'] as String? ?? '',
      telefone: data['telefone'] as String? ?? '',
      tipo: TipoUsuario.fromString(data['tipo'] as String? ?? 'cliente'),
      idEstabelecimento: data['id_estabelecimento'] as String? ?? '',
      isMensalista: mensalista.isMensalista,
      mensalidadePaga: mensalista.pago,
      diaVencimento: mensalista.diaVencimento,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'nome': nome,
        'telefone': telefone,
        'tipo': tipo.value,
        'id_estabelecimento': idEstabelecimento,
        'mensalista': MensalistaModel(
          isMensalista: isMensalista,
          pago: mensalidadePaga,
          diaVencimento: diaVencimento,
        ).toMap(),
      };
}
