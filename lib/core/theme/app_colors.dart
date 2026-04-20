import 'package:flutter/material.dart';

/// AiSend Brand Colors
abstract final class AppColors {
  // ─── Primary (Tons de Ametista / Menos Neon) ───────────────────────────────
  static const Color primary = Color(0xFF6B4FA3);
  static const Color primaryLight = Color(0xFF8A73BA);
  static const Color primaryDark = Color(0xFF483273);
  static const Color primaryGlow = Color(0x336B4FA3);

  // ─── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentGlow = Color(0x2206B6D4);

  // ─── Background & Surface ──────────────────────────────────────────────────
  static const Color background = Color(0xFF080B14);
  static const Color surface = Color(0xFF10141F);
  static const Color card = Color(0xFF161B2E);
  static const Color cardHover = Color(0xFF1E2540);

  // ─── Border ────────────────────────────────────────────────────────────────
  static const Color border = Color(0x12FFFFFF);
  static const Color borderFocus = Color(
    0x408A73BA,
  ); // Ajustado para combinar com primaryLight

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  // ─── Lead Status ───────────────────────────────────────────────────────────
  static const Color statusHot = Color(0xFFF97316);
  static const Color statusHotBg = Color(0x1AF97316);
  static const Color statusWarm = Color(0xFFEAB308);
  static const Color statusWarmBg = Color(0x1AEAB308);
  static const Color statusCold = Color(0xFF60A5FA);
  static const Color statusColdBg = Color(0x1A60A5FA);

  // ─── Feedback ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0x1A10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0x1AEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x1AF59E0B);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, card],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
