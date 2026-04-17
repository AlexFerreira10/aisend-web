import 'package:aisend/core/config/app_config.dart';
import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/core/utils/app_formatters.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/view_models/dashboard_view_model.dart';
import 'package:aisend/widgets/aisend_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'widgets/kpi_card.dart';
import 'widgets/lead_table.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const AiSendAppBar(currentRoute: '/'),
      body: Builder(
        builder: (context) {
          final vm = context.watch<DashboardViewModel>();

          if (vm.isLoading && vm.leads.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.hasError && vm.leads.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.cloud_off_rounded,
                      size: 64,
                      color: context.colorScheme.onSurfaceVariant),
                  const AppSpacerVertical.large(),
                  Text(
                    vm.errorMessage,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge,
                  ),
                  const AppSpacerVertical.medium(),
                  FilledButton.icon(
                    onPressed: vm.loadData,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: AppDimensions.extraLarge(context).isFinite
                    ? AppDimensions.paddingExtraLarge(context)
                    : AppDimensions.paddingLarge(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  <Widget>[
                    _PageHeader(),
                    const AppSpacerVertical.large(),
                    _CaptureLinksSection(),
                    const AppSpacerVertical.large(),
                    _FilterRow(),
                    const AppSpacerVertical.extraLarge(),
                    _KpiSection(),
                    const AppSpacerVertical.huge(),
                    _ActivitySection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = context.isMobile;

    final children = [
      _StyledDropdown<String?>(
        value: vm.selectedInstanceId,
        items: vm.instanceFilters
            .map((f) => DropdownMenuItem(value: f.id, child: Text(f.label)))
            .toList(),
        onChanged: vm.selectInstance,
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
  Widget build(BuildContext context) => SizedBox(
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

class _KpiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = context.isMobile;

    final cards = <KpiCard>[
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
      children: <Widget>[
        Row(
          children: <Widget> [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
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
        LeadTable(leads: vm.leads),
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
  Widget build(BuildContext context) => MouseRegion(
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
                ? <BoxShadow>[
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
            children:<Widget> [
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

class _CaptureLinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final instances = vm.instanceFilters.where((f) => f.id != null).toList();

    if (instances.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.link_rounded,
                  size: 16, color: context.colorScheme.primary),
              const AppSpacerHorizontal.tiny(),
              Text(
                'Links de Captura',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.primary,
                ),
              ),
              const AppSpacerHorizontal.regular(),
              Text(
                '— compartilhe com seus clientes para iniciar conversa automaticamente',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const AppSpacerVertical.medium(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: instances.map((inst) {
              final url = AppConfig.captureUrl(inst.id!);
              return _CaptureLinkChip(label: inst.label, url: url);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CaptureLinkChip extends StatefulWidget {
  final String label;
  final String url;
  const _CaptureLinkChip({required this.label, required this.url});

  @override
  State<_CaptureLinkChip> createState() => _CaptureLinkChipState();
}

class _CaptureLinkChipState extends State<_CaptureLinkChip> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    if (!mounted) return;
    setState(() => _copied = true);
    AppToast.show(context, 'Link copiado!');
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: _copy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppDimensions.paddingHorizontalLarge(context)
            .add(AppDimensions.paddingVerticalSmall(context)),
        decoration: BoxDecoration(
          color: _copied
              ? context.customColors.success.withValues(alpha: 0.12)
              : context.colorScheme.surface,
          borderRadius: AppDimensions.radiusMedium,
          border: Border.all(
            color: _copied
                ? context.customColors.success
                : context.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 13,
              color: _copied
                  ? context.customColors.success
                  : context.colorScheme.onSurfaceVariant,
            ),
            const AppSpacerHorizontal.tiny(),
            Text(
              widget.label,
              style: context.textTheme.labelSmall?.copyWith(
                color: _copied
                    ? context.customColors.success
                    : context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
}
