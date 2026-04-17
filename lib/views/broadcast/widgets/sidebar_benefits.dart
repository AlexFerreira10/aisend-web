import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SidebarBenefits extends StatelessWidget {
  const SidebarBenefits({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _AntiBanCard(),
      const AppSpacerVertical.large(),
      _StatisticsCard(),
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
        children:  <Widget>[
          Row(
            children:  <Widget>[
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

class _StatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardViewModel>();
    final items = [
      (
        label: 'Total de Leads',
        value: dashboard.totalLeads.toString(),
      ),
      (
        label: 'Taxa Resp. Média',
        value: '${(dashboard.responseRate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: 'Leads Quentes',
        value: dashboard.hotLeadsCount.toString(),
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
                  children:  <Widget>[
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
