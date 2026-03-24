import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../services/storage_service.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final _storage = StorageService();
  List<Servico> _servicos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _servicos = _storage.getServicos());

  Future<void> _openSheet([Servico? servico]) async {
    final result = await showModalBottomSheet<Servico>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServicoSheet(servico: servico),
    );
    if (result != null) {
      if (servico != null) {
        final idx = _servicos.indexWhere((s) => s.id == servico.id);
        _servicos[idx] = result;
      } else {
        _servicos.add(result);
      }
      await _storage.saveServicos(_servicos);
      _load();
    }
  }

  Future<void> _excluir(Servico servico) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir serviço'),
        content: Text('Deseja excluir ${servico.nome}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm == true) {
      _servicos.removeWhere((s) => s.id == servico.id);
      await _storage.saveServicos(_servicos);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: _servicos.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.content_cut_outlined, size: 72, color: Colors.grey.shade300), const SizedBox(height: 16), Text('Nenhum serviço cadastrado', style: TextStyle(color: Colors.grey.shade500, fontSize: 16))]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _servicos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = _servicos[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: const Color(0xFF00BCD4).withOpacity(0.12), child: const Icon(Icons.content_cut_outlined, color: Color(0xFF00BCD4))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(s.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))])),
                              ],
                              onSelected: (v) => v == 'edit' ? _openSheet(s) : _excluir(s),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: ['P', 'M', 'G', 'GG'].map((porte) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Text(porte, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4))),
                                    const SizedBox(height: 2),
                                    Text('R\$ ${s.getPreco(porte).toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço'),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ServicoSheet extends StatefulWidget {
  final Servico? servico;
  const ServicoSheet({super.key, this.servico});

  @override
  State<ServicoSheet> createState() => _ServicoSheetState();
}

class _ServicoSheetState extends State<ServicoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.servico?.nome);
  late final _pController = TextEditingController(text: widget.servico?.getPreco('P').toStringAsFixed(2));
  late final _mController = TextEditingController(text: widget.servico?.getPreco('M').toStringAsFixed(2));
  late final _gController = TextEditingController(text: widget.servico?.getPreco('G').toStringAsFixed(2));
  late final _ggController = TextEditingController(text: widget.servico?.getPreco('GG').toStringAsFixed(2));

  @override
  void dispose() {
    _nomeController.dispose();
    _pController.dispose();
    _mController.dispose();
    _gController.dispose();
    _ggController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(widget.servico == null ? 'Novo Serviço' : 'Editar Serviço', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome do Serviço', prefixIcon: Icon(Icons.content_cut_outlined)), textCapitalization: TextCapitalization.words, validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              Text('Preços por Porte', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _pController, decoration: const InputDecoration(labelText: 'Pequeno (P)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _mController, decoration: const InputDecoration(labelText: 'Médio (M)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _gController, decoration: const InputDecoration(labelText: 'Grande (G)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _ggController, decoration: const InputDecoration(labelText: 'Extra Grande (GG)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Cancelar'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, Servico(
                            id: widget.servico?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            nome: _nomeController.text.trim(),
                            precosPorPorte: {
                              'P': double.tryParse(_pController.text.replaceAll(',', '.')) ?? 0,
                              'M': double.tryParse(_mController.text.replaceAll(',', '.')) ?? 0,
                              'G': double.tryParse(_gController.text.replaceAll(',', '.')) ?? 0,
                              'GG': double.tryParse(_ggController.text.replaceAll(',', '.')) ?? 0,
                            },
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
      ),
    );
  }
}
