import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget content;
  final List<Widget> actions;
  final double width;
  final VoidCallback? onClose;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.icon,
    this.width = 480,
    this.onClose,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    required List<Widget> actions,
    IconData? icon,
    double width = 480,
    VoidCallback? onClose,
  }) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 180),
      transitionBuilder: (_, animation, _, child) {
        if (reduceMotion) return child;
        return ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (ctx, _, _) => AppDialog(
        title: title,
        icon: icon,
        content: content,
        actions: actions,
        width: width,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.radiusLarge,
        side: BorderSide(color: context.colorScheme.outline, width: 1),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppDialogHeader(title: title, icon: icon, onClose: onClose),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
            ),
            const Divider(height: 1),
            _AppDialogActions(actions: actions),
          ],
        ),
      ),
    );
  }
}

class _AppDialogHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onClose;

  const _AppDialogHeader({
    required this.title,
    this.icon,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppDimensions.radiusMedium,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Fechar',
              color: context.colorScheme.onSurfaceVariant,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
}

class _AppDialogActions extends StatelessWidget {
  final List<Widget> actions;

  const _AppDialogActions({required this.actions});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions
              .expand((a) => [a, const SizedBox(width: 8)])
              .toList()
            ..removeLast(),
        ),
      );
}
