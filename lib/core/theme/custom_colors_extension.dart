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
  final Color accentSecondary;
  final Color accentSecondaryBg;
  final Color accentSecondaryGlow;
  final LinearGradient primaryGradient;
  final LinearGradient logoGradient;
  final LinearGradient surfaceGradient;
  final LinearGradient amberGradient;

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
    required this.accentSecondary,
    required this.accentSecondaryBg,
    required this.accentSecondaryGlow,
    required this.primaryGradient,
    required this.logoGradient,
    required this.surfaceGradient,
    required this.amberGradient,
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
    Color? accentSecondary,
    Color? accentSecondaryBg,
    Color? accentSecondaryGlow,
    LinearGradient? primaryGradient,
    LinearGradient? logoGradient,
    LinearGradient? surfaceGradient,
    LinearGradient? amberGradient,
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
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentSecondaryBg: accentSecondaryBg ?? this.accentSecondaryBg,
      accentSecondaryGlow: accentSecondaryGlow ?? this.accentSecondaryGlow,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      logoGradient: logoGradient ?? this.logoGradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
      amberGradient: amberGradient ?? this.amberGradient,
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
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentSecondaryBg: Color.lerp(
        accentSecondaryBg,
        other.accentSecondaryBg,
        t,
      )!,
      accentSecondaryGlow: Color.lerp(
        accentSecondaryGlow,
        other.accentSecondaryGlow,
        t,
      )!,
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      logoGradient: LinearGradient.lerp(logoGradient, other.logoGradient, t)!,
      surfaceGradient: LinearGradient.lerp(
        surfaceGradient,
        other.surfaceGradient,
        t,
      )!,
      amberGradient: LinearGradient.lerp(
        amberGradient,
        other.amberGradient,
        t,
      )!,
    );
  }

  static const dark = AppCustomColors(
    statusHot: AppColorsDark.statusHot,
    statusHotBg: AppColorsDark.statusHotBg,
    statusWarm: AppColorsDark.statusWarm,
    statusWarmBg: AppColorsDark.statusWarmBg,
    statusCold: AppColorsDark.statusCold,
    statusColdBg: AppColorsDark.statusColdBg,
    success: AppColorsDark.success,
    successBg: AppColorsDark.successBg,
    error: AppColorsDark.error,
    errorBg: AppColorsDark.errorBg,
    warning: AppColorsDark.warning,
    warningBg: AppColorsDark.warningBg,
    accentSecondary: AppColorsDark.accentSecondary,
    accentSecondaryBg: AppColorsDark.accentSecondaryBg,
    accentSecondaryGlow: AppColorsDark.accentSecondaryGlow,
    primaryGradient: AppColorsDark.primaryGradient,
    logoGradient: AppColorsDark.logoGradient,
    surfaceGradient: AppColorsDark.surfaceGradient,
    amberGradient: AppColorsDark.amberGradient,
  );

  static const light = AppCustomColors(
    statusHot: AppColorsLight.statusHot,
    statusHotBg: AppColorsLight.statusHotBg,
    statusWarm: AppColorsLight.statusWarm,
    statusWarmBg: AppColorsLight.statusWarmBg,
    statusCold: AppColorsLight.statusCold,
    statusColdBg: AppColorsLight.statusColdBg,
    success: AppColorsLight.success,
    successBg: AppColorsLight.successBg,
    error: AppColorsLight.error,
    errorBg: AppColorsLight.errorBg,
    warning: AppColorsLight.warning,
    warningBg: AppColorsLight.warningBg,
    accentSecondary: AppColorsLight.accentSecondary,
    accentSecondaryBg: AppColorsLight.accentSecondaryBg,
    accentSecondaryGlow: AppColorsLight.accentSecondaryGlow,
    primaryGradient: AppColorsLight.primaryGradient,
    logoGradient: AppColorsLight.logoGradient,
    surfaceGradient: AppColorsLight.surfaceGradient,
    amberGradient: AppColorsLight.amberGradient,
  );
}

extension AppCustomColorsExtension on BuildContext {
  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>()!;
}
