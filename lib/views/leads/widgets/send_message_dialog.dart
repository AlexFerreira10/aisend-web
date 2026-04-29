import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/core/widgets/app_dialog.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/view_models/leads_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String? _selectedConsultantId;

  String _sendMode = 'immediate';
  DateTime? _scheduledAt;

  int _followUpDays = 7;
  int _followUpHour = 9;
  int _followUpMaxAttempts = 3;

  final _followUpDaysController = TextEditingController(text: '7');
  final _followUpHourController = TextEditingController(text: '9');
  final _followUpMaxAttemptsController = TextEditingController(text: '3');

  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    _fixedController.dispose();
    _motivoController.dispose();
    _followUpDaysController.dispose();
    _followUpHourController.dispose();
    _followUpMaxAttemptsController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _send(LeadsViewModel vm) async {
    final hasContent = _useAi
        ? _motivoController.text.trim().isNotEmpty
        : _fixedController.text.trim().isNotEmpty;

    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _useAi ? 'Informe o motivo do contato.' : 'Digite a mensagem.'),
          backgroundColor: context.customColors.warning,
        ),
      );
      return;
    }

    if (widget.lead.consultantId == null && _selectedConsultantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um consultor.'),
          backgroundColor: context.customColors.warning,
        ),
      );
      return;
    }

    if (_sendMode == 'scheduled') {
      if (_scheduledAt == null || !_scheduledAt!.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selecione uma data futura.'),
            backgroundColor: context.customColors.warning,
          ),
        );
        return;
      }
    }

    setState(() => _sending = true);

    final dto = {
      'leadId': widget.lead.id,
      'useAi': _useAi,
      if (!_useAi && _fixedController.text.trim().isNotEmpty)
        'fixedMessage': _fixedController.text.trim(),
      if (_useAi && _motivoController.text.trim().isNotEmpty)
        'motivo': _motivoController.text.trim(),
      'sendMode': _sendMode,
      if (_selectedConsultantId != null)
        'overrideConsultantId': _selectedConsultantId,
      if (_sendMode == 'scheduled' && _scheduledAt != null)
        'scheduledAt': _scheduledAt!.toUtc().toIso8601String(),
      if (_sendMode == 'follow_up') 'followUpDays': _followUpDays,
      if (_sendMode == 'follow_up') 'followUpHour': _followUpHour,
      if (_sendMode == 'follow_up') 'followUpMaxAttempts': _followUpMaxAttempts,
    };

    final error = await vm.sendMessage(widget.lead.id, dto);

    if (!mounted) return;
    setState(() => _sending = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: context.customColors.error,
        ),
      );
    } else {
      AppToast.show(context, 'Disparo iniciado para ${widget.lead.name}!');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LeadsViewModel>();
    final showConsultant = widget.lead.consultantId == null;

    return AppDialog(
      title: 'Disparar para ${widget.lead.name}',
      icon: Icons.send_rounded,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showConsultant) ...[
            Text(
              'Consultor',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const AppSpacerVertical.small(),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainer,
                borderRadius: AppDimensions.radiusMedium,
                border:
                    Border.all(color: context.colorScheme.outline, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedConsultantId,
                  isExpanded: true,
                  dropdownColor: context.colorScheme.surfaceContainer,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Selecione um consultor'),
                    ),
                    ...vm.instances.map(
                      (i) => DropdownMenuItem<String?>(
                        value: i.consultantId,
                        child: Text(i.label),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedConsultantId = v),
                ),
              ),
            ),
            const AppSpacerVertical.large(),
          ],
          Text(
            'Mensagem',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const AppSpacerVertical.small(),
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
          const AppSpacerVertical.large(),
          Text(
            'Modo de Envio',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const AppSpacerVertical.small(),
          Row(
            children: [
              _Chip(
                label: 'Imediato',
                isActive: _sendMode == 'immediate',
                onTap: () => setState(() => _sendMode = 'immediate'),
              ),
              const AppSpacerHorizontal.regular(),
              _Chip(
                label: 'Agendar',
                isActive: _sendMode == 'scheduled',
                onTap: () => setState(() => _sendMode = 'scheduled'),
              ),
              const AppSpacerHorizontal.regular(),
              _Chip(
                label: 'Follow-up',
                isActive: _sendMode == 'follow_up',
                onTap: () => setState(() => _sendMode = 'follow_up'),
              ),
            ],
          ),
          if (_sendMode == 'scheduled') ...[
            const AppSpacerVertical.large(),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickScheduledAt,
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: const Text('Selecionar'),
                ),
                const AppSpacerHorizontal.regular(),
                Text(
                  _scheduledAt != null
                      ? _dateFormat.format(_scheduledAt!)
                      : 'Selecione data e hora',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (_sendMode == 'follow_up') ...[
            const AppSpacerVertical.large(),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _followUpDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Dias sem resposta',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 1 && n <= 90) {
                        setState(() => _followUpDays = n);
                      }
                    },
                  ),
                ),
                const AppSpacerHorizontal.regular(),
                Expanded(
                  child: TextFormField(
                    controller: _followUpHourController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hora do envio',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 0 && n <= 23) {
                        setState(() => _followUpHour = n);
                      }
                    },
                  ),
                ),
                const AppSpacerHorizontal.regular(),
                Expanded(
                  child: TextFormField(
                    controller: _followUpMaxAttemptsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Máx. tentativas',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 1 && n <= 10) {
                        setState(() => _followUpMaxAttempts = n);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded, size: 16),
          label: const Text('Enviar'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.surfaceContainer,
            borderRadius: AppDimensions.radiusMedium,
            border: Border.all(
              color: isActive
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isActive
                  ? Colors.white
                  : context.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
}
