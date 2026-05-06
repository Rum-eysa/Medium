// ============================================================================
// APP THEME — DARK & LIGHT (Medium tarzı)
// ============================================================================
// Dosya: core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Renk sabitleri ──────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Dark palette ───────────────────────────────────────────────────────────
  static const darkBg = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF141414);
  static const darkBorder = Color(0xFF1F1F1F);
  static const darkBorderMid = Color(0xFF2A2A2A);
  static const darkText = Color(0xFFF2F2F2);
  static const darkTextSub = Color(0xFF888888);
  static const darkTextHint = Color(0xFF444444);
  static const darkTag = Color(0xFF1E1E1E);
  static const darkTagText = Color(0xFF666666);

  // ── Light palette ─────────────────────────────────────────────────────────
  static const lightBg = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF9F9F9);
  static const lightCard = Color(0xFFFAFAFA);
  static const lightBorder = Color(0xFFF0F0F0);
  static const lightBorderMid = Color(0xFFE0E0E0);
  static const lightText = Color(0xFF1A1A1A);
  static const lightTextSub = Color(0xFF757575);
  static const lightTextHint = Color(0xFFBBBBBB);
  static const lightTag = Color(0xFFF2F2F2);
  static const lightTagText = Color(0xFF555555);

  // ── Semantic — her iki temada aynı ────────────────────────────────────────
  static const accent = Color(0xFF1A8917); // Medium yeşili
  static const accentAmber = Color(0xFFF59E0B); // Premium / AI rengi
  static const memberGold = Color(0xFFF59E0B);
  static const clap = Color(0xFF757575);
  static const danger = Color(0xFFE24B4A);
}

// ── ThemeData factory ───────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    border: AppColors.darkBorder,
    text: AppColors.darkText,
    textSub: AppColors.darkTextSub,
    icon: AppColors.darkTextSub,
    overlay: SystemUiOverlayStyle.light,
  );

  static ThemeData light() => _build(
    brightness: Brightness.light,
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    border: AppColors.lightBorder,
    text: AppColors.lightText,
    textSub: AppColors.lightTextSub,
    icon: AppColors.lightTextSub,
    overlay: SystemUiOverlayStyle.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color border,
    required Color text,
    required Color textSub,
    required Color icon,
    required SystemUiOverlayStyle overlay,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: text,
        onPrimary: bg,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: text,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      fontFamily: 'Inter', // pubspec'e ekle; yoksa system font kullanır
      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Georgia', // Medium logo tipi
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: icon, size: 22),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),

      // ── Tab bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: text,
        unselectedLabelColor: textSub,
        indicatorColor: text,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: border,
        splashFactory: NoSplash.splashFactory,
      ),

      // ── Text ──────────────────────────────────────────────────────────────
      textTheme: TextTheme(
        // Article title
        headlineMedium: TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Georgia',
          height: 1.3,
          letterSpacing: -0.3,
        ),
        // Card title
        titleLarge: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Georgia',
          height: 1.3,
        ),
        // Card subtitle
        titleMedium: TextStyle(
          color: textSub,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        // Meta (author, date)
        labelSmall: TextStyle(
          color: textSub,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        // Body
        bodyMedium: TextStyle(color: text, fontSize: 16, height: 1.7),
        bodySmall: TextStyle(color: textSub, fontSize: 13, height: 1.5),
      ),

      // ── Input / Search ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: text, width: 1),
        ),
        hintStyle: TextStyle(color: textSub, fontSize: 14),
        labelStyle: TextStyle(color: textSub, fontSize: 12, letterSpacing: 0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ── Elevated button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: text,
          foregroundColor: bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Outlined button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(
            color: isDark ? AppColors.darkBorderMid : AppColors.lightBorderMid,
            width: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),

      // ── Icon button ───────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: icon,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkTag : AppColors.lightTag,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTagText : AppColors.lightTagText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: const StadiumBorder(),
      ),

      // ── Bottom nav ────────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: text,
        unselectedItemColor: textSub,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),

      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
