import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_dimensions.dart';

enum ToastType { success, error, warning, info }

abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    final (color, icon) = switch (type) {
      ToastType.success => (AppColors.success, Icons.check_circle_rounded),
      ToastType.error => (AppColors.error, Icons.error_rounded),
      ToastType.warning => (AppColors.warning, Icons.warning_rounded),
      ToastType.info => (AppColors.accent, Icons.info_rounded),
    };

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: color, size: AppDimensions.kIconMedium),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusLarge,
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        margin: AppDimensions.paddingMedium(context),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
