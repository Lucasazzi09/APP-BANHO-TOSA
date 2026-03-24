import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/storage_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _storage = StorageService();
  List<Cliente> _clientes = [];
  List<Cliente> _filtrados = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    final clientes = _storage.getClientes();
    setState(() {
      _clientes = clientes;
      _filtrar();
    });
  }

  void _filtrar() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? List.from(_clientes)
          : _clientes.where((c) => c.nome.toLowerCase().contains(q) || c.telefone.contains(q)).toList();
    });
  }

  Future<void> _openSheet([Cliente? cliente]) async {
    final result = await showModalBottomSheet<Cliente>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClienteSheet(cliente: cliente),
    );
    if (result != null) {
      if (cliente != null) {
        final idx = _clientes.indexWhere((c) => c.id == cliente.id);
        _clientes[idx] = result;
      } else {
        _clientes.add(result);
      }
      await _storage.saveClientes(_clientes);
      _load();
    }
  }

  Future<void> _excluir(Cliente cliente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text('Deseja excluir ${cliente.nome}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _clientes.removeWhere((c) => c.id == cliente.id);
      await _storage.saveClientes(_clientes);
      _load();
    }
  }

  Color _avatarColor(String nome) {
    const colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink];
    return colors[nome.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _filtrados.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _clientes.isEmpty ? 'Nenhum cliente cadastrado' : 'Nenhum resultado encontrado',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filtrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cliente = _filtrados[index];
                final color = _avatarColor(cliente.nome);
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Text(cliente.nome[0].toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(cliente.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.phone_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(cliente.telefone, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ]),
                        if (cliente.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(Icons.email_outlined, size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(cliente.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          ]),
                        ],
                      ],
                    ),
                    isThreeLine: cliente.email.isNotEmpty,
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))])),
                      ],
                      onSelected: (v) => v == 'edit' ? _openSheet(cliente) : _excluir(cliente),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Cliente'),
      ),
    );
  }
}

class ClienteSheet extends StatefulWidget {
  final Cliente? cliente;
  const ClienteSheet({super.key, this.cliente});

  @override
  State<ClienteSheet> createState() => _ClienteSheetState();
}

class _ClienteSheetState extends State<ClienteSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.cliente?.nome);
  late final _telefoneController = TextEditingController(text: widget.cliente?.telefone);
  late final _emailController = TextEditingController(text: widget.cliente?.email);
  late final _enderecoController = TextEditingController(text: widget.cliente?.endereco);

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(
              widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (opcional)', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _enderecoController,
              decoration: const InputDecoration(labelText: 'Endereço (opcional)', prefixIcon: Icon(Icons.location_on_outlined)),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, Cliente(
                          id: widget.cliente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          nome: _nomeController.text.trim(),
                          telefone: _telefoneController.text.trim(),
                          email: _emailController.text.trim(),
                          endereco: _enderecoController.text.trim(),
                        ));
                      }
                    },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
