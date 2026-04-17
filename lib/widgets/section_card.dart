import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String number;
  final String title;
  final Widget child;

  const SectionCard({
    required this.number,
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
      padding: AppDimensions.paddingExtraLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: context.customColors.primaryGradient,
                  borderRadius: AppDimensions.radiusSmall,
                ),
                child: Text(
                  number,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const AppSpacerHorizontal.regular(),
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const AppSpacerVertical.large(),
          child,
        ],
      ),
    );
}
