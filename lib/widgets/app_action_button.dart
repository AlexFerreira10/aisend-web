import 'package:flutter/material.dart';
import '../core/theme/context_extension.dart';
import '../core/theme/custom_colors_extension.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_spacer.dart';

class AppActionButton extends StatefulWidget {
  final bool enabled;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool useGradient;
  final bool fullWidth;

  const AppActionButton({
    super.key,
    required this.enabled,
    required this.icon,
    required this.label,
    required this.onTap,
    this.useGradient = true,
    this.fullWidth = true,
  });

  @override
  State<AppActionButton> createState() => _AppActionButtonState();
}

class _AppActionButtonState extends State<AppActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.fullWidth
              ? AppDimensions.paddingVerticalLarge(context)
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: (widget.enabled && widget.useGradient) ? context.customColors.primaryGradient : null,
            color: (widget.enabled && widget.useGradient) ? null : context.colorScheme.surface,
            borderRadius: AppDimensions.radiusExtraLarge,
            border: (widget.enabled && widget.useGradient)
                ? null
                : Border.all(
                    color: widget.enabled
                        ? context.colorScheme.primary
                        : context.colorScheme.outline,
                    width: 1.5,
                  ),
            boxShadow: (widget.enabled && widget.useGradient && _hovered)
                ? [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                widget.icon,
                size: 18,
                color: (widget.enabled && widget.useGradient)
                    ? Colors.white
                    : widget.enabled
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant,
              ),
              const AppSpacerHorizontal.regular(),
              Text(
                widget.label,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: (widget.enabled && widget.useGradient)
                      ? Colors.white
                      : widget.enabled
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
