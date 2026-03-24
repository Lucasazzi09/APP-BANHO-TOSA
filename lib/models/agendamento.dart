class Agendamento {
  final String id;
  final String petId;
  final DateTime dataHora;
  final String servico;
  final double valor;
  final String status; // Agendado, Concluído, Cancelado
  final String statusPagamento; // Pendente, Pago
  final String formaPagamento; // Dinheiro, Pix, Cartão
  final List<String> produtosUsados; // ids dos produtos
  final String? observacoes;

  Agendamento({
    required this.id,
    required this.petId,
    required this.dataHora,
    required this.servico,
    required this.valor,
    required this.status,
    this.statusPagamento = 'Pendente',
    this.formaPagamento = 'Pix',
    this.produtosUsados = const [],
    this.observacoes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'dataHora': dataHora.toIso8601String(),
        'servico': servico,
        'valor': valor,
        'status': status,
        'statusPagamento': statusPagamento,
        'formaPagamento': formaPagamento,
        'produtosUsados': produtosUsados,
        'observacoes': observacoes,
      };

  factory Agendamento.fromJson(Map<String, dynamic> json) => Agendamento(
        id: json['id'],
        petId: json['petId'],
        dataHora: DateTime.parse(json['dataHora']),
        servico: json['servico'],
        valor: (json['valor'] as num).toDouble(),
        status: json['status'],
        statusPagamento: json['statusPagamento'] ?? 'Pendente',
        formaPagamento: json['formaPagamento'] ?? 'Pix',
        produtosUsados: List<String>.from(json['produtosUsados'] ?? []),
        observacoes: json['observacoes'],
      );

  Agendamento copyWith({String? status, String? statusPagamento, String? formaPagamento}) => Agendamento(
        id: id,
        petId: petId,
        dataHora: dataHora,
        servico: servico,
        valor: valor,
        status: status ?? this.status,
        statusPagamento: statusPagamento ?? this.statusPagamento,
        formaPagamento: formaPagamento ?? this.formaPagamento,
        produtosUsados: produtosUsados,
        observacoes: observacoes,
      );
}
