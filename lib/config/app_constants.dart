/// Constantes da aplicação
class AppConstants {
  // Informações do App
  static const String appName = 'Banho & Tosa';
  static const String appVersion = '1.0.1';

  // Configurações de Notificação
  static const Duration notificationCheckInterval = Duration(minutes: 15);
  static const int notificationAdvanceMinutes = 60; // Notificar 1h antes
  static const int notificationNowMinutes = 5; // Notificar 5min antes/depois

  // Limites e Validações
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
}
