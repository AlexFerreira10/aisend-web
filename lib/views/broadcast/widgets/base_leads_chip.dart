import 'package:flutter/material.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacer.dart';

class BaseLeadsChip extends StatelessWidget {
  final VoidCallback onClear;
  final int leadCount;

  const BaseLeadsChip({super.key, required this.onClear, required this.leadCount});

  @override
  Widget build(BuildContext context) => Container(
      padding: AppDimensions.paddingHorizontalLarge(context)
          .add(AppDimensions.paddingVerticalMedium(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(
          color: context.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.people_alt_rounded,
            color: context.colorScheme.secondary,
            size: 18,
          ),
          const AppSpacerHorizontal.regular(),
          Expanded(
            child: Text(
              '$leadCount lead${leadCount != 1 ? 's' : ''} selecionado${leadCount != 1 ? 's' : ''}',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: context.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onClear,
          ),
        ],
      ),
    );
}
