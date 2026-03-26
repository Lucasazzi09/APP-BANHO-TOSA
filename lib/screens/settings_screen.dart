import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import 'privacy_policy_screen.dart';
import 'login_screen.dart';
import 'package:banho_tosa/providers/user_provider.dart';
import 'package:banho_tosa/providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';

/// Tela de Configurações
///
/// Funcionalidades:
/// - Visualizar e editar foto de perfil
/// - Visualizar informações da conta
/// - Acessar política de privacidade
/// - Excluir conta (conformidade LGPD Art. 18)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _storage = StorageService();
  bool _loading = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // O UserProvider já é carregado na HomeScreen.
  }

  /// Seleciona e faz upload de foto de perfil
  Future<void> _uploadProfilePhoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 400,
        imageQuality: 70,
      );

      if (image == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }

      final bytes = await image.readAsBytes();
      final photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Salva Base64 no Firestore
      await _authService.updateProfilePhoto(photoBase64);
      await Provider.of<UserProvider>(context, listen: false).fetchUser();

      setState(() => _uploadingPhoto = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Remove foto de perfil
  Future<void> _removeProfilePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Foto'),
        content: const Text('Deseja remover sua foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _uploadingPhoto = true);

    try {
      await _authService.removeProfilePhoto();
      await Provider.of<UserProvider>(context, listen: false).fetchUser();

      setState(() => _uploadingPhoto = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto removida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Exclui conta do usuário e todos os dados
  /// Conformidade LGPD Art. 18 - Direito de exclusão
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Excluir Conta'),
        content: const Text(
          'Esta ação é irreversível!\n\n'
          'Todos os seus dados serão permanentemente excluídos:\n'
          '• Conta de usuário\n'
          '• Clientes cadastrados\n'
          '• Pets e agendamentos\n'
          '• Produtos e serviços\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir Tudo'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      await _storage.clearAllData();
      await _authService.deleteAccount();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta excluída com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir conta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeInDown(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          backgroundImage: userData?.photoUrl != null &&
                                  userData!.photoUrl!.isNotEmpty
                              ? MemoryImage(
                                  base64Decode(
                                      userData.photoUrl!.split(',').last),
                                )
                              : null,
                          child: (userData?.photoUrl == null ||
                                  userData!.photoUrl!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                        if (_uploadingPhoto)
                          Positioned.fill(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black54,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap:
                                  _uploadingPhoto ? null : _uploadProfilePhoto,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData?.nome ?? 'Carregando...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (userData?.photoUrl != null &&
                        userData!.photoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _uploadingPhoto ? null : _removeProfilePhoto,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Remover Foto'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInLeft(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Informações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Versão do App',
              subtitle: AppConstants.appVersion,
              onTap: null,
            ),
          ),
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de Privacidade',
              subtitle: 'Veja como seus dados são tratados',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          FadeInLeft(
            delay: const Duration(milliseconds: 350),
            child: const Text(
              'Aparência',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: SwitchListTile(
              title: const Text('Modo Escuro'),
              secondary: Icon(themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
              activeColor: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: const Text(
              'Zona de Perigo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              color: Colors.red.shade50,
              child: InkWell(
                onTap: _loading ? null : _deleteAccount,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Excluir Conta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Remove permanentemente todos os dados',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red.shade700,
                          ),
                        )
                      else
                        Icon(
                          Icons.chevron_right,
                          color: Colors.red.shade400,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
