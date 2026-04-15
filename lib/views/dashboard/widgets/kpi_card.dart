import 'package:flutter/material.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacer.dart';

class KpiCard extends StatefulWidget {
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: AppDimensions.paddingExtraLarge(context),
      decoration: BoxDecoration(
        color: _hovered
            ? context.colorScheme.surfaceContainerHighest
            : context.colorScheme.surface,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(
          color: _hovered
              ? context.colorScheme.primary.withValues(alpha: 0.4)
              : context.theme.dividerColor,
          width: 0.5,
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: widget.iconColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.iconBgColor,
              borderRadius: AppDimensions.radiusLarge,
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: AppDimensions.iconMedium(context),
            ),
          ),
          const AppSpacerHorizontal.large(),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const AppSpacerVertical.small(),
                Text(
                  widget.value,
                  style: context.textTheme.displayMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontSize: 28,
                  ),
                ),
                const AppSpacerVertical.tiny(),
                Text(widget.description, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
