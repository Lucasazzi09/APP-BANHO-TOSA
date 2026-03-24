import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/estoque_notification_service.dart';

/// Ponto de entrada da aplicação
/// 
/// Inicializa:
/// - Firebase (autenticação e Firestore)
/// - SharedPreferences (armazenamento local)
/// - Serviço de notificações
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar status bar para transparência
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  // Inicializar Firebase com configurações centralizadas
  await Firebase.initializeApp(
    options: FirebaseConfig.webOptions,
  );
  
  
  // Inicializar serviço de armazenamento local
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('Erro ao inicializar storage: $e');
  }
  
  // Inicializar serviço de notificações (apenas Web)
  await NotificationService.init();
  
  // Inicializar serviço de notificações de estoque baixo
  await EstoqueNotificationService.init();
  
  runApp(const BanhoTosaApp());
}

/// Widget raiz da aplicação
/// 
/// Configura:
/// - Tema Material Design 3
/// - Cores e estilos globais
/// - Rota inicial (LoginScreen)

class BanhoTosaApp extends StatelessWidget {
  const BanhoTosaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banho e Tosa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
