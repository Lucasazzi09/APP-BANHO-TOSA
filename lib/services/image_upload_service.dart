import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

/// Serviço de Upload de Imagens (SEM Firebase Storage)
/// 
/// Gerencia:
/// - Seleção de imagens da galeria/câmera
/// - Conversão para Base64 (salva no Firestore)
/// - Compressão automática para Web
/// 
/// VANTAGEM: Não precisa Firebase Storage (100% gratuito)
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  /// Seleciona imagem da galeria
  /// 
  /// Retorna:
  /// - String Base64 da imagem
  /// - null se usuário cancelou
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400, // Reduzido para economizar espaço no Firestore
        maxHeight: 400,
        imageQuality: 70, // Qualidade reduzida para Base64
      );
      
      if (image == null) return null;
      
      // Converte para Base64
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      return null;
    }
  }

  /// Seleciona imagem da câmera
  /// 
  /// Retorna:
  /// - String Base64 da imagem
  /// - null se usuário cancelou
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      
      if (image == null) return null;
      
      // Converte para Base64
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
      return null;
    }
  }

  /// Mostra diálogo para escolher fonte da imagem
  /// 
  /// Retorna:
  /// - 'gallery' se escolheu galeria
  /// - 'camera' se escolheu câmera
  /// - null se cancelou
  /// 
  /// Nota: Para Web, câmera pode não funcionar
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    if (kIsWeb) {
      // Web: apenas galeria
      return 'gallery';
    }
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );
  }
}
