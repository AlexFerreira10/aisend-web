import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color statusHot;
  final Color statusHotBg;
  final Color statusWarm;
  final Color statusWarmBg;
  final Color statusCold;
  final Color statusColdBg;
  final Color success;
  final Color successBg;
  final Color error;
  final Color errorBg;
  final Color warning;
  final Color warningBg;
  final LinearGradient primaryGradient;
  final LinearGradient logoGradient;
  final LinearGradient surfaceGradient;

  const AppCustomColors({
    required this.statusHot,
    required this.statusHotBg,
    required this.statusWarm,
    required this.statusWarmBg,
    required this.statusCold,
    required this.statusColdBg,
    required this.success,
    required this.successBg,
    required this.error,
    required this.errorBg,
    required this.warning,
    required this.warningBg,
    required this.primaryGradient,
    required this.logoGradient,
    required this.surfaceGradient,
  });

  @override
  AppCustomColors copyWith({
    Color? statusHot,
    Color? statusHotBg,
    Color? statusWarm,
    Color? statusWarmBg,
    Color? statusCold,
    Color? statusColdBg,
    Color? success,
    Color? successBg,
    Color? error,
    Color? errorBg,
    Color? warning,
    Color? warningBg,
    LinearGradient? primaryGradient,
    LinearGradient? logoGradient,
    LinearGradient? surfaceGradient,
  }) {
    return AppCustomColors(
      statusHot: statusHot ?? this.statusHot,
      statusHotBg: statusHotBg ?? this.statusHotBg,
      statusWarm: statusWarm ?? this.statusWarm,
      statusWarmBg: statusWarmBg ?? this.statusWarmBg,
      statusCold: statusCold ?? this.statusCold,
      statusColdBg: statusColdBg ?? this.statusColdBg,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      logoGradient: logoGradient ?? this.logoGradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      statusHot: Color.lerp(statusHot, other.statusHot, t)!,
      statusHotBg: Color.lerp(statusHotBg, other.statusHotBg, t)!,
      statusWarm: Color.lerp(statusWarm, other.statusWarm, t)!,
      statusWarmBg: Color.lerp(statusWarmBg, other.statusWarmBg, t)!,
      statusCold: Color.lerp(statusCold, other.statusCold, t)!,
      statusColdBg: Color.lerp(statusColdBg, other.statusColdBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      logoGradient: LinearGradient.lerp(logoGradient, other.logoGradient, t)!,
      surfaceGradient: LinearGradient.lerp(surfaceGradient, other.surfaceGradient, t)!,
    );
  }

  // Define the default dark instance
  static const dark = AppCustomColors(
    statusHot: AppColors.statusHot,
    statusHotBg: AppColors.statusHotBg,
    statusWarm: AppColors.statusWarm,
    statusWarmBg: AppColors.statusWarmBg,
    statusCold: AppColors.statusCold,
    statusColdBg: AppColors.statusColdBg,
    success: AppColors.success,
    successBg: AppColors.successBg,
    error: AppColors.error,
    errorBg: AppColors.errorBg,
    warning: AppColors.warning,
    warningBg: AppColors.warningBg,
    primaryGradient: AppColors.primaryGradient,
    logoGradient: AppColors.logoGradient,
    surfaceGradient: AppColors.surfaceGradient,
  );
}

extension AppCustomColorsExtension on BuildContext {
  AppCustomColors get customColors => Theme.of(this).extension<AppCustomColors>()!;
}
