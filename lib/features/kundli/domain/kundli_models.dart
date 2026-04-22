class KundliRequest {
  const KundliRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.birthDate,
    required this.birthPlace,
    required this.priceAtOrderPaise,
    required this.createdAt,
    this.birthTime,
    this.question,
    this.slaDueAt,
    this.reportText,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String status; // pending|accepted|inProgress|completed|declined|expired
  final DateTime birthDate;
  final String birthPlace;
  final int priceAtOrderPaise;
  final DateTime createdAt;
  final String? birthTime;
  final String? question;
  final DateTime? slaDueAt;
  final String? reportText;

  factory KundliRequest.fromJson(Map<String, dynamic> json) {
    return KundliRequest(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? 'Customer',
      status: json['status'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthPlace: json['birthPlace'] as String,
      priceAtOrderPaise: json['priceAtOrderPaise'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      birthTime: json['birthTime'] as String?,
      question: json['question'] as String?,
      slaDueAt: json['slaDueAt'] != null
          ? DateTime.parse(json['slaDueAt'] as String)
          : null,
      reportText: json['reportText'] as String?,
    );
  }
}
