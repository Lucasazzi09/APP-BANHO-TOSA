import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/agendamento.dart';
import '../models/cliente.dart';
import '../models/pet.dart';
import '../models/produto.dart';

/// Serviço para geração de Relatórios em PDF
class PdfService {
  /// Gera um PDF com a lista de produtos e abre a tela de impressão/compartilhamento
  Future<void> gerarCatalogoProdutos(List<Produto> produtos) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Catálogo de Produtos - Banho & Tosa',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Produto', 'Categoria', 'Preço (R\$)', 'Estoque'],
              data: produtos
                  .map((p) => [
                        p.nome,
                        p.categoria,
                        p.preco.toStringAsFixed(2),
                        p.estoque.toString(),
                      ])
                  .toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(
                text: 'Total de produtos cadastrados: ${produtos.length}'),
            pw.Footer(
              title: pw.Text(
                  'Gerado automaticamente pelo App Banho & Tosa em ${DateTime.now()}'),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'catalogo_produtos.pdf',
    );
  }

  /// Gera um relatório de agendamentos em PDF
  Future<void> gerarRelatorioAgendamentos(
      List<Agendamento> agendamentos, List<Pet> pets, List<Cliente> clientes) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Relatório de Agendamentos',
                      style: pw.TextStyle(font: font, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
              cellStyle: pw.TextStyle(font: font, fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                <String>['Data', 'Hora', 'Serviço', 'Pet', 'Cliente', 'Valor', 'Status'],
                ...agendamentos.map((a) {
                  final pet = pets.firstWhere((p) => p.id == a.petId,
                      orElse: () => Pet(id: '', nome: '?', raca: '', porte: '', clienteId: ''));
                  final cliente = clientes.firstWhere((c) => c.id == pet.clienteId,
                      orElse: () => Cliente(id: '', nome: '?', telefone: '', email: '', endereco: ''));
                  
                  return [
                    DateFormat('dd/MM').format(a.dataHora),
                    DateFormat('HH:mm').format(a.dataHora),
                    a.servico,
                    pet.nome,
                    cliente.nome,
                    'R\$ ${a.valor.toStringAsFixed(2)}',
                    a.status
                  ];
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'relatorio_agendamentos.pdf',
    );
  }
}
