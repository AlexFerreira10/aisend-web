import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/core/utils/app_formatters.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/view_models/dashboard_view_model.dart';
import 'package:aisend/widgets/aisend_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'widgets/kpi_card.dart';
import 'widgets/lead_table.dart';
import 'widgets/right_panel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) => AiSendScaffold(
    currentRoute: '/',
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
                Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: context.colorScheme.onSurfaceVariant,
                ),
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

        if (context.isDesktop) {
          return const _DesktopLayout();
        }

        return RefreshIndicator(
          onRefresh: vm.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: AppDimensions.extraLarge(context).isFinite
                  ? AppDimensions.paddingExtraLarge(context)
                  : AppDimensions.paddingLarge(context),
              child: const _MainContent(),
            ),
          ),
        );
      },
    ),
  );
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    return RefreshIndicator(
      onRefresh: vm.loadData,
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(28),
        child: _MainContent(),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isLargeDesktop = width >= 1300;

    final leftColumn = const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PageHeader(),
        AppSpacerVertical.extraLarge(),
        _FilterRow(),
        AppSpacerVertical.extraLarge(),
        _KpiSection(),
        AppSpacerVertical.extraLarge(),
        _ActivitySection(),
      ],
    );

    if (!isLargeDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          leftColumn,
          const AppSpacerVertical.extraLarge(),
          const DashboardRightPanel(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: leftColumn),
        const SizedBox(width: 28),
        const SizedBox(width: 272, child: DashboardRightPanel()),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Central de Resultados', style: context.textTheme.displayMedium),
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
  const _FilterRow();
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
      isMobile
          ? const AppSpacerVertical.regular()
          : const AppSpacerHorizontal.regular(),
      // Period filter
      _StyledDropdown<String>(
        value: vm.selectedPeriod,
        items: vm.periodFilters
            .map(
              (p) => DropdownMenuItem(value: p, child: Text(vm.periodLabel(p))),
            )
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
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}

class _KpiSection extends StatelessWidget {
  const _KpiSection();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    final custom = context.customColors;
    final hotPct = vm.hotPercent;
    final responsePct = vm.responseRate;

    final cards = <KpiCard>[
      KpiCard(
        label: 'Total de Leads',
        value: AppFormatters.formatNumber(vm.totalLeads),
        description: 'Volume total na base de dados',
        icon: Icons.people_alt_rounded,
        iconColor: context.colorScheme.primary,
        iconBgColor: context.colorScheme.primary.withValues(alpha: 0.1),
        progress: vm.totalLeads > 0
            ? (vm.totalLeads / (vm.totalLeads + 100)).clamp(0.0, 1.0)
            : 0.0,
        trend: vm.totalLeads > 0 ? '${vm.totalLeads} cadastrados' : null,
        trendColor: context.colorScheme.primary,
      ),
      KpiCard(
        label: 'Taxa de Resposta',
        value: '${(responsePct * 100).toStringAsFixed(0)}%',
        description: '% respondeu ao último disparo',
        icon: Icons.trending_up_rounded,
        iconColor: custom.success,
        iconBgColor: custom.successBg,
        progress: responsePct,
        trend: responsePct >= 0.5 ? '↑ Boa taxa' : '↓ Pode melhorar',
        trendColor: responsePct >= 0.5 ? custom.success : custom.warning,
        timeLabel: 'todos os períodos',
      ),
      KpiCard(
        label: 'Leads Quentes',
        value: AppFormatters.formatNumber(vm.hotLeadsCount),
        description: 'Interessados — prontos para contato',
        icon: Icons.local_fire_department_rounded,
        iconColor: custom.statusHot,
        iconBgColor: custom.statusHotBg,
        progress: hotPct,
        trend: '${(hotPct * 100).toStringAsFixed(0)}% da base',
        trendColor: custom.statusHot,
      ),
    ];

    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= 1300;

    if (!isLarge) {
      return Column(
        children: cards
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            )
            .toList(),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
      ],
    );
  }
}

class _ActivitySection extends StatefulWidget {
  const _ActivitySection();
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
    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= 1300;
    final isMobile = width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
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
                      style: context.textTheme.headlineSmall,
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
          if (!isLarge)
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
                Expanded(child: _StatusChips(vm: vm)),
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
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final DashboardViewModel vm;

  const _SearchField({required this.controller, required this.vm});

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
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
            filled: true,
            fillColor: context.colorScheme.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.radiusExtraLarge,
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimensions.radiusExtraLarge,
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimensions.radiusExtraLarge,
              borderSide: BorderSide(
                color: context.colorScheme.primary,
                width: 1.0,
              ),
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
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final decoration = BoxDecoration(
      color: isActive
          ? context.colorScheme.primary
          : context.colorScheme.surfaceContainer,
      borderRadius: AppDimensions.radiusExtraLarge,
      border: Border.all(
        color: isActive
            ? context.colorScheme.primary
            : context.colorScheme.outline,
        width: 1,
      ),
    );
    final child = Text(
      label,
      style: context.textTheme.labelMedium?.copyWith(
        color: isActive ? Colors.white : context.colorScheme.onSurfaceVariant,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.radiusExtraLarge,
      child: reduceMotion
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: decoration,
              child: child,
            )
          : AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: decoration,
              child: child,
            ),
    );
  }
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
          tooltip: 'Página anterior',
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
          tooltip: 'Próxima página',
          onPressed: page < total ? () => vm.setActivityPage(page + 1) : null,
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
    child: InkWell(
      onTap: widget.onTap,
      borderRadius: AppDimensions.radiusLarge,
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
  Widget build(BuildContext context) => InkWell(
    onTap: _copy,
    borderRadius: AppDimensions.radiusExtraLarge,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: AppDimensions.paddingHorizontalLarge(
        context,
      ).add(AppDimensions.paddingVerticalSmall(context)),
      decoration: BoxDecoration(
        color: _copied
            ? context.customColors.success.withValues(alpha: 0.12)
            : context.colorScheme.surface,
        borderRadius: AppDimensions.radiusExtraLarge,
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
