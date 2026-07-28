import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  /// Returns true if the current theme is dark mode.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Semantic colors mapping back to Theme or AppColors
  AppColorsData get colors => AppColorsData(this);

  /// Typography mapping back to Theme or AppTextStyles
  AppTextStylesData get textStyles => AppTextStylesData(this);
}

class AppColorsData {
  final BuildContext context;
  AppColorsData(this.context);

  ThemeData get _theme => Theme.of(context);
  bool get _isDark => _theme.brightness == Brightness.dark;

  // -- Core Palette --
  Color get primary => _theme.colorScheme.primary;
  Color get primaryLight =>
      _isDark ? const Color(0xFF0D3D38) : AppColors.primaryLight;
  Color get primaryDark => _isDark ? AppColors.primary : AppColors.primaryDark;

  Color get secondary => _theme.colorScheme.secondary;
  Color get secondaryLight =>
      _isDark ? const Color(0xFF1E1B4B) : AppColors.secondaryLight;
  Color get secondaryDark =>
      _isDark ? AppColors.secondary : AppColors.secondaryDark;

  Color get accent => _theme.colorScheme.tertiary;
  Color get accentLight =>
      _isDark ? const Color(0xFF1F2937) : AppColors.accentLight;

  // -- Semantic Colors --
  Color get success => AppColors.success;
  Color get successLight => _isDark
      ? AppColors.success.withValues(alpha: 0.15)
      : AppColors.successLight;
  Color get warning => AppColors.warning;
  Color get warningLight => _isDark
      ? AppColors.warning.withValues(alpha: 0.15)
      : AppColors.warningLight;
  Color get danger => _theme.colorScheme.error;
  Color get dangerLight => _isDark
      ? AppColors.danger.withValues(alpha: 0.15)
      : AppColors.dangerLight;
  Color get info => AppColors.info;
  Color get infoLight =>
      _isDark ? AppColors.info.withValues(alpha: 0.15) : AppColors.infoLight;

  // -- Backgrounds --
  Color get bgLight => _theme.scaffoldBackgroundColor;
  Color get bgSurface => _theme.cardTheme.color ?? _theme.colorScheme.surface;
  Color get bgMuted => _isDark ? AppColors.bgDarkMuted : AppColors.bgMuted;

  // Backwards compatibility names (in case they explicitly used bgDark)
  Color get bgDark => AppColors.bgDark;
  Color get bgDarkSurface => AppColors.bgDarkSurface;
  Color get bgDarkMuted => AppColors.bgDarkMuted;

  // -- Text --
  Color get textDark => _theme.colorScheme.onSurface;
  Color get textMedium =>
      _isDark ? const Color(0xFFA0AAB2) : AppColors.textMedium;
  Color get textMuted =>
      _isDark ? const Color(0xFF6B7280) : AppColors.textMuted;
  Color get textOnPrimary => _theme.colorScheme.onPrimary;
  Color get textDarkMode => AppColors.textDarkMode;

  // -- Borders & Dividers --
  Color get border => _theme.colorScheme.outline;
  Color get divider =>
      _theme.dividerTheme.color ?? _theme.colorScheme.outlineVariant;

  // -- Gradient Stops --
  Color get gradientStart => AppColors.gradientStart;
  Color get gradientMid => AppColors.gradientMid;
  Color get gradientEnd => AppColors.gradientEnd;

  // -- Static --
  Color get white => AppColors.white;
  Color get black => AppColors.black;
  Color get transparent => AppColors.transparent;
}

class AppTextStylesData {
  final BuildContext context;
  AppTextStylesData(this.context);

  TextTheme get _theme => Theme.of(context).textTheme;

  TextStyle get heading1 => (_theme.displayLarge ?? AppTextStyles.heading1)
      .copyWith(color: ThemeExtension(context).colors.textDark);
  TextStyle get heading2 => (_theme.displayMedium ?? AppTextStyles.heading2)
      .copyWith(color: ThemeExtension(context).colors.textDark);
  TextStyle get heading3 => (_theme.headlineMedium ?? AppTextStyles.heading3)
      .copyWith(color: ThemeExtension(context).colors.textDark);

  TextStyle get bodyLarge => (_theme.bodyLarge ?? AppTextStyles.bodyLarge)
      .copyWith(color: ThemeExtension(context).colors.textDark);
  TextStyle get bodyMedium => (_theme.bodyMedium ?? AppTextStyles.bodyMedium)
      .copyWith(color: ThemeExtension(context).colors.textDark);
  TextStyle get bodySmall => (_theme.bodySmall ?? AppTextStyles.bodySmall)
      .copyWith(color: ThemeExtension(context).colors.textDark);

  TextStyle get bodyMuted =>
      bodyMedium.copyWith(color: ThemeExtension(context).colors.textMuted);

  TextStyle get labelBold => (_theme.labelLarge ?? AppTextStyles.labelBold)
      .copyWith(color: ThemeExtension(context).colors.textDark);
  TextStyle get labelMedium => (_theme.labelMedium ?? AppTextStyles.labelMedium)
      .copyWith(color: ThemeExtension(context).colors.textDark);
  TextStyle get labelSmall => (_theme.labelSmall ?? AppTextStyles.bodySmall)
      .copyWith(color: ThemeExtension(context).colors.textDark);

  TextStyle get buttonLabel => _theme.labelLarge ?? AppTextStyles.buttonLabel;
  TextStyle get caption => bodySmall.copyWith(letterSpacing: 0.2);

  // Dark Mode variants mapping directly since text color is handled automatically
  TextStyle get heading1Dark => heading1;
  TextStyle get heading2Dark => heading2;
  TextStyle get bodyLargeDark => bodyLarge;
  TextStyle get bodyMediumDark => bodyMedium;
}
