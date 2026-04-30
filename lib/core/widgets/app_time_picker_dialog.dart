import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/widgets/app_dialog.dart';
import 'package:flutter/material.dart';

class AppTimePickerDialog extends StatelessWidget {
  final TimeOfDay initialTime;

  const AppTimePickerDialog({super.key, required this.initialTime});

  static Future<TimeOfDay?> show(BuildContext context, {required TimeOfDay initialTime}) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return showGeneralDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Selecionar Horário',
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
      pageBuilder: (ctx, _, _) => AppTimePickerDialog(initialTime: initialTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Selecionar Horário',
      icon: Icons.access_time_rounded,
      width: 400,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Escolha o horário para o disparo das mensagens.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: 15, // 07 to 21
              itemBuilder: (context, index) {
                final hour = index + 7;
                final isSelected = initialTime.hour == hour;
                return InkWell(
                  onTap: () => Navigator.pop(context, TimeOfDay(hour: hour, minute: 0)),
                  borderRadius: AppDimensions.radiusMedium,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? context.colorScheme.primary 
                          : context.colorScheme.surfaceContainer,
                      borderRadius: AppDimensions.radiusMedium,
                      border: Border.all(
                        color: isSelected 
                            ? context.colorScheme.primary 
                            : context.colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: isSelected 
                            ? Colors.white 
                            : context.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
