import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';

class PreviewCard extends StatelessWidget {
  final List<String> parts;
  final VoidCallback onReset;

  const PreviewCard({super.key, required this.parts, required this.onReset});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: AppDimensions.paddingExtraLarge(context),
      decoration: BoxDecoration(
        color: context.customColors.successBg,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(
          color: context.customColors.success.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.visibility_rounded,
                  size: 18, color: context.customColors.success),
              const AppSpacerHorizontal.regular(),
              Text(
                'Prévia da mensagem',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.customColors.success,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onReset,
                child: Text(
                  'Alterar',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const AppSpacerVertical.large(),
          ...parts.map(
            (part) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: AppDimensions.paddingMediumLarge(context),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: AppDimensions.radiusLarge,
                  border: Border.all(
                    color: context.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  part,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
}
