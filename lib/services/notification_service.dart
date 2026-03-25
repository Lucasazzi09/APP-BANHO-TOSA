import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';
import '../models/pet.dart';
import '../models/cliente.dart';
import '../models/agendamento.dart';
import 'storage_service.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Serviço de notificações push para Web
///
/// Funcionalidades:
/// - Solicita permissão de notificações ao usuário
/// - Verifica agendamentos periodicamente
/// - Envia notificações 1h antes e na hora do agendamento
///
/// OTIMIZAÇÃO:
/// - Timer só é iniciado se houver agendamentos pendentes
/// - Verificação a cada 15 minutos (configurável)
class NotificationService {
  static Timer? _timer;
  static bool _isRunning = false;

  /// Inicializa o serviço de notificações
  /// Apenas para plataforma Web
  static Future<void> init() async {
    if (!kIsWeb) return;

    try {
      final permission = await _requestPermission();
      if (permission == 'granted') {
        _startCheckingIfNeeded();
      }
    } catch (e) {
      debugPrint('Notificações não suportadas: $e');
    }
  }

  /// Solicita permissão para enviar notificações
  static Future<String> _requestPermission() async {
    final current = web.Notification.permission;
    if (current == 'granted') return 'granted';
    if (current == 'denied') return 'denied';

    final result = await web.Notification.requestPermission().toDart;
    return result.toDart;
  }

  /// Inicia verificação periódica apenas se houver agendamentos
  /// OTIMIZAÇÃO: Evita timer rodando sem necessidade
  static void _startCheckingIfNeeded() {
    if (_isRunning) return;

    // Verifica se há agendamentos pendentes
    final storage = StorageService();
    final agendamentos = storage.getAgendamentos();
    final hasPending = agendamentos.any((a) => a.status == 'Agendado');

    if (!hasPending) {
      debugPrint('Nenhum agendamento pendente. Timer não iniciado.');
      return;
    }

    _isRunning = true;
    _checkAndNotify();
    _timer = Timer.periodic(
      AppConstants.notificationCheckInterval,
      (_) => _checkAndNotify(),
    );
  }

  /// Verifica agendamentos e envia notificações quando necessário
  ///
  /// Regras:
  /// - Notifica 1h antes do agendamento
  /// - Notifica na hora (5min antes/depois)
  static void _checkAndNotify() {
    try {
      final storage = StorageService();
      final agendamentos = storage.getAgendamentos();
      final pets = storage.getPets();
      final clientes = storage.getClientes();
      final now = DateTime.now();

      bool hasPending = false;

      for (final a in agendamentos) {
        if (a.status != 'Agendado') continue;

        hasPending = true;
        final diff = a.dataHora.difference(now);

        // Notificação 3 horas antes (entre 175-185 min)
        if (diff.inMinutes >= 175 && diff.inMinutes <= 185) {
          _sendNotification(a, pets, clientes, '⏳ Faltam 3 horas!',
              'Prepare-se ou avise o cliente.');
        }

        // Notificação 1 hora antes
        // FIX: Janela ampliada (50-70 min) para garantir que o Timer (geralmente 15 em 15min) capture o momento.
        if (diff.inMinutes >= 50 && diff.inMinutes <= 70) {
          _sendNotification(a, pets, clientes, '🐾 Agendamento em 1 hora!',
              'Confirme se está tudo pronto.');
        }

        // Notificação na hora (entre -5 e +5 min)
        if (diff.inMinutes >= -5 && diff.inMinutes <= 5) {
          _sendNotification(a, pets, clientes, '🐾 Agendamento agora!',
              'O pet deve chegar a qualquer momento.');
        }
      }

      // Para o timer se não houver mais agendamentos pendentes
      if (!hasPending) {
        stop();
      }
    } catch (e) {
      debugPrint('Erro ao verificar agendamentos: $e');
    }
  }

  // Helper para buscar dados e enviar
  static void _sendNotification(Agendamento agendamento, List<Pet> pets,
      List<Cliente> clientes, String titulo, String submsg) {
    final pet = pets.firstWhere(
      (p) => p.id == agendamento.petId,
      orElse: () =>
          Pet(id: '', nome: 'Pet', raca: '', porte: '', clienteId: ''),
    );

    final cliente = clientes.firstWhere(
      (c) => c.id == pet.clienteId,
      orElse: () => Cliente(
          id: '', nome: 'Cliente', telefone: '', email: '', endereco: ''),
    );

    _send(
      title: titulo,
      body: '${pet.nome} (${agendamento.servico}) - ${cliente.nome}. $submsg',
    );
  }

  /// Envia notificação push
  static void _send({required String title, required String body}) {
    if (web.Notification.permission != 'granted') return;

    web.Notification(
      title,
      web.NotificationOptions(
        body: body,
        icon: 'icons/Icon-192.png',
      ),
    );
  }

  /// Formata hora no formato HH:mm
  static String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Para o timer de verificação
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('Timer de notificações parado.');
  }

  /// Reinicia o timer (usado após criar novo agendamento)
  static void restart() {
    stop();
    _startCheckingIfNeeded();
  }

  /// Libera recursos
  static void dispose() {
    stop();
  }
}
