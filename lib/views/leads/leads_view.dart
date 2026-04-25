import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/view_models/leads_view_model.dart';
import 'package:aisend/views/leads/widgets/lead_form_dialog.dart';
import 'package:aisend/views/leads/widgets/leads_table.dart';
import 'package:aisend/widgets/aisend_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeadsView extends StatelessWidget {
  const LeadsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeadsViewModel>();
    final isMobile = context.isMobile;

    return AiSendScaffold(
      currentRoute: '/leads',
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _openCreate(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo Lead'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: vm.loadLeads,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: AppDimensions.extraLarge(context).isFinite
                ? AppDimensions.paddingExtraLarge(context)
                : AppDimensions.paddingLarge(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(onCreateTap: () => _openCreate(context)),
                const AppSpacerVertical.large(),
                _FilterRow(vm: vm),
                const AppSpacerVertical.extraLarge(),
                if (vm.isLoading && vm.leads.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (vm.leads.isEmpty)
                  _EmptyState(onCreateTap: () => _openCreate(context))
                else
                  LeadsTable(leads: vm.leads),
                if (vm.totalPages > 1) ...[
                  const AppSpacerVertical.large(),
                  _Pagination(vm: vm),
                ],
                const AppSpacerVertical.extraLarge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCreate(BuildContext context) => showDialog(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LeadsViewModel>(),
          child: const LeadFormDialog(),
        ),
      );
}

// ─── Page Header ──────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _PageHeader({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    final hasSidebar = MediaQuery.sizeOf(context).width >= 900;
    return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasSidebar) ...[
                  Text('Gestão de Leads', style: context.textTheme.displayMedium),
                  const AppSpacerVertical.small(),
                ],
                Text(
                  'Cadastre e gerencie sua base de contatos',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!context.isMobile)
            FilledButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Novo Lead'),
            ),
        ],
      );
  }
}

// ─── Filter Row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatefulWidget {
  final LeadsViewModel vm;
  const _FilterRow({required this.vm});

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _chips = [
    (label: 'Todos', cls: null),
    (label: 'Quente', cls: 'hot'),
    (label: 'Morno', cls: 'warm'),
    (label: 'Frio', cls: 'cold'),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final isMobile = context.isMobile;

    final searchField = _SearchField(
      controller: _searchController,
      onChanged: vm.setSearch,
    );

    final consultantDropdown = _ConsultantFilter(vm: vm);

    final statusChips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _chips.map((chip) {
          final active = vm.selectedClassification == chip.cls;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: chip.label,
              isActive: active,
              onTap: () => vm.setClassificationFilter(chip.cls),
            ),
          );
        }).toList(),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const AppSpacerVertical.regular(),
          consultantDropdown,
          const AppSpacerVertical.regular(),
          statusChips,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 240, child: searchField),
            const AppSpacerHorizontal.regular(),
            SizedBox(width: 220, child: consultantDropdown),
          ],
        ),
        const AppSpacerVertical.regular(),
        statusChips,
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

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
            onChanged: onChanged,
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou telefone...',
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(Icons.search_rounded,
                  size: 18, color: context.colorScheme.onSurfaceVariant),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
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

class _ConsultantFilter extends StatelessWidget {
  final LeadsViewModel vm;
  const _ConsultantFilter({required this.vm});

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppDimensions.radiusMedium,
          border: Border.all(color: context.colorScheme.outline, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: vm.selectedConsultantId,
            isExpanded: true,
            dropdownColor: context.colorScheme.surfaceContainer,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: context.colorScheme.onSurfaceVariant, size: 18),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todos os consultores'),
              ),
              ...vm.instances.map((i) => DropdownMenuItem<String?>(
                    value: i.consultantId,
                    child: Text(i.label),
                  )),
            ],
            onChanged: vm.setConsultantFilter,
          ),
        ),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              color: isActive ? Colors.white : context.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 64, color: context.colorScheme.onSurfaceVariant),
              const AppSpacerVertical.large(),
              Text(
                'Nenhum lead encontrado.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const AppSpacerVertical.medium(),
              FilledButton.icon(
                onPressed: onCreateTap,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Cadastrar primeiro lead'),
              ),
            ],
          ),
        ),
      );
}

// ─── Pagination ───────────────────────────────────────────────────────────────

class _Pagination extends StatelessWidget {
  final LeadsViewModel vm;
  const _Pagination({required this.vm});

  @override
  Widget build(BuildContext context) {
    final page = vm.page;
    final total = vm.totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: page > 1 ? () => vm.setPage(page - 1) : null,
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
          onPressed: page < total ? () => vm.setPage(page + 1) : null,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
