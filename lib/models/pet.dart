/// Modelo de Pet
/// 
/// Representa um animal de estimação cadastrado
/// Vinculado a um cliente através de [clienteId]
/// 
/// Campos:
/// - [id]: Identificador único (UUID)
/// - [nome]: Nome do pet
/// - [raca]: Raça do animal (ex: Poodle, SRD, Persa)
/// - [porte]: Tamanho do animal (P, M, G, GG) - usado para preço
/// - [clienteId]: ID do cliente proprietário
/// - [observacoes]: Informações adicionais (opcional)
///   Ex: alergias, comportamento, cuidados especiais
/// - [photoUrl]: Foto do pet em Base64 (opcional)
class Pet {
  final String id;
  final String nome;
  final String raca;
  final String porte; // P, M, G, GG
  final String clienteId;
  final String? observacoes;
  final String? photoUrl;

  Pet({
    required this.id,
    required this.nome,
    required this.raca,
    required this.porte,
    required this.clienteId,
    this.observacoes,
    this.photoUrl,
  });

  /// Converte objeto para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'raca': raca,
        'porte': porte,
        'clienteId': clienteId,
        'observacoes': observacoes,
        'photoUrl': photoUrl,
      };

  /// Cria objeto a partir de JSON
  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'],
        nome: json['nome'],
        raca: json['raca'],
        porte: json['porte'],
        clienteId: json['clienteId'],
        observacoes: json['observacoes'],
        photoUrl: json['photoUrl'],
      );
}
