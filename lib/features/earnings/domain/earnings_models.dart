class EarningsSummary {
  const EarningsSummary({
    required this.today,
    required this.week,
    required this.month,
    required this.allTime,
  });

  final double today;
  final double week;
  final double month;
  final double allTime;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      today: (json['today'] as num?)?.toDouble() ?? 0.0,
      week: (json['week'] as num?)?.toDouble() ?? 0.0,
      month: (json['month'] as num?)?.toDouble() ?? 0.0,
      allTime: (json['allTime'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EarningTransaction {
  const EarningTransaction({
    required this.id,
    required this.consultationId,
    required this.gross,
    required this.commissionPct,
    required this.net,
    required this.createdAt,
    this.customerName,
    this.type,
  });

  final String id;
  final String consultationId;
  final double gross;
  final double commissionPct;
  final double net;
  final DateTime createdAt;
  final String? customerName;
  final String? type;

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] as String,
      consultationId: json['consultationId'] as String,
      gross: (json['gross'] as num?)?.toDouble() ?? 0.0,
      commissionPct: (json['commissionPct'] as num?)?.toDouble() ?? 30.0,
      net: (json['net'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerName: json['customerName'] as String?,
      type: json['type'] as String?,
    );
  }
}

class Payout {
  const Payout({
    required this.id,
    required this.amount,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    this.processedAt,
  });

  final String id;
  final double amount;
  final String status; // queued | processing | processed | failed
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? processedAt;

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
    );
  }
}
