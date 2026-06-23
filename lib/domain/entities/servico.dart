class Servico {
  const Servico({
    required this.id,
    required this.idEstabelecimento,
    required this.nome,
    required this.preco,
    required this.duracaoMinutos,
  });

  final String id;
  final String idEstabelecimento;
  final String nome;
  final double preco;
  final int duracaoMinutos;
}
