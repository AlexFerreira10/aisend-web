import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single segment in the donut chart.
class FunnelSegment {
  final String label;
  final double value;
  final Color color;

  const FunnelSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class LeadFunnelChart extends StatefulWidget {
  final List<FunnelSegment> segments;
  final String centerLabel;
  final String centerSubLabel;

  const LeadFunnelChart({
    super.key,
    required this.segments,
    required this.centerLabel,
    required this.centerSubLabel,
  });

  @override
  State<LeadFunnelChart> createState() => _LeadFunnelChartState();
}

class _LeadFunnelChartState extends State<LeadFunnelChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surfaceContainer;
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => CustomPaint(
        painter: _DonutPainter(
          segments: widget.segments,
          progress: _progress.value,
          bgColor: bgColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.centerLabel,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -1.0,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.centerSubLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<FunnelSegment> segments;
  final double progress;
  final Color bgColor;

  _DonutPainter({
    required this.segments,
    required this.progress,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 8;
    final strokeWidth = radius * 0.14; // Thinner, sleeker border
    final innerRadius = radius - strokeWidth;

    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    if (total == 0) return;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(Offset(cx, cy), radius - strokeWidth / 2, bgPaint);

    // Segments — start at 12 o'clock (-π/2)
    double startAngle = -math.pi / 2;
    const gapAngle = 0.025; // small gap between segments in radians

    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * math.pi * progress - gapAngle;
      if (sweep <= 0) {
        startAngle += (seg.value / total) * 2 * math.pi * progress;
        continue;
      }

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: Offset(cx, cy),
        radius: radius - strokeWidth / 2,
      );
      canvas.drawArc(rect, startAngle + gapAngle / 2, sweep, false, paint);

      startAngle += sweep + gapAngle;
    }

    // Inner circle mask to create the donut hole
    final maskPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), innerRadius, maskPaint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.segments != segments;
}

/// Compact legend row: coloured dot + label + value text.
class FunnelLegendItem extends StatelessWidget {
  final FunnelSegment segment;
  final int total;

  const FunnelLegendItem({
    super.key,
    required this.segment,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (segment.value / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: segment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              segment.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
