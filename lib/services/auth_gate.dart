import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Widget "Porteiro"
/// Verifica se o usuário já está logado no Firebase ao abrir o app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuta as mudanças de estado da autenticação (Login/Logout)
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Enquanto verifica a conexão (loading inicial)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se tem dados (usuário logado), vai para Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Se não tem dados (deslogado), vai para Login
        return const LoginScreen();
      },
    );
  }
}
