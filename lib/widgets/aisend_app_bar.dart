import 'package:flutter/material.dart';
import '../core/theme/context_extension.dart';
import '../core/theme/custom_colors_extension.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_spacer.dart';

class AiSendAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const AiSendAppBar({super.key, required this.currentRoute});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: context.theme.dividerColor, width: 1),
        ),
      ),
      padding: AppDimensions.paddingHorizontalExtraLarge(context),
      child: Row(
        children: <Widget>[
          const _AiSendLogo(),
          const Spacer(),
          _NavButton(
            label: context.isMobile ? 'Results' : 'Results Center',
            icon: Icons.bar_chart_rounded,
            isActive: currentRoute == '/',
            onTap: () {
              if (currentRoute != '/') {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          const AppSpacerHorizontal.regular(),
          _NavButton(
            label: context.isMobile ? 'Disparos' : 'Máquina de disparos',
            icon: Icons.send_rounded,
            isActive: currentRoute == '/broadcast',
            onTap: () {
              if (currentRoute != '/broadcast') {
                Navigator.pushReplacementNamed(context, '/broadcast');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AiSendLogo extends StatelessWidget {
  const _AiSendLogo();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: context.customColors.logoGradient,
            borderRadius: AppDimensions.radiusLarge,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
        ),
        if (!isMobile) ...[
          const AppSpacerHorizontal.medium(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    context.customColors.logoGradient.createShader(bounds),
                child: Text(
                  'AiSend',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                'Disparos Inteligentes',
                style: context.textTheme.labelSmall,
              ),
            ],
          ),
        ] else ...[
          const AppSpacerHorizontal.regular(),
          Text(
            'AiSend',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppDimensions.paddingHorizontalMediumLarge(
          context,
        ).add(AppDimensions.paddingVerticalRegular(context)),
        decoration: BoxDecoration(
          color: widget.isActive
              ? context.colorScheme.primary
              : _hovered
              ? context.colorScheme.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: AppDimensions.radiusMedium,
          border: Border.all(
            color: widget.isActive
                ? context.colorScheme.primary
                : _hovered
                ? context.theme.dividerColor
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              widget.icon,
              size: AppDimensions.iconSmall(context),
              color: widget.isActive
                  ? Colors.white
                  : _hovered
                  ? context.colorScheme.onSurface
                  : context.colorScheme.onSurfaceVariant,
            ),
            const AppSpacerHorizontal.tiny(),
            Text(
              widget.label,
              style: context.textTheme.labelLarge?.copyWith(
                color: widget.isActive
                    ? Colors.white
                    : _hovered
                    ? context.colorScheme.onSurface
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
