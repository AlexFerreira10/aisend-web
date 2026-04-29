import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/data/services/consultants_service.dart';
import 'package:aisend/data/services/leads_service.dart';
import 'package:aisend/view_models/broadcast_leads_dialog_view_model.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'broadcast_leads_dialog.dart';

class PullLeadsButton extends StatefulWidget {
  const PullLeadsButton({super.key});

  @override
  State<PullLeadsButton> createState() => _PullLeadsButtonState();
}

class _PullLeadsButtonState extends State<PullLeadsButton> {
  bool _hovered = false;

  void _openDialog(BuildContext context) {
    final leadsService = context.read<LeadsService>();
    final consultantsService = context.read<ConsultantsService>();
    final broadcastVm = context.read<BroadcastViewModel>();

    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => BroadcastLeadsDialogViewModel(
          leadsService: leadsService,
          consultantsService: consultantsService,
        )..init(),
        child: BroadcastLeadsDialog(
          onConfirm: broadcastVm.setSelectedLeads,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _openDialog(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: AppDimensions.paddingVerticalMediumLarge(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? context.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: AppDimensions.radiusLarge,
            border: Border.all(
              color: _hovered
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Text(
            'Buscar Leads',
            style: context.textTheme.labelLarge?.copyWith(
              color: _hovered
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
