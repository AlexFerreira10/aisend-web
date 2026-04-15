import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/context_extension.dart';
import '../../core/theme/custom_colors_extension.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacer.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../widgets/aisend_app_bar.dart';
import 'widgets/kpi_card.dart';
import 'widgets/lead_table.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AiSendAppBar(currentRoute: '/'),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppDimensions.extraLarge(context).isFinite 
              ? AppDimensions.paddingExtraLarge(context)
              : AppDimensions.paddingLarge(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Header ─────────────────────────────────────
              _PageHeader(),
              const AppSpacerVertical.large(),

              // ── Filters ─────────────────────────────────────────
              _FilterRow(),
              const AppSpacerVertical.extraLarge(),

              // ── KPI Cards ────────────────────────────────────────
              _KpiSection(),
              const AppSpacerVertical.huge(),

              // ── Leads Table ──────────────────────────────────────
              _ActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Central de Resultados',
          style: context.textTheme.displayMedium,
        ),
        const AppSpacerVertical.small(),
        Text(
          'Visão geral da sua base de contatos',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = context.isMobile;

    final children = [
      // Instance filter
      _StyledDropdown<String>(
        value: vm.selectedInstanceId,
        items: vm.instanceFilters
            .map((f) => DropdownMenuItem(value: f.id, child: Text(f.label)))
            .toList(),
        onChanged: (v) => vm.selectInstance(v!),
        width: isMobile ? double.infinity : 220,
      ),
      isMobile ? const AppSpacerVertical.regular() : const AppSpacerHorizontal.regular(),
      // Period filter
      _StyledDropdown<String>(
        value: vm.selectedPeriod,
        items: vm.periodFilters
            .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(vm.periodLabel(p)),
                ))
            .toList(),
        onChanged: (v) => vm.selectPeriod(v!),
        width: isMobile ? double.infinity : 180,
      ),
    ];

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          )
        : Row(children: children);
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double width;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == double.infinity ? null : width,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppDimensions.radiusMedium,
          border: Border.all(color: context.colorScheme.outline, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            dropdownColor: context.colorScheme.surfaceContainer,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: context.colorScheme.onSurfaceVariant, size: 18),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = context.isMobile;

    final cards = [
      KpiCard(
        label: 'Total de Leads',
        value: AppFormatters.formatNumber(vm.totalLeads),
        description: 'Volume total na base de dados',
        icon: Icons.people_alt_rounded,
        iconColor: context.colorScheme.secondary,
        iconBgColor: context.colorScheme.secondary.withValues(alpha: 0.1),
      ),
      KpiCard(
        label: 'Taxa de Resposta',
        value: '${(vm.responseRate * 100).toStringAsFixed(0)}%',
        description: '% que respondeu ao último disparo',
        icon: Icons.trending_up_rounded,
        iconColor: context.customColors.success,
        iconBgColor: context.customColors.successBg,
      ),
      KpiCard(
        label: 'Leads Quentes',
        value: AppFormatters.formatNumber(vm.hotLeadsCount),
        description: 'Classificados como interessados pela IA',
        icon: Icons.local_fire_department_rounded,
        iconColor: context.customColors.statusHot,
        iconBgColor: context.customColors.statusHotBg,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: AppDimensions.paddingBottom(context),
                child: c,
                ))
            .toList(),
      );
    }

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: c == cards.last ? 0 : AppDimensions.kExtraLarge,
                  ),
                  child: c,
                ),
              ))
          .toList(),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atividade Recente',
                    style: context.textTheme.headlineMedium,
                  ),
                  const AppSpacerVertical.tiny(),
                  Text(
                    'Quem respondeu e classificação da IA',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile) ...[
              _GradientButton(
                label: 'Criar Novo Disparo',
                icon: Icons.add_rounded,
                onTap: () => Navigator.pushReplacementNamed(context, '/broadcast'),
              ),
            ],
          ],
        ),
        const AppSpacerVertical.extraLarge(),

        // Table
        LeadTable(leads: vm.leads),

        // Mobile button
        if (isMobile) ...[
          const AppSpacerVertical.large(),
          SizedBox(
            width: double.infinity,
            child: _GradientButton(
              label: 'Criar Novo Disparo',
              icon: Icons.add_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/broadcast'),
            ),
          ),
        ],
      ],
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: context.customColors.primaryGradient,
            borderRadius: AppDimensions.radiusLarge,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const AppSpacerHorizontal.regular(),
              Text(
                widget.label,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
