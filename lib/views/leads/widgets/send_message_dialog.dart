import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/view_models/leads_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SendMessageDialog extends StatefulWidget {
  final LeadModel lead;

  const SendMessageDialog({super.key, required this.lead});

  @override
  State<SendMessageDialog> createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends State<SendMessageDialog> {
  bool _useAi = false;
  final _fixedController = TextEditingController();
  final _motivoController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _fixedController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _send(LeadsViewModel vm) async {
    final hasContent = _useAi
        ? _motivoController.text.trim().isNotEmpty
        : _fixedController.text.trim().isNotEmpty;

    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_useAi ? 'Informe o motivo do contato.' : 'Digite a mensagem.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _sending = true);

    final dto = {
      'leadId': widget.lead.id,
      'useAi': _useAi,
      if (!_useAi) 'fixedMessage': _fixedController.text.trim(),
      if (_useAi) 'motivo': _motivoController.text.trim(),
    };

    final error = await vm.sendMessage(widget.lead.id, dto);

    if (!mounted) return;
    setState(() => _sending = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.of(context).pop();
      AppToast.show(context, 'Disparo iniciado para ${widget.lead.name}!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LeadsViewModel>();

    return AlertDialog(
      title: Text('Disparar para ${widget.lead.name}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Mensagem Fixa')),
                ButtonSegment(value: true, label: Text('Gerada por IA')),
              ],
              selected: {_useAi},
              onSelectionChanged: (s) => setState(() => _useAi = s.first),
            ),
            const AppSpacerVertical.large(),
            if (!_useAi)
              TextFormField(
                controller: _fixedController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Digite a mensagem que será enviada...',
                  border: OutlineInputBorder(),
                ),
              )
            else
              TextFormField(
                controller: _motivoController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motivo do contato',
                  hintText: 'Ex: promoção de fevereiro, retomar pedido...',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _sending ? null : () => _send(vm),
          icon: _sending
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded, size: 16),
          label: const Text('Enviar'),
        ),
      ],
    );
  }
}
