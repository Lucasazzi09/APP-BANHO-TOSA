import 'package:flutter/material.dart';

/// Tela de Política de Privacidade
/// 
/// Conformidade LGPD (Lei 13.709/2018):
/// - Art. 9º: Informa sobre coleta e uso de dados
/// - Art. 18: Direitos do titular dos dados
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. Dados Coletados',
              content: 'Coletamos as seguintes informações:\n\n'
                  '• Nome de usuário e email (para autenticação)\n'
                  '• Dados de clientes: nome, telefone, email, endereço\n'
                  '• Dados de pets: nome, raça, porte, observações\n'
                  '• Agendamentos e histórico de serviços\n'
                  '• Informações de produtos e estoque',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '2. Uso dos Dados',
              content: 'Seus dados são utilizados para:\n\n'
                  '• Gerenciar agendamentos e serviços\n'
                  '• Manter histórico de atendimentos\n'
                  '• Enviar notificações de agendamentos\n'
                  '• Controle de estoque e produtos\n'
                  '• Relatórios financeiros',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '3. Armazenamento',
              content: 'Os dados são armazenados:\n\n'
                  '• Localmente no seu navegador (SharedPreferences)\n'
                  '• No Firebase (Google Cloud) de forma criptografada\n'
                  '• Não compartilhamos seus dados com terceiros',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '4. Seus Direitos (LGPD)',
              content: 'Você tem direito a:\n\n'
                  '• Acessar seus dados a qualquer momento\n'
                  '• Corrigir dados incompletos ou incorretos\n'
                  '• Solicitar exclusão de seus dados\n'
                  '• Revogar consentimento\n'
                  '• Exportar seus dados\n\n'
                  'Para exercer seus direitos, acesse Configurações > Excluir Conta',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '5. Segurança',
              content: 'Medidas de segurança:\n\n'
                  '• Autenticação via Firebase Auth\n'
                  '• Conexão HTTPS criptografada\n'
                  '• Acesso restrito aos dados\n'
                  '• Backup regular dos dados',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '6. Contato',
              content: 'Para dúvidas sobre privacidade:\n\n'
                  'Email: lucasazzi270@gmail.com\n'
                  'Telefone: (18) 99669-2266)',
            ),
            const SizedBox(height: 24),
            Text(
              'Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
