import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';

class PreviewCard extends StatefulWidget {
  final List<String> parts;
  final VoidCallback onReset;
  final void Function(int index, String value) onPartChanged;

  const PreviewCard({
    super.key,
    required this.parts,
    required this.onReset,
    required this.onPartChanged,
  });

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.parts
        .map((p) => TextEditingController(text: p))
        .toList();
  }

  @override
  void didUpdateWidget(PreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parts != widget.parts) {
      for (var i = 0; i < _controllers.length; i++) {
        if (i < widget.parts.length) {
          _controllers[i].text = widget.parts[i];
        }
      }
      while (_controllers.length < widget.parts.length) {
        _controllers.add(TextEditingController(text: widget.parts[_controllers.length]));
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: AppDimensions.paddingExtraLarge(context),
      decoration: BoxDecoration(
        color: context.customColors.successBg,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(
          color: context.customColors.success.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.visibility_rounded,
                  size: 18, color: context.customColors.success),
              const AppSpacerHorizontal.regular(),
              Text(
                'Prévia da mensagem',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.customColors.success,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onReset,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.refresh_rounded,
                        size: 14,
                        color: context.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Regenerar',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const AppSpacerVertical.small(),
          Text(
            'Clique em qualquer parte para editar antes de enviar.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const AppSpacerVertical.large(),
          ...List.generate(_controllers.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: _controllers[i],
              onChanged: (v) => widget.onPartChanged(i, v),
              maxLines: null,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
                height: 1.5,
              ),
              decoration: InputDecoration(
                contentPadding: AppDimensions.paddingMediumLarge(context),
                filled: true,
                fillColor: context.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: AppDimensions.radiusLarge,
                  borderSide: BorderSide(
                    color: context.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppDimensions.radiusLarge,
                  borderSide: BorderSide(
                    color: context.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppDimensions.radiusLarge,
                  borderSide: BorderSide(
                    color: context.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
}
