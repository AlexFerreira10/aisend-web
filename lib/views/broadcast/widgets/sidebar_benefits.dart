import 'package:flutter/material.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/theme/custom_colors_extension.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_spacer.dart';
import '../../../data/sources/mock_data_source.dart';

class SidebarBenefits extends StatelessWidget {
  const SidebarBenefits({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      // _BenefitsCard(),
      // const AppSpacerVertical.large(),
      _AntiBanCard(),
      const AppSpacerVertical.large(),
      _StatisticsCard(),
    ],
  );
}

// class _BenefitsCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       (
//         icon: Icons.auto_awesome_rounded,
//         title: 'Mensagens Dinâmicas',
//         subtitle: 'IA varia o texto por lead',
//       ),
//       (icon: Icons.shuffle_rounded, title: 'Intervalo Caótico', subtitle: 'Aleatório e imprevisível'),
//       (
//         icon: Icons.psychology_rounded,
//         title: 'Feedback Inteligente',
//         subtitle: 'Classifica Frio/Morno/Quente',
//       ),
//       (icon: Icons.shield_rounded, title: 'Risco Mínimo', subtitle: 'Simula comportamento humano'),
//     ];

//     return _SideCard(
//       title: 'Vantagens vs ZapNinja',
//       child: Column(
//         children: items
//             .map(
//               (item) => _BenefitItem(
//                 icon: item.icon,
//                 title: item.title,
//                 subtitle: item.subtitle,
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppDimensions.paddingBottom(context),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: AppDimensions.paddingSmall(context),
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: AppDimensions.radiusSmall,
          ),
          child: Icon(
            icon,
            color: context.colorScheme.primary,
            size: AppDimensions.iconSmallest(context),
          ),
        ),
        const AppSpacerHorizontal.regular(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              Text(subtitle, style: context.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AntiBanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Row(
            children: [
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
                  Expanded(
                    child: Text(item, style: context.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        label: 'Disparos Hoje',
        value: MockDataSource.broadcastsToday.toString(),
      ),
      (
        label: 'Taxa Resp. Média',
        value: '${(MockDataSource.responseRate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: 'Leads Convertidos',
        value: MockDataSource.convertedLeads.toString(),
      ),
    ];

    return _SideCard(
      title: 'Estatísticas Recentes',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label, style: context.textTheme.bodyMedium),
                    Text(
                      item.value,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
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
}

class _SideCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SideCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingExtraLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
}
