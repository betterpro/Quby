import 'package:flutter/material.dart';

/// Quby brand color tokens — aligned with the Brand Book.
class QubyColors {
  // Light theme — ink + paper neutrals
  static const bgLight = Color(0xFFF1F3EF); // paper
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF4F6F2);
  static const surface3Light = Color(0xFFE9ECE6);
  static const textLight = Color(0xFF0E1726); // ink
  static const textDimLight = Color(0xFF5C6672); // slate
  static const textFaintLight = Color(0xFF9AA4AF); // mist
  static const lineLight = Color(0x140E1726);
  static const lineStrongLight = Color(0x240E1726);

  // Dark theme — ink surfaces
  static const bgDark = Color(0xFF0A0F1A); // ink-bg
  static const surfaceDark = Color(0xFF121A28); // ink-surface
  static const surface2Dark = Color(0xFF1A2333); // ink-surface-2
  static const surface3Dark = Color(0xFF243049);
  static const textDark = Color(0xFFEAF0F6); // ink-text
  static const textDimDark = Color(0xFF93A1B3); // ink-dim
  static const textFaintDark = Color(0xFF5E6E82);
  static const lineDark = Color(0x17FFFFFF);
  static const lineStrongDark = Color(0x29FFFFFF);

  // Quby Green — primary
  static const accentGreenLight = Color(0xFF00B488); // green
  static const accentGreen600 = Color(0xFF00997A); // green-600
  static const accentGreenInkLight = Color(0xFF067A5C); // green-ink
  static const accentGreenSoftLight = Color(0x2100B488);
  static const accentGreenOnLight = Color(0xFF04261C); // on-green

  static const accentGreenDark = Color(0xFF00D193); // green-bright
  static const accentGreenInkDark = Color(0xFF3FE6B4);
  static const accentGreenSoftDark = Color(0x2900D193);
  static const accentGreenOnDark = Color(0xFF04231A);

  // Mark face colors
  static const markFaceLight = Color(0xFFEAF0F6); // dark-background mark sides

  // Supporting
  static const honey = Color(0xFFE2911F);
  static const honeySoft = Color(0x24E2911F);
  static const honeyDark = Color(0xFFFFB638);
  static const honeyDarkSoft = Color(0x2BFFB638);

  static const danger = Color(0xFFE5484D);
  static const dangerDark = Color(0xFFFF6166);

  // Extended accents
  static const violet = Color(0xFF6C4DE0);
  static const blue = Color(0xFF2E6BF0);
  static const coral = Color(0xFFF2624E);

  // Avatar palette
  static const List<Color> avatarPalette = [
    Color(0xFF6C4DE0),
    Color(0xFFE2911F),
    Color(0xFF00997A),
    Color(0xFF8A6BFF),
    Color(0xFFF2624E),
    Color(0xFF00B488),
    Color(0xFF2E6BF0),
    Color(0xFF5B8DFF),
  ];
}
