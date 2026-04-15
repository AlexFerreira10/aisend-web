import 'package:flutter/material.dart';

extension ThemeExtras on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  Brightness get platformBrightness => MediaQuery.platformBrightnessOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  TextScaler get textScaler => MediaQuery.textScalerOf(this);

  // Quick access to commonly used responsive flags
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1024;
}
