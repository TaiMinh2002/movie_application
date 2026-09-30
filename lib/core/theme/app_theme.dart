import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// App-specific colors not covered by [ColorScheme]. Read via `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.textMuted, required this.card});

  final Color textMuted;
  final Color card;

  static const light = AppColors(
    textMuted: Color(0xFF475569),
    card: Color(0xFFF1F5F9),
  );

  static const dark = AppColors(
    textMuted: Color(0xFF94A3B8),
    card: Color(0xFF1E293B),
  );

  @override
  AppColors copyWith({Color? textMuted, Color? card}) => AppColors(
    textMuted: textMuted ?? this.textMuted,
    card: card ?? this.card,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      card: Color.lerp(card, other.card, t)!,
    );
  }
}

abstract final class AppTheme {
  static const _fontFamily = 'BeVietnamPro';
  static const _seed = Color(0xFFE11D48);

  static final light = _build(
    ColorScheme.fromSeed(seedColor: _seed).copyWith(
      primary: _seed,
      onPrimary: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF8FAFC),
      onSurface: const Color(0xFF0F172A),
      surfaceContainer: const Color(0xFFFFFFFF),
      outline: const Color(0xFFE2E8F0),
      error: const Color(0xFFB91C1C),
      onError: const Color(0xFFFFFFFF),
    ),
    AppColors.light,
  );

  static final dark = _build(
    ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFFB7185),
      onPrimary: const Color(0xFF1A0509),
      surface: const Color(0xFF0B1120),
      onSurface: const Color(0xFFF1F5F9),
      surfaceContainer: const Color(0xFF1E293B),
      outline: const Color(0xFF334155),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF1A0509),
    ),
    AppColors.dark,
  );

  /// Shimmer from `card` to `outline`.
  static final skeleton = SkeletonizerConfigData(
    effectResolver: (brightness) {
      final isLight = brightness == Brightness.light;
      return ShimmerEffect(
        baseColor: (isLight ? AppColors.light : AppColors.dark).card,
        highlightColor: (isLight ? light : dark).colorScheme.outline,
        duration: const Duration(milliseconds: 1600),
      );
    },
  );

  static TextStyle _style(double size, double line, FontWeight weight) =>
      TextStyle(
        // Set here, not only on ThemeData: component themes (buttons) use
        // these styles directly and would fall back to the platform font.
        fontFamily: _fontFamily,
        fontSize: size,
        height: line / size,
        fontWeight: weight,
      );

  static final _textTheme = TextTheme(
    headlineMedium: _style(28, 36, FontWeight.w600),
    titleLarge: _style(22, 28, FontWeight.w600),
    titleMedium: _style(16, 24, FontWeight.w600),
    bodyLarge: _style(16, 24, FontWeight.w400),
    bodyMedium: _style(14, 20, FontWeight.w400),
    labelLarge: _style(14, 20, FontWeight.w600),
    labelMedium: _style(12, 16, FontWeight.w500),
  );

  static ThemeData _build(ColorScheme scheme, AppColors colors) {
    const buttonShape = StadiumBorder();
    const buttonSize = Size(64, 48);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: _fontFamily,
      textTheme: _textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme.titleLarge!.copyWith(
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: _textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: _textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        hintStyle: TextStyle(color: colors.textMuted),
        prefixIconColor: colors.textMuted,
        suffixIconColor: colors.textMuted,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
    );
  }
}
