import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/providers/theme_provider.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideNav extends StatelessWidget {
  final String currentRoute;

  const SideNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) => Container(
        width: 240,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: Border(
            right: BorderSide(color: context.theme.dividerColor, width: 1),
          ),
        ),
        child: Column(
          children: <Widget>[
            _SideNavHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: <Widget>[
                  _SideNavItem(
                    label: 'Central de Resultados',
                    icon: Icons.bar_chart_rounded,
                    isActive: currentRoute == '/',
                    onTap: () => _navigate(context, '/'),
                  ),
                  const AppSpacerVertical.small(),
                  _SideNavItem(
                    label: 'Gestão de Leads',
                    icon: Icons.people_rounded,
                    isActive: currentRoute == '/leads',
                    onTap: () => _navigate(context, '/leads'),
                  ),
                  const AppSpacerVertical.small(),
                  _SideNavItem(
                    label: 'Máquina de Disparos',
                    icon: Icons.send_rounded,
                    isActive: currentRoute == '/broadcast',
                    onTap: () => _navigate(context, '/broadcast'),
                  ),
                  const AppSpacerVertical.small(),
                  _SideNavItem(
                    label: 'Agendamentos',
                    icon: Icons.schedule_rounded,
                    isActive: currentRoute == '/schedule',
                    onTap: () => _navigate(context, '/schedule'),
                  ),
                  const AppSpacerVertical.small(),
                  _SideNavItem(
                    label: 'Follow-up',
                    icon: Icons.tune_rounded,
                    isActive: currentRoute == '/follow_up',
                    onTap: () => _navigate(context, '/follow_up'),
                  ),
                ],
              ),
            ),
            _SideNavFooter(),
          ],
        ),
      );

  void _navigate(BuildContext context, String route) {
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

class _SideNavHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
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
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
            ),
            const AppSpacerHorizontal.medium(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        context.customColors.logoGradient.createShader(bounds),
                    child: Text(
                      'AiSend',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Text(
                    'Disparos Inteligentes',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SideNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final decoration = BoxDecoration(
      color: widget.isActive
          ? context.colorScheme.primary.withValues(alpha: 0.12)
          : _hovered
          ? context.colorScheme.surfaceContainerHighest
          : Colors.transparent,
      borderRadius: AppDimensions.radiusMedium,
      border: Border.all(
        color: widget.isActive
            ? context.colorScheme.primary.withValues(alpha: 0.3)
            : Colors.transparent,
        width: 1,
      ),
    );

    final content = Row(
      children: <Widget>[
        Icon(
          widget.icon,
          size: 20,
          color: widget.isActive
              ? context.colorScheme.primary
              : _hovered
              ? context.colorScheme.onSurface
              : context.colorScheme.onSurfaceVariant,
        ),
        const AppSpacerHorizontal.medium(),
        Expanded(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              color: widget.isActive
                  ? context.colorScheme.primary
                  : _hovered
                  ? context.colorScheme.onSurface
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: decoration,
                    child: content,
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: decoration,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SideNavFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.mode == ThemeMode.dark ||
        (themeProvider.mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'v1.1.0 - Test Mode',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 18,
            ),
            tooltip: 'Alternar tema',
            color: context.colorScheme.onSurfaceVariant,
            onPressed: themeProvider.toggleDarkLight,
          ),
        ],
      ),
    );
  }
}
