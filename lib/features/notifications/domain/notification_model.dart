import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  AppNotification copyWith({DateTime? readAt}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      data: data,
    );
  }

  String get emoji => switch (type) {
        'consultationRequest' => '💬',
        'earningsUpdate' => '💰',
        'kycStatusUpdate' => '✅',
        'payoutProcessed' => '🏦',
        _ => '🔔',
      };

  Color get color => switch (type) {
        'consultationRequest' => AppColors.primary,
        'earningsUpdate' => AppColors.accent,
        'kycStatusUpdate' => AppColors.success,
        'payoutProcessed' => AppColors.success,
        _ => AppColors.textSecondary,
      };
}
