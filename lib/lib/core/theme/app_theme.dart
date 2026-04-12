import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

// ════════════════════════════════════════════════════════════════
// NEXIIA — App Theme
// ════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════
  // MAIN THEME
  // ══════════════════════════════════════════════════════════

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,

      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,

      fontFamily: 'Satoshi',
      textTheme: _textTheme,

      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      iconTheme: _iconTheme,
      cardTheme: _cardTheme,
      bottomSheetTheme: _bottomSheetTheme,
      dialogTheme: _dialogTheme,
      checkboxTheme: _checkboxTheme,
      dividerTheme: _dividerTheme,
      scrollbarTheme: _scrollbarTheme,
    );
  }

  // ══════════════════════════════════════════════════════════
  // SYSTEM UI
  // ══════════════════════════════════════════════════════════

  static void setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ══════════════════════════════════════════════════════════
  // COLOR SCHEME
  // ══════════════════════════════════════════════════════════

  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.electricBlue,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.electricBlueMuted,
    onPrimaryContainer: AppColors.electricBlueLight,
    secondary: AppColors.gold,
    onSecondary: AppColors.background,
    secondaryContainer: AppColors.goldMuted,
    onSecondaryContainer: AppColors.gold,
    surface: AppColors.surface,
    onSurface: AppColors.white95,
    surfaceContainerHighest: AppColors.surfaceHighest,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorSurface,
    outline: AppColors.white15,
    outlineVariant: AppColors.white08,
  );

  // ══════════════════════════════════════════════════════════
  // TEXT THEME
  // ══════════════════════════════════════════════════════════

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.headlineHero,
    displayMedium: AppTypography.headlineLarge,
    displaySmall: AppTypography.headlineMedium,
    headlineMedium: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelButton,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  // ══════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════

  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    titleTextStyle: AppTypography.titleLarge,
    iconTheme: const IconThemeData(
      color: AppColors.white80,
      size: AppSpacing.iconMd,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ══════════════════════════════════════════════════════════
  // INPUT FIELDS
  // ══════════════════════════════════════════════════════════

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceHighest,
    hintStyle: AppTypography.inputHint,
    labelStyle: AppTypography.inputLabel,
    errorStyle: AppTypography.inputError,
    floatingLabelStyle: AppTypography.inputLabel.copyWith(
      color: AppColors.electricBlue,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusSm,
      borderSide: const BorderSide(
        color: AppColors.white10,
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusSm,
      borderSide: const BorderSide(
        color: AppColors.white10,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusSm,
      borderSide: const BorderSide(
        color: AppColors.electricBlue,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusSm,
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.0,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusSm,
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.5,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusSm,
      borderSide: const BorderSide(
        color: AppColors.white05,
        width: 1.0,
      ),
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );

  // ══════════════════════════════════════════════════════════
  // ELEVATED BUTTON
  // ══════════════════════════════════════════════════════════

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.electricBlue,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.white10,
      disabledForegroundColor: AppColors.white30,
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(
        double.infinity,
        AppSpacing.buttonHeight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      textStyle: AppTypography.labelButton,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    ),
  );

  // ══════════════════════════════════════════════════════════
  // TEXT BUTTON
  // ══════════════════════════════════════════════════════════

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.electricBlue,
      textStyle: AppTypography.link,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      minimumSize: const Size(
        AppSpacing.touchTarget,
        AppSpacing.touchTarget,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      splashFactory: NoSplash.splashFactory,
    ),
  );

  // ══════════════════════════════════════════════════════════
  // OUTLINED BUTTON
  // ══════════════════════════════════════════════════════════

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.white80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      minimumSize: const Size(
        double.infinity,
        AppSpacing.buttonHeight,
      ),
      side: const BorderSide(
        color: AppColors.white15,
        width: 1.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      textStyle: AppTypography.labelButton.copyWith(
        color: AppColors.white80,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      splashFactory: NoSplash.splashFactory,
    ),
  );

  // ══════════════════════════════════════════════════════════
  // ICON
  // ══════════════════════════════════════════════════════════

  static const IconThemeData _iconTheme = IconThemeData(
    color: AppColors.white70,
    size: AppSpacing.iconMd,
  );

  // ══════════════════════════════════════════════════════════
  // CARD
  // ══════════════════════════════════════════════════════════

  static final CardThemeData _cardTheme = CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
  );

  // ══════════════════════════════════════════════════════════
  // BOTTOM SHEET
  // ══════════════════════════════════════════════════════════

  static final BottomSheetThemeData _bottomSheetTheme =
      BottomSheetThemeData(
    backgroundColor: AppColors.surfaceElevated,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    dragHandleColor: AppColors.white20,
    dragHandleSize: const Size(40, 4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusXl),
        topRight: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    showDragHandle: true,
  );

  // ══════════════════════════════════════════════════════════
  // DIALOG
  // ══════════════════════════════════════════════════════════

  static final DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surfaceElevated,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusLg,
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  // ══════════════════════════════════════════════════════════
  // CHECKBOX
  // ══════════════════════════════════════════════════════════

  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.electricBlue;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.white),
    side: const BorderSide(
      color: AppColors.white30,
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    visualDensity: VisualDensity.compact,
  );

  // ══════════════════════════════════════════════════════════
  // DIVIDER
  // ══════════════════════════════════════════════════════════

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.white08,
    thickness: 1,
    space: 0,
  );

  // ══════════════════════════════════════════════════════════
  // SCROLLBAR
  // ══════════════════════════════════════════════════════════

  static final ScrollbarThemeData _scrollbarTheme = ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.white15),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    radius: const Radius.circular(2),
    thickness: WidgetStateProperty.all(3.0),
    minThumbLength: 48,
    interactive: true,
  );
}