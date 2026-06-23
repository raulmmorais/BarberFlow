import 'package:barberflow/domain/enums/tipo_usuario.dart';

class Usuario {
  const Usuario({
    required this.uid,
    required this.nome,
    required this.telefone,
    required this.tipo,
    required this.idEstabelecimento,
    this.isMensalista = false,
    this.mensalidadePaga = false,
    this.diaVencimento = 5,
  });

  final String uid;
  final String nome;
  final String telefone;
  final TipoUsuario tipo;
  final String idEstabelecimento;
  final bool isMensalista;
  final bool mensalidadePaga;
  final int diaVencimento;
}
