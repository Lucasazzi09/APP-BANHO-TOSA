class Servico {
  final String id;
  final String nome;
  final Map<String, double> precosPorPorte; // P, M, G, GG

  Servico({
    required this.id,
    required this.nome,
    required this.precosPorPorte,
  });

  double getPreco(String porte) => precosPorPorte[porte] ?? 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'precosPorPorte': precosPorPorte,
      };

  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
        id: json['id'],
        nome: json['nome'],
        precosPorPorte: Map<String, double>.from(
          (json['precosPorPorte'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())),
        ),
      );

  static List<Servico> defaults() => [
        Servico(id: '1', nome: 'Banho', precosPorPorte: {'P': 30, 'M': 45, 'G': 60, 'GG': 80}),
        Servico(id: '2', nome: 'Tosa', precosPorPorte: {'P': 35, 'M': 50, 'G': 70, 'GG': 90}),
        Servico(id: '3', nome: 'Banho e Tosa', precosPorPorte: {'P': 55, 'M': 80, 'G': 110, 'GG': 150}),
        Servico(id: '4', nome: 'Hidratação', precosPorPorte: {'P': 25, 'M': 35, 'G': 45, 'GG': 60}),
      ];
}
