import 'package:flutter/material.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacer.dart';
import '../../../models/lead_model.dart';
import '../../lead_detail/lead_detail_view.dart';
import 'status_badge.dart';

class LeadTable extends StatelessWidget {
  final List<LeadModel> leads;

  const LeadTable({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return _MobileLeadList(leads: leads);
    }
    return _DesktopLeadTable(leads: leads);
  }
}

// ─── Desktop DataTable ─────────────────────────────────────────────────────────

class _DesktopLeadTable extends StatelessWidget {
  final List<LeadModel> leads;
  const _DesktopLeadTable({required this.leads});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          const _TableHeader(),
          Divider(height: 1, color: context.colorScheme.outline),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leads.length,
            separatorBuilder: (context, _) =>
                Divider(height: 1, color: context.colorScheme.outline),
            itemBuilder: (context, i) => _DesktopLeadRow(lead: leads[i]),
          ),
        ],
      ),
    );
  }
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
          Expanded(flex: 3, child: Text('CONTATO', style: style)),
          Expanded(flex: 5, child: Text('ÚLTIMA MENSAGEM', style: style)),
          SizedBox(
            width: 120,
            child: Text('STATUS IA', style: style),
          ),
          const AppSpacerHorizontal.large(),
          SizedBox(
            width: 100,
            child: Text('HORA', style: style),
          ),
          SizedBox(
            width: 60,
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

  @override
  Widget build(BuildContext context) {
    final phone = AppFormatters.formatPhone(widget.lead.phone);

    void navigate() => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeadDetailView(lead: widget.lead),
          ),
        );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: navigate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovered
              ? context.colorScheme.surfaceContainerHighest
              : Colors.transparent,
          padding: AppDimensions.paddingHorizontalExtraLarge(context)
              .add(AppDimensions.paddingLarge(context)),
          child: Row(
          children: [
            // Contact
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.lead.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  const AppSpacerVertical.tiny(),
                  Text(phone, style: context.textTheme.bodySmall),
                ],
              ),
            ),
            // Last message
            Expanded(
              flex: 5,
              child: Text(
                widget.lead.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: widget.lead.status),
              ),
            ),
            const AppSpacerHorizontal.large(),
            SizedBox(
              width: 100,
              child: Text(
                widget.lead.time,
                style: context.textTheme.bodySmall,
              ),
            ),
            // Action
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: context.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeadDetailView(lead: widget.lead),
                      ),
                    );
                  },
                  tooltip: 'Ver detalhes',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

// ─── Mobile Card List ──────────────────────────────────────────────────────────

class _MobileLeadList extends StatelessWidget {
  final List<LeadModel> leads;
  const _MobileLeadList({required this.leads});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: leads.map((lead) => _MobileLeadCard(lead: lead)).toList(),
    );
  }
}

class _MobileLeadCard extends StatelessWidget {
  final LeadModel lead;
  const _MobileLeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final phone = AppFormatters.formatPhone(lead.phone);

    return Container(
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
                    Text(
                      lead.name,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const AppSpacerVertical.tiny(),
                    Text(phone, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(status: lead.status),
            ],
          ),
          const AppSpacerVertical.medium(),
          Text(
            lead.lastMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const AppSpacerVertical.regular(),
          Text(lead.time, style: context.textTheme.labelSmall),
        ],
      ),
    );
  }
}
