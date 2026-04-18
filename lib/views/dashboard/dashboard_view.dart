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

          if (vm.isLoading && vm.activityLeads.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.hasError && vm.activityLeads.isEmpty) {
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

class _ActivitySection extends StatefulWidget {
  @override
  State<_ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<_ActivitySection> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ─── Header ────────────────────────────────────────────────────────
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
            if (!isMobile)
              _GradientButton(
                label: 'Criar Novo Disparo',
                icon: Icons.add_rounded,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/broadcast'),
              ),
          ],
        ),

        const AppSpacerVertical.large(),

        // ─── Search + Status Chips ─────────────────────────────────────────
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(controller: _searchController, vm: vm),
              const AppSpacerVertical.regular(),
              _StatusChips(vm: vm),
            ],
          )
        else
          Row(
            children: [
              SizedBox(
                width: 240,
                child: _SearchField(controller: _searchController, vm: vm),
              ),
              const AppSpacerHorizontal.large(),
              _StatusChips(vm: vm),
            ],
          ),

        const AppSpacerVertical.large(),

        // ─── Table ─────────────────────────────────────────────────────────
        if (vm.activityLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (vm.activityLeads.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Nenhum lead encontrado.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          LeadTable(leads: vm.activityLeads),

        // ─── Pagination ────────────────────────────────────────────────────
        if (vm.activityTotalPages > 1) ...[
          const AppSpacerVertical.large(),
          _Pagination(vm: vm),
        ],

        if (isMobile) ...[
          const AppSpacerVertical.large(),
          SizedBox(
            width: double.infinity,
            child: _GradientButton(
              label: 'Criar Novo Disparo',
              icon: Icons.add_rounded,
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/broadcast'),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final DashboardViewModel vm;

  const _SearchField({required this.controller, required this.vm});

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppDimensions.radiusMedium,
          border: Border.all(color: context.colorScheme.outline, width: 1),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => TextField(
            controller: controller,
            onChanged: vm.setActivitySearch,
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Buscar por nome...',
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        controller.clear();
                        vm.setActivitySearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      );
}

class _StatusChips extends StatelessWidget {
  final DashboardViewModel vm;
  const _StatusChips({required this.vm});

  static const _chips = [
    (label: 'Todos', cls: null, waiting: null),
    (label: 'Quente', cls: 'hot', waiting: null),
    (label: 'Morno', cls: 'warm', waiting: null),
    (label: 'Frio', cls: 'cold', waiting: null),
    (label: 'Aguardando', cls: null, waiting: true),
  ];

  @override
  Widget build(BuildContext context) {
    bool isActive(String? cls, bool? waiting) {
      if (cls == null && waiting == null) {
        return vm.activityClassification == null &&
            vm.activityWaitingHuman == null;
      }
      return vm.activityClassification == cls &&
          vm.activityWaitingHuman == waiting;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _chips.map((chip) {
          final active = isActive(chip.cls, chip.waiting);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: chip.label,
              isActive: active,
              onTap: () => vm.setActivityClassification(
                chip.cls,
                waitingHuman: chip.waiting,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.surfaceContainer,
            borderRadius: AppDimensions.radiusMedium,
            border: Border.all(
              color: isActive
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isActive
                  ? Colors.white
                  : context.colorScheme.onSurfaceVariant,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
}

class _Pagination extends StatelessWidget {
  final DashboardViewModel vm;
  const _Pagination({required this.vm});

  @override
  Widget build(BuildContext context) {
    final page = vm.activityPage;
    final total = vm.activityTotalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: page > 1 ? () => vm.setActivityPage(page - 1) : null,
          color: context.colorScheme.onSurfaceVariant,
        ),
        Text(
          'Página $page de $total',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed:
              page < total ? () => vm.setActivityPage(page + 1) : null,
          color: context.colorScheme.onSurfaceVariant,
        ),
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
