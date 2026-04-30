import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/views/lead_detail/lead_detail_view.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/utils/app_formatters.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/view_models/leads_view_model.dart';
import 'package:aisend/views/dashboard/widgets/status_badge.dart';
import 'package:aisend/views/leads/widgets/lead_form_dialog.dart';
import 'package:aisend/views/leads/widgets/send_message_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeadsTable extends StatelessWidget {
  final List<LeadModel> leads;

  const LeadsTable({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return _MobileLeadList(leads: leads);
    return _DesktopLeadsTable(leads: leads);
  }
}

// ─── Desktop ──────────────────────────────────────────────────────────────────

class _DesktopLeadsTable extends StatelessWidget {
  final List<LeadModel> leads;
  const _DesktopLeadsTable({required this.leads});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppDimensions.radiusExtraLarge,
          border: Border.all(color: context.colorScheme.outline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const _TableHeader(),
            Divider(height: 1, color: context.colorScheme.outline),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leads.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: context.colorScheme.outline),
              itemBuilder: (context, i) => _DesktopLeadRow(lead: leads[i]),
            ),
          ],
        ),
      );
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: context.colorScheme.onSurfaceVariant,
      letterSpacing: 0.8,
    );
    return Container(
      color: context.colorScheme.surface,
      padding: AppDimensions.paddingHorizontalExtraLarge(context)
          .add(AppDimensions.paddingLarge(context)),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('CONTATO', style: style)),
          Expanded(flex: 3, child: Text('ESPECIALIDADE', style: style)),
          Expanded(flex: 2, child: Text('STATUS IA', style: style)),
          Expanded(flex: 3, child: Text('CONSULTOR', style: style)),
          Expanded(flex: 2, child: Text('CRIADO EM', style: style)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('AÇÕES', style: style),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopLeadRow extends StatefulWidget {
  final LeadModel lead;
  const _DesktopLeadRow({required this.lead});

  @override
  State<_DesktopLeadRow> createState() => _DesktopLeadRowState();
}

class _DesktopLeadRowState extends State<_DesktopLeadRow> {
  bool _hovered = false;

  void _openEdit(BuildContext context) => showDialog(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LeadsViewModel>(),
          child: LeadFormDialog(lead: widget.lead),
        ),
      );

  void _openSend(BuildContext context) => showDialog(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LeadsViewModel>(),
          child: SendMessageDialog(lead: widget.lead),
        ),
      );

  void _openChat(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LeadDetailView(lead: widget.lead)),
      );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar Lead'),
        content: Text(
          'Tem certeza que deseja remover "${widget.lead.name}"? Esta ação é irreversível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final error = await context.read<LeadsViewModel>().deleteLead(widget.lead.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = AppFormatters.formatPhone(widget.lead.phone);
    final vm = context.read<LeadsViewModel>();
    final consultantName = widget.lead.consultantId != null
        ? vm.instances
            .where((i) => i.consultantId == widget.lead.consultantId)
            .map((i) => i.label)
            .firstOrNull ?? '—'
        : '—';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _openChat(context),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered
            ? context.colorScheme.surfaceContainerHighest
            : Colors.transparent,
        padding: AppDimensions.paddingHorizontalExtraLarge(context)
            .add(AppDimensions.paddingLarge(context)),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.lead.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppSpacerVertical.tiny(),
                  Text(phone, style: context.textTheme.bodySmall),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                (widget.lead.specialty == null || widget.lead.specialty == 'null') ? 'N/A' : widget.lead.specialty!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: widget.lead.status),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                consultantName,
                style: context.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(widget.lead.createdAt),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded,
                        size: 18, color: context.colorScheme.onSurfaceVariant),
                    onPressed: () => _openEdit(context),
                    tooltip: 'Editar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded,
                        size: 18, color: context.colorScheme.primary),
                    onPressed: () => _openSend(context),
                    tooltip: 'Disparar mensagem',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'Deletar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────

class _MobileLeadList extends StatelessWidget {
  final List<LeadModel> leads;
  const _MobileLeadList({required this.leads});

  @override
  Widget build(BuildContext context) => Column(
        children: leads.map((l) => _MobileLeadCard(lead: l)).toList(),
      );
}

class _MobileLeadCard extends StatelessWidget {
  final LeadModel lead;
  const _MobileLeadCard({required this.lead});

  void _openEdit(BuildContext context) => showDialog(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LeadsViewModel>(),
          child: LeadFormDialog(lead: lead),
        ),
      );

  void _openSend(BuildContext context) => showDialog(
        context: context,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<LeadsViewModel>(),
          child: SendMessageDialog(lead: lead),
        ),
      );

  void _openChat(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LeadDetailView(lead: lead)),
      );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar Lead'),
        content: Text('Remover "${lead.name}"? Esta ação é irreversível.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<LeadsViewModel>().deleteLead(lead.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = AppFormatters.formatPhone(lead.phone);

    return GestureDetector(
      onTap: () => _openChat(context),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.kRegular),
      padding: AppDimensions.paddingLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.name,
                        style: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600)),
                    const AppSpacerVertical.tiny(),
                    Text(phone, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(status: lead.status),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    size: 18, color: context.colorScheme.onSurfaceVariant),
                onSelected: (v) {
                  if (v == 'edit') _openEdit(context);
                  if (v == 'send') _openSend(context);
                  if (v == 'delete') _confirmDelete(context);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'send', child: Text('Disparar')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Deletar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const AppSpacerVertical.small(),
          Text(
            (lead.specialty == null || lead.specialty == 'null') ? 'N/A' : lead.specialty!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
