import 'package:flutter/material.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/theme/custom_colors_extension.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacer.dart';

class BroadcastProgress extends StatelessWidget {
  final double progress;
  final int sentCount;
  final int repliedCount;
  final int errorCount;
  final String currentLeadName;
  final bool isCompleted;

  const BroadcastProgress({
    super.key,
    required this.progress,
    required this.sentCount,
    required this.repliedCount,
    required this.errorCount,
    required this.currentLeadName,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: AppDimensions.paddingExtraLarge(context),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainer,
      borderRadius: AppDimensions.radiusExtraLarge,
      border: Border.all(color: context.colorScheme.outline, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (!isCompleted) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorScheme.primary,
                ),
              ),
              const AppSpacerHorizontal.regular(),
            ] else ...[
              Icon(
                Icons.check_circle_rounded,
                color: context.customColors.success,
                size: AppDimensions.iconSmall(context),
              ),
              const AppSpacerHorizontal.regular(),
            ],
            Text(
              isCompleted ? 'Disparo Concluído!' : 'Disparando...',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCompleted ? context.customColors.success : context.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
        const AppSpacerVertical.mediumLarge(),
        ClipRRect(
          borderRadius: AppDimensions.radiusMedium,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
          ),
        ),
        if (!isCompleted && currentLeadName.isNotEmpty) ...[
          const AppSpacerVertical.regular(),
          Text(
            'Enviando para $currentLeadName...',
            style: context.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const AppSpacerVertical.large(),
        Row(
          children: <Widget>[
            _MetricChip(
              label: 'Enviados',
              value: sentCount.toString(),
              color: context.customColors.success,
              icon: Icons.send_rounded,
            ),
            const AppSpacerHorizontal.regular(),
            _MetricChip(
              label: 'Respondidos',
              value: repliedCount.toString(),
              color: context.colorScheme.secondary,
              icon: Icons.reply_rounded,
            ),
            const AppSpacerHorizontal.regular(),
            _MetricChip(
              label: 'Erros',
              value: errorCount.toString(),
              color: context.colorScheme.error,
              icon: Icons.error_outline_rounded,
            ),
          ],
        ),
      ],
    ),
  );
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: AppDimensions.paddingMedium(context),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: AppDimensions.iconSmall(context)),
          const AppSpacerVertical.tiny(),
          Text(
            value,
            style: context.textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const AppSpacerVertical.tiny(),
          Text(
            label,
            style: context.textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}
