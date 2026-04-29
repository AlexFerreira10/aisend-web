import 'package:flutter/material.dart';

abstract final class AppColorsDark {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryGlow = Color(0x333B82F6);

  static const Color accent = Color(0xFF10B981);
  static const Color accentGlow = Color(0x2210B981);

  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color card = Color(0xFF21262D);
  static const Color cardHover = Color(0xFF2D333B);

  static const Color border = Color(0xFF30363D);
  static const Color borderFocus = Color(0x603B82F6);

  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);

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

abstract final class AppColorsLight {
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryGlow = Color(0x331E40AF);

  static const Color accent = Color(0xFF059669);
  static const Color accentGlow = Color(0x22059669);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF1F5F9);
  static const Color cardHover = Color(0xFFE2E8F0);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0x601E40AF);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

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
}

// Alias mantido para compatibilidade com referências existentes
typedef AppColors = AppColorsDark;
