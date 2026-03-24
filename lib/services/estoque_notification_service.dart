import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Serviço de Notificação de Estoque Baixo
///
/// Verifica periodicamente produtos com estoque abaixo do mínimo
/// e envia notificações no navegador
class EstoqueNotificationService {
  static Timer? _timer;
  static bool _isRunning = false;
  static final Set<String> _notifiedProducts = {};

  /// Inicializa o serviço de notificações de estoque
  /// Verifica a cada 1 hora
  static Future<void> init() async {
    if (!kIsWeb) return;

    try {
      final permission = await _requestPermission();
      if (permission == 'granted') {
        _startChecking();
      }
    } catch (e) {
      debugPrint('Notificações de estoque não suportadas: $e');
    }
  }

  /// Solicita permissão para enviar notificações
  static Future<String> _requestPermission() async {
    final current = web.Notification.permission;
    if (current == 'granted') return 'granted';
    if (current == 'denied') return 'denied';

    try {
      final result = await web.Notification.requestPermission().toDart;
      return result.toDart;
    } catch (e) {
      return 'denied';
    }
  }

  /// Inicia verificação periódica de estoque
  static void _startChecking() {
    if (_isRunning) return;

    _isRunning = true;
    _checkEstoque(); // Verifica imediatamente

    // Verifica a cada 1 hora
    _timer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkEstoque(),
    );

    debugPrint('Serviço de notificação de estoque iniciado');
  }

  /// Verifica produtos com estoque baixo e notifica
  static void _checkEstoque() {
    try {
      final storage = StorageService();
      final produtos = storage.getProdutos();

      final produtosBaixos =
          produtos.where((p) => p.estoque <= p.estoqueMinimo).toList();

      if (produtosBaixos.isEmpty) {
        // Limpa lista de notificados se não há mais produtos baixos
        _notifiedProducts.clear();
        return;
      }

      // Notifica apenas produtos que ainda não foram notificados
      for (final produto in produtosBaixos) {
        if (!_notifiedProducts.contains(produto.id)) {
          _sendNotification(
              produto.nome, produto.estoque, produto.estoqueMinimo);
          _notifiedProducts.add(produto.id);
        }
      }

      // Remove da lista produtos que não estão mais com estoque baixo
      _notifiedProducts
          .removeWhere((id) => !produtosBaixos.any((p) => p.id == id));
    } catch (e) {
      debugPrint('Erro ao verificar estoque: $e');
    }
  }

  /// Envia notificação de estoque baixo
  static void _sendNotification(
      String nomeProduto, int estoqueAtual, int estoqueMinimo) {
    if (web.Notification.permission != 'granted') return;

    web.Notification(
      '⚠️ Estoque Baixo!',
      web.NotificationOptions(
        body: '$nomeProduto: $estoqueAtual un (mínimo: $estoqueMinimo un)',
        icon: 'icons/Icon-192.png',
        badge: 'icons/Icon-192.png',
        tag: 'estoque-baixo-$nomeProduto', // Evita duplicatas
        requireInteraction: true, // Notificação fica até ser fechada
      ),
    );

    debugPrint('Notificação enviada: $nomeProduto com estoque baixo');
  }

  /// Força verificação imediata (útil após ajustar estoque)
  static void checkNow() {
    _checkEstoque();
  }

  /// Para o serviço
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _notifiedProducts.clear();
    debugPrint('Serviço de notificação de estoque parado');
  }

  /// Reinicia o serviço
  static void restart() {
    stop();
    init();
  }

  /// Libera recursos
  static void dispose() {
    stop();
  }
}
