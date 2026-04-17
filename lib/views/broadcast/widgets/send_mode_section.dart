import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mode_chip.dart';

class SendModeSection extends StatelessWidget {
  const SendModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            ModeChip(
              label: 'Enviar agora',
              icon: Icons.send_rounded,
              selected: vm.sendMode == SendMode.immediate,
              onTap: () => vm.setSendMode(SendMode.immediate),
            ),
            const AppSpacerHorizontal.regular(),
            ModeChip(
              label: 'Agendar',
              icon: Icons.schedule_rounded,
              selected: vm.sendMode == SendMode.scheduled,
              onTap: () => vm.setSendMode(SendMode.scheduled),
            ),
          ],
        ),
        if (vm.sendMode == SendMode.scheduled) ...[
          const AppSpacerVertical.large(),
          DateTimePicker(
            value: vm.scheduledAt,
            onChanged: vm.setScheduledAt,
          ),
          if (vm.scheduleSuccess) ...[
            const AppSpacerVertical.medium(),
            Row(
              children:  <Widget>[
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: Colors.green,),
                const AppSpacerHorizontal.tiny(),
                Text(
                  'Disparo agendado com sucesso! Acompanhe em Agendamentos.',
                  style:
                      context.textTheme.bodySmall?.copyWith(color: Colors.green),
                ),
              ],
            ),
          ],
          if (vm.scheduleError != null) ...[
            const AppSpacerVertical.medium(),
            Text(
              vm.scheduleError!,
              style: context.textTheme.bodySmall
                  ?.copyWith(color: context.colorScheme.error),
            ),
          ],
        ],
      ],
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  const DateTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? 'Selecionar data e hora'
        : () {
            final d = value!.toLocal();
            final dd = d.day.toString().padLeft(2, '0');
            final mo = d.month.toString().padLeft(2, '0');
            final h = d.hour.toString().padLeft(2, '0');
            final mi = d.minute.toString().padLeft(2, '0');
            return '$dd/$mo/${d.year} às $h:$mi';
          }();

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? now.add(const Duration(days: 1)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 365)),
        );
        if (date == null || !context.mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? now),
        );
        if (time == null) return;
        onChanged(
            DateTime(date.year, date.month, date.day, time.hour, time.minute));
      },
      child: Container(
        padding: AppDimensions.paddingHorizontalMediumLarge(context)
            .add(AppDimensions.paddingVerticalMedium(context)),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppDimensions.radiusLarge,
          border: Border.all(
            color: value != null
                ? context.colorScheme.primary
                : context.colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          children:  <Widget>[
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: value != null
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            const AppSpacerHorizontal.regular(),
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: value != null
                    ? context.colorScheme.onSurface
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
