import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: QubyColors.bgLight,
      colorScheme: ColorScheme.light(
        primary: QubyColors.accentGreenLight,
        onPrimary: Colors.white,
        secondary: QubyColors.accentGreenLight,
        onSecondary: Colors.white,
        surface: QubyColors.surfaceLight,
        onSurface: QubyColors.textLight,
        error: QubyColors.danger,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: QubyColors.textLight,
        displayColor: QubyColors.textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: QubyColors.bgLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: QubyColors.textLight,
        ),
        iconTheme: const IconThemeData(color: QubyColors.textLight),
      ),
      dividerColor: QubyColors.lineLight,
      dividerTheme: const DividerThemeData(
        color: QubyColors.lineLight,
        thickness: 1,
        space: 0,
      ),
      cardTheme: CardTheme(
        color: QubyColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: QubyColors.lineLight),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: QubyColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QubyColors.surface2Light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: QubyColors.textFaintLight,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: QubyColors.surface2Light,
        selectedColor: QubyColors.accentGreenSoftLight,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
        side: const BorderSide(color: QubyColors.lineLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: QubyColors.bgDark,
      colorScheme: ColorScheme.dark(
        primary: QubyColors.accentGreenDark,
        onPrimary: QubyColors.accentGreenOnDark,
        secondary: QubyColors.accentGreenDark,
        onSecondary: QubyColors.accentGreenOnDark,
        surface: QubyColors.surfaceDark,
        onSurface: QubyColors.textDark,
        error: QubyColors.dangerDark,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: QubyColors.textDark,
        displayColor: QubyColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: QubyColors.bgDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: QubyColors.textDark,
        ),
        iconTheme: const IconThemeData(color: QubyColors.textDark),
      ),
      dividerColor: QubyColors.lineDark,
      dividerTheme: const DividerThemeData(
        color: QubyColors.lineDark,
        thickness: 1,
        space: 0,
      ),
      cardTheme: CardTheme(
        color: QubyColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: QubyColors.lineDark),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: QubyColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QubyColors.surface2Dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: QubyColors.textFaintDark,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: QubyColors.surface2Dark,
        selectedColor: QubyColors.accentGreenSoftDark,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: QubyColors.textDark,
        ),
        side: const BorderSide(color: QubyColors.lineDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
