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

  static final _dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
  static final _timeFormat = DateFormat('HH:mm', 'pt_BR');

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
      locale: const Locale('pt', 'BR'),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
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
            _SectionLabel(label: 'Consultor'),
            const AppSpacerVertical.small(),
            _ConsultantSelector(
              vm: vm,
              value: _selectedConsultantId,
              onChanged: (v) => setState(() => _selectedConsultantId = v),
            ),
            const AppSpacerVertical.large(),
          ],

          _SectionLabel(label: 'Tipo de Mensagem'),
          const AppSpacerVertical.small(),
          _MessageTypeToggle(
            useAi: _useAi,
            onChanged: (v) => setState(() => _useAi = v),
          ),
          const AppSpacerVertical.regular(),
          if (!_useAi)
            TextFormField(
              controller: _fixedController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                hintText: 'Digite o texto que será enviado...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            )
          else
            TextFormField(
              controller: _motivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Contexto para a IA',
                hintText: 'Ex: promoção de fevereiro, retomar pedido pendente...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

          const AppSpacerVertical.large(),
          _SectionLabel(label: 'Modo de Envio'),
          const AppSpacerVertical.small(),
          _SendModeSelector(
            value: _sendMode,
            onChanged: (v) => setState(() => _sendMode = v),
          ),

          if (_sendMode == 'scheduled') ...[
            const AppSpacerVertical.regular(),
            _ScheduledCard(
              scheduledAt: _scheduledAt,
              onTap: _pickScheduledAt,
              dateFormat: _dateFormat,
              timeFormat: _timeFormat,
            ),
          ],

          if (_sendMode == 'follow_up') ...[
            const AppSpacerVertical.regular(),
            _FollowUpCard(
              daysController: _followUpDaysController,
              hourController: _followUpHourController,
              attemptsController: _followUpMaxAttemptsController,
              onDaysChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n >= 1 && n <= 90) setState(() => _followUpDays = n);
              },
              onHourChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n >= 0 && n <= 23) setState(() => _followUpHour = n);
              },
              onAttemptsChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n >= 1 && n <= 10) setState(() => _followUpMaxAttempts = n);
              },
            ),
          ],

          const AppSpacerVertical.regular(),
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
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded, size: 15),
          label: const Text('Enviar'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
}

class _MessageTypeToggle extends StatelessWidget {
  final bool useAi;
  final ValueChanged<bool> onChanged;

  const _MessageTypeToggle({required this.useAi, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusMedium,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Mensagem Fixa',
            icon: Icons.edit_note_rounded,
            isActive: !useAi,
            onTap: () => onChanged(false),
          ),
          _ToggleOption(
            label: 'Gerada por IA',
            icon: Icons.auto_awesome_rounded,
            isActive: useAi,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: AppDimensions.radiusMedium,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.radiusMedium,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isActive ? context.colorScheme.surface : Colors.transparent,
              borderRadius: AppDimensions.radiusMedium,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isActive
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SendModeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SendModeSelector({required this.value, required this.onChanged});

  static const _modes = [
    (id: 'immediate', label: 'Imediato', icon: Icons.bolt_rounded),
    (id: 'scheduled', label: 'Agendar', icon: Icons.calendar_month_rounded),
    (id: 'follow_up', label: 'Follow-up', icon: Icons.loop_rounded),
  ];

  @override
  Widget build(BuildContext context) => Row(
        children: _modes
            .map((m) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: m.id == _modes.last.id ? 0 : 8,
                    ),
                    child: _ModeChip(
                      label: m.label,
                      icon: m.icon,
                      isActive: value == m.id,
                      onTap: () => onChanged(m.id),
                    ),
                  ),
                ))
            .toList(),
      );
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppDimensions.radiusMedium,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.radiusMedium,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isActive ? Colors.white : context.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduledCard extends StatelessWidget {
  final DateTime? scheduledAt;
  final VoidCallback onTap;
  final DateFormat dateFormat;
  final DateFormat timeFormat;

  const _ScheduledCard({
    required this.scheduledAt,
    required this.onTap,
    required this.dateFormat,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = scheduledAt != null;

    return Material(
      color: Colors.transparent,
      borderRadius: AppDimensions.radiusMedium,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.radiusMedium,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasDate
                ? context.colorScheme.primary.withValues(alpha: 0.06)
                : context.colorScheme.surfaceContainer,
            borderRadius: AppDimensions.radiusMedium,
            border: Border.all(
              color: hasDate
                  ? context.colorScheme.primary.withValues(alpha: 0.4)
                  : context.colorScheme.outline,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasDate
                      ? context.colorScheme.primary.withValues(alpha: 0.12)
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: AppDimensions.radiusMedium,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: hasDate
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: hasDate
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(scheduledAt!),
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'às ${timeFormat.format(scheduledAt!)}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Toque para selecionar data e hora',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final TextEditingController daysController;
  final TextEditingController hourController;
  final TextEditingController attemptsController;
  final ValueChanged<String> onDaysChanged;
  final ValueChanged<String> onHourChanged;
  final ValueChanged<String> onAttemptsChanged;

  const _FollowUpCard({
    required this.daysController,
    required this.hourController,
    required this.attemptsController,
    required this.onDaysChanged,
    required this.onHourChanged,
    required this.onAttemptsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusMedium,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'A mensagem é enviada automaticamente quando não houver resposta',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  onChanged: onDaysChanged,
                  decoration: const InputDecoration(
                    labelText: 'Dias sem resposta',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: hourController,
                  keyboardType: TextInputType.number,
                  onChanged: onHourChanged,
                  decoration: const InputDecoration(
                    labelText: 'Hora (0-23)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: attemptsController,
                  keyboardType: TextInputType.number,
                  onChanged: onAttemptsChanged,
                  decoration: const InputDecoration(
                    labelText: 'Máx. tentativas',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsultantSelector extends StatelessWidget {
  final LeadsViewModel vm;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _ConsultantSelector({
    required this.vm,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String?>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: context.colorScheme.surfaceContainer,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: Icon(
            Icons.person_rounded,
            size: 18,
            color: context.colorScheme.onSurfaceVariant,
          ),
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
        onChanged: onChanged,
      );
}
