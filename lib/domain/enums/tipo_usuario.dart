enum TipoUsuario {
  cliente('cliente'),
  barbeiro('barbeiro'),
  dono('dono');

  const TipoUsuario(this.value);

  final String value;

  static TipoUsuario fromString(String value) {
    return TipoUsuario.values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => TipoUsuario.cliente,
    );
  }
}
