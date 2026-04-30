import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:typed_data';

class UploadZone extends StatefulWidget {
  final String? uploadedFileName;
  final int? leadCount;
  final VoidCallback onUpload;
  final VoidCallback onClear;
  final void Function(Uint8List bytes, String name)? onFileDropped;

  const UploadZone({
    super.key,
    required this.uploadedFileName,
    this.leadCount,
    required this.onUpload,
    required this.onClear,
    this.onFileDropped,
  });

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {
  bool _dragOver = false;

  @override
  Widget build(BuildContext context) {
    if (widget.uploadedFileName != null) {
      return _UploadedFile(
        fileName: widget.uploadedFileName!,
        leadCount: widget.leadCount,
        onClear: widget.onClear,
      );
    }

    return DropTarget(
      onDragEntered: (details) => setState(() => _dragOver = true),
      onDragExited: (details) => setState(() => _dragOver = false),
      onDragDone: (details) async {
        if (details.files.isNotEmpty && widget.onFileDropped != null) {
          final file = details.files.first;
          final bytes = await file.readAsBytes();
          widget.onFileDropped!(bytes, file.name);
        }
      },
      child: _DropZone(
        isDragOver: _dragOver,
        onDragEnter: () => setState(() => _dragOver = true),
        onDragExit: () => setState(() => _dragOver = false),
        onTap: widget.onUpload,
      ),
    );
  }
}

class _DropZone extends StatefulWidget {
  final bool isDragOver;
  final VoidCallback onDragEnter;
  final VoidCallback onDragExit;
  final VoidCallback onTap;

  const _DropZone({
    required this.isDragOver,
    required this.onDragEnter,
    required this.onDragExit,
    required this.onTap,
  });

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isDragOver || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppDimensions.radiusExtraLarge,
          splashColor: context.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: context.colorScheme.primary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: AppDimensions.paddingVerticalHuge(
              context,
            ).add(AppDimensions.paddingHorizontalLarge(context)),
            decoration: BoxDecoration(
              color: active
                  ? context.colorScheme.primary.withValues(alpha: 0.1)
                  : context.colorScheme.surface,
              borderRadius: AppDimensions.radiusExtraLarge,
              border: Border.all(
                color: active
                    ? context.colorScheme.primary
                    : context.colorScheme.outline,
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: AppDimensions.paddingMediumLarge(context),
                  decoration: BoxDecoration(
                    color: active
                        ? context.colorScheme.primary.withValues(alpha: 0.2)
                        : context.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.upload_rounded,
                    size: AppDimensions.iconLarge(context),
                    color: active
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const AppSpacerVertical.large(),
                Text(
                  'Arraste lista de contatos',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: active
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurface,
                  ),
                ),
                const AppSpacerVertical.tiny(),
                Text(
                  'CSV, Excel ou JSON',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const AppSpacerVertical.tiny(),
                Text('ou', style: context.textTheme.bodySmall),
                const AppSpacerVertical.medium(),
                Container(
                  padding: AppDimensions.paddingHorizontalExtraLarge(
                    context,
                  ).add(AppDimensions.paddingVerticalRegular(context)),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.colorScheme.outline,
                      width: 1.5,
                    ),
                    borderRadius: AppDimensions.radiusMedium,
                    color: context.colorScheme.surfaceContainer,
                  ),
                  child: Text(
                    'Escolher Arquivo',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadedFile extends StatelessWidget {
  final String fileName;
  final int? leadCount;
  final VoidCallback onClear;

  const _UploadedFile({
    required this.fileName,
    this.leadCount,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: AppDimensions.paddingHorizontalExtraLarge(
      context,
    ).add(AppDimensions.paddingVerticalLarge(context)),
    decoration: BoxDecoration(
      color: context.customColors.successBg,
      borderRadius: AppDimensions.radiusExtraLarge,
      border: Border.all(
        color: context.customColors.success.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: AppDimensions.paddingRegular(context),
          decoration: BoxDecoration(
            color: context.customColors.success.withValues(alpha: 0.15),
            borderRadius: AppDimensions.radiusMedium,
          ),
          child: Icon(
            Icons.insert_drive_file_rounded,
            color: context.customColors.success,
            size: AppDimensions.iconMedium(context),
          ),
        ),
        const AppSpacerHorizontal.medium(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                fileName,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              const AppSpacerVertical.tiny(),
              Text(
                leadCount != null
                    ? '$leadCount contatos prontos para disparar'
                    : 'Pronto para disparar',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.customColors.success,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: context.colorScheme.onSurfaceVariant,
            size: AppDimensions.iconMediumSmall(context),
          ),
          onPressed: onClear,
          tooltip: 'Remover arquivo',
        ),
      ],
    ),
  );
}
