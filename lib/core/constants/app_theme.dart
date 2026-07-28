import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🌅 SUNRISE THEME — TinySteps Design System
//    Primary  : Soft Coral     #FF6B6B
//    Secondary: Gentle Lavender #C77DFF
//    Accent   : Peach          #FFB347
//    Background: Warm White    #FFF9F5
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Core Palette ─────────────────────────────────────────────────────────
  static const primary        = Color(0xFF14B8A6); // Cool Teal
  static const primaryLight   = Color(0xFFCCFBF1); // Teal tint
  static const primaryDark    = Color(0xFF0F766E); // Deeper teal for pressed states

  static const secondary      = Color(0xFF6366F1); // Gentle Indigo
  static const secondaryLight = Color(0xFFE0E7FF); // Indigo tint
  static const secondaryDark  = Color(0xFF4338CA); // Deeper indigo

  static const accent         = Color(0xFF38BDF8); // Sky Blue
  static const accentLight    = Color(0xFFE0F2FE); // Sky tint

  // ── Semantic Colours ─────────────────────────────────────────────────────
  static const success        = Color(0xFF4CAF50);
  static const successLight   = Color(0xFFE8F5E9);
  static const warning        = Color(0xFFFFC107);
  static const warningLight   = Color(0xFFFFF8E1);
  static const danger         = Color(0xFFE53935);
  static const dangerLight    = Color(0xFFFFEBEE);
  static const info           = Color(0xFF2196F3);
  static const infoLight      = Color(0xFFE3F2FD);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const bgLight        = Color(0xFFF8FAFC); // Cool Slate White
  static const bgSurface      = Color(0xFFFFFFFF); // Card surface
  static const bgMuted        = Color(0xFFF1F5F9); // Muted slate tint for sections

  // ── Dark Mode Backgrounds ─────────────────────────────────────────────────
  static const bgDark         = Color(0xFF0D1117); // Deep dark base
  static const bgDarkSurface  = Color(0xFF1C1C2E); // Card surface dark
  static const bgDarkMuted    = Color(0xFF252535); // Muted section dark

  // ── Text ─────────────────────────────────────────────────────────────────
  static const textDark       = Color(0xFF2D1B1B); // Warm near-black
  static const textMedium     = Color(0xFF5C4444); // Mid brown-grey
  static const textMuted      = Color(0xFF9E8484); // Muted warm grey
  static const textOnPrimary  = Color(0xFFFFFFFF); // White on coral buttons
  static const textDarkMode   = Color(0xFFE8E0F0); // Off-white, easier on eyes

  // ── Borders & Dividers ───────────────────────────────────────────────────
  static const border         = Color(0xFFE2E8F0); // Cool slate border
  static const divider        = Color(0xFFF8FAFC); // Soft divider

  // ── Gradient Stops ───────────────────────────────────────────────────────
  static const gradientStart  = Color(0xFF14B8A6); // Teal
  static const gradientMid    = Color(0xFF38BDF8); // Sky Blue
  static const gradientEnd    = Color(0xFF6366F1); // Indigo

  // ── Static ───────────────────────────────────────────────────────────────
  static const white          = Color(0xFFFFFFFF);
  static const black          = Color(0xFF000000);
  static const transparent    = Color(0x00000000);
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradients
// ─────────────────────────────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const sunrise = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientMid, AppColors.gradientEnd],
    stops: [0.0, 0.5, 1.0],
  );

  static const sunriseSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFBAE6FD), AppColors.bgLight],
  );

  static const coralButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.accent],
  );

  static const lavenderAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, Color(0xFF9B5FD9)],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Typography — Lexend (designed for readability, all ages, dyslexia-friendly)
// ─────────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static TextStyle get bodyMuted => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle get labelBold => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: 0.2,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMedium,
    letterSpacing: 0.3,
  );

  static TextStyle get buttonLabel => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  // Dark Mode variants
  static TextStyle get heading1Dark => heading1.copyWith(color: AppColors.textDarkMode);
  static TextStyle get heading2Dark => heading2.copyWith(color: AppColors.textDarkMode);
  static TextStyle get bodyLargeDark => bodyLarge.copyWith(color: AppColors.textDarkMode);
  static TextStyle get bodyMediumDark => bodyMedium.copyWith(color: AppColors.textDarkMode);
}

// ─────────────────────────────────────────────────────────────────────────────
// Spacing — 16px base grid
// ─────────────────────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

