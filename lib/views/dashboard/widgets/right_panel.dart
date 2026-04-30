import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lead_funnel_chart.dart';

class DashboardRightPanel extends StatelessWidget {
  const DashboardRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FunnelSection(),
        SizedBox(height: 16),
        _WaitingSection(),
        SizedBox(height: 16),
      ],
    );
  }
}

// ─── Funnel Section ────────────────────────────────────────────────────────────

class _FunnelSection extends StatelessWidget {
  const _FunnelSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final custom = context.customColors;

    final segments = <FunnelSegment>[
      FunnelSegment(
        label: 'Quente',
        value: vm.hotLeadsCount.toDouble(),
        color: custom.statusHot,
      ),
      FunnelSegment(
        label: 'Morno',
        value: vm.warmLeadsCount.toDouble(),
        color: custom.statusWarm,
      ),
      FunnelSegment(
        label: 'Frio',
        value: vm.coldLeadsCount.toDouble(),
        color: custom.statusCold,
      ),
      FunnelSegment(
        label: 'Cliente Ativo',
        value: vm.activeClientCount.toDouble(),
        color: custom.success,
      ),
    ];

    final total = vm.totalLeads;

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.donut_large_rounded,
                  size: 14, color: custom.accentSecondary),
              const SizedBox(width: 6),
              Text(
                'Funil de Leads',
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: LeadFunnelChart(
                segments: segments,
                centerLabel: total > 999
                    ? '${(total / 1000).toStringAsFixed(1)}k'
                    : '$total',
                centerSubLabel: 'total',
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Column(
            children: segments
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FunnelLegendItem(segment: s, total: total),
                    ))
                .toList(),
          ),

          // Mini distribution bar
          const SizedBox(height: 12),
          _DistributionBar(segments: segments, total: total),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final List<FunnelSegment> segments;
  final int total;

  const _DistributionBar({required this.segments, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 5,
        child: Row(
          children: segments.map((s) {
            final pct = s.value / total;
            return Flexible(
              flex: (pct * 1000).round(),
              child: Container(color: s.color),
            );
          }).toList(),
        ),
      ),
    );
  }
}


// ─── Waiting Section ──────────────────────────────────────────────────────────

class _WaitingSection extends StatelessWidget {
  const _WaitingSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final custom = context.customColors;
    final total = vm.totalLeads;
    final waiting = vm.waitingHumanCount;
    final pct = total > 0 ? waiting / total : 0.0;

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.hourglass_top_rounded,
                  size: 14, color: custom.warning),
              const SizedBox(width: 6),
              Text(
                'Aguardando Atenção',
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '$waiting',
                style: context.textTheme.displayMedium?.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: waiting > 0 ? custom.warning : custom.success,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'leads',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(1)}%',
                style: context.textTheme.labelMedium?.copyWith(
                  color: waiting > 0
                      ? custom.warning
                      : custom.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor:
                  context.colorScheme.outlineVariant.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(
                waiting > 0 ? custom.warning : custom.success,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            waiting > 0
                ? 'Requerem intervenção manual'
                : 'Tudo em dia — sem pendências',
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Card Shell ────────────────────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  final Widget child;
  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: child,
      );
}
