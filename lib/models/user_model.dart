/// Modelo de Usuário
///
/// Representa um usuário autenticado no sistema
/// Dados armazenados no Firestore (coleção 'users')
///
/// Campos:
/// - [uid]: ID único do Firebase Auth
/// - [nome]: Nome de usuário (usado para login)
/// - [email]: Email (usado para autenticação e recuperação de senha)
/// - [photoUrl]: URL da foto de perfil no Firebase Storage (opcional)
/// - [telefone]: Telefone do dono (opcional, para notificações)
class UserModel {
  final String uid;
  final String nome;
  final String email;
  final String? photoUrl;
  final String? telefone;

  UserModel({
    required this.uid,
    required this.nome,
    required this.email,
    this.photoUrl,
    this.telefone,
  });

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'photoUrl': photoUrl,
      'telefone': telefone,
    };
  }

  /// Cria objeto a partir de dados do Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      telefone: map['telefone'],
    );
  }
}
