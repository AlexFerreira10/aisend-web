import 'package:flutter/material.dart';
import '../../../core/theme/context_extension.dart';
import '../../../core/constants/app_dimensions.dart';

class KpiCard extends StatefulWidget {
  final String label;
  final String value;
  final String description;

  /// Coloured trend text e.g. "↑ 23%" — shown bottom-left in trendColor
  final String? trend;
  final Color? trendColor;

  /// Muted label shown bottom-right e.g. "Últimos 7 dias"
  final String? timeLabel;

  /// 0.0–1.0 fill for the slider bar. null hides the bar.
  final double? progress;

  // Legacy fields kept for existing call-sites that still pass them
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.description,
    this.trend,
    this.trendColor,
    this.timeLabel,
    this.progress,
    this.icon,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final sliderColor = widget.trendColor ?? cs.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: _hovered ? cs.surfaceContainerHighest : cs.surfaceContainer,
          borderRadius: AppDimensions.radiusExtraLarge,
          border: Border.all(
            color: _hovered
                ? cs.primary.withValues(alpha: 0.2)
                : cs.outlineVariant,
            width: 1,
          ),
          boxShadow: _hovered
              ? <BoxShadow>[
                  BoxShadow(
                    color: sliderColor.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Row 1: label + dots menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _DotsMenu(),
              ],
            ),

            const SizedBox(height: 16),

            // ── Row 2: BIG number
            Text(
              widget.value,
              style: context.textTheme.displayLarge?.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                color: cs.onSurface,
                height: 1,
              ),
            ),

            const SizedBox(height: 14),

            // ── Row 3: trend% + time label
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.trend != null)
                  Text(
                    widget.trend!,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: sliderColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                if (widget.timeLabel != null)
                  Text(
                    widget.timeLabel!,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Row 4: Slider bar with circle thumb (BitVista style)
            if (widget.progress != null)
              _KpiSliderBar(
                value: widget.progress!.clamp(0.0, 1.0),
                color: sliderColor,
              ),
          ],
        ),
      ),
    );
  }
}

/// Three-dot overflow menu icon button
class _DotsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 24,
    child: CustomPaint(
      painter: _DotsPainter(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
      ),
    ),
  );
}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const r = 2.0;
    final cy = size.height / 2;
    final cx = size.width / 2;
    canvas.drawCircle(Offset(cx - 6, cy), r, paint);
    canvas.drawCircle(Offset(cx, cy), r, paint);
    canvas.drawCircle(Offset(cx + 6, cy), r, paint);
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

/// Slider-style bar with a glowing circle thumb — matches BitVista KPI cards
class _KpiSliderBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color color;

  const _KpiSliderBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    const thumbRadius = 9.0;
    const trackHeight = 6.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackW = constraints.maxWidth;
        // Clamp thumb center so it stays inside the track bounds
        final thumbCx = (trackW * value).clamp(
          thumbRadius,
          trackW - thumbRadius,
        );

        return SizedBox(
          height: thumbRadius * 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // Full track (background) - solid gray
              Positioned(
                left: 0,
                right: 0,
                top: thumbRadius - trackHeight / 2,
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),
              ),

              // Filled portion
              Positioned(
                left: 0,
                width: thumbCx,
                top: thumbRadius - trackHeight / 2,
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),
              ),

              // Circle thumb with thick border
              Positioned(
                left: thumbCx - thumbRadius,
                top: 0,
                child: Container(
                  width: thumbRadius * 2,
                  height: thumbRadius * 2,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white : Colors.white,
                      width: 3.5,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
