class EarningsSummary {
  const EarningsSummary({
    required this.todayPaise,
    required this.weekPaise,
    required this.monthPaise,
    required this.allTimePaise,
  });

  final int todayPaise;
  final int weekPaise;
  final int monthPaise;
  final int allTimePaise;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      todayPaise: json['todayPaise'] as int? ?? 0,
      weekPaise: json['weekPaise'] as int? ?? 0,
      monthPaise: json['monthPaise'] as int? ?? 0,
      allTimePaise: json['allTimePaise'] as int? ?? 0,
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
  final int gross;
  final double commissionPct;
  final int net;
  final DateTime createdAt;
  final String? customerName;
  final String? type;

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] as String,
      consultationId: json['consultationId'] as String,
      gross: json['gross'] as int? ?? 0,
      commissionPct: (json['commissionPct'] as num?)?.toDouble() ?? 30.0,
      net: json['net'] as int? ?? 0,
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
  final int amount;
  final String status; // queued | processing | processed | failed
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? processedAt;

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String,
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
    );
  }
}
