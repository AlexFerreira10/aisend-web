import 'package:flutter/material.dart';
import '../utils/app_responsive.dart';

class AppDimensions {
  AppDimensions._();

  static bool isMobile(BuildContext context) => AppResponsive.isMobile(context);
  static bool isDesktop(BuildContext context) => AppResponsive.isDesktop(context);

  static const double kTiny = 2.0;
  static const double kSmall = 4.0;
  static const double kRegular = 8.0;
  static const double kMedium = 12.0;
  static const double kMediumLarge = 16.0;
  static const double kLarge = 16.0;
  static const double kExtraLarge = 20.0;
  static const double kHuge = 32.0;

  static const double kIconSmall = 14.0;
  static const double kIconMediumSmall = 18.0;
  static const double kIconMedium = 20.0;
  static const double kIconLarge = 28.0;
  static const double kIconExtraLarge = 40.0;

  static const double kButtonHeightSmall = 36.0;
  static const double kButtonHeightMedium = 44.0;
  static const double kButtonHeightLarge = 52.0;

  static double tiny(BuildContext context) =>
      AppResponsive.isMobile(context) ? 2.0 : 4.0;

  static double small(BuildContext context) =>
      AppResponsive.isMobile(context) ? 4.0 : 8.0;

  static double regular(BuildContext context) =>
      AppResponsive.isMobile(context) ? 8.0 : 12.0;

  static double medium(BuildContext context) =>
      AppResponsive.isMobile(context) ? 12.0 : 16.0;

  static double mediumLarge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 16.0 : 20.0;

  static double large(BuildContext context) =>
      AppResponsive.isMobile(context) ? 16.0 : 24.0;

  static double extraLarge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 20.0 : 32.0;

  static double huge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 32.0 : 48.0;

  static final BorderRadius radiusSmall = BorderRadius.circular(4.0);
  static final BorderRadius radiusMedium = BorderRadius.circular(8.0);
  static final BorderRadius radiusLarge = BorderRadius.circular(10.0);
  static final BorderRadius radiusExtraLarge = BorderRadius.circular(16.0);
  static final BorderRadius radiusHuge = BorderRadius.circular(22.0);
  static final BorderRadius radiusRound = BorderRadius.circular(999.0);

  static double iconSmallest(BuildContext context) =>
      AppResponsive.isMobile(context) ? 10.0 : 12.0;

  static double iconSmall(BuildContext context) =>
      AppResponsive.isMobile(context) ? 14.0 : 16.0;

  static double iconMediumSmall(BuildContext context) =>
      AppResponsive.isMobile(context) ? 18.0 : 20.0;

  static double iconMedium(BuildContext context) =>
      AppResponsive.isMobile(context) ? 20.0 : 24.0;

  static double iconLarge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 28.0 : 32.0;

  static double iconExtraLarge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 40.0 : 48.0;

  static double buttonHeightSmall(BuildContext context) =>
      AppResponsive.isMobile(context) ? 32.0 : 34.0;

  static double buttonHeightMedium(BuildContext context) =>
      AppResponsive.isMobile(context) ? 40.0 : 44.0;

  static double buttonHeightLarge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 52.0 : 56.0;

  static double containerSmall(BuildContext context) =>
      AppResponsive.isMobile(context) ? 36.0 : 40.0;

  static double containerMedium(BuildContext context) =>
      AppResponsive.isMobile(context) ? 52.0 : 56.0;

  static double containerLarge(BuildContext context) =>
      AppResponsive.isMobile(context) ? 68.0 : 72.0;

  static EdgeInsets paddingTiny(BuildContext context) =>
      EdgeInsets.all(tiny(context));

  static EdgeInsets paddingSmall(BuildContext context) =>
      EdgeInsets.all(small(context));

  static EdgeInsets paddingRegular(BuildContext context) =>
      EdgeInsets.all(regular(context));

  static EdgeInsets paddingMedium(BuildContext context) =>
      EdgeInsets.all(medium(context));

  static EdgeInsets paddingMediumLarge(BuildContext context) =>
      EdgeInsets.all(mediumLarge(context));

  static EdgeInsets paddingLarge(BuildContext context) =>
      EdgeInsets.all(large(context));

  static EdgeInsets paddingExtraLarge(BuildContext context) =>
      EdgeInsets.all(extraLarge(context));

  static EdgeInsets paddingHuge(BuildContext context) =>
      EdgeInsets.all(huge(context));

  static EdgeInsets paddingHorizontalTiny(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: tiny(context));

  static EdgeInsets paddingHorizontalSmall(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: small(context));

  static EdgeInsets paddingHorizontalRegular(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: regular(context));

  static EdgeInsets paddingHorizontalMedium(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: medium(context));

  static EdgeInsets paddingHorizontalMediumLarge(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: mediumLarge(context));

  static EdgeInsets paddingHorizontalLarge(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: large(context));

  static EdgeInsets paddingHorizontalExtraLarge(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: extraLarge(context));

  static EdgeInsets paddingHorizontalHuge(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: huge(context));

  static EdgeInsets paddingVerticalTiny(BuildContext context) =>
      EdgeInsets.symmetric(vertical: tiny(context));

  static EdgeInsets paddingVerticalSmall(BuildContext context) =>
      EdgeInsets.symmetric(vertical: small(context));

  static EdgeInsets paddingVerticalRegular(BuildContext context) =>
      EdgeInsets.symmetric(vertical: regular(context));

  static EdgeInsets paddingVerticalMedium(BuildContext context) =>
      EdgeInsets.symmetric(vertical: medium(context));

  static EdgeInsets paddingVerticalMediumLarge(BuildContext context) =>
      EdgeInsets.symmetric(vertical: mediumLarge(context));

  static EdgeInsets paddingVerticalLarge(BuildContext context) =>
      EdgeInsets.symmetric(vertical: large(context));

  static EdgeInsets paddingVerticalExtraLarge(BuildContext context) =>
      EdgeInsets.symmetric(vertical: extraLarge(context));

  static EdgeInsets paddingVerticalHuge(BuildContext context) =>
      EdgeInsets.symmetric(vertical: huge(context));

  static const EdgeInsets paddingZero = EdgeInsets.zero;

  static EdgeInsets paddingLeft(BuildContext context) =>
      EdgeInsets.only(left: medium(context));

  static EdgeInsets paddingRight(BuildContext context) =>
      EdgeInsets.only(right: medium(context));

  static EdgeInsets paddingTop(BuildContext context) =>
      EdgeInsets.only(top: medium(context));

  static EdgeInsets paddingBottom(BuildContext context) =>
      EdgeInsets.only(bottom: medium(context));
}
