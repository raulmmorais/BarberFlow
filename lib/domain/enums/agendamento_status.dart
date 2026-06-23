enum AgendamentoStatus {
  pendente('pendente'),
  confirmado('confirmado'),
  concluido('concluido'),
  recusado('recusado');

  const AgendamentoStatus(this.value);

  final String value;

  static AgendamentoStatus fromString(String value) {
    return AgendamentoStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AgendamentoStatus.pendente,
    );
  }
}
