/// Modelo de Cliente
/// 
/// Representa um cliente do pet shop
/// Armazena dados pessoais conforme LGPD
/// 
/// Campos:
/// - [id]: Identificador único (UUID)
/// - [nome]: Nome completo do cliente
/// - [telefone]: Telefone para contato (formato livre)
/// - [email]: Email para comunicação
/// - [endereco]: Endereço completo para entrega/coleta
class Cliente {
  final String id;
  final String nome;
  final String telefone;
  final String email;
  final String endereco;

  Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.endereco,
  });

  /// Converte objeto para JSON (serialização)
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'endereco': endereco,
      };

  /// Cria objeto a partir de JSON (desserialização)
  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json['id'],
        nome: json['nome'],
        telefone: json['telefone'],
        email: json['email'],
        endereco: json['endereco'],
      );
}
