import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importe as telas correspondentes do seu projeto
import 'package:banho_tosa/providers/user_provider.dart';
import '../screens/produtos_screen.dart';
import '../screens/categorias_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/clientes_screen.dart';
import '../screens/pets_screen.dart';
import '../screens/servicos_screen.dart';
import 'package:web/web.dart' as web;

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Fecha o drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _sendEmail() {
    // Abre o cliente de email padrão para contato com o desenvolvedor
    web.window.open(
        'mailto:lucasazzi270@gmail.com?subject=Suporte App Banho e Tosa',
        '_self');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        ImageProvider? userImage;
        if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
          try {
            final pureBase64 = user.photoUrl!.contains(',')
                ? user.photoUrl!.split(',').last
                : user.photoUrl!;
            userImage = MemoryImage(base64Decode(pureBase64));
          } catch (e) {
            userImage = null;
          }
        }

        return Drawer(
          child: Column(
            children: [
              // 🔹 Header Moderno com Gradiente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple.shade800, Colors.blue.shade700],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userImage != null
                        ? CircleAvatar(
                            radius: 32,
                            backgroundImage: userImage,
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white30, width: 2),
                            ),
                            child: const Icon(Icons.pets_rounded,
                                color: Colors.white, size: 32),
                          ),
                    const SizedBox(height: 16),
                    Text(
                      user?.nome ?? 'Banho & Tosa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestão Profissional',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // 🔹 Itens do Menu
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard_rounded,
                      label: 'Resumo do Dia',
                      color: Colors.blue,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Divider(height: 1),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.people_alt_rounded,
                      label: 'Clientes',
                      color: Colors.orange,
                      onTap: () => _navigateTo(context, const ClientesScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.pets_rounded,
                      label: 'Pets',
                      color: Colors.green,
                      onTap: () => _navigateTo(context, const PetsScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.content_cut_rounded,
                      label: 'Serviços',
                      color: Colors.pink,
                      onTap: () => _navigateTo(context, const ServicosScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.shopping_bag_rounded,
                      label: 'Produtos',
                      color: Colors.purple,
                      onTap: () => _navigateTo(context, const ProdutosScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.category_rounded,
                      label: 'Categorias',
                      color: Colors.teal,
                      onTap: () =>
                          _navigateTo(context, const CategoriasScreen()),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Divider(height: 1),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_rounded,
                      label: 'Configurações',
                      color: Colors.grey.shade700,
                      onTap: () => _navigateTo(context, const SettingsScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline_rounded,
                      label: 'Ajuda',
                      color: Colors.grey.shade700,
                      onTap: () {
                        _sendEmail();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Widget auxiliar para criar itens de menu padronizados
  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      hoverColor: color.withOpacity(0.05),
    );
  }
}
