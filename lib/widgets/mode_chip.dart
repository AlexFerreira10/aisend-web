import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:flutter/material.dart';

class ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: AppDimensions.paddingHorizontalLarge(context)
            .add(AppDimensions.paddingVerticalMedium(context)),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.primary.withValues(alpha: 0.12)
              : context.colorScheme.surface,
          borderRadius: AppDimensions.radiusLarge,
          border: Border.all(
            color: selected
                ? context.colorScheme.primary
                : context.colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 15,
              color: selected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            const AppSpacerHorizontal.tiny(),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
}
