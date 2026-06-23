class HorarioFuncionamentoModel {
  const HorarioFuncionamentoModel({
    required this.diasUteis,
    required this.abertura,
    required this.fechamento,
  });

  final List<int> diasUteis;
  final String abertura;
  final String fechamento;

  factory HorarioFuncionamentoModel.fromMap(Map<String, dynamic> map) {
    return HorarioFuncionamentoModel(
      diasUteis: List<int>.from(map['dias_uteis'] as List? ?? [1, 2, 3, 4, 5, 6]),
      abertura: map['abertura'] as String? ?? '09:00',
      fechamento: map['fechamento'] as String? ?? '19:00',
    );
  }

  Map<String, dynamic> toMap() => {
        'dias_uteis': diasUteis,
        'abertura': abertura,
        'fechamento': fechamento,
      };
}
