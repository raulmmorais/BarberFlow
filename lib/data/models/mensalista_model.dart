class MensalistaModel {
  const MensalistaModel({
    required this.isMensalista,
    required this.pago,
    required this.diaVencimento,
  });

  final bool isMensalista;
  final bool pago;
  final int diaVencimento;

  factory MensalistaModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MensalistaModel(
        isMensalista: false,
        pago: false,
        diaVencimento: 5,
      );
    }
    return MensalistaModel(
      isMensalista: map['is_mensalista'] as bool? ?? false,
      pago: map['pago'] as bool? ?? false,
      diaVencimento: map['dia_vencimento'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toMap() => {
        'is_mensalista': isMensalista,
        'pago': pago,
        'dia_vencimento': diaVencimento,
      };
}
