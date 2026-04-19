import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/data/services/schedule_service.dart';
import 'package:aisend/models/enums/blast_status_enum.dart';
import 'package:aisend/view_models/schedule_view_model.dart';
import 'package:aisend/widgets/aisend_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _fmtDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$d/$mo/${dt.year} $h:$mi';
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AiSendAppBar(currentRoute: '/schedule'),
      body: Consumer<ScheduleViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.cloud_off_rounded,
                      size: 48, color: context.colorScheme.onSurfaceVariant),
                  const AppSpacerVertical.large(),
                  Text(vm.error!, style: context.textTheme.bodyLarge),
                  const AppSpacerVertical.medium(),
                  FilledButton.icon(
                    onPressed: vm.loadScheduled,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: vm.loadScheduled,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: AppDimensions.paddingExtraLarge(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Disparos Agendados',
                      style: context.textTheme.displayMedium,
                    ),
                    const AppSpacerVertical.small(),
                    Text(
                      'Histórico e próximos disparos programados',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const AppSpacerVertical.extraLarge(),
                    if (vm.consultantNames.isNotEmpty)
                      _ConsultantFilter(vm: vm),
                    if (vm.consultantNames.isNotEmpty)
                      const AppSpacerVertical.large(),
                    if (vm.items.isEmpty)
                      _EmptyState()
                    else
                      _ScheduleList(items: vm.items),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConsultantFilter extends StatelessWidget {
  final ScheduleViewModel vm;
  const _ConsultantFilter({required this.vm});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: vm.selectedConsultant,
      decoration: const InputDecoration(
        labelText: 'Consultor',
        prefixIcon: Icon(Icons.person_rounded),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...vm.consultantNames.map(
          (name) => DropdownMenuItem(value: name, child: Text(name)),
        ),
      ],
      onChanged: vm.setConsultantFilter,
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.schedule_rounded,
                size: 64, color: context.colorScheme.onSurfaceVariant),
            const AppSpacerVertical.large(),
            Text('Nenhum disparo agendado',
                style: context.textTheme.titleLarge),
            const AppSpacerVertical.small(),
            Text(
              'Agende um disparo na tela de Broadcast.',
              style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
}

class _ScheduleList extends StatelessWidget {
  final List<ScheduledBlastItem> items;
  const _ScheduleList({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScheduleCard(item: item),
                ))
            .toList(),
      );
}

class _ScheduleCard extends StatelessWidget {
  final ScheduledBlastItem item;
  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ScheduleViewModel>();

    return Container(
      padding: AppDimensions.paddingLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:<Widget> [
          _StatusDot(status: item.status),
          const AppSpacerHorizontal.medium(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _StatusChip(status: item.status),
                    const Spacer(),
                    Text(
                      _fmtDate(item.scheduledAt.toLocal()),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const AppSpacerVertical.small(),
                Text(
                  item.motivo.isNotEmpty ? item.motivo : '(sem motivo)',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const AppSpacerVertical.tiny(),
                Text(
                  '${item.totalContacts} contatos'
                  '${item.consultantName != null ? ' • ${item.consultantName}' : ''}'
                  '${item.status == BlastStatus.done ? ' • ${item.sentCount} enviados' : ''}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (item.status == BlastStatus.pending) ...[
            const AppSpacerHorizontal.medium(),
            IconButton(
              icon: Icon(Icons.cancel_outlined,
                  color: context.colorScheme.error, size: 20),
              tooltip: 'Cancelar',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cancelar disparo'),
                    content: const Text(
                        'Tem certeza que deseja cancelar este agendamento?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Não')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Cancelar disparo')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await vm.cancel(item.id);
                  if (vm.cancelError != null && context.mounted) {
                    AppToast.show(context, vm.cancelError!, type: ToastType.error);
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final BlastStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 4),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: status.color(context),
          shape: BoxShape.circle,
        ),
      );
}

class _StatusChip extends StatelessWidget {
  final BlastStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
