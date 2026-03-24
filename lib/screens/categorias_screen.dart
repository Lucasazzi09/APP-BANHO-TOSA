import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/categoria_produto.dart';
import '../services/storage_service.dart';

/// Tela de Gerenciamento de Categorias de Produtos
/// 
/// Permite criar, editar e excluir categorias personalizadas
class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final _storage = StorageService();
  List<CategoriaProduto> _categorias = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _categorias = _storage.getCategoriasProdutos();
    });
  }

  Future<void> _openDialog([CategoriaProduto? categoria]) async {
    final controller = TextEditingController(text: categoria?.nome);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoria == null ? 'Nova Categoria' : 'Editar Categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da Categoria',
            prefixIcon: Icon(Icons.category),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (categoria != null) {
        // Editar
        final idx = _categorias.indexWhere((c) => c.id == categoria.id);
        _categorias[idx] = CategoriaProduto(
          id: categoria.id,
          nome: result,
          icone: categoria.icone,
        );
      } else {
        // Adicionar
        _categorias.add(CategoriaProduto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: result,
          icone: 'category',
        ));
      }
      
      await _storage.saveCategoriasProdutos(_categorias);
      _load();
    }
  }

  Future<void> _excluir(CategoriaProduto categoria) async {
    // Verificar se há produtos usando esta categoria
    final produtos = _storage.getProdutos();
    final produtosUsando = produtos.where((p) => p.categoria == categoria.nome).length;
    
    if (produtosUsando > 0) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Não é possível excluir'),
          content: Text(
            'Existem $produtosUsando produto(s) usando esta categoria.\n\n'
            'Altere a categoria desses produtos antes de excluir.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Deseja excluir a categoria "${categoria.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _categorias.removeWhere((c) => c.id == categoria.id);
      await _storage.saveCategoriasProdutos(_categorias);
      _load();
    }
  }

  Future<void> _restaurarPadroes() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrões'),
        content: const Text(
          'Isso irá restaurar as categorias padrão do sistema.\n\n'
          'Suas categorias personalizadas serão mantidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final padroes = CategoriaProduto.defaults();
      
      // Adiciona categorias padrão que não existem
      for (final padrao in padroes) {
        if (!_categorias.any((c) => c.nome == padrao.nome)) {
          _categorias.add(padrao);
        }
      }
      
      await _storage.saveCategoriasProdutos(_categorias);
      _load();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categorias padrão restauradas!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias de Produtos'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restaurarPadroes,
            tooltip: 'Restaurar padrões',
          ),
        ],
      ),
      body: _categorias.isEmpty
          ? Center(
              child: FadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma categoria',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione categorias para organizar seus produtos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _categorias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = _categorias[index];
                final produtos = _storage.getProdutos();
                final qtdProdutos = produtos.where((p) => p.categoria == c.nome).length;
                
                return FadeInLeft(
                  delay: Duration(milliseconds: index * 50),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF9C27B0).withOpacity(0.12),
                        child: const Icon(
                          Icons.category,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      title: Text(
                        c.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '$qtdProdutos produto(s)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _openDialog(c),
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _excluir(c),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
    );
  }
}
