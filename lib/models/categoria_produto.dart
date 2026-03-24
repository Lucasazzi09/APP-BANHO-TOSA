/// Modelo de Categoria de Produto
/// 
/// Permite criar categorias personalizadas para organizar produtos
class CategoriaProduto {
  final String id;
  final String nome;
  final String icone; // Nome do ícone Material

  CategoriaProduto({
    required this.id,
    required this.nome,
    required this.icone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'icone': icone,
      };

  factory CategoriaProduto.fromJson(Map<String, dynamic> json) => CategoriaProduto(
        id: json['id'],
        nome: json['nome'],
        icone: json['icone'] ?? 'category',
      );

  /// Categorias padrão do sistema
  static List<CategoriaProduto> defaults() => [
        CategoriaProduto(id: '1', nome: 'Shampoo', icone: 'soap'),
        CategoriaProduto(id: '2', nome: 'Condicionador', icone: 'water_drop'),
        CategoriaProduto(id: '3', nome: 'Perfume', icone: 'air'),
        CategoriaProduto(id: '4', nome: 'Acessório', icone: 'shopping_bag'),
        CategoriaProduto(id: '5', nome: 'Medicamento', icone: 'medication'),
        CategoriaProduto(id: '6', nome: 'Ração', icone: 'pets'),
        CategoriaProduto(id: '7', nome: 'Brinquedo', icone: 'toys'),
        CategoriaProduto(id: '8', nome: 'Outro', icone: 'category'),
      ];
}
