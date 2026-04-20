import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageInputField extends StatelessWidget {
  const MessageInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();

    if (vm.messageMode == MessageMode.fixed) {
      return _FixedMessageField(onChanged: vm.setFixedMessage);
    }

    return _AiReasonField(onChanged: vm.setReason);
  }
}

class _FixedMessageField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _FixedMessageField({required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Mensagem',
        style: context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      const AppSpacerVertical.regular(),
      TextField(
        maxLines: 6,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          hintText:
              'Digite a mensagem exata que será enviada para todos os contatos.',
          alignLabelWithHint: true,
        ),
        onChanged: onChanged,
      ),
      const AppSpacerVertical.tiny(),
      Text(
        'A mesma mensagem será enviada para todos, sem variações.',
        style: context.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          fontSize: 11,
        ),
      ),
    ],
  );
}

class _AiReasonField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _AiReasonField({required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Motivo do Contato',
        style: context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      const AppSpacerVertical.regular(),
      TextField(
        maxLines: 4,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          hintText:
              'Descreva o objetivo do contato. Ex: Avisar sobre o novo lote de Tirzepatida disponível para entrega imediata.',
          alignLabelWithHint: true,
        ),
        onChanged: onChanged,
      ),
      const AppSpacerVertical.small(),
      Text(
        'A IA gerará variações naturais com base neste contexto.',
        style: context.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          fontSize: 11,
        ),
      ),
    ],
  );
}
