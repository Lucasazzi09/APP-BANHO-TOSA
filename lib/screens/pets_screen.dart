import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/cliente.dart';
import '../services/storage_service.dart';
import '../services/image_upload_service.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final _storage = StorageService();
  List<Pet> _pets = [];
  List<Pet> _filtrados = [];
  List<Cliente> _clientes = [];
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
    final pets = _storage.getPets();
    final clientes = _storage.getClientes();
    setState(() {
      _pets = pets;
      _clientes = clientes;
      _filtrar();
    });
  }

  void _filtrar() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? List.from(_pets)
          : _pets
              .where((p) =>
                  p.nome.toLowerCase().contains(q) ||
                  p.raca.toLowerCase().contains(q))
              .toList();
    });
  }

  String _getClienteNome(String clienteId) {
    return _clientes
        .firstWhere((c) => c.id == clienteId,
            orElse: () => Cliente(
                id: '',
                nome: 'Desconhecido',
                telefone: '',
                email: '',
                endereco: ''))
        .nome;
  }

  Future<void> _openDialog([Pet? pet]) async {
    final result = await showDialog<Pet>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _PetForm(clientes: _clientes, pet: pet),
      ),
    );
    if (result != null) {
      if (pet != null) {
        final idx = _pets.indexWhere((p) => p.id == pet.id);
        _pets[idx] = result;
      } else {
        _pets.add(result);
      }
      await _storage.savePets(_pets);
      _load();
    }
  }

  Future<void> _excluir(Pet pet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir pet'),
        content: Text('Deseja excluir ${pet.nome}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _pets.removeWhere((p) => p.id == pet.id);
      await _storage.savePets(_pets);
      _load();
    }
  }

  Color _porteColor(String porte) => switch (porte) {
        'P' => Colors.green,
        'M' => Colors.orange,
        'G' => Colors.red,
        'GG' => Colors.purple,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pets'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar pet...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                  Icon(Icons.pets, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _pets.isEmpty
                        ? 'Nenhum pet cadastrado'
                        : 'Nenhum resultado encontrado',
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
                final pet = _filtrados[index];
                final porteColor = _porteColor(pet.porte);
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          const Color(0xFF4CAF50).withOpacity(0.12),
                      backgroundImage: pet.photoUrl != null
                          ? MemoryImage(
                              Uri.parse(pet.photoUrl!).data!.contentAsBytes(),
                            )
                          : null,
                      child: pet.photoUrl == null
                          ? const Icon(Icons.pets, color: Color(0xFF4CAF50))
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(pet.nome,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: porteColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(pet.porte,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: porteColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(pet.raca,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        Row(children: [
                          Icon(Icons.person_outline,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(_getClienteNome(pet.clienteId),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ]),
                        if (pet.observacoes != null &&
                            pet.observacoes!.isNotEmpty)
                          Text('Obs: ${pet.observacoes}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic)),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Editar')
                            ])),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Excluir',
                                  style: TextStyle(color: Colors.red))
                            ])),
                      ],
                      onSelected: (v) =>
                          v == 'edit' ? _openDialog(pet) : _excluir(pet),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Pet'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _PetForm extends StatefulWidget {
  final List<Cliente> clientes;
  final Pet? pet;
  const _PetForm({required this.clientes, this.pet});

  @override
  State<_PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<_PetForm> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageUploadService();
  late final _nomeController = TextEditingController(text: widget.pet?.nome);
  late final _racaController = TextEditingController(text: widget.pet?.raca);
  late final _obsController =
      TextEditingController(text: widget.pet?.observacoes);
  late String? _clienteId = widget.pet?.clienteId;
  late String _porte = widget.pet?.porte ?? 'P';
  String? _photoUrl;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.pet?.photoUrl;
  }

  Future<void> _selectPhoto() async {
    final source = await ImageUploadService.showImageSourceDialog(context);
    if (source == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final photoBase64 = source == 'gallery'
          ? await _imageService.pickImageFromGallery()
          : await _imageService.pickImageFromCamera();

      if (photoBase64 != null) {
        setState(() {
          _photoUrl = photoBase64;
          _uploadingPhoto = false;
        });
      } else {
        setState(() => _uploadingPhoto = false);
      }
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePhoto() {
    setState(() => _photoUrl = null);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.pet == null ? 'Novo Pet' : 'Editar Pet',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _uploadingPhoto ? null : _selectPhoto,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.5),
                            width: 2),
                        image: _photoUrl != null
                            ? DecorationImage(
                                image: MemoryImage(Uri.parse(_photoUrl!)
                                    .data!
                                    .contentAsBytes()),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _photoUrl == null
                          ? const Icon(
                              Icons.pets,
                              size: 50,
                              color: Color(0xFF4CAF50),
                            )
                          : null,
                    ),
                    if (_uploadingPhoto)
                      Container(
                        height: 110,
                        width: 110,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ),
            if (_photoUrl != null) ...[
              Center(
                child: TextButton(
                  onPressed: _uploadingPhoto ? null : _removePhoto,
                  child: const Text('Remover Foto',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ] else
              const SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Pet',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _racaController,
              decoration: const InputDecoration(
                labelText: 'Raça',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _porte,
              decoration: const InputDecoration(
                labelText: 'Porte',
                border: OutlineInputBorder(),
              ),
              items: ['P', 'M', 'G', 'GG']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _porte = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _clienteId,
              decoration: const InputDecoration(
                labelText: 'Dono',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: widget.clientes
                  .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() => _clienteId = v),
              validator: (v) => v == null ? 'Selecione um cliente' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _obsController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                          context,
                          Pet(
                            id: widget.pet?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            nome: _nomeController.text.trim(),
                            raca: _racaController.text.trim(),
                            porte: _porte,
                            clienteId: _clienteId!,
                            observacoes: _obsController.text.trim().isEmpty
                                ? null
                                : _obsController.text.trim(),
                            photoUrl: _photoUrl,
                          ));
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
