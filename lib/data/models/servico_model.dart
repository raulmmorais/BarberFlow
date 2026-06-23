import 'package:barberflow/domain/entities/servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicoModel extends Servico {
  const ServicoModel({
    required super.id,
    required super.idEstabelecimento,
    required super.nome,
    required super.preco,
    required super.duracaoMinutos,
  });

  factory ServicoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String idEstabelecimento,
  ) {
    final data = doc.data() ?? {};
    return ServicoModel(
      id: doc.id,
      idEstabelecimento: idEstabelecimento,
      nome: data['nome'] as String? ?? '',
      preco: (data['preco'] as num?)?.toDouble() ?? 0,
      duracaoMinutos: data['duracao_minutos'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome': nome,
        'preco': preco,
        'duracao_minutos': duracaoMinutos,
      };
}
