import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Serviço de Autenticação
///
/// Gerencia:
/// - Login com username ou email
/// - Cadastro de novos usuários
/// - Recuperação de senha
/// - Exclusão de conta (LGPD)
///
/// Utiliza:
/// - Firebase Auth para autenticação
/// - Firestore para armazenar dados do usuário
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService();

  /// Retorna usuário atualmente logado
  User? get currentUser => _auth.currentUser;

  /// Stream de mudanças no estado de autenticação
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  /// Busca dados do usuário no Firestore
  /// Retorna null se não encontrado ou erro
  Future<UserModel?> getUserData() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      } else {
        // Auto-correção: Se o usuário existe no Auth mas não no Firestore (criado manualmente),
        // cria um perfil padrão usando o início do email como nome.
        String nomePadrao = user.email!.split('@')[0];
        // Capitaliza a primeira letra (ex: lucas -> Lucas)
        if (nomePadrao.isNotEmpty) {
          nomePadrao = nomePadrao[0].toUpperCase() + nomePadrao.substring(1);
        }

        final newUser = UserModel(
          uid: user.uid,
          nome: nomePadrao,
          email: user.email!,
          telefone: '',
        );

        // Salva no banco para que nas próximas vezes já exista
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Faz login com username ou email
  ///
  /// Parâmetros:
  /// - [usernameOrEmail]: Nome de usuário ou email
  /// - [password]: Senha do usuário
  ///
  /// Retorna:
  /// - null se sucesso
  /// - String com mensagem de erro se falhar
  ///
  /// Lógica:
  /// 1. Se contém @, é email - usa direto
  /// 2. Senão, busca email no Firestore pelo username
  Future<String?> signIn(String usernameOrEmail, String password) async {
    try {
      String email = usernameOrEmail;

      // Garante persistência LOCAL (essencial para Web e App não deslogarem)
      // Isso diz ao Firebase: "Mantenha o login mesmo fechando o app/aba"
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }

      // Se não contém @, é username - buscar email no Firestore
      if (!usernameOrEmail.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('nome', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return 'Usuário não encontrado';
        }

        email = querySnapshot.docs.first.data()['email'] as String;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Erro ao fazer login';
    }
  }

  /// Cria nova conta de usuário
  ///
  /// Parâmetros:
  /// - [nome]: Nome de usuário (único, usado para login)
  /// - [email]: Email (único, usado para autenticação)
  /// - [password]: Senha (mínimo 6 caracteres)
  ///
  /// Retorna:
  /// - null se sucesso
  /// - String com mensagem de erro se falhar
  ///
  /// Processo:
  /// 1. Verifica se username já existe
  /// 2. Cria conta no Firebase Auth
  /// 3. Salva dados no Firestore
  Future<String?> signUp(String nome, String email, String password,
      {String? telefone}) async {
    // Evita avisos de variáveis não usadas (método desativado)
    // ignore: unused_local_variable
    final args = [nome, email, password, telefone];

    // SEGURANÇA: Cadastro público desativado para comercialização.
    // Retorna erro imediatamente se alguém tentar criar conta.
    return 'O cadastro público está desativado. Contate o administrador.';
  }

  /// Envia email de recuperação de senha
  ///
  /// Parâmetro:
  /// - [email]: Email cadastrado
  ///
  /// Retorna:
  /// - null se email enviado com sucesso
  /// - String com mensagem de erro se falhar
  Future<String?> resetPassword(String usernameOrEmail) async {
    try {
      String email = usernameOrEmail.trim();

      // Se não contém @, é username - buscar email no Firestore
      if (!email.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('nome', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return 'Usuário não encontrado.';
        }

        email = querySnapshot.docs.first.data()['email'] as String;
        email = email.trim();
      } else {
        // Validação extra: Verifica se o email realmente existe no Firestore
        // Isso evita o "falso positivo" do Firebase (proteção de enumeração)
        // e garante que o usuário receba feedback real se errar o email.
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          return 'Este email não possui cadastro no sistema.';
        }
      }

      await _auth.setLanguageCode('pt');
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Erro ao tentar enviar email.';
    }
  }

  /// Atualiza foto de perfil do usuário (Base64)
  ///
  /// Parâmetro:
  /// - [photoBase64]: String Base64 da imagem
  ///
  /// Atualiza no Firestore (sem usar Storage)
  Future<void> updateProfilePhoto(String photoBase64) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    try {
      // Atualiza no Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoBase64,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar foto: $e');
    }
  }

  /// Remove foto de perfil do usuário
  Future<void> removeProfilePhoto() async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    try {
      // Remove do Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': null,
      });
    } catch (e) {
      throw Exception('Erro ao remover foto: $e');
    }
  }

  /// Desloga usuário atual
  Future<void> signOut() async => await _auth.signOut();

  /// Exclui a conta do usuário do Firebase
  /// Conformidade LGPD Art. 18 - Direito de exclusão
  ///
  /// Processo:
  /// 1. Remove documento do Firestore
  /// 2. Deleta conta do Firebase Auth
  ///
  /// Throws:
  /// - Exception se usuário não autenticado ou erro
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    try {
      // Deletar documento do Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Deletar conta do Firebase Auth
      await user.delete();
    } catch (e) {
      throw Exception('Erro ao excluir conta: $e');
    }
  }

  /// Traduz códigos de erro do Firebase para mensagens em português
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já cadastrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres)';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde';
      default:
        return 'Erro ao processar. Tente novamente';
    }
  }
}
