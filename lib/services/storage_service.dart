import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cliente.dart';
import '../models/pet.dart';
import '../models/agendamento.dart';
import '../models/produto.dart';
import '../models/servico.dart';
import '../models/categoria_produto.dart';

/// Serviço de armazenamento local usando SharedPreferences
///
/// Responsável por:
/// - Persistir dados localmente no navegador/dispositivo
/// - Serializar/deserializar objetos para JSON
/// - Gerenciar cache de dados
///
/// ATENÇÃO LGPD:
/// - Dados são armazenados em texto puro (sem criptografia)
/// - Para produção, considere usar flutter_secure_storage
/// - Implemente política de retenção de dados
class StorageService {
  // Chaves de armazenamento
  static const _clientesKey = 'clientes';
  static const _petsKey = 'pets';
  static const _agendamentosKey = 'agendamentos';
  static const _produtosKey = 'produtos';
  static const _servicosKey = 'servicos';
  static const _categoriasKey = 'categorias_produtos';
  static const _themeKey = 'app_theme_mode'; // dark ou light

  static SharedPreferences? _prefs;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa o SharedPreferences
  /// Deve ser chamado antes de usar qualquer método
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Getter seguro para SharedPreferences
  /// Lança erro se init() não foi chamado
  SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('StorageService.init() não foi chamado');
    }
    return _prefs!;
  }

  /// Retorna o UID do usuário atual para salvar no caminho correto do banco
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Referência para coleção do usuário no Firestore
  DocumentReference? get _userDoc =>
      _uid != null ? _firestore.collection('users').doc(_uid) : null;

  // ========== CLIENTES ==========

  /// Retorna lista de todos os clientes cadastrados
  List<Cliente> getClientes() {
    final data = _p.getString(_clientesKey);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List)
          .map((j) => Cliente.fromJson(j))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Salva lista de clientes
  /// Sobrescreve dados existentes
  Future<void> saveClientes(List<Cliente> clientes) async {
    final json = jsonEncode(clientes.map((c) => c.toJson()).toList());
    await _p.setString(_clientesKey, json);

    // Sync com Firestore (Backup na nuvem)
    if (_userDoc != null) {
      // Salvamos a lista inteira como JSON no Firestore
      await _userDoc!
          .collection('backup_data')
          .doc('clientes')
          .set({'data': json});
    }
  }

  // ========== PETS ==========

  /// Retorna lista de todos os pets cadastrados
  List<Pet> getPets() {
    final data = _p.getString(_petsKey);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List).map((j) => Pet.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Salva lista de pets
  Future<void> savePets(List<Pet> pets) async {
    final json = jsonEncode(pets.map((p) => p.toJson()).toList());
    await _p.setString(_petsKey, json);

    if (_userDoc != null) {
      await _userDoc!.collection('backup_data').doc('pets').set({'data': json});
    }
  }

  // ========== AGENDAMENTOS ==========

  /// Retorna lista de todos os agendamentos
  List<Agendamento> getAgendamentos() {
    final data = _p.getString(_agendamentosKey);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List)
          .map((j) => Agendamento.fromJson(j))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Salva lista de agendamentos
  Future<void> saveAgendamentos(List<Agendamento> agendamentos) async {
    final json = jsonEncode(agendamentos.map((a) => a.toJson()).toList());
    await _p.setString(_agendamentosKey, json);

    if (_userDoc != null) {
      await _userDoc!
          .collection('backup_data')
          .doc('agendamentos')
          .set({'data': json});
    }
  }

  // ========== PRODUTOS ==========

  /// Retorna lista de produtos cadastrados
  List<Produto> getProdutos() {
    final data = _p.getString(_produtosKey);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List)
          .map((j) => Produto.fromJson(j))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Salva lista de produtos
  Future<void> saveProdutos(List<Produto> produtos) async {
    final json = jsonEncode(produtos.map((p) => p.toJson()).toList());
    await _p.setString(_produtosKey, json);

    if (_userDoc != null) {
      await _userDoc!
          .collection('backup_data')
          .doc('produtos')
          .set({'data': json});
    }
  }

  // ========== SERVIÇOS ==========

  /// Retorna lista de serviços
  /// Se não houver dados, retorna lista padrão
  List<Servico> getServicos() {
    final data = _p.getString(_servicosKey);
    if (data == null) return Servico.defaults();
    try {
      return (jsonDecode(data) as List)
          .map((j) => Servico.fromJson(j))
          .toList();
    } catch (e) {
      return Servico.defaults();
    }
  }

  /// Salva lista de serviços
  Future<void> saveServicos(List<Servico> servicos) async {
    final json = jsonEncode(servicos.map((s) => s.toJson()).toList());
    await _p.setString(_servicosKey, json);
  }

  // ========== CATEGORIAS DE PRODUTOS ==========

  /// Retorna lista de categorias de produtos
  /// Se não houver dados, retorna lista padrão
  List<CategoriaProduto> getCategoriasProdutos() {
    final data = _p.getString(_categoriasKey);
    if (data == null) return CategoriaProduto.defaults();
    try {
      return (jsonDecode(data) as List)
          .map((j) => CategoriaProduto.fromJson(j))
          .toList();
    } catch (e) {
      return CategoriaProduto.defaults();
    }
  }

  /// Salva lista de categorias
  Future<void> saveCategoriasProdutos(List<CategoriaProduto> categorias) async {
    final json = jsonEncode(categorias.map((c) => c.toJson()).toList());
    await _p.setString(_categoriasKey, json);
  }

  // ========== TEMA (CONFIGURAÇÕES) ==========

  /// Retorna true se o tema for escuro, false se claro/sistema
  bool isDarkMode() {
    final theme = _p.getString(_themeKey);
    return theme == 'dark';
  }

  Future<void> saveThemeMode(bool isDark) async {
    await _p.setString(_themeKey, isDark ? 'dark' : 'light');
  }

  // ========== LIMPEZA DE DADOS (LGPD) ==========

  /// Limpa TODOS os dados armazenados localmente
  /// Usado quando usuário solicita exclusão de conta (Art. 18 LGPD)
  Future<void> clearAllData() async {
    await _p.clear();
  }

  /// Remove apenas dados de um cliente específico
  Future<void> deleteClienteData(String clienteId) async {
    // Remove cliente
    final clientes = getClientes();
    clientes.removeWhere((c) => c.id == clienteId);
    await saveClientes(clientes);

    // Remove pets do cliente
    final pets = getPets();
    pets.removeWhere((p) => p.clienteId == clienteId);
    await savePets(pets);

    // Remove agendamentos dos pets do cliente
    final agendamentos = getAgendamentos();
    final petIds =
        pets.where((p) => p.clienteId == clienteId).map((p) => p.id).toList();
    agendamentos.removeWhere((a) => petIds.contains(a.petId));
    await saveAgendamentos(agendamentos);
  }

  // ========== SINCRONIZAÇÃO ==========

  /// Baixa dados do Firestore e atualiza o Cache Local
  Future<void> sincronizarDados() async {
    if (_userDoc == null) return;

    try {
      final collections = [
        {'key': _clientesKey, 'doc': 'clientes'},
        {'key': _petsKey, 'doc': 'pets'},
        {'key': _agendamentosKey, 'doc': 'agendamentos'},
        {'key': _produtosKey, 'doc': 'produtos'},
        {'key': _servicosKey, 'doc': 'servicos'},
        {'key': _categoriasKey, 'doc': 'categorias_produtos'},
      ];

      for (var item in collections) {
        final docSnapshot =
            await _userDoc!.collection('backup_data').doc(item['doc']).get();
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final dataMap = docSnapshot.data() as Map<String, dynamic>;
          if (dataMap.containsKey('data')) {
            final jsonCloud = dataMap['data'] as String;
            if (jsonCloud.isNotEmpty && jsonCloud != '[]') {
              await _p.setString(item['key']!, jsonCloud);
            }
          }
        }
      }
    } catch (e) {
      // Ignora erro silenciosamente ou loga se necessário
    }
  }
}
