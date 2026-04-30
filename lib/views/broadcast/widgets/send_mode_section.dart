import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mode_chip.dart';
import 'schedule_dialog.dart';
import 'package:aisend/core/widgets/app_time_picker_dialog.dart';

class SendModeSection extends StatelessWidget {
  const SendModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ModeChip(
              label: 'Imediato',
              icon: Icons.send_rounded,
              selected: vm.sendMode == SendMode.immediate,
              onTap: () => vm.setSendMode(SendMode.immediate),
            ),
            ModeChip(
              label: 'Agendar',
              icon: Icons.schedule_rounded,
              selected: vm.sendMode == SendMode.scheduled,
              onTap: () => vm.setSendMode(SendMode.scheduled),
            ),
            ModeChip(
              label: 'Recorrente',
              icon: Icons.repeat_rounded,
              selected: vm.sendMode == SendMode.recurrent,
              onTap: () => vm.setSendMode(SendMode.recurrent),
            ),
          ],
        ),
        if (vm.sendMode == SendMode.scheduled) ...[
          const AppSpacerVertical.large(),
          DateTimePicker(value: vm.scheduledAt, onChanged: vm.setScheduledAt),
          if (vm.scheduleSuccess) ...[
            const AppSpacerVertical.medium(),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Colors.green,
                ),
                const AppSpacerHorizontal.tiny(),
                Text(
                  'Disparo agendado com sucesso! Acompanhe em Agendamentos.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          if (vm.scheduleError != null) ...[
            const AppSpacerVertical.medium(),
            Text(
              vm.scheduleError!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
        ],
        if (vm.sendMode == SendMode.recurrent) ...[
          const AppSpacerVertical.large(),
          _RecurrentPanel(vm: vm),
          if (vm.ruleError != null) ...[
            const AppSpacerVertical.medium(),
            Text(
              vm.ruleError!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ─── Recurrent Configuration Panel ───────────────────────────────────────────

class _RecurrentPanel extends StatelessWidget {
  final BroadcastViewModel vm;
  const _RecurrentPanel({required this.vm});

  static const _classifications = [
    ('hot', '🔥', 'Quente'),
    ('warm', '☀️', 'Morno'),
    ('cold', '❄️', 'Frio'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuração da Recorrência',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const AppSpacerVertical.large(),
          _ConfigRow(
            label: 'Dias sem resposta',
            child: _Stepper(
              value: vm.followUpDays,
              min: 1,
              max: 90,
              onChanged: vm.setFollowUpDays,
            ),
          ),
          const AppSpacerVertical.regular(),
          _ConfigRow(
            label: 'Horário de envio',
            child: InkWell(
              onTap: () async {
                final time = await AppTimePickerDialog.show(
                  context,
                  initialTime: TimeOfDay(hour: vm.followUpHour, minute: 0),
                );
                if (time != null) vm.setFollowUpHour(time.hour);
              },
              borderRadius: AppDimensions.radiusMedium,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: AppDimensions.radiusMedium,
                  border: Border.all(color: context.colorScheme.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${vm.followUpHour.toString().padLeft(2, '0')}:00',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit_rounded,
                      size: 12,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AppSpacerVertical.regular(),
          _ConfigRow(
            label: 'Tentativas por lead',
            child: _Stepper(
              value: vm.followUpMaxAttempts,
              min: 1,
              max: 10,
              onChanged: vm.setFollowUpMaxAttempts,
            ),
          ),
          const AppSpacerVertical.large(),
          Text(
            'Público-alvo',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const AppSpacerVertical.small(),
          Wrap(
            spacing: 8,
            children: _classifications.map((opt) {
              final selected = vm.followUpClassifications.contains(opt.$1);
              return GestureDetector(
                onTap: () => vm.toggleFollowUpClassification(opt.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colorScheme.primaryContainer
                        : context.colorScheme.surface,
                    borderRadius: AppDimensions.radiusRound,
                    border: Border.all(
                      color: selected
                          ? context.colorScheme.primary
                          : context.colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    '${opt.$2} ${opt.$3}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: selected
                          ? context.colorScheme.onPrimaryContainer
                          : context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _ConfigRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_rounded),
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded),
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

// ─── DateTime Picker ──────────────────────────────────────────────────────────

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
        final result = await ScheduleDialog.show(context, initialDate: value);
        if (result != null) {
          onChanged(result);
        }
      },
      child: Container(
        padding: AppDimensions.paddingHorizontalMediumLarge(
          context,
        ).add(AppDimensions.paddingVerticalMedium(context)),
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
          children: <Widget>[
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
