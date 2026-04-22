import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────
  static const primary = Color(0xFF5C6BC0);       // indigo-400
  static const primaryDark = Color(0xFF3949AB);   // indigo-600
  static const primaryLight = Color(0xFF7986CB);  // indigo-300
  static const accent = Color(0xFFFFB300);        // amber
  static const accentLight = Color(0xFFFFE082);   // amber-200

  // ── Dark mode surfaces ───────────────────────────────────────────────
  static const bgDark = Color(0xFF0D0B1E);        // near-black navy
  static const surfaceDark = Color(0xFF14122A);   // elevated surface
  static const cardDark = Color(0xFF1E1B38);      // card bg
  static const borderDark = Color(0xFF2D2850);    // border / divider
  static const inputDark = Color(0xFF1A1835);     // input field bg

  // ── Light mode surfaces ──────────────────────────────────────────────
  static const bgLight = Color(0xFFF5F5FF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE0E0F0);
  static const inputLight = Color(0xFFF0F0FA);

  // ── Text ─────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFECEFF1);
  static const textSecondary = Color(0xFFB0BEC5);
  static const textDisabled = Color(0xFF546E7A);
  static const textDark = Color(0xFF1A1A2E);
  static const textMedium = Color(0xFF4A4A6A);

  // ── Status ───────────────────────────────────────────────────────────
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);
  static const warning = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFF3E0);
  static const error = Color(0xFFEF5350);
  static const errorLight = Color(0xFFFFEBEE);
  static const info = Color(0xFF42A5F5);
  static const infoLight = Color(0xFFE3F2FD);

  // ── Online / busy ────────────────────────────────────────────────────
  static const online = Color(0xFF66BB6A);
  static const offline = Color(0xFF78909C);
  static const busy = Color(0xFFFF7043);

  // ── Chat bubbles ─────────────────────────────────────────────────────
  static const bubbleSent = Color(0xFF3949AB);
  static const bubbleReceived = Color(0xFF1E1B38);

  // ── Gradient ─────────────────────────────────────────────────────────
  static const List<Color> brandGradient = [Color(0xFF3949AB), Color(0xFF7C4DFF)];
  static const List<Color> goldGradient = [Color(0xFFFFB300), Color(0xFFFF6F00)];
  static const List<Color> darkBgGradient = [Color(0xFF0D0B1E), Color(0xFF14122A)];
}