// ─────────────────────────────────────────────────────────────────────────────
// Border Radius — 16–24px everywhere (soft, child-friendly, no sharp corners)
// ─────────────────────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double xs   = 8;
  static const double sm   = 12;
  static const double md   = 16;   // Minimum per design spec
  static const double lg   = 20;
  static const double xl   = 24;   // Maximum per design spec
  static const double full = 999;  // Pill shape

  static BorderRadius get cardRadius     => BorderRadius.circular(xl);
  static BorderRadius get buttonRadius   => BorderRadius.circular(full);
  static BorderRadius get inputRadius    => BorderRadius.circular(md);
  static BorderRadius get chipRadius     => BorderRadius.circular(full);
  static BorderRadius get sheetRadius    => const BorderRadius.vertical(top: Radius.circular(xl));
  static BorderRadius get dialogRadius   => BorderRadius.circular(xl);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shadows — soft, low-opacity (not harsh)
// ─────────────────────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeData — Light (Sunrise)
// ─────────────────────────────────────────────────────────────────────────────
ThemeData sunriseLightTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary:          AppColors.primary,
      onPrimary:        AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLight,
      secondary:        AppColors.secondary,
      onSecondary:      AppColors.textOnPrimary,
      secondaryContainer: AppColors.secondaryLight,
      tertiary:         AppColors.accent,
      onTertiary:       AppColors.textOnPrimary,
      surface:          AppColors.bgSurface,
      onSurface:        AppColors.textDark,
      error:            AppColors.danger,
      onError:          AppColors.white,
      outline:          AppColors.border,
      outlineVariant:   AppColors.divider,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge:  AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      headlineMedium: AppTextStyles.heading3,
      bodyLarge:     AppTextStyles.bodyLarge,
      bodyMedium:    AppTextStyles.bodyMedium,
      bodySmall:     AppTextStyles.bodySmall,
      labelLarge:    AppTextStyles.buttonLabel,
      labelMedium:   AppTextStyles.labelMedium,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgLight,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading3,
      iconTheme: const IconThemeData(color: AppColors.textDark),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        textStyle: AppTextStyles.buttonLabel,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        textStyle: AppTextStyles.buttonLabel.copyWith(color: AppColors.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.labelBold.copyWith(color: AppColors.primary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      hintStyle: AppTextStyles.bodyMuted,
      labelStyle: AppTextStyles.labelMedium,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLight,
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: AppSpacing.md,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textDark,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textMedium,
      size: 24,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return AppColors.border;
      }),
    ),
    // ── Dialog & Popup global theming ────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bgLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: AppTextStyles.heading3,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.bgSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: AppTextStyles.bodyMedium,
    ),
    // ── Smooth page transitions ──────────────────────────────────────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeData — Dark (Sunrise Dark Mode)
// ─────────────────────────────────────────────────────────────────────────────
ThemeData sunriseDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  // Reduced saturation primaries for dark mode
  // Adapted primaries for dark mode (maintaining mint/ice/teal palette)
  const primaryDark   = Color(0xFF2DD4BF); // Brighter Teal (Teal 400) for contrast
  const secondaryDark = Color(0xFF818CF8); // Brighter Indigo (Indigo 400)
  const accentDark    = Color(0xFF7DD3FC); // Brighter Sky Blue (Sky 300)

  return base.copyWith(
    colorScheme: const ColorScheme.dark(
      primary:            primaryDark,
      onPrimary:          AppColors.white,
      primaryContainer:   Color(0xFF0D3D38), // Dark Teal container
      secondary:          secondaryDark,
      onSecondary:        AppColors.white,
      secondaryContainer: Color(0xFF1E1B4B), // Dark Indigo container
      tertiary:           accentDark,
      surface:            AppColors.bgDarkSurface,
      onSurface:          AppColors.textDarkMode,
      error:              AppColors.danger,
      onError:            AppColors.white,
      outline:            Color(0xFF3A2A2A),
      outlineVariant:     Color(0xFF2A2020),
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge:   AppTextStyles.heading1Dark,
      displayMedium:  AppTextStyles.heading2Dark,
      bodyLarge:      AppTextStyles.bodyLargeDark,
      bodyMedium:     AppTextStyles.bodyMediumDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.textDarkMode,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.textDarkMode),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgDarkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgDarkMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: Color(0xFF3A2A2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: Color(0xFF3A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      hintStyle: AppTextStyles.bodyMuted.copyWith(color: const Color(0xFF6A5A5A)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2020),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgDarkSurface,
      selectedItemColor: primaryDark,
      unselectedItemColor: Color(0xFF6A5A6A),
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: AppColors.white,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textDarkMode,
      size: 24,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryDark;
        return AppColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryDark.withValues(alpha: 0.3);
        return const Color(0xFF2D3748);
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bgDarkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.textDarkMode),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDarkMode),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.bgDarkMuted,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDarkMode),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
