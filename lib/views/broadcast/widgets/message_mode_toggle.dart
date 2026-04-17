import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mode_chip.dart';

class MessageModeToggle extends StatelessWidget {
  const MessageModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();
    return Row(
      children: <Widget>[
        ModeChip(
          label: 'IA gera variações',
          icon: Icons.auto_awesome_rounded,
          selected: vm.messageMode == MessageMode.aiGenerated,
          onTap: () => vm.setMessageMode(MessageMode.aiGenerated),
        ),
        const AppSpacerHorizontal.regular(),
        ModeChip(
          label: 'Mensagem fixa',
          icon: Icons.edit_rounded,
          selected: vm.messageMode == MessageMode.fixed,
          onTap: () => vm.setMessageMode(MessageMode.fixed),
        ),
      ],
    );
  }
}
