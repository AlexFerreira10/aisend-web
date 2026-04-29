import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';

class AiSendAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const AiSendAppBar({super.key, required this.currentRoute});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showDrawerIcon = width < 900;
    final useShortLabels = width >= 900 && width < 1200;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: context.theme.dividerColor, width: 1),
        ),
      ),
      padding: AppDimensions.paddingHorizontalLarge(context),
      child: Row(
        children: <Widget>[
          if (showDrawerIcon)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Abrir menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
              color: context.colorScheme.onSurface,
            ),
          const _AiSendLogo(),
          const Spacer(),
          if (!showDrawerIcon) ...[
            _NavButton(
              label: useShortLabels ? 'Resultados' : 'Central de Resultados',
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
              label: useShortLabels ? 'Disparos' : 'Máquina de disparos',
              icon: Icons.send_rounded,
              isActive: currentRoute == '/broadcast',
              onTap: () {
                if (currentRoute != '/broadcast') {
                  Navigator.pushReplacementNamed(context, '/broadcast');
                }
              },
            ),
            const AppSpacerHorizontal.regular(),
            _NavButton(
              label: useShortLabels ? 'Agenda' : 'Agendamentos',
              icon: Icons.schedule_rounded,
              isActive: currentRoute == '/schedule',
              onTap: () {
                if (currentRoute != '/schedule') {
                  Navigator.pushReplacementNamed(context, '/schedule');
                }
              },
            ),
            const AppSpacerHorizontal.regular(),
            _NavButton(
              label: 'Follow-up',
              icon: Icons.tune_rounded,
              isActive: currentRoute == '/follow_up',
              onTap: () {
                if (currentRoute != '/follow_up') {
                  Navigator.pushReplacementNamed(context, '/follow_up');
                }
              },
            ),
          ],
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
            children: <Widget>[
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
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final padding = AppDimensions.paddingHorizontalMediumLarge(context)
        .add(AppDimensions.paddingVerticalRegular(context));

    final decoration = BoxDecoration(
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
    );

    final content = Row(
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
        if (MediaQuery.sizeOf(context).width >= 680) ...[
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
      ],
    );

    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppDimensions.radiusMedium,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppDimensions.radiusMedium,
            child: reduceMotion
                ? Container(padding: padding, decoration: decoration, child: content)
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: padding,
                    decoration: decoration,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}
