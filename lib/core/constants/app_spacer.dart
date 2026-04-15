import 'package:flutter/material.dart';
import 'app_dimensions.dart';

enum SpacerSize {
  tiny,
  small,
  regular,
  medium,
  mediumLarge,
  large,
  extraLarge,
  huge,
}

class AppSpacerVertical extends StatelessWidget {
  final double? height;
  final SpacerSize _size;

  const AppSpacerVertical({super.key, this.height, required SpacerSize size})
    : _size = size;

  const AppSpacerVertical.tiny({super.key})
    : height = null,
      _size = SpacerSize.tiny;

  const AppSpacerVertical.small({super.key})
    : height = null,
      _size = SpacerSize.small;

  const AppSpacerVertical.regular({super.key})
    : height = null,
      _size = SpacerSize.regular;

  const AppSpacerVertical.medium({super.key})
    : height = null,
      _size = SpacerSize.medium;

  const AppSpacerVertical.mediumLarge({super.key})
    : height = null,
      _size = SpacerSize.mediumLarge;

  const AppSpacerVertical.large({super.key})
    : height = null,
      _size = SpacerSize.large;

  const AppSpacerVertical.extraLarge({super.key})
    : height = null,
      _size = SpacerSize.extraLarge;

  const AppSpacerVertical.huge({super.key})
    : height = null,
      _size = SpacerSize.huge;

  const AppSpacerVertical.custom({super.key, required this.height})
    : _size = SpacerSize.tiny;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _getHeightForSize(context);
    return SizedBox(height: effectiveHeight);
  }

  double _getHeightForSize(BuildContext context) => switch (_size) {
    SpacerSize.tiny => AppDimensions.tiny(context),
    SpacerSize.small => AppDimensions.small(context),
    SpacerSize.regular => AppDimensions.regular(context),
    SpacerSize.medium => AppDimensions.medium(context),
    SpacerSize.mediumLarge => AppDimensions.mediumLarge(context),
    SpacerSize.large => AppDimensions.large(context),
    SpacerSize.extraLarge => AppDimensions.extraLarge(context),
    SpacerSize.huge => AppDimensions.huge(context),
  };
}

class AppSpacerHorizontal extends StatelessWidget {
  final double? width;
  final SpacerSize _size;

  const AppSpacerHorizontal({super.key, this.width, required SpacerSize size})
    : _size = size;

  const AppSpacerHorizontal.tiny({super.key})
    : width = null,
      _size = SpacerSize.tiny;

  const AppSpacerHorizontal.small({super.key})
    : width = null,
      _size = SpacerSize.small;

  const AppSpacerHorizontal.regular({super.key})
    : width = null,
      _size = SpacerSize.regular;

  const AppSpacerHorizontal.medium({super.key})
    : width = null,
      _size = SpacerSize.medium;

  const AppSpacerHorizontal.mediumLarge({super.key})
    : width = null,
      _size = SpacerSize.mediumLarge;

  const AppSpacerHorizontal.large({super.key})
    : width = null,
      _size = SpacerSize.large;

  const AppSpacerHorizontal.extraLarge({super.key})
    : width = null,
      _size = SpacerSize.extraLarge;

  const AppSpacerHorizontal.huge({super.key})
    : width = null,
      _size = SpacerSize.huge;

  const AppSpacerHorizontal.custom({super.key, required this.width})
    : _size = SpacerSize.tiny;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? _getWidthForSize(context);
    return SizedBox(width: effectiveWidth);
  }

  double _getWidthForSize(BuildContext context) => switch (_size) {
    SpacerSize.tiny => AppDimensions.tiny(context),
    SpacerSize.small => AppDimensions.small(context),
    SpacerSize.regular => AppDimensions.regular(context),
    SpacerSize.medium => AppDimensions.medium(context),
    SpacerSize.mediumLarge => AppDimensions.mediumLarge(context),
    SpacerSize.large => AppDimensions.large(context),
    SpacerSize.extraLarge => AppDimensions.extraLarge(context),
    SpacerSize.huge => AppDimensions.huge(context),
  };
}
