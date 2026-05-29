import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 应用主题配置
/// 提供浅色和深色两套主题，采用圆角卡片风格和简约设计
class AppTheme {
  AppTheme._();

  // ==================== 通用配置 ====================

  /// 默认圆角半径
  static const double borderRadius = 16.0;

  /// 小圆角半径
  static const double smallBorderRadius = 8.0;

  /// 大圆角半径
  static const double largeBorderRadius = 24.0;

  /// 卡片内边距
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  /// 页面水平内边距
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0);

  /// 组件间距
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;

  // ==================== 浅色主题 ====================

  /// 浅色主题
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.learning,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDBEAFE),
      onSecondaryContainer: const Color(0xFF1E40AF),
      tertiary: AppColors.gaming,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.divider,
      outlineVariant: const Color(0xFFF1F5F9),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dividerTheme: _buildDividerTheme(),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(colorScheme),
      textTheme: _buildTextTheme(),
    );
  }

  // ==================== 深色主题 ====================

  /// 深色主题
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.darkBackground,
      primaryContainer: const Color(0xFF166534),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: const Color(0xFF60A5FA),
      onSecondary: AppColors.darkBackground,
      secondaryContainer: const Color(0xFF1E3A5F),
      onSecondaryContainer: const Color(0xFFBFDBFE),
      tertiary: const Color(0xFFA78BFA),
      onTertiary: AppColors.darkBackground,
      error: const Color(0xFFF87171),
      onError: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkDivider,
      outlineVariant: const Color(0xFF334155),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: _buildDarkAppBarTheme(colorScheme),
      cardTheme: _buildDarkCardTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dividerTheme: _buildDarkDividerTheme(),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(colorScheme),
      textTheme: _buildDarkTextTheme(),
    );
  }

  // ==================== 主题组件配置 ====================

  /// 浅色 AppBar 主题
  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }

  /// 深色 AppBar 主题
  static AppBarTheme _buildDarkAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }

  /// 浅色卡片主题
  static CardTheme _buildCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  /// 深色卡片主题
  static CardTheme _buildDarkCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  /// ElevatedButton 主题
  static ElevatedButtonThemeData _buildElevatedButtonTheme(
      ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// TextButton 主题
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// OutlinedButton 主题
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
      ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// InputDecoration 主题
  static InputDecorationTheme _buildInputDecorationTheme(
      ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1,
        ),
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        fontSize: 14,
      ),
    );
  }

  /// FloatingActionButton 主题
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme(
      ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(largeBorderRadius),
      ),
      iconSize: 28,
    );
  }

  /// BottomNavigationBar 主题
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
      ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Chip 主题
  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: colorScheme.onPrimaryContainer,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  /// 浅色分割线主题
  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    );
  }

  /// 深色分割线主题
  static DividerThemeData _buildDarkDividerTheme() {
    return const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    );
  }

  /// SnackBar 主题
  static SnackBarThemeData _buildSnackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.onSurface,
      contentTextStyle: TextStyle(
        color: colorScheme.surface,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
      ),
    );
  }

  /// ProgressIndicator 主题
  static ProgressIndicatorThemeData _buildProgressIndicatorTheme(
      ColorScheme colorScheme) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      circularTrackColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
    );
  }

  /// 浅色文字主题
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // 大标题 - 用于页面主标题
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      // 中标题 - 用于区域标题
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      // 小标题 - 用于卡片标题
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      // 标题
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      // 正文
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      // 标签
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        height: 1.4,
      ),
    );
  }

  /// 深色文字主题
  static TextTheme _buildDarkTextTheme() {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.darkTextPrimary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        height: 1.4,
      ),
    );
  }
}
