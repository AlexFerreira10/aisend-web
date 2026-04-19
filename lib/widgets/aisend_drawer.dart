import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';

class AiSendDrawer extends StatelessWidget {
  final String currentRoute;

  const AiSendDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: context.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Column(
      children: <Widget>[
        _DrawerHeader(),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: AppDimensions.paddingMediumLarge(context),
            children: <Widget>[
              _DrawerItem(
                label: 'Central de Resultados',
                icon: Icons.bar_chart_rounded,
                isActive: currentRoute == '/',
                onTap: () => _navigateTo(context, '/'),
              ),
              const AppSpacerVertical.regular(),
              _DrawerItem(
                label: 'Máquina de disparos',
                icon: Icons.send_rounded,
                isActive: currentRoute == '/broadcast',
                onTap: () => _navigateTo(context, '/broadcast'),
              ),
              const AppSpacerVertical.regular(),
              _DrawerItem(
                label: 'Agendamentos',
                icon: Icons.schedule_rounded,
                isActive: currentRoute == '/schedule',
                onTap: () => _navigateTo(context, '/schedule'),
              ),
              const AppSpacerVertical.regular(),
              _DrawerItem(
                label: 'Follow-up',
                icon: Icons.tune_rounded,
                isActive: currentRoute == '/follow_up',
                onTap: () => _navigateTo(context, '/follow_up'),
              ),
            ],
          ),
        ),
        _DrawerFooter(),
      ],
    ),
  );

  void _navigateTo(BuildContext context, String route) {
    if (currentRoute == route) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
    decoration: BoxDecoration(gradient: context.customColors.surfaceGradient),
    child: Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: context.customColors.logoGradient,
            borderRadius: AppDimensions.radiusLarge,
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
        ),
        const AppSpacerHorizontal.medium(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'AiSend',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                'Intelligent System',
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

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: AppDimensions.radiusMedium,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? context.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: AppDimensions.radiusMedium,
        border: Border.all(
          color: isActive
              ? context.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 22,
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.onSurfaceVariant,
          ),
          const AppSpacerHorizontal.medium(),
          Text(
            label,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Text(
      'v1.1.0 - Test Mode',
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    ),
  );
}
