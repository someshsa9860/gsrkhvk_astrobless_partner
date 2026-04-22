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
    required this.grossPaise,
    required this.commissionPct,
    required this.netPaise,
    required this.createdAt,
    this.customerName,
    this.type,
  });

  final String id;
  final String consultationId;
  final int grossPaise;
  final double commissionPct;
  final int netPaise;
  final DateTime createdAt;
  final String? customerName;
  final String? type;

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] as String,
      consultationId: json['consultationId'] as String,
      grossPaise: json['grossPaise'] as int? ?? 0,
      commissionPct: (json['commissionPct'] as num?)?.toDouble() ?? 30.0,
      netPaise: json['netPaise'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerName: json['customerName'] as String?,
      type: json['type'] as String?,
    );
  }
}

class Payout {
  const Payout({
    required this.id,
    required this.amountPaise,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    this.processedAt,
  });

  final String id;
  final int amountPaise;
  final String status; // queued | processing | processed | failed
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? processedAt;

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String,
      amountPaise: json['amountPaise'] as int? ?? 0,
      status: json['status'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
    );
  }
}
