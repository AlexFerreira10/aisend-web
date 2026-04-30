import 'package:flutter/material.dart';

abstract final class AppColorsDark {
  // Primary — azul vibrante fidélissimo à referência
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryGlow = Color(0x333B82F6);

  // Accent — verde esmeralda
  static const Color accent = Color(0xFF10B981);
  static const Color accentGlow = Color(0x2210B981);

  // Accent secundário — âmbar/laranja
  static const Color accentSecondary = Color(0xFFF5A623);
  static const Color accentSecondaryBg = Color(0x1AF5A623);
  static const Color accentSecondaryGlow = Color(0x33F5A623);

  // ── Backgrounds — extraídos fielmente da referência BitVista ──
  // Fundo principal: dark gray neutro e escuro
  static const Color background = Color(0xFF13131A);
  // Sidebar / superfície elevada: um degrau acima do fundo
  static const Color surface = Color(0xFF1C1C24);
  // Cards: degrau acima da surface
  static const Color card = Color(0xFF262630);
  // Cards hover: leve clareada
  static const Color cardHover = Color(0xFF323240);

  // ── Bordas ──
  static const Color border = Color(0xFF3A3A4A);
  static const Color borderSubtle = Color(0x0FFFFFFF);
  static const Color borderFocus = Color(0x603B82F6);

  // ── Texto ──
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ── Status ──
  static const Color statusHot = Color(0xFFF97316);
  static const Color statusHotBg = Color(0x1AF97316);
  static const Color statusWarm = Color(0xFFEAB308);
  static const Color statusWarmBg = Color(0x1AEAB308);
  static const Color statusCold = Color(0xFF60A5FA);
  static const Color statusColdBg = Color(0x1A60A5FA);

  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0x1A10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0x1AEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x1AF59E0B);

  // ── Gradients ──
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

  static const LinearGradient amberGradient = LinearGradient(
    colors: [accentSecondary, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract final class AppColorsLight {
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryGlow = Color(0x331E40AF);

  static const Color accent = Color(0xFF059669);
  static const Color accentGlow = Color(0x22059669);

  static const Color accentSecondary = Color(0xFFD97706);
  static const Color accentSecondaryBg = Color(0x1AD97706);
  static const Color accentSecondaryGlow = Color(0x33D97706);

  // Fundos claros — versão light do mesmo sistema
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF8FAFC);
  static const Color cardHover = Color(0xFFE2E8F0);

  static const Color border = Color(0xFFCBD5E1);
  static const Color borderSubtle = Color(0x18000000);
  static const Color borderFocus = Color(0x801E40AF);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);

  static const Color statusHot = Color(0xFFF97316);
  static const Color statusHotBg = Color(0x1AF97316);
  static const Color statusWarm = Color(0xFFEAB308);
  static const Color statusWarmBg = Color(0x1AEAB308);
  static const Color statusCold = Color(0xFF2563EB);
  static const Color statusColdBg = Color(0x1A2563EB);

  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0x1A059669);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0x1ADC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0x1AD97706);

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

  static const LinearGradient amberGradient = LinearGradient(
    colors: [accentSecondary, Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Alias mantido para compatibilidade com referências existentes
typedef AppColors = AppColorsDark;
