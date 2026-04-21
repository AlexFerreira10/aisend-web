import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/theme/custom_colors_extension.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacer.dart';
import '../../../models/instance_model.dart';
import '../../../view_models/broadcast_view_model.dart';

class InstanceDropdown extends StatelessWidget {
  const InstanceDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();

    return Container(
      height: 48,
      padding: AppDimensions.paddingHorizontalMediumLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<InstanceModel>(
          value: vm.selectedInstance,
          hint: Text(
            'Selecione um consultor...',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          isExpanded: true,
          dropdownColor: context.colorScheme.surfaceContainer,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          items: vm.instances
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i.isConnected
                              ? context.customColors.statusCold
                              : context.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const AppSpacerHorizontal.regular(),
                      Text(
                        i.displayName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => vm.selectInstance(v),
        ),
      ),
    );
  }
}
