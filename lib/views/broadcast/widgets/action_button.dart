import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();

    if (vm.isCompleted) {
      return _BroadcastButton(
        enabled: true,
        icon: Icons.refresh_rounded,
        label: 'Novo Disparo',
        onTap: vm.resetBroadcast,
      );
    }

    if (vm.isBroadcasting) {
      return const _BroadcastButton(
        enabled: false,
        icon: Icons.hourglass_empty_rounded,
        label: 'Disparando...',
        onTap: null,
      );
    }

    if (vm.hasPreview) {
      return _BroadcastButton(
        enabled: vm.canBroadcast,
        icon: Icons.send_rounded,
        label: 'Confirmar e Disparar',
        onTap: vm.canBroadcast
            ? () => vm.startBroadcast(
                  () => AppToast.show(
                    context,
                    'Disparo concluído! ${vm.sentCount} mensagens enviadas.',
                  ),
                )
            : null,
      );
    }

    if (vm.sendMode == SendMode.scheduled) {
      final enabled = vm.canSchedule && !vm.isScheduling;
      return _BroadcastButton(
        enabled: enabled,
        icon: vm.isScheduling
            ? Icons.hourglass_empty_rounded
            : Icons.schedule_rounded,
        label: vm.isScheduling ? 'Agendando...' : 'Agendar Disparo',
        onTap: enabled ? vm.scheduleBlast : null,
      );
    }

    return _BroadcastButton(
      enabled: vm.canPreview,
      icon: vm.isPreviewing
          ? Icons.hourglass_empty_rounded
          : Icons.visibility_rounded,
      label: vm.isPreviewing ? 'Gerando prévia...' : 'Pré-visualizar',
      onTap: vm.canPreview
          ? vm.previewBlast
          : () => _showValidationToast(context, vm),
      useGradient: false,
    );
  }

  void _showValidationToast(BuildContext context, BroadcastViewModel vm) {
    final String msg;
    if (vm.selectedInstance == null) {
      msg = 'Selecione uma instância.';
    } else if (vm.messageMode == MessageMode.fixed &&
        vm.fixedMessage.trim().isEmpty) {
      msg = 'Digite a mensagem fixa para pré-visualizar.';
    } else if (vm.messageMode == MessageMode.aiGenerated &&
        vm.contactReason.trim().isEmpty) {
      msg = 'Preencha o motivo do contato para pré-visualizar.';
    } else if (!(vm.uploadedFileName != null || vm.leadsFromBase)) {
      msg = 'Adicione ou selecione leads para enviar.';
    } else if (vm.dynamicLeadsCount == 0) {
      msg = 'A lista de leads está vazia.';
    } else if (vm.isBroadcasting) {
      msg = 'Aguarde o disparo terminar.';
    } else if (vm.isPreviewing) {
      msg = 'Aguarde a prévia ser gerada.';
    } else {
      msg = 'Preencha todos os campos obrigatórios.';
    }
    AppToast.show(context, msg);
  }
}

class _BroadcastButton extends StatefulWidget {
  final bool enabled;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool useGradient;

  const _BroadcastButton({
    required this.enabled,
    required this.icon,
    required this.label,
    required this.onTap,
    this.useGradient = true,
  });

  @override
  State<_BroadcastButton> createState() => _BroadcastButtonState();
}

class _BroadcastButtonState extends State<_BroadcastButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final withGradient = widget.enabled && widget.useGradient;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: AppDimensions.paddingVerticalLarge(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: withGradient ? context.customColors.primaryGradient : null,
            color: withGradient ? null : context.colorScheme.surface,
            borderRadius: AppDimensions.radiusExtraLarge,
            border: withGradient
                ? null
                : Border.all(
                    color: widget.enabled
                        ? context.colorScheme.primary
                        : context.colorScheme.outline,
                    width: 1.5,
                  ),
            boxShadow: (withGradient && _hovered)
                ? [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: _BroadcastButtonContent(
            icon: widget.icon,
            label: widget.label,
            enabled: widget.enabled,
            withGradient: withGradient,
          ),
        ),
      ),
    );
  }
}

class _BroadcastButtonContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool withGradient;

  const _BroadcastButtonContent({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.withGradient,
  });

  @override
  Widget build(BuildContext context) {
    final color = withGradient
        ? Colors.white
        : enabled
            ? context.colorScheme.primary
            : context.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const AppSpacerHorizontal.regular(),
        Text(
          label,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: color,
          ),
        ),
      ],
    );
  }
}
