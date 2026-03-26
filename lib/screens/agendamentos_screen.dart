import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/agendamento.dart';
import '../models/pet.dart';
import '../models/cliente.dart';
import '../models/servico.dart';
import '../services/storage_service.dart';
import 'package:web/web.dart' as web;

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen>
    with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  List<Agendamento> _agendamentos = [];
  List<Pet> _pets = [];
  List<Cliente> _clientes = [];
  List<Servico> _servicos = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final agendamentos = _storage.getAgendamentos();
    agendamentos.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    setState(() {
      _agendamentos = agendamentos;
      _pets = _storage.getPets();
      _clientes = _storage.getClientes();
      _servicos = _storage.getServicos();
    });
  }

  List<Agendamento> _byStatus(String status) =>
      _agendamentos.where((a) => a.status == status).toList();

  Pet _getPet(String petId) => _pets.firstWhere((p) => p.id == petId,
      orElse: () => Pet(
          id: '', nome: 'Desconhecido', raca: '', porte: '', clienteId: ''));

  Cliente _getCliente(String petId) {
    final pet = _getPet(petId);
    return _clientes.firstWhere((c) => c.id == pet.clienteId,
        orElse: () =>
            Cliente(id: '', nome: '', telefone: '', email: '', endereco: ''));
  }

  Future<void> _openSheet([Agendamento? agendamento]) async {
    final result = await showModalBottomSheet<Agendamento>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AgendamentoSheet(
          pets: _pets, servicos: _servicos, agendamento: agendamento),
    );
    if (result != null) {
      if (agendamento != null) {
        final idx = _agendamentos.indexWhere((a) => a.id == agendamento.id);
        _agendamentos[idx] = result;
      } else {
        _agendamentos.add(result);
      }
      await _storage.saveAgendamentos(_agendamentos);
      _load();
    }
  }

  Future<void> _alterarStatus(
      Agendamento agendamento, String novoStatus) async {
    final idx = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    _agendamentos[idx] = agendamento.copyWith(status: novoStatus);
    await _storage.saveAgendamentos(_agendamentos);
    _load();
  }

  Future<void> _alterarPagamento(Agendamento agendamento) async {
    final novoStatus =
        agendamento.statusPagamento == 'Pago' ? 'Pendente' : 'Pago';
    final idx = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    _agendamentos[idx] = agendamento.copyWith(statusPagamento: novoStatus);
    await _storage.saveAgendamentos(_agendamentos);
    _load();
  }

  Future<void> _excluir(Agendamento agendamento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir agendamento'),
        content: const Text('Deseja excluir este agendamento?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm == true) {
      _agendamentos.removeWhere((a) => a.id == agendamento.id);
      await _storage.saveAgendamentos(_agendamentos);
      _load();
    }
  }

  void _enviarWhatsApp(Agendamento agendamento) {
    final pet = _getPet(agendamento.petId);
    final cliente = _getCliente(agendamento.petId);
    if (cliente.telefone.isEmpty) return;
    final tel = cliente.telefone.replaceAll(RegExp(r'\D'), '');
    final data = DateFormat('dd/MM/yyyy').format(agendamento.dataHora);
    final hora = DateFormat('HH:mm').format(agendamento.dataHora);
    final msg = Uri.encodeComponent(
      'Olá ${cliente.nome}! 🐾\n\nLembrando que o(a) *${pet.nome}* tem *${agendamento.servico}* agendado para *$data às $hora*.\n\nQualquer dúvida estamos à disposição!\n\n 🐶',
    );
    web.window.open('https://wa.me/55$tel?text=$msg', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Agendados (${_byStatus('Agendado').length})'),
            Tab(text: 'Concluídos (${_byStatus('Concluído').length})'),
            Tab(text: 'Cancelados (${_byStatus('Cancelado').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AgendamentoList(
              agendamentos: _byStatus('Agendado'),
              getPet: _getPet,
              getCliente: _getCliente,
              onEdit: _openSheet,
              onDelete: _excluir,
              onStatusChange: _alterarStatus,
              onPagamento: _alterarPagamento,
              onWhatsApp: _enviarWhatsApp),
          _AgendamentoList(
              agendamentos: _byStatus('Concluído'),
              getPet: _getPet,
              getCliente: _getCliente,
              onEdit: _openSheet,
              onDelete: _excluir,
              onStatusChange: _alterarStatus,
              onPagamento: _alterarPagamento,
              onWhatsApp: _enviarWhatsApp),
          _AgendamentoList(
              agendamentos: _byStatus('Cancelado'),
              getPet: _getPet,
              getCliente: _getCliente,
              onEdit: _openSheet,
              onDelete: _excluir,
              onStatusChange: _alterarStatus,
              onPagamento: _alterarPagamento,
              onWhatsApp: _enviarWhatsApp),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Agendamento'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AgendamentoList extends StatelessWidget {
  final List<Agendamento> agendamentos;
  final Pet Function(String) getPet;
  final Cliente Function(String) getCliente;
  final void Function(Agendamento) onEdit;
  final void Function(Agendamento) onDelete;
  final void Function(Agendamento, String) onStatusChange;
  final void Function(Agendamento) onPagamento;
  final void Function(Agendamento) onWhatsApp;

  const _AgendamentoList(
      {required this.agendamentos,
      required this.getPet,
      required this.getCliente,
      required this.onEdit,
      required this.onDelete,
      required this.onStatusChange,
      required this.onPagamento,
      required this.onWhatsApp});

  Color _statusColor(String status) => switch (status) {
        'Agendado' => Colors.orange,
        'Concluído' => Colors.green,
        'Cancelado' => Colors.red,
        _ => Colors.grey
      };
  IconData _statusIcon(String status) => switch (status) {
        'Agendado' => Icons.schedule,
        'Concluído' => Icons.check_circle_outline,
        'Cancelado' => Icons.cancel_outlined,
        _ => Icons.help_outline
      };

  @override
  Widget build(BuildContext context) {
    if (agendamentos.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calendar_today_outlined,
            size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('Nenhum agendamento',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16))
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: agendamentos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = agendamentos[index];
        final pet = getPet(a.petId);
        final cliente = getCliente(a.petId);
        final statusColor = _statusColor(a.status);
        final pago = a.statusPagamento == 'Pago';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.pets,
                            color: Color(0xFFFF9800), size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pet.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            if (cliente.nome.isNotEmpty)
                              Text(cliente.nome,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_statusIcon(a.status),
                            size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Text(a.status,
                            style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(Icons.content_cut_outlined, a.servico),
                    const SizedBox(width: 8),
                    _InfoChip(Icons.calendar_today_outlined,
                        DateFormat('dd/MM/yyyy').format(a.dataHora)),
                    const SizedBox(width: 8),
                    _InfoChip(Icons.access_time_outlined,
                        DateFormat('HH:mm').format(a.dataHora)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(Icons.straighten, 'Porte ${pet.porte}'),
                    const Spacer(),
                    Text('R\$ ${a.valor.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF4CAF50))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onPagamento(a),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: pago
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              pago
                                  ? Icons.check_circle_outline
                                  : Icons.pending_outlined,
                              size: 13,
                              color: pago ? Colors.green : Colors.orange),
                          const SizedBox(width: 4),
                          Text(pago ? 'Pago' : 'Pendente',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: pago ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(Icons.payment_outlined, a.formaPagamento),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cliente.telefone.isNotEmpty)
                      _ActionButton('WhatsApp', Icons.chat_outlined,
                          const Color(0xFF25D366), () => onWhatsApp(a)),
                    if (a.status == 'Agendado') ...[
                      const SizedBox(width: 8),
                      _ActionButton('Concluir', Icons.check, Colors.green,
                          () => onStatusChange(a, 'Concluído')),
                      const SizedBox(width: 8),
                      _ActionButton('Cancelar', Icons.close, Colors.red,
                          () => onStatusChange(a, 'Cancelado')),
                    ],
                    const SizedBox(width: 8),
                    IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: Colors.grey.shade500),
                        onPressed: () => onEdit(a),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            minimumSize: const Size(32, 32),
                            padding: EdgeInsets.zero)),
                    const SizedBox(width: 8),
                    IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 18, color: Colors.red.shade300),
                        onPressed: () => onDelete(a),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            minimumSize: const Size(32, 32),
                            padding: EdgeInsets.zero)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: Colors.grey.shade500),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class AgendamentoSheet extends StatefulWidget {
  final List<Pet> pets;
  final List<Servico> servicos;
  final Agendamento? agendamento;
  const AgendamentoSheet(
      {super.key,
      required this.pets,
      required this.servicos,
      this.agendamento});

  @override
  State<AgendamentoSheet> createState() => _AgendamentoSheetState();
}

