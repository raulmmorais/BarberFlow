class Estabelecimento {
  const Estabelecimento({
    required this.id,
    required this.nomeComercial,
    required this.logoUrl,
    required this.corPrimaria,
    required this.corSecundaria,
    required this.diasUteis,
    required this.abertura,
    required this.fechamento,
  });

  final String id;
  final String nomeComercial;
  final String logoUrl;
  final String corPrimaria;
  final String corSecundaria;
  final List<int> diasUteis;
  final String abertura;
  final String fechamento;
}
