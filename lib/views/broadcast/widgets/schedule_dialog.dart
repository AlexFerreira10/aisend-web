import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/widgets/app_dialog.dart';
import 'package:aisend/core/widgets/app_time_picker_dialog.dart';
import 'package:flutter/material.dart';

class ScheduleDialog extends StatefulWidget {
  final DateTime? initialDate;

  const ScheduleDialog({super.key, this.initialDate});

  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Agendar',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 200),
      transitionBuilder: (_, animation, _, child) {
        if (reduceMotion) return child;
        return ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (ctx, _, _) => ScheduleDialog(initialDate: initialDate),
    );
  }

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? DateTime.now().add(const Duration(hours: 1));
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _selectedTime = TimeOfDay.fromDateTime(initial);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Agendar Disparo',
      icon: Icons.schedule_rounded,
      width: 420,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Escolha o melhor momento para sua mensagem ser enviada.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const AppSpacerVertical.large(),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: context.colorScheme.copyWith(
                surface: Colors.transparent,
              ),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const Divider(),
          const AppSpacerVertical.medium(),
          _TimeSelector(
            time: _selectedTime,
            onTap: () async {
              final time = await AppTimePickerDialog.show(
                context,
                initialTime: _selectedTime,
              );
              if (time != null) setState(() => _selectedTime = time);
            },
          ),
          const AppSpacerVertical.medium(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final result = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            Navigator.pop(context, result);
          },
          child: const Text('Confirmar Horário'),
        ),
      ],
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeSelector({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.radiusLarge,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: AppDimensions.radiusLarge,
          border: Border.all(color: context.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, 
              size: 18, 
              color: context.colorScheme.primary),
            const AppSpacerHorizontal.regular(),
            Text(
              'Horário do envio:',
              style: context.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '$hour:$minute',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const AppSpacerHorizontal.small(),
            Icon(Icons.edit_rounded, 
              size: 14, 
              color: context.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
