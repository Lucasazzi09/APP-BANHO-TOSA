import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Como funciona o Sistema', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSection(
            icon: Icons.dashboard,
            title: '1. Visão Geral (Dashboard)',
            description: 'Acompanhe seu negócio em tempo real. Veja quantos agendamentos tem no dia, alertas de estoque e atalhos rápidos.',
            color: Colors.blue,
            delay: 100,
          ),
          _buildSection(
            icon: Icons.pets,
            title: '2. Gestão de Pets e Clientes',
            description: 'Cadastro completo com foto, raça, porte e observações de alergia. Histórico completo na palma da mão.',
            color: Colors.orange,
            delay: 200,
          ),
          _buildSection(
            icon: Icons.calendar_month,
            title: '3. Agenda Inteligente',
            description: 'Evite faltas! O sistema envia lembretes automáticos e organiza os horários por status (Agendado, Em Andamento, Concluído).',
            color: Colors.green,
            delay: 300,
          ),
          _buildSection(
            icon: Icons.attach_money,
            title: '4. Controle Financeiro',
            description: 'Saiba exatamente quanto faturou. Relatórios detalhados por dia ou mês, aceitando PIX, Cartão e Dinheiro.',
            color: Colors.purple,
            delay: 400,
          ),
          _buildSection(
            icon: Icons.inventory_2,
            title: '5. Estoque Automático',
            description: 'Nunca mais fique sem produtos. O sistema avisa quando o shampoo ou outros itens estão acabando.',
            color: Colors.red,
            delay: 500,
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Banho & Tosa App v1.0.0',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.shade100),
        ),
        child: Column(
          children: [
            const Icon(Icons.rocket_launch, size: 40, color: Colors.purple),
            const SizedBox(height: 10),
            const Text(
              'Bem-vindo ao Futuro do seu Pet Shop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 5),
            Text(
              'Organize, Controle e Cresça.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.purple.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required String description, required Color color, required int delay}) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
        ),
      ),
    );
  }
}
