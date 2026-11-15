import 'package:flutter/material.dart';

/// Cores usadas para temperaturas, fora do esquema padrão do Material.
@immutable
class CoresTemperatura extends ThemeExtension<CoresTemperatura> {
  const CoresTemperatura({required this.maxima, required this.minima});

  final Color maxima;
  final Color minima;

  static CoresTemperatura de(BuildContext context) =>
      Theme.of(context).extension<CoresTemperatura>()!;

  @override
  CoresTemperatura copyWith({Color? maxima, Color? minima}) =>
      CoresTemperatura(maxima: maxima ?? this.maxima, minima: minima ?? this.minima);

  @override
  CoresTemperatura lerp(CoresTemperatura? other, double t) {
    if (other == null) return this;
    return CoresTemperatura(
      maxima: Color.lerp(maxima, other.maxima, t)!,
      minima: Color.lerp(minima, other.minima, t)!,
    );
  }
}

ThemeData criarTema(Brightness brilho) {
  final escuro = brilho == Brightness.dark;
  final esquema = ColorScheme(
    brightness: brilho,
    primary: escuro ? const Color(0xFF7DB3F5) : const Color(0xFF1C5DB0),
    onPrimary: escuro ? const Color(0xFF0B1A2E) : Colors.white,
    secondary: escuro ? const Color(0xFF9AA4B1) : const Color(0xFF4A5462),
    onSecondary: escuro ? const Color(0xFF111418) : Colors.white,
    tertiary: escuro ? const Color(0xFFF2B263) : const Color(0xFF9A5B00),
    onTertiary: escuro ? const Color(0xFF2A1700) : Colors.white,
    error: escuro ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    onError: escuro ? const Color(0xFF370B07) : Colors.white,
    surface: escuro ? const Color(0xFF111316) : const Color(0xFFF7F7F5),
    onSurface: escuro ? const Color(0xFFE6E8EB) : const Color(0xFF15181C),
    onSurfaceVariant: escuro ? const Color(0xFF9AA2AD) : const Color(0xFF5C6470),
    surfaceContainerLowest: escuro ? const Color(0xFF0C0D10) : Colors.white,
    surfaceContainerLow: escuro ? const Color(0xFF181A1E) : Colors.white,
    surfaceContainer: escuro ? const Color(0xFF1D2025) : const Color(0xFFEFF0EE),
    surfaceContainerHigh: escuro ? const Color(0xFF23262C) : const Color(0xFFE8E9E6),
    outline: escuro ? const Color(0xFF3A3F47) : const Color(0xFFC9CDD2),
    outlineVariant: escuro ? const Color(0xFF262A30) : const Color(0xFFE2E4E1),
  );

  final base = ThemeData(colorScheme: esquema);
  final textos = base.textTheme;
  const cantos = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)));

  return base.copyWith(
    scaffoldBackgroundColor: esquema.surface,
    extensions: [
      CoresTemperatura(
        maxima: escuro ? const Color(0xFFFF9466) : const Color(0xFFC2410C),
        minima: escuro ? const Color(0xFF6CB4F7) : const Color(0xFF1D6FC2),
      ),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: esquema.surface,
      foregroundColor: esquema.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      shape: Border(bottom: BorderSide(color: esquema.outlineVariant)),
    ),
    dividerTheme: DividerThemeData(color: esquema.outlineVariant, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: esquema.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: esquema.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: esquema.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: esquema.primary, width: 1.5),
      ),
    ),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(cantos)),
    ),
    outlinedButtonTheme: const OutlinedButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(cantos)),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(cantos)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: cantos),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: esquema.primary,
      linearTrackColor: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 20)),
  );
}
