import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/models/enums/lead_status_enum.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatefulWidget {
  final LeadStatusEnum status;
  const StatusBadge({super.key, required this.status});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status == LeadStatusEnum.hot) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  (Color bg, Color text, String label, String emoji) _getConfig(BuildContext context) => switch (widget.status) {
      LeadStatusEnum.hot => (
          context.customColors.statusHotBg,
          context.customColors.statusHot,
          widget.status.label,
          widget.status.emoji,
        ),
      LeadStatusEnum.warm => (
          context.customColors.statusWarmBg,
          context.customColors.statusWarm,
          widget.status.label,
          widget.status.emoji,
        ),
      LeadStatusEnum.cold => (
          context.customColors.statusColdBg,
          context.customColors.statusCold,
          widget.status.label,
          widget.status.emoji,
        ),
      LeadStatusEnum.activeClient => (
          const Color(0xFFFFF8E1),
          const Color(0xFFF59E0B),
          widget.status.label,
          widget.status.emoji,
        ),
    };

  @override
  Widget build(BuildContext context) {
    final (bg, text, label, emoji) = _getConfig(context);

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.regular(context),
        vertical: AppDimensions.tiny(context) * 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimensions.radiusRound,
        border: Border.all(color: text.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: context.textTheme.labelSmall?.copyWith(fontSize: 11)),
          const AppSpacerHorizontal.small(),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );

    if (widget.status == LeadStatusEnum.hot) {
      return AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Opacity(
          opacity: _pulseAnim.value,
          child: child,
        ),
        child: badge,
      );
    }

    return badge;
  }
}
