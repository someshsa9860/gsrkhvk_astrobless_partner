class DashboardSummary {
  const DashboardSummary({
    required this.todayEarningsPaise,
    required this.weekEarningsPaise,
    required this.totalConsultations,
    required this.activeConsultations,
    required this.ratingAvg,
    required this.isOnline,
  });

  final int todayEarningsPaise;
  final int weekEarningsPaise;
  final int totalConsultations;
  final int activeConsultations;
  final double ratingAvg;
  final bool isOnline;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todayEarningsPaise: json['todayEarningsPaise'] as int? ?? 0,
      weekEarningsPaise: json['weekEarningsPaise'] as int? ?? 0,
      totalConsultations: json['totalConsultations'] as int? ?? 0,
      activeConsultations: json['activeConsultations'] as int? ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'todayEarningsPaise': todayEarningsPaise,
        'weekEarningsPaise': weekEarningsPaise,
        'totalConsultations': totalConsultations,
        'activeConsultations': activeConsultations,
        'ratingAvg': ratingAvg,
        'isOnline': isOnline,
      };

  DashboardSummary copyWith({bool? isOnline}) {
    return DashboardSummary(
      todayEarningsPaise: todayEarningsPaise,
      weekEarningsPaise: weekEarningsPaise,
      totalConsultations: totalConsultations,
      activeConsultations: activeConsultations,
      ratingAvg: ratingAvg,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
