import 'package:barberflow/data/models/cores_tema_model.dart';
import 'package:barberflow/data/models/horario_funcionamento_model.dart';
import 'package:barberflow/domain/entities/estabelecimento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstabelecimentoModel extends Estabelecimento {
  const EstabelecimentoModel({
    required super.id,
    required super.nomeComercial,
    required super.logoUrl,
    required super.corPrimaria,
    required super.corSecundaria,
    required super.diasUteis,
    required super.abertura,
    required super.fechamento,
  });

  factory EstabelecimentoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final cores = CoresTemaModel.fromMap(
      Map<String, dynamic>.from(data['cores_tema'] as Map? ?? {}),
    );
    final horario = HorarioFuncionamentoModel.fromMap(
      Map<String, dynamic>.from(data['horario_funcionamento'] as Map? ?? {}),
    );

    return EstabelecimentoModel(
      id: doc.id,
      nomeComercial: data['nome_comercial'] as String? ?? '',
      logoUrl: data['logo_url'] as String? ?? '',
      corPrimaria: cores.primary,
      corSecundaria: cores.secondary,
      diasUteis: horario.diasUteis,
      abertura: horario.abertura,
      fechamento: horario.fechamento,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nome_comercial': nomeComercial,
        'logo_url': logoUrl,
        'cores_tema': CoresTemaModel(
          primary: corPrimaria,
          secondary: corSecundaria,
        ).toMap(),
        'horario_funcionamento': HorarioFuncionamentoModel(
          diasUteis: diasUteis,
          abertura: abertura,
          fechamento: fechamento,
        ).toMap(),
      };
}
