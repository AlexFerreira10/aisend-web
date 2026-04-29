import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/widgets/app_dialog.dart';
import 'package:aisend/models/enums/lead_status_enum.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/view_models/broadcast_leads_dialog_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BroadcastLeadsDialog extends StatefulWidget {
  final void Function(List<LeadModel> leads) onConfirm;

  const BroadcastLeadsDialog({super.key, required this.onConfirm});

  @override
  State<BroadcastLeadsDialog> createState() => _BroadcastLeadsDialogState();
}

class _BroadcastLeadsDialogState extends State<BroadcastLeadsDialog> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastLeadsDialogViewModel>();

    return AppDialog(
      title: 'Buscar Leads',
      icon: Icons.manage_search_rounded,
      width: context.isDesktop ? 680 : 480,
      content: SizedBox(
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.selectedCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: AppDimensions.radiusMedium,
                  ),
                  child: Text(
                    '${vm.selectedCount} selecionado${vm.selectedCount > 1 ? 's' : ''}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            _SearchField(
              controller: _searchController,
              onChanged: vm.setSearch,
            ),
            const AppSpacerVertical.regular(),
            _FilterRow(vm: vm),
            const AppSpacerVertical.regular(),
            Expanded(child: _LeadsListBody(vm: vm)),
            const AppSpacerVertical.regular(),
            _BottomRow(vm: vm),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (vm.selectedCount > 0)
          FilledButton(
            onPressed: () {
              widget.onConfirm(vm.selectedLeads);
              Navigator.of(context).pop();
            },
            child: Text(
              'Confirmar (${vm.selectedCount} lead${vm.selectedCount > 1 ? 's' : ''})',
            ),
          ),
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
          builder: (_, value, _) => TextField(
            controller: controller,
            onChanged: onChanged,
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou telefone...',
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
      );
}

class _FilterRow extends StatelessWidget {
  final BroadcastLeadsDialogViewModel vm;

  const _FilterRow({required this.vm});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatusChip(
              label: 'Todos',
              isActive: vm.statusFilter == null,
              onTap: () => vm.setStatusFilter(null),
            ),
            const AppSpacerHorizontal.small(),
            ...LeadStatusEnum.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _StatusChip(
                    label: '${s.emoji} ${s.label}',
                    isActive: vm.statusFilter == s,
                    onTap: () => vm.setStatusFilter(s),
                  ),
                )),
            const AppSpacerHorizontal.regular(),
            _ConsultantDropdown(vm: vm),
          ],
        ),
      );
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.radiusMedium,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.surfaceContainer,
            borderRadius: AppDimensions.radiusMedium,
            border: Border.all(
              color: isActive
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isActive
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
}

class _ConsultantDropdown extends StatelessWidget {
  final BroadcastLeadsDialogViewModel vm;

  const _ConsultantDropdown({required this.vm});

  @override
  Widget build(BuildContext context) => Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppDimensions.radiusMedium,
          border: Border.all(color: context.colorScheme.outline, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: vm.consultantFilter,
            dropdownColor: context.colorScheme.surfaceContainer,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'Todos os consultores',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ...vm.instances.map((i) => DropdownMenuItem<String?>(
                    value: i.id,
                    child: Text(i.displayName),
                  )),
            ],
            onChanged: vm.setConsultantFilter,
          ),
        ),
      );
}

class _LeadsListBody extends StatelessWidget {
  final BroadcastLeadsDialogViewModel vm;

  const _LeadsListBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return Center(
        child: Text(
          vm.error!,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.colorScheme.error),
        ),
      );
    }
    if (vm.leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 40, color: context.colorScheme.onSurfaceVariant),
            const AppSpacerVertical.small(),
            Text(
              'Nenhum lead encontrado',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: vm.leads.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _LeadTile(lead: vm.leads[i], vm: vm),
    );
  }
}

class _LeadTile extends StatelessWidget {
  final LeadModel lead;
  final BroadcastLeadsDialogViewModel vm;

  const _LeadTile({required this.lead, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.isSelected(lead.id);
    return InkWell(
      onTap: () => vm.toggleLead(lead),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => vm.toggleLead(lead),
            ),
            const AppSpacerHorizontal.regular(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium,
                  ),
                  Text(
                    lead.phone,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainer,
                borderRadius: AppDimensions.radiusSmall,
              ),
              child: Text(
                '${lead.aiClassification.emoji} ${lead.aiClassification.label}',
                style: context.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  final BroadcastLeadsDialogViewModel vm;

  const _BottomRow({required this.vm});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          InkWell(
            onTap: vm.toggleAllOnPage,
            borderRadius: AppDimensions.radiusSmall,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: vm.isAllPageSelected,
                  onChanged: (_) => vm.toggleAllOnPage(),
                ),
                Text(
                  'Selecionar página',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Página anterior',
            onPressed: vm.page > 1 ? () => vm.setPage(vm.page - 1) : null,
          ),
          Text(
            '${vm.page} / ${vm.totalPages}',
            style: context.textTheme.labelMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Próxima página',
            onPressed:
                vm.page < vm.totalPages ? () => vm.setPage(vm.page + 1) : null,
          ),
        ],
      );
}
