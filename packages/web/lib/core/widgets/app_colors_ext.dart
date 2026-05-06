// ============================================================================
// APP COLORS EXTENSION
// ============================================================================
// Dosya: core/widgets/app_colors_ext.dart
//
// Kullanım: context.appColors.bg, context.appColors.textSub, ...
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _AppColorSet {
  const _AppColorSet({required this.isDark});
  final bool isDark;

  Color get bg => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get card => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get borderMid =>
      isDark ? AppColors.darkBorderMid : AppColors.lightBorderMid;
  Color get text => isDark ? AppColors.darkText : AppColors.lightText;
  Color get textSub => isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
  Color get textHint =>
      isDark ? AppColors.darkTextHint : AppColors.lightTextHint;
  Color get tag => isDark ? AppColors.darkTag : AppColors.lightTag;
  Color get tagText => isDark ? AppColors.darkTagText : AppColors.lightTagText;
}

extension AppColorsExt on BuildContext {
  _AppColorSet get appColors =>
      _AppColorSet(isDark: Theme.of(this).brightness == Brightness.dark);
}
