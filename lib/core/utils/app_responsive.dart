import 'package:flutter/material.dart';

abstract final class AppResponsive {
  // ─── Breakpoints ────────────────────────────────────────────────────────────
  
  /// Desktop breakpoint: 1024px
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  /// Tablet breakpoint: 768px to 1023px
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 768 &&
      MediaQuery.sizeOf(context).width < 1024;

  /// Mobile breakpoint: less than 768px
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 768;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool shouldReduceSpacing(BuildContext context) => isMobile(context);

  // ─── Responsive Padding ─────────────────────────────────────────────────────
  
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
  }

  static EdgeInsets pageContentPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.fromLTRB(40, 32, 40, 40);
    } else if (isTablet(context)) {
      return const EdgeInsets.fromLTRB(24, 24, 24, 32);
    }
    return const EdgeInsets.fromLTRB(16, 20, 16, 32);
  }
}
