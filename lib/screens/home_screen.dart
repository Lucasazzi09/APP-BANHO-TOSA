import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'clientes_screen.dart';
import 'pets_screen.dart';
import 'agendamentos_screen.dart';
import 'produtos_screen.dart';
import 'servicos_screen.dart';
import 'relatorio_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _authService = AuthService();
  int _totalClientes = 0;
  int _totalPets = 0;
  int _agendamentosHoje = 0;
  int _agendamentosPendentes = 0;
  int _agendamentosCancelados = 0;
  double _faturamentoHoje = 0;
  int _agendamentosMes = 0;
  double _faturamentoMes = 0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Dispara a busca de dados do usuário de forma global
    Provider.of<UserProvider>(context, listen: false).fetchUser();
    // Sincroniza dados da nuvem ao iniciar o app
    _storage.sincronizarDados().then((_) => _loadData());
    _loadData();
    _isDarkMode = _storage.isDarkMode();
  }

  /// Carrega dados do usuário e estatísticas
  /// Otimização: Carrega de forma assíncrona sem travar UI
  Future<void> _loadData() async {
    try {
      // Carrega estatísticas locais
      final clientes = _storage.getClientes();
      final pets = _storage.getPets();
      final agendamentos = _storage.getAgendamentos();
      final hoje = DateTime.now();

      final agendamentosHoje = agendamentos
          .where((a) =>
              a.dataHora.year == hoje.year &&
              a.dataHora.month == hoje.month &&
              a.dataHora.day == hoje.day)
          .toList();

      final agendamentosMes = agendamentos
          .where((a) =>
              a.dataHora.year == hoje.year && a.dataHora.month == hoje.month)
          .toList();

      setState(() {
        _totalClientes = clientes.length;
        _totalPets = pets.length;
        _agendamentosHoje = agendamentosHoje.length;
        _agendamentosPendentes =
            agendamentos.where((a) => a.status == 'Agendado').length;
        _agendamentosCancelados = agendamentos
            .where((a) =>
                a.status == 'Cancelado' &&
                a.dataHora.year == hoje.year &&
                a.dataHora.month == hoje.month &&
                a.dataHora.day == hoje.day)
            .length;
        _faturamentoHoje = agendamentosHoje
            .where((a) => a.statusPagamento == 'Pago')
            .fold(0, (sum, a) => sum + a.valor);
        _agendamentosMes = agendamentosMes.length;
        _faturamentoMes = agendamentosMes
            .where((a) => a.statusPagamento == 'Pago')
            .fold(0, (sum, a) => sum + a.valor);
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  void _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.user;
    return Scaffold(
      backgroundColor: cs.surface,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: cs.primary,
            // 🔹 Botão de Menu Personalizado
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    size: 28, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Menu Principal',
                style: IconButton.styleFrom(shape: const CircleBorder()),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Sair',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Banho & Tosa',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.tertiary],
                  ),
                ),
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 24, bottom: 48),
                        child:
                            Icon(Icons.pets, size: 80, color: Colors.white24),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 60,
                      child: FadeInLeft(
                        child: Row(
                          children: [
                            if (userData?.photoUrl != null &&
                                userData!.photoUrl!.isNotEmpty)
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: MemoryImage(
                                  base64Decode(
                                      userData.photoUrl!.split(',').last),
                                ),
                              )
                            else
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bem-vindo, ${userData?.nome ?? "Usuário"}!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: const _SectionTitle('Resumo do Dia'),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Expanded(
                          child: _StatCard('Hoje', _agendamentosHoje.toString(),
                              Icons.today, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              'Pendentes',
                              _agendamentosPendentes.toString(),
                              Icons.pending_actions,
                              Colors.red.shade400)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              'Cancelados',
                              _agendamentosCancelados.toString(),
                              Icons.cancel_outlined,
                              Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _StatCardWide(
                      'Faturamento Hoje',
                      'R\$ ${_faturamentoHoje.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: const _SectionTitle('Resumo do Mês'),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              'Total Agendado',
                              _agendamentosMes.toString(),
                              Icons.calendar_month,
                              Colors.blue.shade700)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              'Faturamento Mensal',
                              'R\$ ${_faturamentoMes.toStringAsFixed(2)}',
                              Icons.savings,
                              Colors.teal)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: const _SectionTitle('Operações'),
                ),
                const SizedBox(height: 12),
                FadeInRight(
                  delay: const Duration(milliseconds: 1100),
                  child: _MenuCard(
                      title: 'Agendamentos',
                      subtitle: '$_agendamentosPendentes pendentes',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFFFF9800),
                      onTap: () => _navigate(const AgendamentosScreen())),
                ),
                const SizedBox(height: 12),
                FadeInRight(
                  delay: const Duration(milliseconds: 1200),
                  child: _MenuCard(
                      title: 'Relatório de Agendamentos',
                      subtitle: 'Agendados, Concluídos e Cancelados',
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFF607D8B),
                      onTap: () => _navigate(const RelatorioScreen())),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _loadData()); // Recarrega dados ao voltar
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.grey.shade700));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(label,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCardWide(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        height: 110, // Altura fixa para alinhar
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(label,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
