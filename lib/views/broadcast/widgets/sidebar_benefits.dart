import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';

class SidebarBenefits extends StatelessWidget {
  const SidebarBenefits({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _AntiBanCard(),
      const AppSpacerVertical.large(),
      const _SendModesCard(),
    ],
  );
}

class _AntiBanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: AppDimensions.paddingLarge(context),
    decoration: BoxDecoration(
      color: context.customColors.warningBg,
      borderRadius: AppDimensions.radiusExtraLarge,
      border: Border.all(
        color: context.customColors.warning.withValues(alpha: 0.3),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.security_rounded,
              color: context.customColors.warning,
              size: AppDimensions.iconSmall(context),
            ),
            const AppSpacerHorizontal.regular(),
            Text(
              'Proteção Anti-Ban',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.customColors.warning,
              ),
            ),
          ],
        ),
        const AppSpacerVertical.regular(),
        ...[
          'Intervalo aleatório entre 45-120s',
          'Textos únicos para cada contato',
          'Monitoramento de erros em tempo real',
          'Pausa automática se risco detectado',
        ].map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Text(
                  '•  ',
                  style: TextStyle(
                    color: context.customColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(child: Text(item, style: context.textTheme.bodySmall)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SendModesCard extends StatelessWidget {
  const _SendModesCard();

  static const _modes = [
    (
      icon: Icons.send_rounded,
      label: 'Imediato',
      description:
          'Dispara para todos os leads agora, com intervalo aleatório entre mensagens para proteger o número.',
    ),
    (
      icon: Icons.schedule_rounded,
      label: 'Agendado',
      description:
          'Programa o disparo para uma data e hora específica. Ideal para campanhas pontuais.',
    ),
    (
      icon: Icons.repeat_rounded,
      label: 'Recorrente',
      description:
          'Cria uma regra automática de follow-up para leads que não responderam em X dias.',
    ),
  ];

  @override
  Widget build(BuildContext context) => _SideCard(
    title: 'Modos de Envio',
    child: Column(
      children: _modes
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: AppDimensions.radiusMedium,
                    ),
                    child: Icon(
                      m.icon,
                      size: 14,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const AppSpacerHorizontal.regular(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.label,
                          style: context.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.description,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _SideCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SideCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: AppDimensions.paddingExtraLarge(context),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainer,
      borderRadius: AppDimensions.radiusExtraLarge,
      border: Border.all(color: context.colorScheme.outline, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
        ),
        const AppSpacerVertical.mediumLarge(),
        child,
      ],
    ),
  );
}
