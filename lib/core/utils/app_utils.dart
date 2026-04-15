import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// General utility helpers for AiSend UI decorations.
/// Specialized utilities have been moved to AppResponsive, AppToast, and AppFormatters.
abstract final class AppUtils {
  
  // ─── Gradient Button Decoration ──────────────────────────────────────────────
  
  static BoxDecoration gradientButtonDecoration({
    double radius = 10,
    bool withGlow = false,
  }) {
    return BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: withGlow
          ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );
  }
}
