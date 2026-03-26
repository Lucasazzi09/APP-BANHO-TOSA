import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/produto.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import 'estoque_baixo_screen.dart';
import '../models/categoria_produto.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final _storage = StorageService();
  final _pdfService = PdfService();
  List<Produto> _produtos = [];
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  void _loadProdutos() {
    setState(() {
      _produtos = _storage.getProdutos();
    });
  }

  void _saveProduto(Produto produto) async {
    final index = _produtos.indexWhere((p) => p.id == produto.id);
    if (index >= 0) {
      _produtos[index] = produto;
    } else {
      _produtos.add(produto);
    }
    await _storage.saveProdutos(_produtos);
    _loadProdutos();
  }

  void _deleteProduto(String id) async {
    _produtos.removeWhere((p) => p.id == id);
    await _storage.saveProdutos(_produtos);
    _loadProdutos();
  }

  void _gerarPdf() async {
    if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nenhum produto cadastrado para gerar o catálogo.')),
      );
      return;
    }

    // Chama o serviço de PDF criado anteriormente
    await _pdfService.gerarCatalogoProdutos(_produtos);
  }

  void _openEstoqueBaixoScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const EstoqueBaixoScreen()));
  }

  void _openForm({Produto? produto}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _ProdutoFormScreen(
          produto: produto,
          onSave: _saveProduto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtosFiltrados = _produtos.where((p) {
      return p.nome.toLowerCase().contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botão Estoque Baixo
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded),
            tooltip: 'Ver Estoque Baixo',
            onPressed: _openEstoqueBaixoScreen,
          ),
          // Botão para Gerar PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Gerar Catálogo PDF',
            onPressed: _gerarPdf,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Cadastrar'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquisar Produto',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() => _filtro = value),
            ),
          ),
          Expanded(
            child: produtosFiltrados.isEmpty
                ? const Center(child: Text('Nenhum produto encontrado.'))
                : ListView.builder(
                    itemCount: produtosFiltrados.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final p = produtosFiltrados[index];
                      // Delay progressivo para animação em cascata
                      final delay = index * 100 > 800 ? 800 : index * 100;

                      // Decodifica imagem para exibir na lista
                      Uint8List? imageBytes;
                      if (p.imagemBase64 != null &&
                          p.imagemBase64!.isNotEmpty) {
                        try {
                          imageBytes = base64Decode(p.imagemBase64!);
                        } catch (_) {}
                      }

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: imageBytes != null
                                ? MemoryImage(imageBytes)
                                : null,
                            child: imageBytes == null
                                ? const Icon(Icons.inventory_2,
                                    color: Colors.grey)
                                : null,
                          ),
                          title: Text(p.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p.categoria} • Estoque: ${p.estoque}'),
                              if (p.estoque <= p.estoqueMinimo)
                                Text(
                                  'Estoque Baixo!',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('R\$ ${p.preco.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _openForm(produto: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () => _deleteProduto(p.id),
                              ),
                            ],
                          ),
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

/// Tela de Formulário para Adicionar/Editar Produto
class _ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;
  final Function(Produto) onSave;

  const _ProdutoFormScreen({this.produto, required this.onSave});

  @override
  State<_ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<_ProdutoFormScreen> {
  final _storage = StorageService();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();
  final _minimoController = TextEditingController();

  String? _imagemBase64;
  String? _selectedCategoria;
  List<CategoriaProduto> _categorias = [];

  @override
  void initState() {
    super.initState();
    // Ordem corrigida: Carrega dados do produto primeiro
    if (widget.produto != null) {
      _nomeController.text = widget.produto!.nome;
      _selectedCategoria = widget.produto!.categoria;
      _precoController.text = widget.produto!.preco.toString();
      _estoqueController.text = widget.produto!.estoque.toString();
      _minimoController.text = widget.produto!.estoqueMinimo.toString();
      _imagemBase64 = widget.produto!.imagemBase64;
    }
    // Depois carrega categorias, garantindo que a categoria do produto seja incluída/validada
    _loadCategorias();
  }

  void _loadCategorias() {
    setState(() {
      // 1. Carrega do storage
      final rawCategorias = _storage.getCategoriasProdutos();

      // 2. Remove duplicatas baseadas no nome (para evitar erro "2 or more items")
      final seen = <String>{};
      _categorias = rawCategorias.where((c) => seen.add(c.nome)).toList();

      // 3. Garante que a categoria selecionada exista na lista (evita erro "Zero items")
      if (_selectedCategoria != null &&
          !_categorias.any((c) => c.nome == _selectedCategoria)) {
        // Se a categoria antiga do produto foi apagada, adicionamos ela temporariamente
        _categorias.add(CategoriaProduto(
            id: 'temp', nome: _selectedCategoria!, icone: 'box'));
      }

      // 4. Segurança final: Se por algum motivo bizarro ainda não existir, limpa a seleção
      if (_selectedCategoria != null &&
          !_categorias.any((c) => c.nome == _selectedCategoria)) {
        _selectedCategoria = null;
      }
    });
  }

  /// Função para selecionar imagem da galeria
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600, // Otimização: Reduz tamanho
        imageQuality: 80, // Otimização: Qualidade
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imagemBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final produto = Produto(
        id: widget.produto?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        categoria: _selectedCategoria!,
        preco:
            double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0,
        estoque: int.tryParse(_estoqueController.text) ?? 0,
        estoqueMinimo: int.tryParse(_minimoController.text) ?? 5,
        imagemBase64: _imagemBase64,
      );
      widget.onSave(produto);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (_imagemBase64 != null) {
      try {
        imageBytes = base64Decode(_imagemBase64!);
      } catch (_) {}
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.produto == null ? 'Novo Produto' : 'Editar Produto',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Área de Seleção de Imagem
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.purple.withOpacity(0.5), width: 2),
                      image: imageBytes != null
                          ? DecorationImage(
                              image: MemoryImage(imageBytes), fit: BoxFit.cover)
                          : null,
                    ),
                    child: imageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey.shade600),
                              const SizedBox(height: 4),
                              Text('Adicionar Foto',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              if (imageBytes != null)
                TextButton(
                  onPressed: () => setState(() => _imagemBase64 = null),
                  child: const Text('Remover Foto',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 20),

              // Campos do Formulário
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: _categorias
                    .map((c) =>
                        DropdownMenuItem(value: c.nome, child: Text(c.nome)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoria = v),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _estoqueController,
                      decoration: const InputDecoration(
                        labelText: 'Qtd. Est Atual',
                        suffixText: 'un',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minimoController,
                decoration: const InputDecoration(
                  labelText: 'Estoque Mínimo (Alerta)',
                  prefixIcon: Icon(Icons.warning_amber),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
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
                    onPressed: _submit,
                    child: const Text('Salvar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
