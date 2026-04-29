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

    if (vm.sendMode == SendMode.recurrent) {
      if (vm.ruleCreated) {
        return const _BroadcastButton(
          enabled: false,
          icon: Icons.check_circle_rounded,
          label: 'Regra Criada!',
          onTap: null,
        );
      }
      return _BroadcastButton(
        enabled: !vm.isCreatingRule && vm.canCreateRule,
        icon: vm.isCreatingRule
            ? Icons.hourglass_empty_rounded
            : Icons.repeat_rounded,
        label: vm.isCreatingRule ? 'Criando...' : 'Criar Regra',
        onTap: vm.canCreateRule
            ? () => vm.createFollowUpRule(
                () => AppToast.show(
                  context,
                  'Regra de follow-up criada com sucesso!',
                ),
              )
            : () => _showValidationToast(context, vm),
      );
    }

    // Dois botões: Pré-visualizar (opcional) + Enviar agora (principal)
    final sendLabel = vm.sendMode == SendMode.scheduled
        ? 'Agendar Disparo'
        : 'Enviar agora';
    final sendIcon = vm.sendMode == SendMode.scheduled
        ? Icons.schedule_rounded
        : Icons.send_rounded;
    final canSend = vm.sendMode == SendMode.scheduled
        ? (vm.canSchedule && !vm.isScheduling)
        : vm.canBroadcast;
    final sendAction = vm.sendMode == SendMode.scheduled
        ? (canSend ? vm.scheduleBlast : () => _showValidationToast(context, vm))
        : (canSend
              ? () => vm.startBroadcast(() {
                  final total = vm.sentCount + vm.errorCount;
                  final msg = vm.errorCount == 0
                      ? 'Todas as $total solicitações foram feitas com sucesso!'
                      : 'Foram feitas ${vm.sentCount} de $total solicitações. ${vm.errorCount} com erro.';
                  AppToast.show(context, msg);
                })
              : () => _showValidationToast(context, vm));

    if (!context.isDesktop) {
      return Column(
        children: <Widget>[
          _BroadcastButton(
            enabled: !vm.isPreviewing,
            icon: vm.isPreviewing
                ? Icons.hourglass_empty_rounded
                : Icons.visibility_rounded,
            label: vm.isPreviewing ? 'Gerando...' : 'Pré-visualizar',
            onTap: vm.isPreviewing
                ? null
                : (vm.canPreview
                      ? () => vm.previewBlast(onError: (msg) => AppToast.show(context, msg))
                      : () => _showValidationToast(context, vm)),
            useGradient: false,
          ),
          const AppSpacerVertical.regular(),
          _BroadcastButton(
            enabled: canSend,
            icon: sendIcon,
            label: sendLabel,
            onTap: sendAction,
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: _BroadcastButton(
            enabled: !vm.isPreviewing,
            icon: vm.isPreviewing
                ? Icons.hourglass_empty_rounded
                : Icons.visibility_rounded,
            label: vm.isPreviewing ? 'Gerando...' : 'Pré-visualizar',
            onTap: vm.isPreviewing
                ? null
                : (vm.canPreview
                      ? () => vm.previewBlast(onError: (msg) => AppToast.show(context, msg))
                      : () => _showValidationToast(context, vm)),
            useGradient: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _BroadcastButton(
            enabled: canSend,
            icon: sendIcon,
            label: sendLabel,
            onTap: sendAction,
          ),
        ),
      ],
    );
  }

  void _showValidationToast(BuildContext context, BroadcastViewModel vm) {
    final String msg;
    if (vm.selectedInstance == null) {
      msg = 'Selecione um consultor.';
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
    } else if (vm.sendMode == SendMode.scheduled && vm.scheduledAt == null) {
      msg = 'Selecione a data e hora do agendamento.';
    } else if (vm.sendMode == SendMode.scheduled &&
        vm.scheduledAt != null &&
        !vm.scheduledAt!.isAfter(DateTime.now())) {
      msg = 'O horário agendado deve ser no futuro.';
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
            gradient: withGradient
                ? context.customColors.primaryGradient
                : null,
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
