class DashboardSummary {
  const DashboardSummary({
    required this.todayEarnings,
    required this.weekEarnings,
    required this.totalConsultations,
    required this.activeConsultations,
    required this.ratingAvg,
    required this.isOnline,
  });

  final int todayEarnings;
  final int weekEarnings;
  final int totalConsultations;
  final int activeConsultations;
  final double ratingAvg;
  final bool isOnline;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todayEarnings: json['todayEarnings'] as int? ?? 0,
      weekEarnings: json['weekEarnings'] as int? ?? 0,
      totalConsultations: json['totalConsultations'] as int? ?? 0,
      activeConsultations: json['activeConsultations'] as int? ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'todayEarnings': todayEarnings,
        'weekEarnings': weekEarnings,
        'totalConsultations': totalConsultations,
        'activeConsultations': activeConsultations,
        'ratingAvg': ratingAvg,
        'isOnline': isOnline,
      };

  DashboardSummary copyWith({bool? isOnline}) {
    return DashboardSummary(
      todayEarnings: todayEarnings,
      weekEarnings: weekEarnings,
      totalConsultations: totalConsultations,
      activeConsultations: activeConsultations,
      ratingAvg: ratingAvg,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
