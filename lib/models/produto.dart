class Produto {
  final String id;
  final String nome;
  final String categoria;
  final double preco;
  final int estoque;
  final int estoqueMinimo;
  final String? imagemBase64;

  Produto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.estoque,
    required this.estoqueMinimo,
    this.imagemBase64,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'categoria': categoria,
        'preco': preco,
        'estoque': estoque,
        'estoqueMinimo': estoqueMinimo,
        'imagemBase64': imagemBase64,
      };

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
        id: json['id'],
        nome: json['nome'],
        categoria: json['categoria'],
        preco: json['preco'],
        estoque: json['estoque'],
        estoqueMinimo: json['estoqueMinimo'] ?? 0,
        imagemBase64: json['imagemBase64'],
      );

  Produto copyWith({int? estoque, String? imagemBase64}) => Produto(
        id: id,
        nome: nome,
        categoria: categoria,
        preco: preco,
        estoque: estoque ?? this.estoque,
        estoqueMinimo: estoqueMinimo,
        imagemBase64: imagemBase64 ?? this.imagemBase64,
      );
}
