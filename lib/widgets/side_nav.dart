import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/providers/theme_provider.dart';
import 'package:aisend/core/theme/app_colors.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideNav extends StatelessWidget {
  final String currentRoute;

  const SideNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sidebar uses the same background as the outer frame — no visual border needed
    return Container(
      width: 240,
      color: isDark ? AppColorsDark.background : AppColorsLight.background,
      child: Column(
        children: <Widget>[
          _SideNavHeader(),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              height: 1,
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: <Widget>[
                _SideNavItem(
                  label: 'Central de Resultados',
                  icon: Icons.bar_chart_rounded,
                  isActive: currentRoute == '/',
                  onTap: () => _navigate(context, '/'),
                ),
                _SideNavItem(
                  label: 'Gestão de Leads',
                  icon: Icons.people_rounded,
                  isActive: currentRoute == '/leads',
                  onTap: () => _navigate(context, '/leads'),
                ),
                _SideNavItem(
                  label: 'Máquina de Disparos',
                  icon: Icons.send_rounded,
                  isActive: currentRoute == '/broadcast',
                  onTap: () => _navigate(context, '/broadcast'),
                ),
                _SideNavItem(
                  label: 'Agendamentos',
                  icon: Icons.schedule_rounded,
                  isActive: currentRoute == '/schedule',
                  onTap: () => _navigate(context, '/schedule'),
                ),
                _SideNavItem(
                  label: 'Follow-up Automático',
                  icon: Icons.tune_rounded,
                  isActive: currentRoute == '/follow_up',
                  onTap: () => _navigate(context, '/follow_up'),
                ),
              ],
            ),
          ),
          const _ThemeToggle(),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SideNavHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
    child: Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: context.customColors.logoGradient,
            borderRadius: AppDimensions.radiusMedium,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
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
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                'Disparos Inteligentes',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

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
    final primary = context.colorScheme.primary;

    final iconBgColor = widget.isActive
        ? primary.withValues(alpha: 0.15)
        : _hovered
        ? context.colorScheme.surfaceContainerHighest
        : context.colorScheme.surfaceContainer;

    final iconColor = widget.isActive
        ? primary
        : context.colorScheme.onSurfaceVariant;

    final textColor = widget.isActive
        ? primary
        : _hovered
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurfaceVariant;

    final row = Row(
      children: <Widget>[
        const SizedBox(width: 20),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              color: textColor,
              fontSize: 13,
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
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              children: <Widget>[
                row,
                if (widget.isActive)
                  Positioned(
                    left: 0,
                    top: 2,
                    bottom: 2,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark =
        themeProvider.mode == ThemeMode.dark ||
        (themeProvider.mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: themeProvider.toggleDarkLight,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 18,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isDark ? 'Tema Claro' : 'Tema Escuro',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
