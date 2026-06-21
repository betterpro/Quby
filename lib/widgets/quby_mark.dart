import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

enum QubyMarkVariant {
  /// Green top + ink sides — for light/paper backgrounds.
  light,

  /// Bright green top + green depth sides — for dark/ink backgrounds.
  dark,
}

class QubyMark extends StatelessWidget {
  final double size;
  final QubyMarkVariant variant;

  const QubyMark({
    super.key,
    this.size = 32,
    this.variant = QubyMarkVariant.light,
  });

  String _hex(Color c) {
    final r = c.red.toRadixString(16).padLeft(2, '0');
    final g = c.green.toRadixString(16).padLeft(2, '0');
    final b = c.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = variant == QubyMarkVariant.dark;

    final top   = isDark ? QubyColors.accentGreenDark       : QubyColors.accentGreenLight;
    final left  = isDark ? QubyColors.markFaceLeft           : QubyColors.markFaceLeftLight;
    final right = isDark ? QubyColors.markFaceRight          : QubyColors.markFaceRightLight;

    final svg =
        '''<svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <polygon points="27.4,9.4 16,15.6 16,28.8 27.4,22.6" fill="${_hex(right)}"/>
  <polygon points="4.6,9.4 16,15.6 16,28.8 4.6,22.6" fill="${_hex(left)}"/>
  <polygon points="16,3.2 27.4,9.4 16,15.6 4.6,9.4" fill="${_hex(top)}"/>
  <polygon points="16,3.2 27.4,9.4 24.2,7.7 16,5.2 7.8,7.7 4.6,9.4" fill="white" opacity="0.09"/>
</svg>''';

    return SvgPicture.string(svg, width: size, height: size);
  }
}