class _AgendamentoSheetState extends State<AgendamentoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _valorController =
      TextEditingController(text: widget.agendamento?.valor.toStringAsFixed(2));
  late String? _petId = widget.agendamento?.petId;
  late String? _servicoId = widget.agendamento != null
      ? widget.servicos
          .firstWhere((s) => s.nome == widget.agendamento!.servico,
              orElse: () => widget.servicos.first)
          .id
      : null;
  late String _formaPagamento = widget.agendamento?.formaPagamento ?? 'Pix';
  late DateTime _dataHora = widget.agendamento?.dataHora ?? DateTime.now();

  void _calcularPreco() {
    if (_petId == null || _servicoId == null) return;
    final pet = widget.pets
        .firstWhere((p) => p.id == _petId, orElse: () => widget.pets.first);
    final servico = widget.servicos.firstWhere((s) => s.id == _servicoId,
        orElse: () => widget.servicos.first);
    final preco = servico.getPreco(pet.porte);
    if (preco > 0) _valorController.text = preco.toStringAsFixed(2);
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _dataHora,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null && mounted) {
      final time = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(_dataHora));
      if (time != null) {
        setState(() => _dataHora =
            DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final servicoAtual = _servicoId != null
        ? widget.servicos.firstWhere((s) => s.id == _servicoId,
            orElse: () => widget.servicos.first)
        : null;
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(
                  widget.agendamento == null
                      ? 'Novo Agendamento'
                      : 'Editar Agendamento',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _petId,
                decoration: const InputDecoration(
                    labelText: 'Pet', prefixIcon: Icon(Icons.pets)),
                items: widget.pets
                    .map((p) => DropdownMenuItem(
                        value: p.id, child: Text('${p.nome} (${p.porte})')))
                    .toList(),
                onChanged: (v) {
                  setState(() => _petId = v);
                  _calcularPreco();
                },
                validator: (v) => v == null ? 'Selecione um pet' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _servicoId,
                decoration: const InputDecoration(
                    labelText: 'Serviço',
                    prefixIcon: Icon(Icons.content_cut_outlined)),
                items: widget.servicos
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.nome)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _servicoId = v);
                  _calcularPreco();
                },
                validator: (v) => v == null ? 'Selecione um serviço' : null,
              ),
              if (servicoAtual != null && _petId != null) ...[
                const SizedBox(height: 8),
                Text(
                    'Preço sugerido: R\$ ${servicoAtual.getPreco(widget.pets.firstWhere((p) => p.id == _petId!).porte).toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDateTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Data e Hora',
                      prefixIcon: Icon(Icons.calendar_today_outlined)),
                  child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_dataHora)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    prefixIcon: Icon(Icons.attach_money)),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _formaPagamento,
                decoration: const InputDecoration(
                    labelText: 'Forma de Pagamento',
                    prefixIcon: Icon(Icons.payment_outlined)),
                items: [
                  'Pix',
                  'Dinheiro',
                  'Cartão de Débito',
                  'Cartão de Crédito'
                ]
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _formaPagamento = v!),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Cancelar'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final servico = widget.servicos
                              .firstWhere((s) => s.id == _servicoId);
                          Navigator.pop(
                              context,
                              Agendamento(
                                id: widget.agendamento?.id ??
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                petId: _petId!,
                                dataHora: _dataHora,
                                servico: servico.nome,
                                valor: double.tryParse(_valorController.text
                                        .trim()
                                        .replaceAll(',', '.')) ??
                                    0,
                                status:
                                    widget.agendamento?.status ?? 'Agendado',
                                statusPagamento:
                                    widget.agendamento?.statusPagamento ??
                                        'Pendente',
                                formaPagamento: _formaPagamento,
                              ));
                        }
                      },
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
