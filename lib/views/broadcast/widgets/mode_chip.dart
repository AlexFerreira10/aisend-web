import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:flutter/material.dart';

class ModeChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ModeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<ModeChip> createState() => _ModeChipState();
}

class _ModeChipState extends State<ModeChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: AppDimensions.paddingHorizontalLarge(context)
              .add(AppDimensions.paddingVerticalMedium(context)),
          decoration: BoxDecoration(
            color: widget.selected
                ? context.colorScheme.primary.withValues(alpha: 0.1)
                : _hovered
                    ? context.colorScheme.surfaceContainerHighest
                    : context.colorScheme.surface,
            borderRadius: AppDimensions.radiusLarge,
            border: Border.all(
              color: active
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                widget.icon,
                size: 15,
                color: active
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
              const AppSpacerHorizontal.tiny(),
              Text(
                widget.label,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
