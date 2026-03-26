import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/agendamento.dart';
import '../models/cliente.dart';
import '../models/pet.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  final _storage = StorageService();
  final _pdfService = PdfService();
  List<Agendamento> _agendamentos = [];
  List<Agendamento> _agendamentosFiltrados = [];
  List<Pet> _pets = [];
  List<Cliente> _clientes = [];
  String _filtroStatus = 'Todos';
  DateTimeRange? _periodoSelecionado;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _agendamentos = _storage.getAgendamentos();
      _pets = _storage.getPets();
      _clientes = _storage.getClientes();
      _agendamentos.sort(
          (a, b) => b.dataHora.compareTo(a.dataHora)); // Mais recentes primeiro
      _filtrarAgendamentos();
    });
  }

  void _filtrarAgendamentos() {
    setState(() {
      var temp = _agendamentos;

      // 1. Filtro por Status
      if (_filtroStatus != 'Todos') {
        temp = temp.where((a) => a.status == _filtroStatus).toList();
      }

      // 2. Filtro por Período
      if (_periodoSelecionado != null) {
        final inicio = _periodoSelecionado!.start;
        // Ajusta o fim para o final do dia (23:59:59)
        final fim = _periodoSelecionado!.end
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1));

        temp = temp.where((a) {
          return a.dataHora
                  .isAfter(inicio.subtract(const Duration(seconds: 1))) &&
              a.dataHora.isBefore(fim);
        }).toList();
      }

      _agendamentosFiltrados = temp;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _periodoSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      saveText: 'CONFIRMAR',
    );
    if (picked != null) {
      setState(() {
        _periodoSelecionado = picked;
        _filtrarAgendamentos();
      });
    }
  }

  String _getPetName(String petId) {
    return _pets
        .firstWhere((p) => p.id == petId,
            orElse: () =>
                Pet(id: '', nome: '?', raca: '', porte: '', clienteId: ''))
        .nome;
  }

  String _getClienteName(String petId) {
    final pet = _pets.firstWhere((p) => p.id == petId,
        orElse: () =>
            Pet(id: '', nome: '', raca: '', porte: '', clienteId: ''));
    if (pet.clienteId.isEmpty) return '?';
    return _clientes
        .firstWhere((c) => c.id == pet.clienteId,
            orElse: () => Cliente(
                id: '', nome: '?', telefone: '', email: '', endereco: ''))
        .nome;
  }

  void _gerarPdf() async {
    if (_agendamentosFiltrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Nenhum agendamento listado para gerar o relatório.')),
      );
      return;
    }
    // Chama o novo método que você irá adicionar no PdfService
    await _pdfService.gerarRelatorioAgendamentos(
        _agendamentosFiltrados, _pets, _clientes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Agendamentos'),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Gerar Relatório PDF',
            onPressed: _gerarPdf,
          ),
          if (_periodoSelecionado != null)
            Chip(
              label: Text(
                '${DateFormat('dd/MM').format(_periodoSelecionado!.start)} até ${DateFormat('dd/MM').format(_periodoSelecionado!.end)}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _periodoSelecionado = null;
                  _filtrarAgendamentos();
                });
              },
              backgroundColor: Colors.white,
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filtrar por período',
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children:
                  ['Todos', 'Agendado', 'Concluído', 'Cancelado'].map((status) {
                return ChoiceChip(
                  label: Text(status),
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color:
                        _filtroStatus == status ? Colors.white : Colors.black,
                  ),
                  selected: _filtroStatus == status,
                  onSelected: (selected) {
                    if (selected) {
                      _filtroStatus = status;
                      _filtrarAgendamentos();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: _agendamentosFiltrados.isEmpty
                ? const Center(
                    child: Text('Nenhum agendamento encontrado no período.'))
                : ListView.builder(
                    itemCount: _agendamentosFiltrados.length,
                    itemBuilder: (context, index) {
                      final ag = _agendamentosFiltrados[index];
                      final petName = _getPetName(ag.petId);
                      final clienteName = _getClienteName(ag.petId);
                      final dataFormatada =
                          DateFormat('dd/MM/yyyy HH:mm').format(ag.dataHora);

                      return ListTile(
                        title: Text('${ag.servico} - $petName'),
                        subtitle:
                            Text('Cliente: $clienteName\nData: $dataFormatada'),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'R\$ ${ag.valor.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ag.status,
                              style: TextStyle(
                                color: ag.status == 'Cancelado'
                                    ? Colors.red
                                    : (ag.status == 'Concluído'
                                        ? Colors.green
                                        : Colors.orange),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
